{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.storage.monitoring;
in
{
  imports = [
    ./options.nix
  ];

  config = mkIf (cfg.datadog.enable && config.services.monitoring.enable && config.services.monitoring.provider == "datadog") {
    # Helper script for sending metrics to Datadog via StatsD
    environment.etc."panther-monitoring/datadog-metrics.sh".text = ''
      #!/bin/bash
      # PantherOS Datadog Metrics Sender
      # Sends custom metrics to Datadog agent via StatsD protocol
      # Usage: send_metric <type> <name> <value> [tags]

      set -euo pipefail

      STATSD_HOST="${cfg.datadog.statsdHost}"
      STATSD_PORT="${toString cfg.datadog.statsdPort}"
      NAMESPACE="${cfg.datadog.namespace}"

      # Send metric via StatsD protocol
      # Format: <metric_name>:<value>|<type>|#<tags>
      send_metric() {
        local metric_type="$1"  # c=counter, g=gauge, h=histogram
        local metric_name="$2"
        local metric_value="$3"
        local tags="${4:-}"

        local full_name="${NAMESPACE}.${metric_name}"

        # Build StatsD message
        local message="${full_name}:${metric_value}|${metric_type}"

        # Add tags if provided
        if [ -n "$tags" ]; then
          message="${message}|#${tags}"
        fi

        # Send via UDP to StatsD
        echo "$message" | nc -w 1 -u "$STATSD_HOST" "$STATSD_PORT" || true
      }

      # Convenience wrappers
      send_counter() {
        send_metric "c" "$1" "$2" "$3"
      }

      send_gauge() {
        send_metric "g" "$1" "$2" "$3"
      }

      send_histogram() {
        send_metric "h" "$1" "$2" "$3"
      }

      # Snapshot metrics
      snapshot_created() {
        local host="$(hostname)"
        send_counter "snapshot.created" 1 "host:${host},subvolume:$1"
      }

      snapshot_failed() {
        local host="$(hostname)"
        send_counter "snapshot.failed" 1 "host:${host},subvolume:$1"
      }

      snapshot_age_hours() {
        local host="$(hostname)"
        send_gauge "snapshot.age" "$1" "host:${host},subvolume:$2"
      }

      snapshot_count() {
        local host="$(hostname)"
        send_gauge "snapshot.count" "$1" "host:${host},type:$2"
      }

      # Backup metrics
      backup_completed() {
        local host="$(hostname)"
        send_counter "backup.completed" 1 "host:${host},subvolume:$1"
      }

      backup_failed() {
        local host="$(hostname)"
        send_counter "backup.failed" 1 "host:${host},subvolume:$1"
      }

      backup_duration_seconds() {
        local host="$(hostname)"
        send_gauge "backup.duration" "$1" "host:${host},subvolume:$2"
      }

      backup_size_bytes() {
        local host="$(hostname)"
        send_gauge "backup.size" "$1" "host:${host},subvolume:$2"
      }

      backup_b2_cost() {
        local host="$(hostname)"
        send_gauge "backup.b2.cost" "$1" "host:${host}"
      }

      # Disk metrics
      disk_usage_percent() {
        local host="$(hostname)"
        send_gauge "disk.usage" "$1" "host:${host},device:$2"
      }

      btrfs_balance_status() {
        local host="$(hostname)"
        send_gauge "btrfs.balance" "$1" "host:${host},device:$2"
      }

      # Export functions
      export -f send_metric send_counter send_gauge send_histogram
      export -f snapshot_created snapshot_failed snapshot_age_hours snapshot_count
      export -f backup_completed backup_failed backup_duration_seconds backup_size_bytes backup_b2_cost
      export -f disk_usage_percent btrfs_balance_status
    '';

    # Make the script executable
    systemd.tmpfiles.rules = [
      "f /etc/panther-monitoring/datadog-metrics.sh 0755 root root -"
    ];

    # Document the metrics API
    environment.etc."panther-monitoring/README".text = ''
      # PantherOS Datadog Custom Metrics

      ## Metric Naming Convention

      All metrics are prefixed with `${cfg.datadog.namespace}.`

      ## Snapshot Metrics

      ### Counters
      - `${cfg.datadog.namespace}.snapshot.created` - Incremented when snapshot created successfully
        - Tags: host, subvolume
      - `${cfg.datadog.namespace}.snapshot.failed` - Incremented when snapshot creation fails
        - Tags: host, subvolume

      ### Gauges
      - `${cfg.datadog.namespace}.snapshot.age` - Age of last snapshot in hours
        - Tags: host, subvolume
      - `${cfg.datadog.namespace}.snapshot.count` - Number of snapshots by type
        - Tags: host, type (daily/weekly/monthly)

      ## Backup Metrics

      ### Counters
      - `${cfg.datadog.namespace}.backup.completed` - Incremented when backup completes successfully
        - Tags: host, subvolume
      - `${cfg.datadog.namespace}.backup.failed` - Incremented when backup fails
        - Tags: host, subvolume

      ### Gauges
      - `${cfg.datadog.namespace}.backup.duration` - Backup duration in seconds
        - Tags: host, subvolume
      - `${cfg.datadog.namespace}.backup.size` - Backup size in bytes
        - Tags: host, subvolume
      - `${cfg.datadog.namespace}.backup.b2.cost` - Estimated B2 storage cost
        - Tags: host

      ## Disk Metrics

      ### Gauges
      - `${cfg.datadog.namespace}.disk.usage` - Disk usage percentage
        - Tags: host, device
      - `${cfg.datadog.namespace}.btrfs.balance` - Btrfs balance status (0=idle, 1=running)
        - Tags: host, device

      ## Usage in Scripts

      Source the metrics helper:
        source /etc/panther-monitoring/datadog-metrics.sh

      Send a counter:
        snapshot_created "/@home"

      Send a gauge:
        snapshot_age_hours 12.5 "/@home"

      Send with custom tags:
        send_gauge "custom.metric" "42.0" "env:prod,team:platform"

      ## StatsD Protocol

      Metrics are sent to Datadog agent via StatsD protocol:
      - Host: ${cfg.datadog.statsdHost}
      - Port: ${cfg.datadog.statsdPort}
      - Protocol: UDP

      The Datadog agent forwards metrics to Datadog cloud.

      ## Tags Standard

      Common tags used across all metrics:
      - `host` - Hostname of the system
      - `subvolume` - Btrfs subvolume path
      - `device` - Block device name
      - `type` - Snapshot or retention type

      Additional tags added contextually based on metric type.

      ## Integration

      These metrics integrate with:
      - Datadog custom metrics dashboard
      - Datadog monitors/alerts
      - Datadog log correlation
      - Custom SLO dashboards

      For more information:
      - StatsD protocol: https://github.com/statsd/statsd
      - Datadog metrics: https://docs.datadoghq.com/metrics/
    '';

    # Documentation
    environment.etc."monitoring/datadog/README".text = ''
      # Datadog Custom Metrics for Storage

      The storage monitoring module provides custom metrics for:
      - Snapshot operations (creation, failures, age, count)
      - Backup operations (completion, failures, duration, size)
      - Disk space and usage
      - Btrfs-specific metrics

      All metrics use the `${cfg.datadog.namespace}.*` namespace.

      ## Setup

      1. Enable monitoring in your host configuration:
         ```
         services.monitoring.enable = true;
         services.monitoring.provider = "datadog";
         services.monitoring.datadog.apiKey = "your-api-key";
         storage.monitoring.datadog.enable = true;
         ```

      2. Source the metrics helper in your scripts:
         ```
         source /etc/panther-monitoring/datadog-metrics.sh
         ```

      3. Call metric functions in your code:
         ```
         snapshot_created "/@home"
         backup_completed "/@home"
         disk_usage_percent 85.5 "/dev/nvme0n1"
         ```

      ## Viewing Metrics

      In Datadog:
      - Metrics Explorer: Search for `pantheros.*`
      - Custom Dashboard: Create dashboard with your metrics
      - Monitors: Create alerts on metric thresholds
      - Logs: Correlate with application logs via tags

      ## Example Monitor

      Snapshot age warning:
      - Metric: `avg:pantheros.snapshot.age{*}`
      - Alert when: > 24 hours for 5 minutes
      - Message: "Last snapshot is older than 24h"

      Backup failure critical:
      - Metric: `sum:pantheros.backup.failed{*}`
      - Alert when: > 0 for 10 minutes
      - Message: "Backup failures detected"

      Disk usage warning:
      - Metric: `avg:pantheros.disk.usage{*}`
      - Alert when: > 85% for 5 minutes
      - Message: "Disk usage above 85%"
    '';
  };
}
