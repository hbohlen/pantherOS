# B2 Cost Monitoring Module
# Tracks and monitors Backblaze B2 storage costs to stay within budget
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.storage.backup;
  # Generate cost monitoring script
  costMonitorScript = pkgs.writeScript "panther-backup-cost-monitor" ''
    #!/bin/bash
    # PantherOS B2 Cost Monitoring
    # Calculates current B2 storage usage and estimates costs

    set -euo pipefail

    LOG_FILE="/var/log/panther-backup/cost-monitor.log"
    REPORT_FILE="/var/log/panther-backup/cost-report.log"

    # Logging function
    log() {
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
    }

    # Calculate bucket size and cost
    calculate_bucket_cost() {
      local bucket_name="$1"
      local date="$2"

      log "Calculating cost for bucket: $bucket_name"

      # Get all files in bucket
      local total_bytes=$(b2 ls -r "$bucket_name" 2>/dev/null | awk '{sum += $1} END {print sum}' || echo "0")

      if [ "$total_bytes" = "0" ]; then
        log "  Bucket empty or inaccessible"
        echo "$date,0,0,0,0" >> "$REPORT_FILE"
        return 0
      fi

      local size_gb=$(( total_bytes / 1024 / 1024 / 1024 ))
      local size_tb=$(( size_gb / 1024 ))

      # B2 pricing: $0.005/GB/month (Standard)
      local cost_cents=$(( size_gb * 5 ))
      local cost_dollars=$(( cost_cents / 100 ))
      local cost_cents_remainder=$(( cost_cents % 100 ))

      # B2 transfer pricing: $0.01/GB (first 10GB free per day)
      # Note: We don't track transfer costs here, only storage

      log "  Storage: ${total_bytes} bytes (${size_gb}GB / ${size_tb}TB)"
      log "  Estimated cost: $${cost_dollars}.${cost_cents_remainder#0}/month"

      # Append to CSV report
      echo "$date,$total_bytes,$size_gb,$cost_cents,$cost_dollars.${cost_cents_remainder#0}" >> "$REPORT_FILE"

      # Return cost in cents for threshold checking
      echo "$cost_cents"
    }

    # Check cost thresholds
    check_thresholds() {
      local cost_cents="$1"
      local size_gb="$2"

      log "Checking cost thresholds..."

      if [ "$cost_cents" -ge "${cfg.bucket.lifecycle.costCritical}" ]; then
        log "*** COST CRITICAL: $${cost_cents / 100}.${cost_cents % 100#0}/month ***"
        log "  Exceeds critical threshold: $${cfg.bucket.lifecycle.costCritical / 100}.00/month"
        log "  Immediate action required:"
        log "  - Review retention policies"
        log "  - Consider archival of old backups"
        log "  - Clean up unnecessary backups"
        return 2
      elif [ "$cost_cents" -ge "${cfg.bucket.lifecycle.costWarning}" ]; then
        log "!!! COST WARNING: $${cost_cents / 100}.${cost_cents % 100#0}/month !!!"
        log "  Exceeds warning threshold: $${cfg.bucket.lifecycle.costWarning / 100}.00/month"
        log "  Recommended actions:"
        log "  - Review backup retention settings"
        log "  - Check for unexpected large backups"
        log "  - Consider archiving old backups"
        return 1
      else
        log "✓ Cost within budget: $${cost_cents / 100}.${cost_cents % 100#0}/month"
        return 0
      fi
    }

    # Generate monthly summary
    generate_summary() {
      log "Generating monthly cost summary..."

      local current_month=$(date +%Y-%m)
      local report_month="$1"

      if [ -f "$REPORT_FILE" ]; then
        local monthly_data=$(grep "^$report_month" "$REPORT_FILE" || echo "")

        if [ -n "$monthly_data" ]; then
          log "Monthly summary for $report_month:"
          echo "$monthly_data" | while IFS=',' read -r date bytes size_gb cost_cents cost_str; do
            log "  $date: ${size_gb}GB, est. $${cost_str}/month"
          done

          # Calculate average
          local total_gb=0
          local count=0
          while IFS=',' read -r date bytes size_gb cost_cents cost_str; do
            total_gb=$(( total_gb + size_gb ))
            count=$(( count + 1 ))
          done <<< "$monthly_data"

          if [ "$count" -gt 0 ]; then
            local avg_gb=$(( total_gb / count ))
            log "  Average storage: ${avg_gb}GB"
          fi
        else
          log "No data for $report_month"
        fi
      fi
    }

    # Main execution
    log "=== B2 Cost Monitoring Started ==="

    local date=$(date +%Y-%m-%d)
    local bucket="${cfg.b2.bucket}"

    # Verify B2 access
    if ! b2 whoami >/dev/null 2>&1; then
      log "ERROR: B2 credentials not available or invalid"
      exit 1
    fi

    log "B2 account: $(b2 get-account-info | grep accountId | awk '{print $2}')"
    log "Bucket: $bucket"

    # Calculate cost
    local cost_cents=$(calculate_bucket_cost "$bucket" "$date")
    local size_gb=$(( cost_cents / 5 ))

    # Check thresholds
    local threshold_result=0
    check_thresholds "$cost_cents" "$size_gb" || threshold_result=$?

    # Generate summary for current month
    generate_summary "${date%-*}"

    # Calculate projections
    log ""
    log "Cost projections (based on current rate):"

    # Simple projection: current cost * 12
    local annual_cost_cents=$(( cost_cents * 12 ))
    local annual_cost_dollars=$(( annual_cost_cents / 100 ))
    local annual_cents_remainder=$(( annual_cost_cents % 100 ))

    log "  Annual (projected): $${annual_cost_dollars}.${annual_cents_remainder#0}"

    # If we have historical data, try to project better
    if [ -f "$REPORT_FILE" ] && [ -s "$REPORT_FILE" ]; then
      local last_week=$(date -d "7 days ago" +%Y-%m-%d)
      local week_data=$(grep "^$last_week" "$REPORT_FILE" | tail -1 || echo "")

      if [ -n "$week_data" ]; then
        local prev_size_gb=$(echo "$week_data" | cut -d',' -f3)
        local growth_gb=$(( size_gb - prev_size_gb ))
        if [ "$growth_gb" -gt 0 ]; then
          log "  Weekly growth: +${growth_gb}GB"
          local monthly_projection=$(( size_gb + (growth_gb * 4) ))
          log "  1-month projection: ${monthly_projection}GB ($$(( monthly_projection * 5 / 100 )).$(( (monthly_projection * 5) % 100 ))/month)"
        fi
      fi
    fi

    log ""
    log "=== B2 Cost Monitoring Completed ==="

    # Return appropriate exit code
    if [ "$threshold_result" -eq 2 ]; then
      exit 2  # Critical
    elif [ "$threshold_result" -eq 1 ]; then
      exit 1  # Warning
    else
      exit 0  # OK
    fi
  '';
in
{
  options.storage.backup.costMonitoring = {
    enable = mkEnableOption "Enable B2 cost monitoring";

    # Thresholds (in cents)
    warningThreshold = mkOption {
      type = types.int;
      default = 800; # $8.00
      description = "Cost warning threshold in cents (80% of $10 budget)";
    };

    criticalThreshold = mkOption {
      type = types.int;
      default = 1000; # $10.00
      description = "Cost critical threshold in cents (100% of $10 budget)";
    };

    # Monitoring frequency
    frequency = mkOption {
      type = types.enum [ "daily" "weekly" "monthly" ];
      default = "weekly";
      description = "How often to run cost monitoring";
    };

    # Historical tracking
    historyDays = mkOption {
      type = types.int;
      default = 90;
      description = "Number of days of cost history to maintain";
    };

    # B2 pricing (updates should be reflected here)
    pricing = {
      storagePerGB = mkOption {
        type = types.str;
        default = "0.005";
        description = "B2 storage pricing per GB per month (USD)";
      };
    };
  };

  config = mkIf cfg.costMonitoring.enable {
    # Install required packages
    environment.systemPackages = with pkgs; [
      bc
      jq
    ];

    # Cost monitoring service
    systemd.services.panther-backup-cost-monitor = {
      description = "PantherOS B2 Cost Monitoring Service";
      documentation = [
        "https://www.backblaze.com/b2/docs/object-storage"
      ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${costMonitorScript}";
        User = "root";
        Group = "root";
        WorkingDirectory = "/";
        # Timeout
        TimeoutStartSec = "10m";
      };

      # Run after backup and validation
      after = [ "panther-backup.service" ]
        ++ optionals cfg.b2.opnix.enable [ "onepassword-secrets.service" ];

      # Require OpNix secrets
      requires = optionals cfg.b2.opnix.enable [ "onepassword-secrets.service" ];

      # Environment
      environment = {
        PATH = "${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.gawk}/bin:${pkgs.bc}/bin";
        B2_ACCOUNT_ID = cfg.b2.accountId;
        B2_BUCKET = cfg.b2.bucket;
      };
    };

    # Cost monitoring timer
    systemd.timers.panther-backup-cost-monitor-timer = {
      description = "PantherOS B2 Cost Monitoring Schedule";
      documentation = [ "man:systemd.timer(5)" ];

      timerConfig = {
        OnCalendar = lib.mkIf (cfg.costMonitoring.frequency == "daily") "daily";
        OnCalendar = lib.mkIf (cfg.costMonitoring.frequency == "weekly") "weekly";
        OnCalendar = lib.mkIf (cfg.costMonitoring.frequency == "monthly") "monthly";
        Persistent = true;
        Unit = "panther-backup-cost-monitor.service";
      };

      wantedBy = [ "timers.target" ];
      partOf = [ "panther-backup-cost-monitor.service" ];
    };

    # Cron job for monthly cost report (additional to timer)
    # This ensures we get a report at the beginning of each month
    systemd.timers.panther-backup-monthly-report = {
      description = "Monthly B2 Cost Report";
      documentation = [ "man:systemd.timer(5)" ];

      timerConfig = {
        OnCalendar = "mon 1..7 03:00:00";  # First week of month at 3 AM
        RandomizedDelaySec = "1h";
        Persistent = true;
        Unit = "panther-backup-cost-monitor.service";
      };

      wantedBy = [ "timers.target" ];
    };

    # Clean up old cost reports
    systemd.services.panther-backup-clean-cost-history = {
      description = "Clean old B2 cost history";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeScript "clean-cost-history" ''
          #!/bin/bash
          set -euo pipefail

          # Keep only the last N days of cost reports
          find /var/log/panther-backup/ -name "cost-report.log*" -mtime +${cfg.costMonitoring.historyDays} -delete || true

          # Compress old reports
          find /var/log/panther-backup/ -name "cost-report.log" -mtime +7 -exec gzip {} \; 2>/dev/null || true
        '';
        }";
        User = "root";
        # Run monthly
      };
    };

    systemd.timers.panther-backup-clean-cost-history-timer = {
      description = "Clean B2 Cost History Monthly";
      timerConfig = {
        OnCalendar = "monthly";
        Persistent = true;
        Unit = "panther-backup-clean-cost-history.service";
      };
      wantedBy = [ "timers.target" ];
    };

    # Cost tracking configuration
    environment.etc."backups/cost-monitoring/config.json".text = ''
      {
        "service": "panther-backup-cost-monitor",
        "pricing": {
          "storage_per_gb_usd": "${cfg.costMonitoring.pricing.storagePerGB}",
          "currency": "USD"
        },
        "thresholds": {
          "warning_cents": ${toString cfg.costMonitoring.warningThreshold},
          "critical_cents": ${toString cfg.costMonitoring.criticalThreshold},
          "warning_usd": ${toString cfg.costMonitoring.warningThreshold},
          "critical_usd": ${toString cfg.costMonitoring.criticalThreshold}
        },
        "frequency": "${cfg.costMonitoring.frequency}",
        "history_days": ${toString cfg.costMonitoring.historyDays}
      }
    '';

    # Documentation
    environment.etc."backups/cost-monitoring/README".text = ''
      # B2 Cost Monitoring

      This service monitors Backblaze B2 storage costs to stay within the $5-10/month budget.

      ## Budget

      Target budget: $5-10/month
      Warning threshold: $${cfg.costMonitoring.warningThreshold / 100}/month
      Critical threshold: $${cfg.costMonitoring.criticalThreshold / 100}/month

      ## Pricing

      B2 Standard storage: $${cfg.costMonitoring.pricing.storagePerGB}/GB/month

      For current pricing, see: https://www.backblaze.com/b2/docs/object-storage

      ## Monitoring Schedule

      - Frequency: ${cfg.costMonitoring.frequency}
      - Service: panther-backup-cost-monitor.service
      - Timer: panther-backup-cost-monitor-timer.timer
      - Additional monthly report: panther-backup-monthly-report.timer

      ## Service Management

      Run cost monitoring manually:
        sudo systemctl start panther-backup-cost-monitor.service

      Check status:
        sudo systemctl status panther-backup-cost-monitor.service

      View logs:
        sudo journalctl -u panther-backup-cost-monitor.service -f
        sudo tail -f /var/log/panther-backup/cost-monitor.log

      View cost report:
        sudo tail -f /var/log/panther-backup/cost-report.log
        zcat /var/log/panther-backup/cost-report.log.gz | tail -30

      ## Cost Report Format

      CSV format: date,bytes,gb,cost_cents,dollars

      Example:
        2024-12-04,1073741824,1,5,0.05
        2024-12-11,2147483648,2,10,0.10

      ## Exit Codes

      - 0: Cost within budget
      - 1: Cost exceeds warning threshold
      - 2: Cost exceeds critical threshold

      ## Cost Optimization

      If costs exceed thresholds:

      1. **Review retention settings**
         - Reduce number of retained backups
         - Archive old backups to deeper storage tiers

      2. **Clean up unnecessary data**
         - Delete old test backups
         - Remove duplicated backups
         - Compress older archives

      3. **Monitor growth trends**
         - Weekly cost reports show growth patterns
         - Identify unexpected large backups
         - Plan capacity accordingly

      4. **Adjust backup scope**
         - Exclude less critical data
         - Use separate buckets for different purposes
         - Consider lifecycle policies

      ## Integration with Alerts

      Configure monitoring to alert on cost threshold breaches:

      ### With Prometheus/AlertManager:
        - alert: B2CostWarning
          expr: b2_monthly_cost_usd > 8
          for: 0m
          labels:
            severity: warning
          annotations:
            summary: "B2 storage cost approaching budget"

        - alert: B2CostCritical
          expr: b2_monthly_cost_usd > 10
          for: 0m
          labels:
            severity: critical
          annotations:
            summary: "B2 storage cost exceeds budget"

      ### With Nagios/Icinga:
        - Monitor exit code of cost-monitor.service
        - Alert on non-zero exit codes

      ## Historical Data

      - Cost reports maintained for ${cfg.costMonitoring.historyDays} days
      - Old reports automatically compressed
      - Monthly summary generated automatically

      ## Data Sources

      - B2 API for bucket listing
      - B2 pricing: $${cfg.costMonitoring.pricing.storagePerGB}/GB/month
      - Storage calculations based on actual bucket usage

      ## Cost Breakdown

      Typical monthly costs for PantherOS:
      - Server with databases: $2-5/month
      - Laptop with minimal data: $0.50-2/month
      - Development workstation: $1-3/month

      Note: Actual costs depend on:
      - Amount of data stored
      - Retention period
      - Backup frequency
      - Compression efficiency

      For more information:
      - B2 pricing: https://www.backblaze.com/b2/docs/object-storage
      - B2 lifecycle rules: https://www.backblaze.com/b2/docs/lifecycle-rules
    '';
  };
}
