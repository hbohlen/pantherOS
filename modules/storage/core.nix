# modules/storage/core.nix
# Core Storage Module with enable option and base configuration

{ config, lib, ... }:

let
  cfg = config.storage;
in
{
  options = {
    storage = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Enable the PantherOS storage, snapshots, and backup foundation.
          This module provides hardware-aware storage profiles, Btrfs subvolume
          management, automated snapshots, and offsite backups to Backblaze B2.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Base storage configuration will be added in subsequent task groups
    # For now, just a placeholder to verify module loads correctly

    # Make storage lib available via specialArgs in the NixOS config
    # The actual lib functions can be accessed via flake outputs
  };
}
