# modules/storage/snapshots/policies.nix
# Snapshot Retention Policy Definitions
# Defines reusable retention policies for different host types
#
# Retention Policies:
# - laptop: Shorter retention for development laptops
# - server: Longer retention for production/staging servers

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.snapshots;
in
{
  options = {
    storage.snapshots.retention = mkOption {
      description = ''
        Default snapshot retention configuration.
        Defines how many snapshots to keep for each retention period.
      '';
      type = types.submodule {
        options = {
          daily = mkOption {
            description = "Number of daily snapshots to retain";
            type = types.int;
            default = 7;
          };
          weekly = mkOption {
            description = "Number of weekly snapshots to retain";
            type = types.int;
            default = 4;
          };
          monthly = mkOption {
            description = "Number of monthly snapshots to retain";
            type = types.int;
            default = 12;
          };
        };
      };
      default = {
        daily = 7;
        weekly = 4;
        monthly = 12;
      };
    };

    storage.snapshots.presets = mkOption {
      description = ''
        Preset snapshot retention policies for different host types.
        These presets can be referenced when configuring host snapshots.
      '';
      type = types.attrs;
      default = {
        # ===== LAPTOP PRESET =====
        # Optimized for development laptops with limited disk space
        # - 7 daily snapshots: 1 week of recovery
        # - 4 weekly snapshots: 1 month of recovery
        # - 12 monthly snapshots: 1 year of recovery
        laptop = {
          daily = 7;
          weekly = 4;
          monthly = 12;
        };

        # ===== SERVER PRESET =====
        # Optimized for production/staging servers with more disk space
        # - 30 daily snapshots: 1 month of recovery
        # - 12 weekly snapshots: 3 months of recovery
        # - 12 monthly snapshots: 1 year of recovery
        server = {
          daily = 30;
          weekly = 12;
          monthly = 12;
        };
      };
      readOnly = true;
    };
  };

  config = {
    # Export presets for use by host profile configurations
    # These can be referenced as: config.storage.snapshots.presets.laptop
  };
}
