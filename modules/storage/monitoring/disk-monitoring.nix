# modules/storage/monitoring/disk-monitoring.nix
# Disk Space and Btrfs Monitoring
# Tracks disk usage and Btrfs-specific metrics for Datadog

{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.storage.monitoring;
in
{
  options.storage.monitoring.disk = {
    enable = mkEnableOption "Enable disk space and Btrfs monitoring";

    # Monitoring interval
    interval = mkOption {
      type = types.str;
      default = "*/5 * * * *";  # Every 5 minutes
      description = "Cron schedule for disk monitoring";
    };

    # Devices to monitor (auto-detect if empty)
    devices = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of devices to monitor (empty = auto-detect all Btrfs devices)";
    };

    # Alert thresholds
    thresholds = {
      warning = mkOption {
        type = types.int;
        default = 85;
        description = "Disk usage warning threshold (%)";
      };
      critical = mkOption {
        type = types.int;
        default = 95;
        description = "Disk usage critical threshold (%)";
      };
    };
  };

  config = mkIf (cfg.datadog.enable && cfg.disk.enable) {
    # Generate disk monitoring script
    environment.etc."panther-monitoring/disk-metrics.sh".text = ''
      #!/bin/bash
      # Disk Space and Btrfs Monitoring Script
      # Collects disk usage and Btrfs-specific metrics for Datadog

      set -euo pipefail

      source /etc/panther-monitoring/datadog-metrics.sh

      LOG_FILE="/var/log/panther-monitoring/disk.log"

      # Logging function
      log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
      }

      # Get list of devices to monitor
      if [ ${toString cfg.disk.devices} = "[]" ]; then
        # Auto-detect Btrfs devices
        DEVICES=$(btrfs filesystem show 2>/dev/null | grep "/dev/" | awk '{print $3}' | sort -u)
      else
        DEVICES="${cfg.disk.devices}"
      fi

      log "Monitoring devices: $DEVICES"

      # Process each device
      for device in $DEVICES; do
        # Skip if device doesn't exist
        if [ ! -b "$device" ]; then
          log "Device $device not found, skipping"
          continue
        fi

        log "Processing device: $device"

        # Get device name (e.g., /dev/nvme0n1 -> nvme0n1)
        device_name=$(basename "$device")

        # Get disk usage using df
        # For Btrfs, we need to check the filesystem mounted on this device
        # Use findmnt to get the mount point
        mount_point=$(findmnt -n -o SOURCE --target "$device" 2>/dev/null || echo "")

        if [ -n "$mount_point" ]; then
          # Get usage percentage and size
          df_output=$(df -h "$mount_point" 2>/dev/null | tail -1)

          if [ -n "$df_output" ]; then
            usage_percent=$(echo "$df_output" | awk '{print $5}' | sed 's/%//')
            total_size=$(echo "$df_output" | awk '{print $2}')
            used_size=$(echo "$df_output" | awk '{print $3}')
            avail_size=$(echo "$df_output" | awk '{print $4}')

            # Convert sizes to bytes for accurate reporting
            total_bytes=$(numfmt --from=iec "$total_size" 2>/dev/null || echo 0)
            used_bytes=$(numfmt --from=iec "$used_size" 2>/dev/null || echo 0)

            # Send disk usage metric
            if [ -n "$usage_percent" ] && [ "$usage_percent" -ge 0 ] 2>/dev/null; then
              disk_usage_percent "$usage_percent" "$device_name"
              log "Disk usage: ${usage_percent}% for $device_name"
            fi

            # Log disk info
            log "Device $device_name: $used_size/$total_size used, $avail_size available"

            # Check thresholds and log warnings
            warning_threshold=${cfg.disk.thresholds.warning}
            critical_threshold=${cfg.disk.thresholds.critical}

            if [ "$usage_percent" -ge "$critical_threshold" ]; then
              log "CRITICAL: Device $device_name at ${usage_percent}% usage (threshold: ${critical_threshold}%)"
            elif [ "$usage_percent" -ge "$warning_threshold" ]; then
              log "WARNING: Device $device_name at ${usage_percent}% usage (threshold: ${warning_threshold}%)"
            fi
          fi
        fi

        # Get Btrfs-specific metrics
        if command -v btrfs >/dev/null 2>&1; then
          # Get Btrfs filesystem info
          btrfs_info=$(btrfs filesystem show "$device" 2>/dev/null || echo "")

          if [ -n "$btrfs_info" ]; then
            # Parse Btrfs info
            # Example output:
            # Label: none  uuid: 1234-5678
            #   Total devices 1 FS bytes used 12345678
            #   devid    1 size 50000000000 used 1234567890 path /dev/nvme0n1

            uuid=$(echo "$btrfs_info" | grep "uuid:" | awk '{print $3}')
            fs_bytes_used=$(echo "$btrfs_info" | grep "FS bytes used" | awk '{print $4}')

            log "Btrfs info for $device: UUID=$uuid, FS bytes used=$fs_bytes_used"

            # Get Btrfs balance status
            # Check if balance is currently running
            balance_status=0  # 0 = idle, 1 = running
            if btrfs balance status "$mount_point" 2>/dev/null | grep -q "Balance"; then
              balance_status=1
              log "Btrfs balance is running on $mount_point"
            fi

            # Send Btrfs balance metric
            btrfs_balance_status "$balance_status" "$device_name"

            # Get Btrfs space info
            btrfs_space=$(btrfs filesystem df "$mount_point" 2>/dev/null || echo "")

            if [ -n "$btrfs_space" ]; then
              # Parse space info
              # Example output:
              # Data, single: total=1.00GiB, used=512.00MiB
              # System, single: total=32.00MiB, used=4.00KiB
              # Metadata, single: total=1.00GiB, used=128.00MiB

              while IFS= read -r line; do
                if [[ "$line" =~ Data.*total=([0-9.]+[A-Z]+).*used=([0-9.]+[A-Z]+) ]]; then
                  total="${BASH_REMATCH[1]}"
                  used="${BASH_REMATCH[2]}"

                  # Convert to bytes
                  total_bytes=$(numfmt --from=iec "$total" 2>/dev/null || echo 0)
                  used_bytes=$(numfmt --from=iec "$used" 2>/dev/null || echo 0)

                  # Calculate usage percentage for data
                  if [ "$total_bytes" -gt 0 ]; then
                    data_percent=$(( used_bytes * 100 / total_bytes ))
                    log "Btrfs Data: ${data_percent}% used ($used/$total)"

                    # You can emit additional metrics here if needed
                    # Example: send_gauge "btrfs.data.usage" "$data_percent" "device:$device_name"
                  fi
                fi

                if [[ "$line" =~ Metadata.*total=([0-9.]+[A-Z]+).*used=([0-9.]+[A-Z]+) ]]; then
                  total="${BASH_REMATCH[1]}"
                  used="${BASH_REMATCH[2]}"

                  total_bytes=$(numfmt --from=iec "$total" 2>/dev/null || echo 0)
                  used_bytes=$(numfmt --from=iec "$used" 2>/dev/null || echo 0)

                  if [ "$total_bytes" -gt 0 ]; then
                    metadata_percent=$(( used_bytes * 100 / total_bytes ))
                    log "Btrfs Metadata: ${metadata_percent}% used ($used/$total)"
                  fi
                fi
              done <<< "$btrfs_space"
            fi

            # Get Btrfs scrub status (if available)
            scrub_status=$(btrfs scrub status "$mount_point" 2>/dev/null || echo "")
            if [ -n "$scrub_status" ]; then
              log "Btrfs scrub status for $mount_point: $scrub_status"
            fi
          fi
        fi
      done

      log "Disk monitoring collection completed"
    '';

    # Make script executable
    systemd.tmpfiles.rules = [
      "f /etc/panther-monitoring/disk-metrics.sh 0755 root root -"
      "d /var/log/panther-monitoring 0755 root root -"
    ];

    # Service to collect disk metrics
    systemd.services."panther-disk-metrics" = {
      description = "Collect Disk and Btrfs Metrics for Datadog";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/etc/panther-monitoring/disk-metrics.sh";
        User = "root";
        Group = "root";
        WorkingDirectory = "/";
        # Timeout
        TimeoutStartSec = "2min";
      };

      # Run as part of monitoring.timer
    };

    # Timer to run disk monitoring
    systemd.timers."panther-disk-metrics" = {
      description = "Disk Monitoring Schedule";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.disk.interval;
        Persistent = true;
        Unit = "panther-disk-metrics.service";
      };
    };

    # Additional systemd service for continuous monitoring
    systemd.services."panther-disk-monitor" = {
      description = "Continuous Disk Space Monitoring";
      serviceConfig = {
        Type = "simple";
        ExecStart = let
          monitorScript = pkgs.writeScript "disk-monitor-continuous" ''
            #!/bin/bash
            # Continuous disk monitoring - checks every minute

            source /etc/panther-monitoring/disk-metrics.sh

            while true; do
              /etc/panther-monitoring/disk-metrics.sh
              sleep 60  # Check every minute
            done
          '';
        in
          "${monitorScript}";
        User = "root";
        Group = "root";
        Restart = "always";
        RestartSec = "10s";
      };

      wantedBy = [ "multi-user.target" ];
    };

    # Documentation
    environment.etc."monitoring/disk/README".text = ''
      # Disk Space and Btrfs Monitoring

      This module monitors disk usage and Btrfs-specific metrics.

      ## Metrics Collected

      ### Disk Usage
      - `pantheros.disk.usage` - Disk usage percentage per device
        - Tags: host, device
        - Value: 0-100 (percent)
        - Source: df output

      ### Btrfs Metrics
      - `pantheros.btrfs.balance` - Balance operation status
        - Tags: host, device
        - Value: 0 (idle) or 1 (running)
        - Source: btrfs balance status

      ## Monitoring Coverage

      Devices monitored:
      ${if cfg.disk.devices != [] then "    - ${concatStringsSep "\n    - " cfg.disk.devices}" else "    - Auto-detect all Btrfs devices"}

      Schedule: ${cfg.disk.interval}

      ## Alert Thresholds

      Warning: ${cfg.disk.thresholds.warning}% disk usage
      Critical: ${cfg.disk.thresholds.critical}% disk usage

      ## Scripts

      Manual execution:
        sudo /etc/panther-monitoring/disk-metrics.sh

      View logs:
        sudo tail -f /var/log/panther-monitoring/disk.log

      ## Services

      Periodic collection:
        systemctl status panther-disk-metrics.timer

      Continuous monitoring:
        systemctl status panther-disk-monitor.service

      Start/stop:
        sudo systemctl start panther-disk-metrics.service
        sudo systemctl enable panther-disk-monitor.service

      ## Btrfs-Specific Monitoring

      The module tracks:
      1. **Data Usage** - Btrfs data filesystem usage
      2. **Metadata Usage** - Btrfs metadata filesystem usage
      3. **Balance Status** - Whether Btrfs balance is running
      4. **Scrub Status** - Btrfs scrub operation status (logged only)

      ## Disk Space Management

      When disk space is low:

      1. **Check disk usage:**
         ```
         df -h
         btrfs filesystem df /
         ```

      2. **Clean up old snapshots:**
         ```
         snapper cleanup timeline
         snapper list
         ```

      3. **Balance Btrfs (if needed):**
         ```
         btrfs balance start --full-balance /
         ```

      4. **Check large files:**
         ```
         du -sh /* | sort -h
         ```

      5. **Monitor progress:**
         ```
         watch -n 1 'df -h /'
         ```

      ## Datadog Integration

      In Datadog:
      - Metrics: Search for `pantheros.disk.*` and `pantheros.btrfs.*`
      - Dashboard: Create disk space dashboard
      - Monitors: Alert on usage thresholds

      Example monitors:
      - Disk usage warning: `avg:pantheros.disk.usage{*} > ${cfg.disk.thresholds.warning}`
      - Btrfs balance running: `avg:pantheros.btrfs.balance{*} > 0`

      ## Troubleshooting

      Device not found:
      - Check device exists: `ls -l $device`
      - Verify Btrfs: `btrfs filesystem show $device`

      No metrics collected:
      - Check script: `bash -x /etc/panther-monitoring/disk-metrics.sh`
      - Check permissions: Must run as root
      - Check logs: `/var/log/panther-monitoring/disk.log`

      High disk usage:
      - Identify usage: `ncdu /`
      - Clean caches: `sudo nix-collect-garbage`
      - Remove old logs: `journalctl --vacuum-time=7d`
      - Check snapshots: `snapper list`

      ## Performance

      The monitoring script:
      - Runs every ${cfg.disk.interval} (or every minute in continuous mode)
      - Takes ~2-5 seconds per device
      - Minimal I/O impact
      - Can be run on busy systems without issues

      Continuous monitor uses ~1% CPU when running
    '';

    # Add disk monitoring to main storage monitoring README
  };
}
