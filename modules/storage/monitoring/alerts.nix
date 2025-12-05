# modules/storage/monitoring/alerts.nix
# Storage Monitoring Alert Definitions
# Defines Datadog monitor configurations for storage/snapshot/backup health

{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.storage.monitoring;
in
{
  options.storage.monitoring.alerts = {
    enable = mkEnableOption "Enable storage monitoring alert rules";

    # Alert thresholds
    snapshot = {
      # Critical: snapshot failure - immediate alert
      failureImmediate = mkOption {
        type = types.bool;
        default = true;
        description = "Alert immediately on snapshot failure";
      };

      # Warning: snapshot age > 24h
      ageWarningHours = mkOption {
        type = types.int;
        default = 24;
        description = "Hours after last snapshot to send warning";
      };

      # Critical: snapshot age > 48h
      ageCriticalHours = mkOption {
        type = types.int;
        default = 48;
        description = "Hours after last snapshot to send critical alert";
      };
    };

    backup = {
      # Critical: backup failure - alert within 1 hour
      failureAlertMinutes = mkOption {
        type = types.int;
        default = 60;
        description = "Minutes to wait before alerting on backup failure";
      };

      # Critical: last backup > 36h ago
      lastBackupHours = mkOption {
        type = types.int;
        default = 36;
        description = "Hours since last successful backup (critical)";
      };

      # Warning: backup duration > threshold (in minutes)
      durationWarningMinutes = mkOption {
        type = types.int;
        default = 60;
        description = "Backup duration warning threshold in minutes";
      };

      # Critical: backup duration > threshold (in minutes)
      durationCriticalMinutes = mkOption {
        type = types.int;
        default = 120;
        description = "Backup duration critical threshold in minutes";
      };
    };

    disk = {
      # Warning: disk usage > 85%
      usageWarningPercent = mkOption {
        type = types.int;
        default = 85;
        description = "Disk usage warning threshold (%)";
      };

      # Critical: disk usage > 95%
      usageCriticalPercent = mkOption {
        type = types.int;
        default = 95;
        description = "Disk usage critical threshold (%)";
      };
    };

    b2Cost = {
      # Warning: B2 cost > 90% of budget ($9 if budget is $10)
      warningPercent = mkOption {
        type = types.int;
        default = 90;
        description = "B2 cost warning threshold (% of budget)";
      };

      # Critical: B2 cost > 100% of budget
      criticalPercent = mkOption {
        type = types.int;
        default = 100;
        description = "B2 cost critical threshold (% of budget)";
      };

      # Budget in cents ($10 = 1000 cents)
      budgetCents = mkOption {
        type = types.int;
        default = 1000;
        description = "Monthly B2 budget in cents";
      };
    };
  };

  config = mkIf (cfg.alerts.enable) {
    # Generate alert rules documentation (Datadog monitors configured via UI/API)
    environment.etc."monitoring/alerts/README".text = ''
      # Storage Monitoring Alert Rules

      This module provides documentation for Datadog monitor configurations.
      Datadog monitors are configured via the Datadog UI or API, not via configuration files.

      ## Monitor Configuration Guide

      ### Snapshot Monitors

      #### 1. Snapshot Failure (CRITICAL - Immediate)
      **What it does:** Alerts immediately when snapshot creation fails

      **Monitor Query:**
      ```
      sum(last_10m):sum:pantheros.snapshot.failed{*} by {host,subvolume} > 0
      ```

      **Alert Settings:**
      - Name: `[CRITICAL] Snapshot failed on {{host.name}}:{{subvolume}}`
      - Message: |
          Snapshot creation failed for {{subvolume}} on {{host.name}}.

          **Runbook:** [Snapshot Failure Runbook](https://internal.runbooks/snapshot-failure)

          **Actions:**
          - Check snapper logs: `journalctl -u snapper-timeline.service`
          - Verify disk space: `df -h`
          - Check Btrfs status: `btrfs check /dev/device`
      - Notify: @oncall-infrastructure
      - Schedule: 24/7

      #### 2. Snapshot Age Warning (WARNING)
      **What it does:** Alerts when last snapshot is older than 24h

      **Monitor Query:**
      ```
      avg(last_1h):avg:pantheros.snapshot.age{*} by {host,subvolume} > ${cfg.alerts.snapshot.ageWarningHours}
      ```

      **Alert Settings:**
      - Name: `[WARNING] Snapshot age on {{host.name}}:{{subvolume}}`
      - Message: |
          Last snapshot for {{subvolume}} on {{host.name}} is {{value}}h old.

          **Runbook:** [Snapshot Age Runbook](https://internal.runbooks/snapshot-age)
      - Notify: @team-storage
      - Schedule: Business hours

      #### 3. Snapshot Age Critical (CRITICAL)
      **What it does:** Alerts when last snapshot is older than 48h

      **Monitor Query:**
      ```
      avg(last_1h):avg:pantheros.snapshot.age{*} by {host,subvolume} > ${cfg.alerts.snapshot.ageCriticalHours}
      ```

      **Alert Settings:**
      - Name: `[CRITICAL] Snapshot too old on {{host.name}}:{{subvolume}}`
      - Message: |
          Last snapshot for {{subvolume}} on {{host.name}} is {{value}}h old (critical threshold: ${cfg.alerts.snapshot.ageCriticalHours}h).

          **Immediate action required!**

          **Runbook:** [Snapshot Failure Runbook](https://internal.runbooks/snapshot-failure)
      - Notify: @oncall-infrastructure
      - Schedule: 24/7

      ### Backup Monitors

      #### 4. Backup Failure (CRITICAL - 1 hour)
      **What it does:** Alerts when backup fails for more than 1 hour

      **Monitor Query:**
      ```
      sum(last_60m):sum:pantheros.backup.failed{*} by {host,subvolume} > 0
      ```

      **Alert Settings:**
      - Name: `[CRITICAL] Backup failed on {{host.name}}:{{subvolume}}`
      - Message: |
          Backup failed for {{subvolume}} on {{host.name}}.

          **Runbook:** [Backup Failure Runbook](https://internal.runbooks/backup-failure)

          **Actions:**
          - Check backup logs: `journalctl -u panther-backup.service`
          - Verify B2 credentials: `b2 whoami`
          - Check disk space: `df -h`
          - Check network connectivity
      - Notify: @oncall-infrastructure
      - Schedule: 24/7
      - Evaluation delay: 60m

      #### 5. Last Backup Too Old (CRITICAL)
      **What it does:** Alerts when last successful backup is more than 36h ago

      **Monitor Query:**
      ```
      time_since_agg(last_24h):time_since(last_1d):pantheros.backup.completed{*} by {host,subvolume} > ${cfg.alerts.backup.lastBackupHours}h
      ```

      **Alert Settings:**
      - Name: `[CRITICAL] Last backup too old on {{host.name}}:{{subvolume}}`
      - Message: |
          Last successful backup for {{subvolume}} on {{host.name}} was {{value}}h ago.

          Critical threshold: ${cfg.alerts.backup.lastBackupHours}h

          **Runbook:** [Backup Failure Runbook](https://internal.runbooks/backup-failure)
      - Notify: @oncall-infrastructure
      - Schedule: 24/7

      #### 6. Backup Duration Warning (WARNING)
      **What it does:** Alerts when backup takes longer than expected

      **Monitor Query:**
      ```
      avg(last_1d):avg:pantheros.backup.duration{*} by {host,subvolume} > ${cfg.alerts.backup.durationWarningMinutes}m
      ```

      **Alert Settings:**
      - Name: `[WARNING] Long backup duration on {{host.name}}:{{subvolume}}`
      - Message: |
          Backup for {{subvolume}} on {{host.name}} took {{value}} minutes.

          Warning threshold: ${cfg.alerts.backup.durationWarningMinutes}m

          **Runbook:** [Backup Performance Runbook](https://internal.runbooks/backup-performance)
      - Notify: @team-storage
      - Schedule: Business hours

      #### 7. Backup Duration Critical (CRITICAL)
      **What it does:** Alerts when backup takes much longer than expected

      **Monitor Query:**
      ```
      avg(last_1d):avg:pantheros.backup.duration{*} by {host,subvolume} > ${cfg.alerts.backup.durationCriticalMinutes}m
      ```

      **Alert Settings:**
      - Name: `[CRITICAL] Very long backup on {{host.name}}:{{subvolume}}`
      - Message: |
          Backup for {{subvolume}} on {{host.name}} took {{value}} minutes (critical threshold: ${cfg.alerts.backup.durationCriticalMinutes}m).

          **Runbook:** [Backup Performance Runbook](https://internal.runbooks/backup-performance)
      - Notify: @oncall-infrastructure
      - Schedule: 24/7

      ### Disk Monitors

      #### 8. Disk Usage Warning (WARNING)
      **What it does:** Alerts when disk usage exceeds 85%

      **Monitor Query:**
      ```
      avg(last_5m):avg:pantheros.disk.usage{*} by {host,device} > ${cfg.alerts.disk.usageWarningPercent}
      ```

      **Alert Settings:**
      - Name: `[WARNING] Disk usage on {{host.name}}:{{device}}`
      - Message: |
          Disk {{device}} on {{host.name}} is {{value}}% full.

          **Runbook:** [Disk Space Runbook](https://internal.runbooks/disk-space)

          **Actions:**
          - Clean old snapshots: `snapper cleanup`
          - Remove old backups: Check B2 lifecycle rules
          - Check for large files: `du -sh /*`
      - Notify: @team-storage
      - Schedule: Business hours

      #### 9. Disk Usage Critical (CRITICAL)
      **What it does:** Alerts when disk usage exceeds 95%

      **Monitor Query:**
      ```
      avg(last_5m):avg:pantheros.disk.usage{*} by {host,device} > ${cfg.alerts.disk.usageCriticalPercent}
      ```

      **Alert Settings:**
      - Name: `[CRITICAL] Disk usage critical on {{host.name}}:{{device}}`
      - Message: |
          Disk {{device}} on {{host.name}} is {{value}}% full (CRITICAL).

          Immediate action required!

          **Runbook:** [Disk Space Runbook](https://internal.runbooks/disk-space)
      - Notify: @oncall-infrastructure
      - Schedule: 24/7

      ### B2 Cost Monitors

      #### 10. B2 Cost Warning (WARNING)
      **What it does:** Alerts when B2 cost exceeds 90% of budget

      **Monitor Query:**
      ```
      avg(last_24h):avg:pantheros.backup.b2.cost{*} by {host} > ${cfg.alerts.b2Cost.warningPercent} * ${cfg.alerts.b2Cost.budgetCents} / 100
      ```

      **Alert Settings:**
      - Name: `[WARNING] B2 cost high on {{host.name}}`
      - Message: |
          Estimated B2 cost on {{host.name}} is {{value}} cents ({{value}} dollars).

          Budget threshold: $${cfg.alerts.b2Cost.warningPercent}% of $${cfg.alerts.b2Cost.budgetCents / 100}

          **Runbook:** [B2 Cost Optimization Runbook](https://internal.runbooks/b2-cost)

          **Actions:**
          - Review retention policies
          - Check B2 lifecycle rules
          - Analyze large backups
      - Notify: @team-storage
      - Schedule: Business hours
      - No data timeout: 1d

      #### 11. B2 Cost Critical (CRITICAL)
      **What it does:** Alerts when B2 cost exceeds 100% of budget

      **Monitor Query:**
      ```
      avg(last_24h):avg:pantheros.backup.b2.cost{*} by {host} > ${cfg.alerts.b2Cost.criticalPercent} * ${cfg.alerts.b2Cost.budgetCents} / 100
      ```

      **Alert Settings:**
      - Name: `[CRITICAL] B2 cost over budget on {{host.name}}`
      - Message: |
          Estimated B2 cost on {{host.name}} is {{value}} dollars (CRITICAL).

          Budget exceeded: $${cfg.alerts.b2Cost.criticalPercent}% of $${cfg.alerts.b2Cost.budgetCents / 100}

          **Runbook:** [B2 Cost Optimization Runbook](https://internal.runbooks/b2-cost)

          **Immediate action required!**
      - Notify: @oncall-infrastructure
      - Schedule: 24/7
      - No data timeout: 1d

      ## Monitor Tags

      All monitors should include these tags:
      - `service:storage`
      - `component:snapshots` or `component:backup` or `component:disk`
      - `team:platform`
      - `environment:prod` (or staging/dev)

      ## Runbooks

      Each alert should have an associated runbook with:
      1. Symptoms - What the alert means
      2. Diagnosis - How to investigate
      3. Remediation - How to fix
      4. Prevention - How to avoid in future
      5. Escalation - Who to call if needed

      Example runbook locations:
      - https://internal.runbooks/snapshot-failure
      - https://internal.runbooks/backup-failure
      - https://internal.runbooks/disk-space
      - https://internal.runbooks/b2-cost

      ## Notification Channels

      - **CRITICAL alerts:** PagerDuty (24/7 oncall)
      - **WARNING alerts:** Slack #infrastructure-alerts
      - **EMAIL alerts:** team-storage@company.com (weekly summary)

      ## Monitor Maintenance

      Monthly review:
      - Check for false positives
      - Adjust thresholds based on data
      - Update runbooks with lessons learned
      - Review monitor coverage

      Quarterly review:
      - Evaluate monitor effectiveness
      - Check for gaps in coverage
      - Update thresholds for seasonal patterns
    '';

    # Generate Datadog monitor API configuration (optional - can be used with API)
    environment.etc."monitoring/alerts/datadog-monitors.json".text = ''
      {
        "monitors": [
          {
            "name": "[CRITICAL] Snapshot failed on {{host.name}}:{{subvolume}}",
            "type": "metric alert",
            "query": "sum(last_10m):sum:pantheros.snapshot.failed{*} by {host,subvolume} > 0",
            "message": "Snapshot creation failed for {{subvolume}} on {{host.name}}.\n\nRunbook: https://internal.runbooks/snapshot-failure",
            "tags": ["service:storage", "component:snapshots", "severity:critical"],
            "options": {
              "notify_audit": true,
              "locked": false,
              "include_tags": true,
              "require_full_window": false,
              "new_host_delay": 300,
              "evaluation_delay": 0,
              "escalation_message": "Escalated snapshot failure",
              "thresholds": {
                "critical": 0
              }
            }
          },
          {
            "name": "[WARNING] Snapshot age on {{host.name}}:{{subvolume}}",
            "type": "metric alert",
            "query": "avg(last_1h):avg:pantheros.snapshot.age{*} by {host,subvolume}} > ${cfg.alerts.snapshot.ageWarningHours}",
            "message": "Last snapshot for {{subvolume}} on {{host.name}} is {{value}}h old.\n\nRunbook: https://internal.runbooks/snapshot-age",
            "tags": ["service:storage", "component:snapshots", "severity:warning"],
            "options": {
              "notify_audit": false,
              "locked": false,
              "include_tags": true,
              "require_full_window": false,
              "new_host_delay": 300,
              "evaluation_delay": 0,
              "thresholds": {
                "warning": ${cfg.alerts.snapshot.ageWarningHours},
                "critical": ${cfg.alerts.snapshot.ageCriticalHours}
              }
            }
          },
          {
            "name": "[CRITICAL] Backup failed on {{host.name}}:{{subvolume}}",
            "type": "metric alert",
            "query": "sum(last_60m):sum:pantheros.backup.failed{*} by {host,subvolume}} > 0",
            "message": "Backup failed for {{subvolume}} on {{host.name}}.\n\nRunbook: https://internal.runbooks/backup-failure",
            "tags": ["service:storage", "component:backup", "severity:critical"],
            "options": {
              "notify_audit": true,
              "locked": false,
              "include_tags": true,
              "require_full_window": false,
              "new_host_delay": 300,
              "evaluation_delay": ${cfg.alerts.backup.failureAlertMinutes},
              "thresholds": {
                "critical": 0
              }
            }
          },
          {
            "name": "[CRITICAL] Last backup too old on {{host.name}}:{{subvolume}}",
            "type": "metric alert",
            "query": "time_since_agg(last_24h):time_since(last_1d):pantheros.backup.completed{*} by {host,subvolume}} > ${cfg.alerts.backup.lastBackupHours}h",
            "message": "Last successful backup for {{subvolume}} on {{host.name}} was {{value}}h ago.\n\nRunbook: https://internal.runbooks/backup-failure",
            "tags": ["service:storage", "component:backup", "severity:critical"],
            "options": {
              "notify_audit": true,
              "locked": false,
              "include_tags": true,
              "require_full_window": false,
              "new_host_delay": 300,
              "evaluation_delay": 0,
              "thresholds": {
                "critical": ${cfg.alerts.backup.lastBackupHours}
              }
            }
          },
          {
            "name": "[WARNING] Disk usage on {{host.name}}:{{device}}",
            "type": "metric alert",
            "query": "avg(last_5m):avg:pantheros.disk.usage{*} by {host,device}} > ${cfg.alerts.disk.usageWarningPercent}",
            "message": "Disk {{device}} on {{host.name}} is {{value}}% full.\n\nRunbook: https://internal.runbooks/disk-space",
            "tags": ["service:storage", "component:disk", "severity:warning"],
            "options": {
              "notify_audit": false,
              "locked": false,
              "include_tags": true,
              "require_full_window": false,
              "new_host_delay": 300,
              "evaluation_delay": 0,
              "thresholds": {
                "warning": ${cfg.alerts.disk.usageWarningPercent},
                "critical": ${cfg.alerts.disk.usageCriticalPercent}
              }
            }
          },
          {
            "name": "[WARNING] B2 cost high on {{host.name}}",
            "type": "metric alert",
            "query": "avg(last_24h):avg:pantheros.backup.b2.cost{*} by {host}} > ${toString (cfg.alerts.b2Cost.warningPercent * cfg.alerts.b2Cost.budgetCents / 100)}",
            "message": "Estimated B2 cost on {{host.name}} is ${{value}}.\n\nRunbook: https://internal.runbooks/b2-cost",
            "tags": ["service:storage", "component:backup", "severity:warning"],
            "options": {
              "notify_audit": false,
              "locked": false,
              "include_tags": true,
              "require_full_window": false,
              "new_host_delay": 300,
              "evaluation_delay": 0,
              "no_data_timeframe": 1440,
              "thresholds": {
                "warning": ${toString (cfg.alerts.b2Cost.warningPercent * cfg.alerts.b2Cost.budgetCents / 100)},
                "critical": ${toString (cfg.alerts.b2Cost.criticalPercent * cfg.alerts.b2Cost.budgetCents / 100)}
              }
            }
          }
        ]
      }
    '';

    # Documentation summary
    environment.etc."monitoring/README".text = ''
      # Storage Monitoring Implementation

      Task Group 8: Monitoring Integration with Datadog

      ## Components

      ### 8.1 Datadog Custom Metrics (datadog.nix)
      - Defines custom metrics namespace: `pantheros.*`
      - Provides helper functions for sending metrics
      - StatsD protocol to Datadog agent
      - Metrics: snapshot, backup, disk, B2 cost

      ### 8.2 Snapshot Metrics Collection (snapshots/monitoring.nix)
      - Emits metrics on snapshot success/failure
      - Tracks snapshot age and count
      - Periodic metrics collection service
      - Integration with snapper hooks

      ### 8.3 Backup Metrics Collection (backup/monitoring.nix)
      - Emits metrics on backup completion/failure
      - Tracks backup duration and size
      - B2 cost calculation and reporting
      - Integration with backup service

      ### 8.4 Alert Definitions (alerts.nix)
      - Comprehensive monitor configurations
      - Critical alerts: snapshot/backup failure, disk space
      - Warning alerts: snapshot age, backup duration, B2 cost
      - Runbook links and documentation

      ### 8.5 Disk Space Monitoring (disk-monitoring.nix)
      - Disk usage tracking per device
      - Btrfs-specific metrics
      - Balance status monitoring

      ## Metrics Reference

      ### Snapshot Metrics
      - `pantheros.snapshot.created` (counter)
      - `pantheros.snapshot.failed` (counter)
      - `pantheros.snapshot.age` (gauge, hours)
      - `pantheros.snapshot.count` (gauge, by type)

      ### Backup Metrics
      - `pantheros.backup.completed` (counter)
      - `pantheros.backup.failed` (counter)
      - `pantheros.backup.duration` (gauge, seconds)
      - `pantheros.backup.size` (gauge, bytes)
      - `pantheros.backup.b2.cost` (gauge, cents)

      ### Disk Metrics
      - `pantheros.disk.usage` (gauge, percent)
      - `pantheros.btrfs.balance` (gauge, status)

      ## Enabling Monitoring

      1. Enable system monitoring:
         ```
         services.monitoring.enable = true;
         services.monitoring.provider = "datadog";
         services.monitoring.datadog.apiKey = "your-api-key";
         ```

      2. Enable storage monitoring:
         ```
         storage.monitoring.datadog.enable = true;
         storage.monitoring.alerts.enable = true;
         storage.snapshots.monitoring.enable = true;
         storage.backup.monitoring.enable = true;
         ```

      3. Configure alerts in Datadog UI:
         - Import monitors from `/etc/monitoring/alerts/datadog-monitors.json`
         - Or create manually using guide in `/etc/monitoring/alerts/README`

      4. Verify metrics:
         - Check Datadog Metrics Explorer for `pantheros.*`
         - Verify snapshots: `snapper list`
         - Test backup: `systemctl start panther-backup.service`

      ## Alert Summary

      Critical (24/7):
      - Snapshot failure (immediate)
      - Backup failure (1h delay)
      - Last backup > 36h
      - Disk usage > 95%
      - B2 cost over budget

      Warning (business hours):
      - Snapshot age > 24h
      - Backup duration > 60m
      - Disk usage > 85%
      - B2 cost > 90% budget

      ## Documentation

      - Metrics API: /etc/panther-monitoring/README
      - Alert rules: /etc/monitoring/alerts/README
      - Snapshot metrics: /etc/backups/monitoring/README
      - Datadog setup: /etc/monitoring/datadog/README
    '';
  };
}
