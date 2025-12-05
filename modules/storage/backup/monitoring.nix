# modules/storage/backup/monitoring.nix
# Backup Monitoring and Metrics Collection
# Integrates with Datadog to emit metrics for backup operations

{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.storage.backup;
  monCfg = config.storage.monitoring;
in
{
  options.storage.backup.monitoring = {
    enable = mkEnableOption "Enable backup monitoring metrics";
  };

  config = mkIf (cfg.enable && cfg.monitoring.enable && monCfg.datadog.enable) {
    # Generate backup metrics collection script
    environment.etc."panther-monitoring/backup-metrics.sh".text = ''
      #!/bin/bash
      # Backup Metrics Collection Script
      # Tracks backup status and emits Datadog metrics

      set -euo pipefail

      source /etc/panther-monitoring/datadog-metrics.sh

      LOG_FILE="/var/log/panther-backup/metrics.log"

      # Logging function
      log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
      }

      # Get backup duration from last run
      if [ -f "/var/log/panther-backup/backup.log" ]; then
        # Extract duration from logs (look for "Backup completed successfully")
        last_success=$(grep "Backup completed successfully" /var/log/panther-backup/backup.log | tail -1)

        if [ -n "$last_success" ]; then
          # Calculate duration from log timestamps
          start_time=$(echo "$last_success" | awk '{print $1 " " $2}' | sed 's/\[//;s/\]//')
          start_epoch=$(date -d "$start_time" +%s 2>/dev/null || echo 0)

          if [ "$start_epoch" -gt 0 ]; then
            end_epoch=$(date +%s)
            duration=$((end_epoch - start_epoch))

            # Send duration metric (use first subvolume as example)
            subvol="${cfg.subvolumes.paths.0 or "/"}"
            backup_duration_seconds "$duration" "$subvol"
            log "Duration metric sent: ${duration}s for $subvol"
          fi
        fi
      fi

      # Get backup size from B2
      if command -v b2 >/dev/null 2>&1; then
        subvols=(${cfg.subvolumes.paths})

        for subvol in "$${subvols[@]}"; do
          # Get size of most recent backup for this subvolume
          backup_info=$(b2 ls -r ${cfg.b2.bucket}/${config.networking.hostName}/$subvol 2>/dev/null | head -5 || echo "")

          if [ -n "$backup_info" ]; then
            # Get the most recent backup size
            recent_backup=$(echo "$backup_info" | grep "_snapshots\.tar\.zst" | head -1)
            if [ -n "$recent_backup" ]; then
              size_bytes=$(echo "$recent_backup" | awk '{print $1}')
              if [ -n "$size_bytes" ] && [ "$size_bytes" -gt 0 ]; then
                backup_size_bytes "$size_bytes" "$subvol"
                log "Size metric sent: ${size_bytes} bytes for $subvol"
              fi
            fi
          fi
        done

        # Calculate and send B2 cost
        if command -v bc >/dev/null 2>&1; then
          bucket_info=$(b2 ls -r ${cfg.b2.bucket}/ 2>/dev/null | awk '{sum += $1} END {print sum}' || echo "0")

          if [ "$bucket_info" != "0" ]; then
            size_gb=$(echo "scale=2; $bucket_info / 1024 / 1024 / 1024" | bc)
            cost_cents=$(echo "scale=0; $size_gb * 0.5" | bc)  # $0.005/GB = 0.5 cents/GB

            backup_b2_cost "$cost_cents"
            log "Cost metric sent: ${cost_cents} cents ($${size_gb}GB)"
          fi
        fi
      fi
    '';

    # Make script executable
    systemd.tmpfiles.rules = [
      "f /etc/panther-monitoring/backup-metrics.sh 0755 root root -"
    ];

    # Service to collect backup metrics
    systemd.services."panther-backup-metrics" = {
      description = "Collect Backup Metrics for Datadog";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/etc/panther-monitoring/backup-metrics.sh";
        User = "root";
        Group = "root";
        WorkingDirectory = "/";
        # Timeout
        TimeoutStartSec = "5min";
      };

      # Run after backup service
      after = [ "panther-backup.service" ];
      requires = [ "panther-backup.service" ];
    };

    # Timer to run metrics collection hourly (if backup fails to trigger)
    systemd.timers."panther-backup-metrics" = {
      description = "Backup Metrics Collection Schedule";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* *:15:00";
        Persistent = true;
        Unit = "panther-backup-metrics.service";
      };
    };

    # Modify backup service to emit metrics on success/failure
    systemd.services.panther-backup.serviceConfig = let
      backupScript = pkgs.writeScript "panther-backup-with-metrics" ''
        #!/bin/sh
        # PantherOS Backup Service with Metrics
        # Executes btrbk backup with retry logic, logging, and metrics

        set -euo pipefail

        source /etc/panther-monitoring/datadog-metrics.sh

        LOG_FILE="/var/log/panther-backup/backup.log"
        BACKUP_LOCK="/var/run/panther-backup.lock"
        START_TIME=$(date +%s)

        # Logging function
        log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
        }

        # Error handler
        error_exit() {
          log "ERROR: $1"
          exit 1
        }

        # Main backup function with retry logic
        run_backup() {
          local attempt=1
          local max_attempts=3
          local backoff=10

          while [ $attempt -le $max_attempts ]; do
            log "Starting backup (attempt $attempt of $max_attempts)..."

            # Execute btrbk backup
            if btrbk run --config /etc/panther-backup/btrbk.conf 2>&1 | tee -a "$LOG_FILE"; then
              log "Backup completed successfully on attempt $attempt"

              # Emit success metrics for each subvolume
              subvols=(${cfg.subvolumes.paths})
              for subvol in "$${subvols[@]}"; do
                backup_completed "$subvol"
              done

              return 0
            else
              log "Backup failed on attempt $attempt"

              # Emit failure metrics on last attempt
              if [ $attempt -eq $max_attempts ]; then
                subvols=(${cfg.subvolumes.paths})
                for subvol in "$${subvols[@]}"; do
                  backup_failed "$subvol"
                done
              fi

              if [ $attempt -lt $max_attempts ]; then
                local wait_time=$((backoff * attempt))
                log "Retrying in $wait_time seconds..."
                sleep $wait_time
                attempt=$((attempt + 1))
              else
                error_exit "Backup failed after $max_attempts attempts"
              fi
            fi
          done
        }

        # Check for existing backup process
        if [ -f "$BACKUP_LOCK" ]; then
          PID=$(cat "$BACKUP_LOCK" 2>/dev/null || echo "")
          if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
            log "WARNING: Backup already running (PID: $PID), skipping this execution"
            exit 0
          fi
        fi

        # Create lock file
        echo $$ > "$BACKUP_LOCK"
        trap 'rm -f "$BACKUP_LOCK"' EXIT

        # Ensure log directory exists
        mkdir -p "$(dirname "$LOG_FILE")"

        log "=== Backup Service Started ==="
        log "Hostname: $(hostname)"
        log "User: $(whoami)"

        # Check for required configuration
        if [ ! -f /etc/panther-backup/btrbk.conf ]; then
          error_exit "Configuration file /etc/panther-backup/btrbk.conf not found"
        fi

        # Execute backup with error handling
        if run_backup; then
          log "=== Backup Service Completed Successfully ==="
          exit 0
        else
          log "=== Backup Service Failed ==="
          exit 1
        fi
      '';
    in
     ExecStart = "${backupScript}";

    # Documentation
    environment.etc."backups/monitoring/README".text = ''
      # Backup Monitoring and Metrics

      This module integrates backup operations with Datadog metrics collection.

      ## Metrics Emitted

      ### Backup Completion
      - `pantheros.backup.completed` - Counter incremented on successful backup
        - Emitted per subvolume
        - Tags: host, subvolume

      ### Backup Failures
      - `pantheros.backup.failed` - Counter incremented on backup failure
        - Emitted per subvolume (on final failure)
        - Tags: host, subvolume

      ### Backup Duration
      - `pantheros.backup.duration` - Gauge of backup duration in seconds
        - Emitted on successful backup completion
        - Tags: host, subvolume

      ### Backup Size
      - `pantheros.backup.size` - Gauge of backup size in bytes
        - Emitted from B2 storage listing
        - Tags: host, subvolume

      ### B2 Cost
      - `pantheros.backup.b2.cost` - Gauge of estimated B2 storage cost
        - Emitted monthly and on schedule
        - Tags: host
        - Value: Cost in cents

      ## Integration

      Metrics are automatically emitted during backup operations:
      - On backup success: completion + duration + size metrics
      - On backup failure: failure counter
      - On schedule: B2 cost calculation

      Metrics collection script: /etc/panther-monitoring/backup-metrics.sh

      Service: panther-backup-metrics.service
      Timer: panther-backup-metrics.timer

      ## Viewing Metrics

      In Datadog:
      - Metrics: Search for `pantheros.backup.*`
      - Dashboard: Create custom dashboard with backup metrics
      - Monitors: Alert on failures or long durations

      Example monitors:
      - Backup failure: Alert if `sum:pantheros.backup.failed{*}` > 0
      - Long backup: Alert if `avg:pantheros.backup.duration{*}` > 3600 (1 hour)
      - High cost: Alert if `avg:pantheros.backup.b2.cost{*}` > 1000 (>$10)
    '';
  };
}
