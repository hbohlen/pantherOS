# modules/storage/btrfs/ssd-optimization.nix
# SSD Optimization for NVMe Laptops
# Provides mount options and systemd services for optimal SSD performance
#
# Features:
# - Mount options: ssd flag, discard=async, optional autodefrag
# - Weekly fstrim.timer for automatic TRIM operations
# - Configurable per-host profile

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.btrfs;
in
{
  options = {
    storage.btrfs.ssdOptimization = mkOption {
      description = ''
        Enable SSD-specific optimizations for NVMe and SATA SSDs.

        When enabled, adds mount options optimized for SSD performance:
        - ssd: Btrfs SSD-specific optimizations
        - discard=async: Asynchronous TRIM for better performance
        - autodefrag: Background defragmentation (optional)

        Additionally creates weekly fstrim.timer for automatic TRIM.

        Default: true for laptops (detected via hardware profiles)
        Default: false for servers (traditional HDDs more common)
      '';
      type = types.bool;
      default = false;
      defaultText = "false (enable explicitly per profile)";
    };

    storage.btrfs.ssdAutodefrag = mkOption {
      description = ''
        Enable background autodefrag for SSD.

        Autodefrag performs background defragmentation to keep files contiguous.
        For SSDs, this is less critical than for HDDs but can still help with:
        - Large files that get modified frequently
        - Database workloads with scattered writes
        - Container layers with many small files

        Note: Autodefrag has some CPU and I/O overhead.
        Default: false (only enable for specific workloads)

        TRIM (discard) is still recommended even with autodefrag disabled.
      '';
      type = types.bool;
      default = false;
      defaultText = "false";
    };

    storage.btrfs.fstrimSchedule = mkOption {
      description = ''
        Schedule for automatic fstrim (TRIM) operations.

        Cron-style schedule for weekly fstrim.timer:
        - Format: "min hour day month dayOfWeek"
        - Default: "Sun 3:30 AM" (Sunday at 03:30)
        - Set to "never" to disable automatic TRIM

        Note: TRIM should run weekly or at least monthly for SSD health.
        Running daily is excessive; monthly is minimum recommendation.
      '';
      type = types.str;
      default = "Sun 3:30";
      defaultText = "Sun 3:30 (weekly on Sunday at 03:30)";
      example = "Sun 3:30";
    };
  };

  config = lib.mkIf cfg.ssdOptimization {
    # ===== SSD MOUNT OPTIONS =====
    # Note: Mount options are typically added in disko layout modules
    # This module provides the configuration options and fstrim service

    # ===== FSTRIM SYSTEMD TIMER =====
    # Automatic TRIM for SSD health and performance

    systemd.timers.fstrim-weekly = {
      description = "Weekly TRIM for SSDs";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.fstrimSchedule;
        # Persistent=true runs the timer if it was missed while offline
        Persistent = true;
        # RandomizedDelay smooths out simultaneous TRIM across hosts
        RandomizedDelay = "30min";
      };
    };

    systemd.services.fstrim-weekly = {
      description = "Trim SSD filesystems";
      documentation = [ "man:fstrim(8)" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getBin "util-linux"}/bin/fstrim --verbose --all";
        # StandardOutput and StandardError are journald by default
        # SuccessExitStatus = 1 allows non-zero exit codes (trim not supported)
        SuccessExitStatus = 1;
        # ProtectSystem=strict prevents writes outside allowed paths
        ProtectSystem = "strict";
        ProtectHome = true;
        # Read-only paths that shouldn't be trimmed
        ReadOnlyPaths = [ "/" "/boot" "/nix" ];
        # PrivateTmp creates a private /tmp
        PrivateTmp = true;
        # NoNewPrivileges prevents privilege escalation
        NoNewPrivileges = true;
        # Resource limits (conservative, TRIM is not CPU intensive)
        CPUQuota = "20%";
      };

      # Ensure this runs after the system is sufficiently booted
      after = [ "multi-user.target" ];
      wants = [ "multi-user.target" ];
    };

    # Export SSD mount options for use by disko modules
    # Profiles can reference: config.storage.btrfs.ssdMountOptions
    storage.btrfs.ssdMountOptions = [
      # Enable Btrfs SSD-specific optimizations
      # Tells Btrfs the underlying storage is an SSD
      "ssd"

      # Asynchronous TRIM (discard) for better performance
      # TRIM allows SSD to reclaim unused blocks efficiently
      # async reduces performance impact during regular operations
      "discard=async"
    ] ++ lib.optionals cfg.ssdAutodefrag [
      # Optional: Background autodefrag for contiguous files
      # For SSDs, fragmentation is less critical than HDDs
      # Can help with large frequently-modified files
      "autodefrag"
    ];
  };
}
