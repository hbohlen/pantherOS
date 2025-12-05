# Backup Service Module
# Creates systemd service for executing backups with btrbk
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.storage.backup;
  # Helper function to generate backup script
  backupScript = pkgs.writeScript "panther-backup-run" ''
    #!/bin/sh
    # PantherOS Backup Service
    # Executes btrbk backup with retry logic and logging

    set -euo pipefail

    LOG_FILE="/var/log/panther-backup/backup.log"
    BACKUP_LOCK="/var/run/panther-backup.lock"

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
          return 0
        else
          log "Backup failed on attempt $attempt"
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
    log "Working directory: $(pwd)"

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
{
  options.storage.backup.service = {
    enable = mkEnableOption "Enable backup service";

    retryAttempts = mkOption {
      type = types.int;
      default = 3;
      description = "Number of retry attempts on failure";
    };

    retryBackoff = mkOption {
      type = types.int;
      default = 10;
      description = "Initial backoff delay in seconds (doubles each attempt)";
    };

    # Resource limits for backup process
    resourceLimits = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable resource limits for backup process";
      };

      ioWeight = mkOption {
        type = types.int;
        default = 100;
        description = "IO weight for backup process (100 = normal, lower = more lenient)";
      };

      cpuQuota = mkOption {
        type = types.str;
        default = "50%";
        description = "CPU quota for backup process";
      };
    };
  };

  config = mkIf cfg.service.enable {
    # Install required packages
    environment.systemPackages = with pkgs; [
      btrbk
      bc # For calculations if needed
    ];

    # Create backup configuration directory
    systemd.tmpfiles.rules = [
      "d /etc/panther-backup 0750 root root -"
      "d /var/log/panther-backup 0750 root root -"
      "d /var/lib/panther-backups 0750 root root -"
    ];

    # Create btrbk configuration file
    environment.etc."panther-backup/btrbk.conf".text = ''
      # PantherOS Btrbk Backup Configuration
      # Generated from NixOS configuration

      # Global settings
      snapshot_create  on
      snapshot_preserve  7d  4w  12m
      target_preserve  30d  12w  12m
      target_sync     B2_backup

      # Logging
      loglevel  info
      logfile  /var/log/panther-backup/btrbk.log

      # Backup source and target
      ${concatStringsSep "\n" (map (subvol: ''
      snapshot_dir  ${subvol}/.snapshots
      subvolume     ${subvol}
      target        b2:${cfg.b2.bucket}/${config.networking.hostName}/${subvol}

      '') cfg.subvolumes.paths)}

      # B2 credentials file (managed by OpNix or manual)
      ${if cfg.b2.opnix.enable then ''
      b2_credentials_file  /var/lib/panther-backups/b2-credentials.env
      '' else ''
      # Manual credentials required - set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
      ''}
    '';

    # Backup service unit
    systemd.services.panther-backup = {
      description = "PantherOS Backup Service";
      documentation = [
        "man:btrbk(1)"
        "https://github.com/digint/btrbk"
      ];

      # Service configuration
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${backupScript}";
        # Resource limits
        ${if cfg.service.resourceLimits.enable then ''
        IOWeight = "${toString cfg.service.resourceLimits.ioWeight}";
        CPUQuota = "${cfg.service.resourceLimits.cpuQuota}";
        '' else ''}
        # Security settings
        User = "root";
        Group = "root";
        # Restart policy
        Restart = "on-failure";
        RestartSec = "30s";
        # Timeout
        TimeoutStartSec = "2h";
        # Working directory
        WorkingDirectory = "/";
      };

      # Dependencies
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ]
        ++ optionals cfg.b2.opnix.enable [ "onepassword-secrets.service" ];

      # Environment
      environment = {
        PATH = "${pkgs.btrbk}/bin:${pkgs.coreutils}/bin:${pkgs.gawk}/bin";
      };

      # Ensure OpNix secrets are available before running

}

    # Documentation
    environment.etc."backups/service/README".text = ''
      # Backup Service

      The PantherOS backup service uses btrbk to create and synchronize Btrfs snapshots.

      ## Service Management

      Check status:
        sudo systemctl status panther-backup.service

      View logs:
        sudo journalctl -u panther-backup.service -f
        sudo tail -f /var/log/panther-backup/backup.log

      Run backup manually:
        sudo systemctl start panther-backup.service

      ## Configuration

      Backup configuration: /etc/panther-backup/btrbk.conf
      Backup log: /var/log/panther-backup/backup.log
      Btrbk log: /var/log/panther-backup/btrbk.log

      ## Retry Logic

      The service includes retry logic:
      - Retries up to 3 times on failure
      - Exponential backoff starting at <value>s, doubling each attempt
      - Logs all attempts to /var/log/panther-backup/backup.log

      ## Resource Limits

      - IOWeight: 100 (lower = less I/O priority)
      - CPUQuota: 50%

      For more information: https://github.com/digint/btrbk
    '';
  };
}
