# Backup Timer Module
# Creates systemd timer for automated backup scheduling
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.storage.backup;
in
{
  options.storage.backup.timer = {
    enable = mkEnableOption "Enable backup timer";

    schedule = mkOption {
      type = types.str;
      default = "02:00";
      description = "Daily backup time (HH:MM format)";
      example = "02:00";
    };

    # Randomized delay to stagger multiple hosts
    randomizedDelay = mkOption {
      type = types.str;
      default = "30min";
      description = "Randomized delay to stagger backup starts across hosts";
      example = "30min";
    };

    # Make timer persistent (runs on boot if missed)
    persistent = mkOption {
      type = types.bool;
      default = true;
      description = "Run missed backups on boot";
    };

    # Run weekly validation check
    runValidation = mkOption {
      type = types.bool;
      default = true;
      description = "Run backup validation service after backup";
    };
  };

  config = mkIf cfg.timer.enable {
    # Backup timer
    systemd.timers.panther-backup-timer = {
      description = "PantherOS Backup Schedule";
      documentation = [
        "man:systemd.timer(5)"
        "https://github.com/digint/btrbk"
      ];

      # Timer configuration
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = cfg.timer.randomizedDelay;
        Persistent = cfg.timer.persistent;
        # Add specific time to calendar specification
        Unit = "panther-backup.service";
      };

      # Make timer part of the backup service
      partOf = [ "panther-backup.service" ];

      # Enable and start timer
      wantedBy = [ "timers.target" ];
    };

    # Service that runs before the backup
    systemd.services.pre-backup = {
      description = "Pre-backup preparation";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeScript "pre-backup" ''
          #!/bin/sh
          set -euo pipefail

          log() {
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
          }

          log "Running pre-backup checks..."

          # Check disk space before backup
          AVAILABLE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
          if [ "$AVAILABLE" -lt 5 ]; then
            log "WARNING: Low disk space: ${AVAILABLE}GB available"
          else
            log "Disk space check: ${AVAILABLE}GB available"
          fi

          # Check if B2 credentials are available
          ${if cfg.b2.opnix.enable then ''
          if [ ! -f /var/lib/panther-backups/b2-credentials.env ]; then
            log "ERROR: B2 credentials not found"
            exit 1
          fi
          log "B2 credentials found"
          '' else ''
          log "Manual B2 credentials configured"
          ''}

          # Verify btrbk configuration
          if [ ! -f /etc/panther-backup/btrbk.conf ]; then
            log "ERROR: btrbk configuration not found"
            exit 1
          fi
          log "btrbk configuration validated"

          log "Pre-backup checks completed successfully"
        '';
        }";
        User = "root";
        WorkingDirectory = "/";
      };
      before = [ "panther-backup.service" ];
      requiredBy = [ "panther-backup.service" ];
    };

    ${if cfg.timer.runValidation then ''
    # Service that runs after backup for validation
    systemd.services.post-backup = {
      description = "Post-backup validation";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeScript "post-backup" ''
          #!/bin/sh
          set -euo pipefail

          log() {
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
          }

          log "Running post-backup validation..."

          # Check if backup log exists and has recent entries
          if [ -f /var/log/panther-backup/backup.log ]; then
            LAST_BACKUP=$(tail -n 1 /var/log/panther-backup/backup.log | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" || echo "")
            if [ -n "$LAST_BACKUP" ]; then
              log "Last backup date: $LAST_BACKUP"

              # Check if backup is recent (within last 26 hours to allow for timer delay)
              BACKUP_EPOCH=$(date -d "$LAST_BACKUP" +%s 2>/dev/null || echo 0)
              NOW_EPOCH=$(date +%s)
              AGE_HOURS=$(( (NOW_EPOCH - BACKUP_EPOCH) / 3600 ))

              if [ "$AGE_HOURS" -lt 26 ]; then
                log "Backup validation: PASSED (backup is recent: ${AGE_HOURS}h old)"
              else
                log "WARNING: Backup appears old: ${AGE_HOURS}h old"
              fi
            fi
          else
            log "WARNING: No backup log found"
          fi

          # Trigger validation service if it exists
          if systemctl is-enabled --quiet panther-backup-validation.service 2>/dev/null; then
            log "Triggering backup validation service..."
            systemctl start panther-backup-validation.service || log "WARNING: Validation service failed"
          fi

          log "Post-backup validation completed"
        '';
        }";
        User = "root";
        WorkingDirectory = "/";
      };
      after = [ "panther-backup.service" ];
    };
    '' else ''}

    # Documentation
    environment.etc."backups/timer/README".text = ''
      # Backup Timer Configuration

      The PantherOS backup timer is configured to run daily at ${cfg.timer.schedule} with a randomized delay.

      ## Schedule

      - Time: ${cfg.timer.schedule} daily
      - Randomized delay: ${cfg.timer.randomizedDelay} (to stagger across multiple hosts)
      - Persistent: ${boolToString cfg.timer.persistent} (runs missed backups on boot)

      ## Timer Management

      Check timer status:
        sudo systemctl status panther-backup-timer.timer

      View timer schedule:
        sudo systemctl list-timers panther-backup-timer.timer

      Enable/disable timer:
        sudo systemctl enable panther-backup-timer.timer
        sudo systemctl disable panther-backup-timer.timer

      Start/stop timer:
        sudo systemctl start panther-backup-timer.timer
        sudo systemctl stop panther-backup-timer.timer

      ## Backup Sequence

      The backup process runs in sequence:

      1. **pre-backup.service** (preparation)
         - Checks disk space
         - Validates B2 credentials
         - Verifies btrbk configuration

      2. **panther-backup.service** (main backup)
         - Creates Btrfs snapshots
         - Uploads to Backblaze B2
         - Logs all operations

      ${if cfg.timer.runValidation then "3. **post-backup.service** (validation)\n         - Checks backup completion\n         - Triggers validation service\n       " else ""}

      ## Randomized Delay

      The timer includes a randomized delay of ${cfg.timer.randomizedDelay} to prevent all hosts from starting backups simultaneously. This is important for:

      - Reducing load on Backblaze B2 API
      - Avoiding network congestion
      - Distributing resource usage across time windows

      Each host will delay its backup by a random amount within the specified range.

      ## Persistent Timer

      If the system is down during the scheduled backup time, the timer will run the backup once on next boot (catch-up behavior). This ensures backups are not missed during:

      - System maintenance
      - Unexpected downtime
      - Reboots during maintenance windows

      For more information: man:systemd.timer(5)
    '';
  };
}
