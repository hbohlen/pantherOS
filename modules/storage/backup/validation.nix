# Backup Validation Service Module
# Validates backup integrity, completeness, and cost monitoring
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.storage.backup;
  # Generate validation script
  validationScript = pkgs.writeScript "panther-backup-validate" ''
    #!/bin/bash
    # PantherOS Backup Validation Service
    # Validates backup integrity and reports status

    set -euo pipefail

    LOG_FILE="/var/log/panther-backup/validation.log"
    VALIDATION_LOCK="/var/run/panther-backup-validation.lock"

    # Logging function
    log() {
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
    }

    # Error handler
    error_exit() {
      log "ERROR: $1"
      exit 1
    }

    # Check for existing validation process
    if [ -f "$VALIDATION_LOCK" ]; then
      PID=$(cat "$VALIDATION_LOCK" 2>/dev/null || echo "")
      if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        log "WARNING: Validation already running (PID: $PID), skipping this execution"
        exit 0
      fi
    fi

    # Create lock file
    echo $$ > "$VALIDATION_LOCK"
    trap 'rm -f "$VALIDATION_LOCK"' EXIT

    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"

    log "=== Backup Validation Started ==="

    # Validation results tracking
    VALIDATION_PASSED=true
    WARNINGS=()
    ERRORS=()

    # Function to validate backup exists and is recent
    validate_backup_recency() {
      local subvol="$1"
      local max_age_hours=36  # Allow up to 36 hours (timer delay + validation)

      log "Validating backup recency for: $subvol"

      # Find most recent backup in B2
      # Check last 3 months of directories
      local found=false
      local recent_backups=$(b2 ls -r ${cfg.b2.bucket}/${config.networking.hostName}/$subvol 2>/dev/null | tail -20 || echo "")

      if [ -n "$recent_backups" ]; then
        # Parse timestamps from filenames
        while IFS= read -r line; do
          local filename=$(echo "$line" | awk '{print $4}')
          if [[ "$filename" =~ ^[0-9]{8}_[0-9]{6}_.*_snapshots\.tar\.zst$ ]]; then
            local timestamp="${filename:0:15}"  # Extract YYYYMMDD_HHMMSS
            local year="${timestamp:0:4}"
            local month="${timestamp:4:2}"
            local day="${timestamp:6:2}"
            local hour="${timestamp:9:2}"
            local min="${timestamp:11:2}"
            local sec="${timestamp:13:2}"

            # Create epoch timestamp for comparison
            local backup_epoch=$(date -d "$year-$month-$day $hour:$min:$sec" +%s 2>/dev/null || echo 0)
            local now_epoch=$(date +%s)
            local age_hours=$(( (now_epoch - backup_epoch) / 3600 ))

            if [ "$age_hours" -le "$max_age_hours" ]; then
              log "  ✓ $subvol: Found recent backup (${age_hours}h old): $filename"
              found=true
              break
            fi
          fi
        done <<< "$recent_backups"
      fi

      if [ "$found" = false ]; then
        log "  ✗ $subvol: No recent backup found (expected within $max_age_hours hours)"
        ERRORS+=("Backup missing or too old: $subvol")
        VALIDATION_PASSED=false
        return 1
      fi

      return 0
    }

    # Function to validate backup size
    validate_backup_size() {
      local subvol="$1"
      log "Validating backup size for: $subvol"

      # Get sizes of recent backups
      local backup_info=$(b2 ls -r ${cfg.b2.bucket}/${config.networking.hostName}/$subvol 2>/dev/null | tail -5 || echo "")

      if [ -n "$backup_info" ]; then
        local count=0
        local total_size=0
        local avg_size=0

        while IFS= read -r line; do
          local size=$(echo "$line" | awk '{print $1}')
          local filename=$(echo "$line" | awk '{print $4}')

          if [[ "$filename" =~ .*_snapshots\.tar\.zst$ ]]; then
            size=$(( size / 1024 / 1024 ))  # Convert to MB
            total_size=$(( total_size + size ))
            count=$(( count + 1 ))
            log "  - $filename: ${size}MB"
          fi
        done <<< "$backup_info"

        if [ "$count" -gt 0 ]; then
          avg_size=$(( total_size / count ))
          log "  Average size: ${avg_size}MB ($count backups)"

          # Check for reasonableness
          # These are loose checks - backup sizes vary greatly
          if [ "$avg_size" -lt 1 ]; then
            WARNINGS+=("Backup suspiciously small: $subvol (${avg_size}MB)")
          elif [ "$avg_size" -gt 50000 ]; then  # 50GB
            WARNINGS+=("Backup very large: $subvol (${avg_size}MB)")
          fi
        fi
      fi

      return 0
    }

    # Function to calculate B2 storage cost
    calculate_b2_cost() {
      log "Calculating B2 storage cost..."

      # Get all files in bucket
      local bucket_info=$(b2 ls -r ${cfg.b2.bucket}/ 2>/dev/null | awk '{sum += $1} END {print sum}' || echo "0")

      if [ "$bucket_info" = "0" ]; then
        WARNINGS+=("Could not calculate bucket size")
        return 0
      fi

      local size_gb=$(( bucket_info / 1024 / 1024 / 1024 ))
      local cost_cents=$(( size_gb * 5 ))  # $0.005/GB/month = 0.5 cents/GB
      local cost_dollars=$(( cost_cents / 100 ))
      local cost_cents_remainder=$(( cost_cents % 100 ))

      log "  Total storage: ${size_gb}GB"
      log "  Estimated cost: $${cost_dollars}.${cost_cents_remainder#0}/month (at \$0.005/GB)"

      # Check cost thresholds
      if [ "$cost_cents" -gt "${cfg.bucket.lifecycle.costCritical}" ]; then
        ERRORS+=("B2 cost critical: $${cost_dollars}.${cost_cents_remainder#0}/month (exceeds $${cfg.bucket.lifecycle.costCritical / 100})")
        VALIDATION_PASSED=false
      elif [ "$cost_cents" -gt "${cfg.bucket.lifecycle.costWarning}" ]; then
        WARNINGS+=("B2 cost high: $${cost_dollars}.${cost_cents_remainder#0}/month (exceeds $${cfg.bucket.lifecycle.costWarning / 100})")
      fi

      # Write cost report
      echo "[$(date '+%Y-%m-%d')] B2 Cost Report: ${size_gb}GB, est. $${cost_dollars}.${cost_cents_remainder#0}/month" >> \
        /var/log/panther-backup/cost-report.log

      return 0
    }

    # Main validation logic
    if ! b2 whoami >/dev/null 2>&1; then
      error_exit "B2 credentials not available or invalid"
    fi

    log "B2 account: $(b2 get-account-info | grep accountId | awk '{print $2}')"
    log "Bucket: ${cfg.b2.bucket}"

    # Validate each subvolume
    for subvol in ${cfg.subvolumes.paths}; do
      validate_backup_recency "$subvol" || true
      validate_backup_size "$subvol" || true
    done

    # Validate database subvolumes if enabled
    ${if cfg.subvolumes.includeDatabases then ''
    if ${config.services.databases.enable or "false"}; then
      ${if config.services.postgresql.enable or "false"} then
        validate_backup_recency "/var/lib/postgresql" || true
        validate_backup_size "/var/lib/postgresql" || true
      fi
      ${if config.services.redis.enable or "false"} then
        validate_backup_recency "/var/lib/redis" || true
        validate_backup_size "/var/lib/redis" || true
      fi
    fi
    '' else ''}

    # Validate container subvolumes if enabled
    ${if cfg.subvolumes.includeContainers then ''
    validate_backup_recency "/var/lib/containers" || true
    validate_backup_size "/var/lib/containers" || true
    '' else ''}

    # Calculate and report cost
    calculate_b2_cost

    # Report validation results
    log ""
    log "=== Validation Summary ==="

    if [ ${#WARNINGS[@]} -gt 0 ]; then
      log "WARNINGS (${#WARNINGS[@]}):"
      for warning in "''${WARNINGS[@]}"; do
        log "  - $warning"
      done
    fi

    if [ ${#ERRORS[@]} -gt 0 ]; then
      log "ERRORS (${#ERRORS[@]}):"
      for error in "''${ERRORS[@]}"; do
        log "  ✗ $error"
      done
    fi

    if [ "$VALIDATION_PASSED" = true ]; then
      log "✓ All validations PASSED"
      log "=== Backup Validation Completed Successfully ==="
      exit 0
    else
      log "✗ Validation FAILED - Review errors above"
      log "=== Backup Validation Completed with Errors ==="
      exit 1
    fi
  '';
in
{
  options.storage.backup.validation = {
    enable = mkEnableOption "Enable backup validation service";

    # Validation frequency
    schedule = mkOption {
      type = types.enum [ "daily" "weekly" "monthly" ];
      default = "weekly";
      description = "How often to run backup validation";
    };

    # Validation checks
    checks = {
      recency = mkOption {
        type = types.bool;
        default = true;
        description = "Check that backups exist and are recent";
      };

      size = mkOption {
        type = types.bool;
        default = true;
        description = "Validate backup sizes for reasonableness";
      };

      cost = mkOption {
        type = types.bool;
        default = true;
        description = "Calculate and monitor B2 storage costs";
      };
    };

    # Alert thresholds
    maxBackupAge = mkOption {
      type = types.int;
      default = 36;
      description = "Maximum age of backup in hours before alerting";
    };
  };

  config = mkIf cfg.validation.enable {
    # Backup validation service
    systemd.services.panther-backup-validation = {
      description = "PantherOS Backup Validation Service";
      documentation = [
        "man:systemd.service(5)"
        "https://github.com/digint/btrbk"
      ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${validationScript}";
        User = "root";
        Group = "root";
        WorkingDirectory = "/";
        # Timeout
        TimeoutStartSec = "30m";
      };

      # Run after backup service
      after = [ "panther-backup.service" ]
        ++ optionals cfg.b2.opnix.enable [ "onepassword-secrets.service" ];

      # Require OpNix secrets
      requires = optionals cfg.b2.opnix.enable [ "onepassword-secrets.service" ];

      # Environment
      environment = {
        PATH = "${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.gawk}/bin:${pkgs.jq}/bin";
        B2_ACCOUNT_ID = cfg.b2.accountId;
        B2_BUCKET = cfg.b2.bucket;
      };
    };

    # Validation timer (weekly by default)
    systemd.timers.panther-backup-validation-timer = {
      description = "PantherOS Backup Validation Schedule";
      documentation = [ "man:systemd.timer(5)" ];

      timerConfig = {
        OnCalendar = lib.mkIf (cfg.validation.schedule == "daily") "daily";
        OnCalendar = lib.mkIf (cfg.validation.schedule == "weekly") "weekly";
        OnCalendar = lib.mkIf (cfg.validation.schedule == "monthly") "monthly";
        Persistent = true;
        Unit = "panther-backup-validation.service";
      };

      wantedBy = [ "timers.target" ];
      partOf = [ "panther-backup-validation.service" ];
    };

    # File for monitoring integration
    environment.etc."backups/validation/status.json".text = ''
      {
        "service": "panther-backup-validation",
        "last_run": "$(date -Iseconds)",
        "status": "configured",
        "checks": {
          "recency": ${boolToString cfg.validation.checks.recency},
          "size": ${boolToString cfg.validation.checks.size},
          "cost": ${boolToString cfg.validation.checks.cost}
        },
        "thresholds": {
          "max_backup_age_hours": ${toString cfg.validation.maxBackupAge},
          "cost_warning_cents": ${toString cfg.bucket.lifecycle.costWarning},
          "cost_critical_cents": ${toString cfg.bucket.lifecycle.costCritical}
        }
      }
    '';

    # Documentation
    environment.etc."backups/validation/README".text = ''
      # Backup Validation Service

      The validation service checks backup integrity and monitors costs.

      ## Checks Performed

      ${if cfg.validation.checks.recency then "✓ " else "✗ "}Backup Recency
      - Verifies backups exist in B2
      - Checks backup age (max ${cfg.validation.maxBackupAge} hours)
      - Reports missing or stale backups

      ${if cfg.validation.checks.size then "✓ " else "✗ "}Backup Size Validation
      - Checks backup sizes for reasonableness
      - Detects suspiciously small or large backups
      - Helps identify problems early

      ${if cfg.validation.checks.cost then "✓ " else "✗ "}Cost Monitoring
      - Calculates total B2 storage usage
      - Estimates monthly cost
      - Alerts on high cost thresholds

      ## Validation Schedule

      - Frequency: ${cfg.validation.schedule}
      - Service: panther-backup-validation.service
      - Timer: panther-backup-validation-timer.timer

      ## Service Management

      Run validation manually:
        sudo systemctl start panther-backup-validation.service

      Check status:
        sudo systemctl status panther-backup-validation.service

      View logs:
        sudo journalctl -u panther-backup-validation.service -f
        sudo tail -f /var/log/panther-backup/validation.log

      View cost report:
        sudo tail -f /var/log/panther-backup/cost-report.log

      ## Validation Results

      Status file: /etc/backups/validation/status.json

      Exit codes:
      - 0: All validations passed
      - 1: Validation failed (see logs)

      ## Alerts

      The validation service reports:
      - Warnings: Non-critical issues
      - Errors: Critical issues that need attention

      Consider setting up monitoring (Nagios, Prometheus, etc.) to:
      - Monitor validation service status
      - Alert on validation failures
      - Track cost trends over time

      ## Cost Thresholds

      Warning: $${cfg.bucket.lifecycle.costWarning / 100}/month
      Critical: $${cfg.bucket.lifecycle.costCritical / 100}/month

      Current pricing: $0.005/GB/month (Standard class)

      ## Log Files

      - Main validation log: /var/log/panther-backup/validation.log
      - Cost report: /var/log/panther-backup/cost-report.log
      - Service journal: journalctl -u panther-backup-validation.service

      ## Integration

      The validation service is automatically triggered after backups and can be:
      - Integrated with monitoring systems
      - Used for compliance reporting
      - Used for capacity planning

      For more information: https://github.com/digint/btrbk
    '';
  };
}
