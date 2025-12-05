# Datadog Monitoring Setup Guide

## Overview

This guide covers setting up comprehensive monitoring for the PantherOS storage infrastructure using Datadog, including dashboards, metrics, and alerting for snapshots, backups, and storage health.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Datadog Agent Installation](#datadog-agent-installation)
3. [Metrics Collection Setup](#metrics-collection-setup)
4. [Dashboard Configuration](#dashboard-configuration)
5. [Alert Rules](#alert-rules)
6. [Integration with Existing Monitors](#integration-with-existing-monitors)
7. [Escalation Procedures](#escalation-procedures)
8. [Verification and Testing](#verification-and-testing)

---

## Prerequisites

### Required Access

1. **Datadog Account**
   - API Key and Application Key
   - Datadog Pro subscription (required for custom metrics)
   - Admin or write permissions

2. **Hosts to Monitor**
   - Zephyrus (laptop)
   - Yoga (laptop)
   - Hetzner (production VPS)
   - Contabo (staging VPS)
   - OVH (utility VPS)

3. **Network Access**
   - Outbound HTTPS (443) to Datadog endpoints
   - DNS resolution for `datadoghq.com` and `datadoghq.eu`

### Required Packages

Install on each host:
```bash
# Datadog agent
nix-env -iA nixos.datadog-agent

# Btrfs tools for monitoring
nix-env -iA nixos.btrfs-progs

# Snapper for snapshot monitoring
nix-env -iA nixos.snapper
```

---

## Datadog Agent Installation

### Automated Installation (NixOS)

Add to each host's `configuration.nix`:

```nix
{ config, pkgs, ... }: {
  # Enable Datadog Agent
  services.datadog-agent = {
    enable = true;
    apiKey = "your_datadog_api_key";
    site = "datadoghq.com";  # or datadoghq.eu
    tags = [
      "env:production"
      "service:pantherOS"
      "component:storage"
    ];
    enableProcessCollection = true;
    enableLogCollection = true;
  };

  # Custom check for storage metrics
  environment.etc."datadog-agent/conf.d/storage.yaml" = {
    text = ''
      init_config:

      instances:
        - storage_path: /
          snapshot_check: true
          backup_check: true
          b2_integration: true
    '';
  };
}
```

### Manual Installation

If not using NixOS module:

```bash
# Install Datadog agent
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=YOUR_API_KEY DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Configure agent
vim /etc/datadog-agent/datadog.yaml

# Add API key
echo "api_key: YOUR_API_KEY" >> /etc/datadog-agent/datadog.yaml

# Restart agent
systemctl restart datadog-agent
```

### Verify Installation

```bash
# Check agent status
systemctl status datadog-agent

# Test connectivity
datadog-agent status

# Check logs
journalctl -u datadog-agent -f

# Test metrics
curl -X GET "https://api.datadoghq.com/api/v1/metrics" \
  -H "DD-API-KEY: YOUR_API_KEY" \
  -H "DD-APPLICATION-KEY: YOUR_APP_KEY"
```

---

## Metrics Collection Setup

### Custom Metrics Script

Create custom check for storage metrics:

```bash
#!/bin/bash
# /etc/datadog-agent/checks.d/storage.py

"""
Custom Datadog check for PantherOS storage monitoring.
"""
import os
import json
import subprocess
import time
from datetime import datetime, timedelta

from datadog_checks.base import AgentCheck

class StorageCheck(AgentCheck):
    def check(self, instance):
        # Get configuration
        storage_path = instance.get('storage_path', '/')
        check_snapshots = instance.get('snapshot_check', True)
        check_backups = instance.get('backup_check', True)
        check_b2 = instance.get('b2_integration', True)

        # Get hostname for tagging
        hostname = self.hostname

        # Collect disk usage metrics
        self.collect_disk_metrics(hostname)

        # Collect Btrfs metrics
        self.collect_btrfs_metrics(hostname, storage_path)

        # Collect snapshot metrics
        if check_snapshots:
            self.collect_snapshot_metrics(hostname)

        # Collect backup metrics
        if check_backups:
            self.collect_backup_metrics(hostname)

        # Collect B2 metrics
        if check_b2:
            self.collect_b2_metrics(hostname)

    def collect_disk_metrics(self, hostname):
        """Collect disk usage metrics"""
        try:
            result = subprocess.run(
                ['df', '-B1', '/'],
                capture_output=True,
                text=True,
                check=True
            )
            lines = result.stdout.strip().split('\n')
            if len(lines) > 1:
                fields = lines[1].split()
                if len(fields) >= 6:
                    total = int(fields[1])
                    used = int(fields[2])
                    available = int(fields[3])
                    percent = float(fields[4].rstrip('%'))

                    self.gauge('system.disk.total', total, tags=[f'host:{hostname}'])
                    self.gauge('system.disk.used', used, tags=[f'host:{hostname}'])
                    self.gauge('system.disk.available', available, tags=[f'host:{hostname}'])
                    self.gauge('system.disk.used_pct', percent, tags=[f'host:{hostname}'])

                    # Alert if disk usage > 85%
                    if percent > 85:
                        self.service_check('system.disk.health', self.WARNING, tags=[f'host:{hostname}'])
                    elif percent > 90:
                        self.service_check('system.disk.health', self.CRITICAL, tags=[f'host:{hostname}'])
                    else:
                        self.service_check('system.disk.health', self.OK, tags=[f'host:{hostname}'])
        except Exception as e:
            self.log.error(f"Failed to collect disk metrics: {e}")

    def collect_btrfs_metrics(self, hostname, storage_path):
        """Collect Btrfs-specific metrics"""
        try:
            # Get Btrfs filesystem info
            result = subprocess.run(
                ['btrfs', 'filesystem', 'show', storage_path],
                capture_output=True,
                text=True,
                check=True
            )

            # Parse output for allocation info
            # This is a simplified example
            self.gauge('btrfs.allocation.info', 1, tags=[
                f'host:{hostname}',
                f'path:{storage_path}'
            ])

            # Check filesystem balance
            result = subprocess.run(
                ['btrfs', 'balance', 'status', storage_path],
                capture_output=True,
                text=True
            )
            if 'Balance status' in result.stdout:
                if 'running' in result.stdout:
                    self.gauge('btrfs.balance.running', 1, tags=[f'host:{hostname}'])
                else:
                    self.gauge('btrfs.balance.running', 0, tags=[f'host:{hostname}'])

        except Exception as e:
            self.log.error(f"Failed to collect Btrfs metrics: {e}")

    def collect_snapshot_metrics(self, hostname):
        """Collect snapshot metrics"""
        try:
            # Get snapshot count
            result = subprocess.run(
                ['snapper', 'list', '--json'],
                capture_output=True,
                text=True,
                check=True
            )
            data = json.loads(result.stdout)

            total_snapshots = len(data.get('snapshots', []))
            self.gauge('snapper.snapshots.total', total_snapshots, tags=[f'host:{hostname}'])

            # Count by type
            type_counts = {'single': 0, 'pre': 0, 'post': 0}
            for snapshot in data.get('snapshots', []):
                snapshot_type = snapshot.get('type', 'single')
                type_counts[snapshot_type] = type_counts.get(snapshot_type, 0) + 1

            for snap_type, count in type_counts.items():
                if count > 0:
                    self.gauge(f'snapper.snapshots.{snap_type}', count, tags=[f'host:{hostname}'])

            # Check for failed snapshots
            failed_count = sum(1 for s in data.get('snapshots', []) if s.get('status') != 0)
            self.gauge('snapper.snapshots.failed', failed_count, tags=[f'host:{hostname}'])

            if failed_count > 0:
                self.service_check('snapper.health', self.WARNING, tags=[f'host:{hostname}'])
            else:
                self.service_check('snapper.health', self.OK, tags=[f'host:{hostname}'])

            # Check snapshot age (detect stale snapshots)
            if data.get('snapshots'):
                latest_snapshot = data['snapshots'][0]
                snapshot_time = datetime.fromisoformat(latest_snapshot.get('date'))
                age_hours = (datetime.now() - snapshot_time).total_seconds() / 3600

                self.gauge('snapper.snapshot.age_hours', age_hours, tags=[f'host:{hostname}'])

                # Alert if latest snapshot is > 24 hours old
                if age_hours > 24:
                    self.service_check('snapper.timeline', self.WARNING, tags=[f'host:{hostname}'])
                else:
                    self.service_check('snapper.timeline', self.OK, tags=[f'host:{hostname}'])

        except Exception as e:
            self.log.error(f"Failed to collect snapshot metrics: {e}")

    def collect_backup_metrics(self, hostname):
        """Collect backup metrics"""
        try:
            # Check backup service status
            result = subprocess.run(
                ['systemctl', 'is-active', 'panther-backup.service'],
                capture_output=True,
                text=True
            )
            backup_active = 1 if result.stdout.strip() == 'active' else 0
            self.gauge('backup.service.active', backup_active, tags=[f'host:{hostname}'])

            # Check last backup
            log_file = '/var/log/panther-backup/backup.log'
            if os.path.exists(log_file):
                # Get last successful backup timestamp
                with open(log_file, 'r') as f:
                    lines = f.readlines()
                    for line in reversed(lines):
                        if 'Backup completed successfully' in line:
                            # Parse timestamp
                            timestamp_str = line.split()[0:2]  # e.g., '2024-12-04', '02:15:32'
                            backup_time = datetime.strptime(' '.join(timestamp_str), '%Y-%m-%d %H:%M:%S')
                            age_hours = (datetime.now() - backup_time).total_seconds() / 3600
                            self.gauge('backup.last_age_hours', age_hours, tags=[f'host:{hostname}'])

                            # Alert if backup is > 36 hours old
                            if age_hours > 36:
                                self.service_check('backup.recency', self.CRITICAL, tags=[f'host:{hostname}'])
                            elif age_hours > 24:
                                self.service_check('backup.recency', self.WARNING, tags=[f'host:{hostname}'])
                            else:
                                self.service_check('backup.recency', self.OK, tags=[f'host:{hostname}'])
                            break

            # Check backup validation status
            status_file = '/etc/backups/validation/status.json'
            if os.path.exists(status_file):
                with open(status_file, 'r') as f:
                    status = json.load(f)
                    validation_status = 0 if status.get('valid', False) else 1
                    self.gauge('backup.validation.failed', validation_status, tags=[f'host:{hostname}'])

                    if status.get('valid', False):
                        self.service_check('backup.validation', self.OK, tags=[f'host:{hostname}'])
                    else:
                        self.service_check('backup.validation', self.CRITICAL, tags=[f'host:{hostname}'])

        except Exception as e:
            self.log.error(f"Failed to collect backup metrics: {e}")

    def collect_b2_metrics(self, hostname):
        """Collect Backblaze B2 metrics"""
        try:
            # Get B2 storage usage (requires b2 CLI)
            result = subprocess.run(
                ['b2', 'ls', '--json', 'pantherOS-backups/'],
                capture_output=True,
                text=True,
                check=True
            )
            data = json.loads(result.stdout)

            # Count backup files
            backup_count = len(data)
            self.gauge('b2.backup.file_count', backup_count, tags=[f'host:{hostname}'])

            # Calculate total size (if available)
            total_size = sum(item.get('size', 0) for item in data)
            self.gauge('b2.backup.total_bytes', total_size, tags=[f'host:{hostname}'])

            # Estimate cost (B2 pricing: $0.005/GB/month)
            cost_estimate = (total_size / (1024**3)) * 0.005
            self.gauge('b2.backup.estimated_cost', cost_estimate, tags=[f'host:{hostname}'])

            # Alert if cost exceeds budget
            if cost_estimate > 10.0:
                self.service_check('b2.cost.budget', self.CRITICAL, tags=[f'host:{hostname}'])
            elif cost_estimate > 8.0:
                self.service_check('b2.cost.budget', self.WARNING, tags=[f'host:{hostname}'])
            else:
                self.service_check('b2.cost.budget', self.OK, tags=[f'host:{hostname}'])

        except Exception as e:
            self.log.error(f"Failed to collect B2 metrics: {e}")
```

### Deploy Custom Check

```bash
# Copy to Datadog checks directory
cp storage.py /etc/datadog-agent/checks.d/storage.py
chown dd-agent:dd-agent /etc/datadog-agent/checks.d/storage.py
chmod 644 /etc/datadog-agent/checks.d/storage.py

# Restart agent
systemctl restart datadog-agent

# Verify check is loaded
datadog-agent check storage

# View metrics
datadog-agent status | grep -A 20 "storage"
```

---

## Dashboard Configuration

### Main Storage Overview Dashboard

Create a comprehensive dashboard for storage health monitoring.

**Dashboard JSON** (import via Datadog UI):

```json
{
  "title": "PantherOS Storage Overview",
  "description": "Storage, snapshots, and backup monitoring for all PantherOS hosts",
  "widgets": [
    {
      "id": 1,
      "type": "query_value",
      "definition": {
        "metrics": [{"query": "avg:snapper.snapshots.total{*} by {host}", "name": "total_snapshots"}],
        "time": {"live_span": "1h"},
        "autoscale": true,
        "precision": 0,
        "custom_links": []
      },
      "layout": {"x": 0, "y": 0, "width": 6, "height": 4}
    },
    {
      "id": 2,
      "type": "query_value",
      "definition": {
        "metrics": [{"query": "avg:system.disk.used_pct{*} by {host}", "name": "disk_usage"}],
        "time": {"live_span": "1h"},
        "autoscale": true,
        "precision": 0,
        "thresholds": {"critical": 90, "warning": 85}
      },
      "layout": {"x": 6, "y": 0, "width": 6, "height": 4}
    },
    {
      "id": 3,
      "type": "timeseries",
      "definition": {
        "metrics": [
          {"query": "avg:system.disk.used{*} by {host}", "name": "disk_used"},
          {"query": "avg:system.disk.available{*} by {host}", "name": "disk_available"}
        ],
        "time": {"live_span": "24h"},
        "yaxis": {"scale": "linear"},
        "events": [
          {"query": "status:error"}
        ]
      },
      "layout": {"x": 0, "y": 4, "width": 12, "height": 6}
    },
    {
      "id": 4,
      "type": "timeseries",
      "definition": {
        "metrics": [
          {"query": "avg:backup.last_age_hours{*} by {host}", "name": "backup_age"}
        ],
        "time": {"live_span": "7d"},
        "yaxis": {"min": "0", "max": "48"}
      },
      "layout": {"x": 0, "y": 10, "width": 12, "height": 6}
    },
    {
      "id": 5,
      "type": "query_value",
      "definition": {
        "metrics": [{"query": "avg:b2.backup.estimated_cost{*}", "name": "b2_cost"}],
        "time": {"live_span": "1h"},
        "autoscale": true,
        "precision": 2
      },
      "layout": {"x": 0, "y": 16, "width": 6, "height": 4}
    },
    {
      "id": 6,
      "type": "toplist",
      "definition": {
        "metrics": [
          {"query": "avg:b2.backup.file_count{*} by {host}", "name": "backup_count"}
        ],
        "time": {"live_span": "24h"}
      },
      "layout": {"x": 6, "y": 16, "width": 6, "height": 4}
    }
  ],
  "template_variables": [
    {"name": "host", "prefix": "host", "default": "*"}
  ]
}
```

### Alternative: Dashboard Setup via UI

If importing JSON is not available, create dashboard manually:

1. **Go to Dashboards** → **New Dashboard**
2. **Add Widgets**:
   - **Query Value**: Snapper snapshots total
   - **Query Value**: System disk used %
   - **Timeseries**: Disk usage over time
   - **Timeseries**: Backup age
   - **Query Value**: B2 cost estimate
   - **Top List**: Backup file counts

3. **Configure each widget**:
   - Set time range to 1h or 24h
   - Add appropriate tags
   - Configure thresholds

---

## Alert Rules

### Storage-Based Alerts

#### Disk Usage High

```yaml
# Alert name
Disk Usage Critical

# Query
avg(last_5m):avg:system.disk.used_pct{*} by {host} > 90

# Message
Disk usage on {{host.name}} is critically high: {{value}}%

# Tags
alert:storage
severity:critical
component:disk

# Escalation
Notify: @oncall-ops
Schedule: 24/7
```

#### Disk Usage Warning

```yaml
# Alert name
Disk Usage Warning

# Query
avg(last_5m):avg:system.disk.used_pct{*} by {host} > 85

# Message
Disk usage on {{host.name}} is high: {{value}}%

# Tags
alert:storage
severity:warning
component:disk

# Notify
@ops-team
```

### Snapshot-Based Alerts

#### No Recent Snapshot

```yaml
# Alert name
Snapshot Age Critical

# Query
avg(last_5m):avg:snapper.snapshot.age_hours{*} by {host} > 24

# Message
Latest snapshot on {{host.name}} is {{value}} hours old

# Tags
alert:snapshot
severity:critical
component:snapper

# Notify
@oncall-sysadmin
```

#### Snapshot Creation Failed

```yaml
# Alert name
Snapshot Failures Detected

# Query
avg(last_5m):avg:snapper.snapshots.failed{*} by {host} > 0

# Message
{{value}} failed snapshots detected on {{host.name}}

# Tags
alert:snapshot
severity:warning
component:snapper
```

### Backup-Based Alerts

#### Backup Too Old

```yaml
# Alert name
Backup Too Old

# Query
avg(last_5m):avg:backup.last_age_hours{*} by {host} > 36

# Message
Latest backup on {{host.name}} is {{value}} hours old

# Tags
alert:backup
severity:critical
component:backup

# Notify
@oncall-sysadmin
Schedule: 24/7
```

#### Backup Service Down

```yaml
# Alert name
Backup Service Down

# Query
avg(last_5m):avg:backup.service.active{*} by {host} < 1

# Message
Backup service is not running on {{host.name}}

# Tags
alert:backup
severity:critical
component:backup
```

#### Backup Validation Failed

```yaml
# Alert name
Backup Validation Failed

# Query
avg(last_5m):avg:backup.validation.failed{*} by {host} > 0

# Message
Backup validation failed on {{host.name}}

# Tags
alert:backup
severity:critical
component:backup
```

### B2 Cost Alerts

#### B2 Cost Warning

```yaml
# Alert name
B2 Cost Warning

# Query
avg(last_1h):avg:b2.backup.estimated_cost{*} > 8

# Message
B2 backup cost estimate: ${{value}} (approaching $10 budget)

# Tags
alert:cost
severity:warning
component:b2

# Notify
@ops-team
```

#### B2 Cost Critical

```yaml
# Alert name
B2 Cost Critical

# Query
avg(last_1h):avg:b2.backup.estimated_cost{*} > 10

# Message
B2 backup cost estimate: ${{value}} (exceeded $10 budget)

# Tags
alert:cost
severity:critical
component:b2

# Notify
@oncall-ops
Schedule: 24/7
```

### Composite Alerts

#### Storage System Degraded

```yaml
# Alert name
Storage System Degraded

# Query
(avg(last_5m):avg:system.disk.used_pct{*} by {host} > 85) || (avg(last_5m):avg:backup.last_age_hours{*} by {host} > 36)

# Message
Storage system on {{host.name}} has issues:
- Disk usage: {{disk_usage}}%
- Backup age: {{backup_age}}h

# Tags
alert:storage
severity:warning
component:storage

# Notify
@ops-team
```

---

## Integration with Existing Monitors

### Slack Integration

1. **Install Datadog Slack Integration**
   - Go to Integrations → Slack
   - Add to Slack workspace
   - Authorize

2. **Configure Notifications**
   ```yaml
   # In alert configuration:
   notify: @slack-storage-alerts
   channel: #ops-storage
   ```

### PagerDuty Integration

1. **Install PagerDuty Integration**
   - Go to Integrations → PagerDuty
   - Add PagerDuty API key

2. **Assign to Service**
   ```yaml
   # Create PagerDuty service for storage infrastructure
   Service: pantherOS-storage
   Escalation Policy: storage-oncall
   ```

### Email Notifications

```yaml
# Configure email recipients
notifications:
  - email: ops-team@example.com
  - email: sysadmin@example.com
```

---

## Escalation Procedures

### Alert Severity Levels

#### Critical (P1)
- **Response Time**: 15 minutes
- **Escalation**: Immediate
- **Notifications**:
  - PagerDuty (24/7 oncall)
  - Slack #oncall channel
  - SMS to oncall phone

**Examples**:
- Backup service down
- Disk usage > 90%
- Backup age > 36 hours
- B2 cost exceeded

#### Warning (P2)
- **Response Time**: 2 hours
- **Escalation**: Business hours
- **Notifications**:
  - Slack #ops channel
  - Email ops-team

**Examples**:
- Disk usage > 85%
- Snapshot age > 24 hours
- B2 cost approaching budget
- Failed snapshot detected

#### Info (P3)
- **Response Time**: 24 hours
- **Escalation**: None
- **Notifications**:
  - Email summary

**Examples**:
- Daily backup summary
- Weekly cost reports
- Snapshot count changes

### Escalation Workflow

```
Alert Triggered
     ↓
Check: Is business hours?
     ↓ Yes                  ↓ No
     ↓                     ↓
Ops Team                PagerDuty Oncall
     ↓                     ↓
Alert in Slack          Page oncall engineer
     ↓                     ↓
Response Required       Response Required
     ↓                     ↓
15-120 min             15-30 min
     ↓                     ↓
If no response,        If no response,
escalate to manager    escalate to senior
```

### Emergency Contacts

| Role | Name | Email | Phone | PagerDuty |
|------|------|-------|-------|-----------|
| Primary Oncall | [Name] | [email] | [phone] | [link] |
| Secondary Oncall | [Name] | [email] | [phone] | [link] |
| Storage Lead | [Name] | [email] | [phone] | [link] |
| Manager | [Name] | [email] | [phone] | [link] |

---

## Verification and Testing

### Verify Metrics Collection

```bash
# Check Datadog agent is sending metrics
datadog-agent status | grep -A 10 "storage"

# View recent metrics in Datadog UI
# Go to Metrics → Explorer
# Query: snapper.snapshots.total, system.disk.used_pct, backup.last_age_hours

# List active checks
curl -s http://localhost:8125/api/v1/checks | jq '.'

# View check output
journalctl -u datadog-agent | grep storage
```

### Test Alert Rules

```bash
# Simulate high disk usage
dd if=/dev/zero of=/tmp/test-file bs=1G count=1

# Wait for alert (check threshold: 85% or 90%)
# Monitor in Datadog UI

# Cleanup
rm /tmp/test-file

# Simulate backup failure
systemctl stop panther-backup.service

# Wait for alert
# Monitor in Datadog UI

# Restore
systemctl start panther-backup.service
```

### Verify Dashboard

1. **Open Main Storage Dashboard**
2. **Check each widget**:
   - [ ] Snapshot count displays values
   - [ ] Disk usage shows current values
   - [ ] Backup age timeline shows recent data
   - [ ] B2 cost estimate is accurate
   - [ ] All hosts appear in graphs

3. **Test Time Ranges**:
   - [ ] 1h view works
   - [ ] 24h view works
   - [ ] 7d view works

### Test Notifications

```bash
# Temporarily lower thresholds to trigger alerts
# (Or use Datadog's "Trigger Test Alerts" feature)

# Expected:
# 1. Alert triggers in Datadog
# 2. Slack notification received
# 3. PagerDuty page sent (for critical)
# 4. Email received

# After testing, restore thresholds
```

### Documentation Checklist

- [ ] Dashboard URL saved in documentation
- [ ] Alert rules documented
- [ ] Escalation contacts verified
- [ ] Response procedures documented
- [ ] Test results archived
- [ ] Runbook links added to alerts

---

## Additional Resources

### Datadog Documentation

- [Datadog Agent Configuration](https://docs.datadoghq.com/agent/)
- [Custom Checks](https://docs.datadoghq.com/agent/custom_checks/)
- [Metrics and Events](https://docs.datadoghq.com/metrics/)
- [Dashboards](https://docs.datadoghq.com/dashboards/)
- [Monitors](https://docs.datadoghq.com/monitors/)
- [Alerts](https://docs.datadoghq.com/monitors/notify/)

### Integration Guides

- [Slack Integration](https://docs.datadoghq.com/integrations/slack/)
- [PagerDuty Integration](https://docs.datadoghq.com/integrations/pagerduty/)
- [Email Notifications](https://docs.datadoghq.com/monitors/notify/)

### Related Documentation

- [Storage Module README](../README.md)
- [Backup System Documentation](backup/README.md)
- [Snapshot Runbook](../operational/runbook-snapshot-restore.md)

---

## Maintenance

### Regular Tasks

**Weekly**:
- Review alert trends in Datadog
- Check dashboard accuracy
- Review false positives

**Monthly**:
- Review and update alert thresholds
- Audit alert rule effectiveness
- Update escalation contacts

**Quarterly**:
- Review dashboard relevance
- Test all alert rules
- Update monitoring documentation
- Conduct monitoring audit

### Troubleshooting

**Agent Not Sending Metrics**:
```bash
# Check agent status
systemctl status datadog-agent

# Check network connectivity
curl -v https://datadoghq.com

# Check configuration
cat /etc/datadog-agent/datadog.yaml

# Restart agent
systemctl restart datadog-agent
```

**Missing Metrics**:
```bash
# Check custom check
datadog-agent check storage

# Check logs
tail -f /var/log/datadog/agent.log

# Verify check file
ls -l /etc/datadog-agent/checks.d/storage.py
```

**Alerts Not Firing**:
1. Verify monitor configuration in Datadog UI
2. Check threshold values
3. Ensure metrics are being collected
4. Test alert notification channel
5. Check alert routing rules

---

**Document Version**: 1.0
**Last Updated**: 2025-12-04
**Maintained By**: PantherOS Operations Team
**Review Frequency**: Quarterly
