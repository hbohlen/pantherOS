# modules/storage/snapshots/snapper.nix
# Snapper Integration for Automated Snapshots
# Configures snapper to manage Btrfs snapshots with automated scheduling
#
# Snapper is the standard tool for Btrfs snapshot management on NixOS.
# This module integrates snapper with the storage snapshot policies.

{ lib, config, ... }:

let
  inherit (lib) mkOption types mkIf;
  inherit (lib) optional optionals;
  cfg = config.storage.snapshots;
  snapperCfg = config.services.snapper;

  # Helper to convert retention days to snapper TIMELINE_LIMIT
  timelineLimitDays = days: toString days;

  # Helper to determine if a subvolume should have snapshots enabled
  shouldSnapshotSubvolume = subvolumeName:
    # Check if this subvolume is in the enabled snapshot subvolumes list
    lib.elem ("@" + subvolumeName) cfg.enabledSubvolumes;

in
{
  options = {
    storage.snapshots.enable = mkOption {
      description = ''
        Enable automatic snapshot management with snapper.

        When enabled, snapper will:
        - Create timeline snapshots (hourly/daily/weekly/monthly)
        - Automatically clean up old snapshots based on retention policies
        - Manage snapshot numbering and metadata
      '';
      type = types.bool;
      default = false;
    };

    storage.snapshots.enabledSubvolumes = mkOption {
      description = ''
        List of subvolumes to enable snapper snapshotting for.
        Each subvolume will have its own snapper configuration.

        Common subvolumes:
        - "@" (root filesystem)
        - "@home" (user data)
        - "@nix" (Nix store)
        - "@var/log" (system logs)
      '';
      type = types.listOf types.str;
      default = [ "@" "@home" ];
    };

    storage.snapshots.usePreset = mkOption {
      description = ''
        Use a preset retention policy from storage.snapshots.presets.
        Common values: "laptop" or "server"
      '';
      type = types.enum [ "laptop" "server" ];
      default = "laptop";
    };
  };

  config = mkIf cfg.enable {
    # ===== ENABLE SNAPPER SERVICE =====
    services.snapper = {
      enable = true;
      configs = let
        retention = cfg.presets.${cfg.usePreset};
      in
        builtins.listToAttrs (
          map (subvolume: {
            name = subvolume;
            value = {
              # Subvolume path (will be relative to Btrfs root)
              subvolume = "/${subvolume}";

              # ===== TIMELINE SETTINGS =====
              # Enable timeline snapshots for automated snapshotting
              TIMELINE_CREATE = "yes";
              TIMELINE_CLEANUP = "yes";

              # ===== RETENTION LIMITS =====
              # Map retention policy to snapper timeline limits
              TIMELINE_LIMIT_DAILY = timelineLimitDays retention.daily;
              TIMELINE_LIMIT_WEEKLY = timelineLimitDays retention.weekly;
              TIMELINE_LIMIT_MONTHLY = timelineLimitDays retention.monthly;

              # ===== TIMELINE SCHEDULE =====
              # Create snapshots at regular intervals
              # hourly - Snapshots every hour (kept for daily limit)
              TIMELINE_HOURLY = "yes";

              # ===== NOTIFICATION SETTINGS =====
              # Enable notifications for snapshot operations
              TIMELINE_NOTIFY = "yes";

              # ===== MINIMUM FREE INODE PERCENTAGE =====
              # Keep at least 5% inodes free to prevent filesystem issues
              FREE_INO = "5";
            };
          }) cfg.enabledSubvolumes
        );
    };

    # ===== SYSTEMD TIMER OVERRIDES =====
    # Configure snapper-timeline.timer to run during off-peak hours
    systemd.timers."snapper-timeline".timer = {
      # Run timeline snapshots at 02:00 (off-peak hours)
      # This will be configured in automation.nix
    };
  };
}
