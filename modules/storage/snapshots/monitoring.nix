# modules/storage/snapshots/monitoring.nix
# Snapshot Monitoring and Metrics Collection
# Integrates with Datadog to emit metrics for snapshot operations

{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.storage.snapshots;
  monCfg = config.storage.monitoring;
in
{
  options.storage.snapshots.monitoring = {
    enable = mkEnableOption "Enable snapshot monitoring metrics";
  };

  config = mkIf (cfg.enable && cfg.monitoring.enable && monCfg.datadog.enable) {
    # Generate snapshot metrics collection script
    environment.etc."panther-monitoring/snapshot-metrics.sh".text = ''
      #!/bin/bash
      # Snapshot Metrics Collection Script
      # Tracks snapshot age, count, and emits Datadog metrics

      set -euo pipefail

      source /etc/panther-monitoring/datadog-metrics.sh

      # Get subvolumes to monitor
      SUBVOLUMES=(${concatStringsSep " " cfg.enabledSubvolumes})

      # Track metrics for each subvolume
      for subvol in "$${SUBVOLUMES[@]}"; do
        # Skip if subvolume doesn't exist
        if [ ! -d "$subvol" ]; then
          continue
        fi

        # Get last snapshot info
        last_snap=$(snapper list -t single -u --columns number,date,description "$subvol" 2>/dev/null | tail -1)

        if [ -n "$last_snap" ]; then
          # Calculate age in hours
          snap_date=$(echo "$last_snap" | awk '{print $2}')
          snap_epoch=$(date -d "$snap_date" +%s 2>/dev/null || echo 0)
          now_epoch=$(date +%s)
          age_hours=$(( (now_epoch - snap_epoch) / 3600 ))

          # Send age metric
          snapshot_age_hours "$age_hours" "$subvol"
        fi

        # Get snapshot counts by type
        total_snaps=$(snapper list "$subvol" 2>/dev/null | tail -n +4 | wc -l)
        if [ -n "$total_snaps" ]; then
          snapshot_count "$total_snaps" "total"
        fi

        # Count timeline snapshots
        timeline_snaps=$(snapper list -t single --columns number "$subvol" 2>/dev/null | wc -l)
        if [ -n "$timeline_snaps" ]; then
          snapshot_count "$timeline_snaps" "timeline"
        fi
      done
    '';

    # Make script executable
    systemd.tmpfiles.rules = [
      "f /etc/panther-monitoring/snapshot-metrics.sh 0755 root root -"
    ];

    # Service to collect snapshot metrics periodically
    systemd.services."panther-snapshot-metrics" = {
      description = "Collect Snapshot Metrics for Datadog";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/etc/panther-monitoring/snapshot-metrics.sh";
        User = "root";
        Group = "root";
        WorkingDirectory = "/";
        # Timeout
        TimeoutStartSec = "1min";
      };

      # Run after snapshot operations
      after = [ "snapper-timeline.service" "snapper-cleanup.service" ];
      requires = [ "snapper-timeline.service" ];
    };

    # Timer to run metrics collection every 30 minutes
    systemd.timers."panther-snapshot-metrics" = {
      description = "Snapshot Metrics Collection Schedule";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* *:00:30";
        Persistent = true;
        Unit = "panther-snapshot-metrics.service";
      };
    };

    # Hook service for timeline snapshots (runs on each timeline snapshot)
    systemd.services."snapper-timeline" = {
      serviceConfig = {
        # Source metrics helper and emit success metric
        ExecStartPost = let
          successHook = pkgs.writeScript "snapshot-success-hook" ''
            #!/bin/bash
            set -euo pipefail

            source /etc/panther-monitoring/datadog-metrics.sh

            # Get the snapshot that was just created
            snap_num=$(snapper list --columns number | tail -1 | awk '{print $1}')

            if [ -n "$snap_num" ] && [ "$snap_num" != "No." ]; then
              # Get subvolume from config
              subvol="$(lib.head cfg.enabledSubvolumes or "/")"
              snapshot_created "$subvol"
            fi
          '';
        in
          "${successHook}";
      };
    };

    # Hook service for failed snapshots
    systemd.services."snapper-timeline-failure" = {
      description = "Handle Snapshot Failures";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = let
          failureHook = pkgs.writeScript "snapshot-failure-hook" ''
            #!/bin/bash
            set -euo pipefail

            source /etc/panther-monitoring/datadog-metrics.sh

            # Get subvolume from config
            subvol="$(lib.head cfg.enabledSubvolumes or "/")"
            snapshot_failed "$subvol"
          '';
        in
          "${failureHook}";
      };
    };

    # Post hooks for weekly snapshots
    systemd.services."snapper-weekly" = {
      serviceConfig = {
        ExecStartPost = let
          weeklyHook = pkgs.writeScript "snapshot-weekly-hook" ''
            #!/bin/bash
            set -euo pipefail

            source /etc/panther-monitoring/datadog-metrics.sh

            # Emit metrics for each subvolume
            subvols=(${concatStringsSep " " cfg.enabledSubvolumes})
            for subvol in "$${subvols[@]}"; do
              snapshot_created "$subvol"
              snapshot_count 1 "weekly"
            done
          '';
        in
          "${weeklyHook}";
      };
    };

    # Post hooks for monthly snapshots
    systemd.services."snapper-monthly" = {
      serviceConfig = {
        ExecStartPost = let
          monthlyHook = pkgs.writeScript "snapshot-monthly-hook" ''
            #!/bin/bash
            set -euo pipefail

            source /etc/panther-monitoring/datadog-metrics.sh

            # Emit metrics for each subvolume
            subvols=(${concatStringsSep " " cfg.enabledSubvolumes})
            for subvol in "$${subvols[@]}"; do
              snapshot_created "$subvol"
              snapshot_count 1 "monthly"
            done
          '';
        in
          "${monthlyHook}";
      };
    };
  };
}
