{ lib, config, ... }:

let
  inherit (lib) mkOption types;
in
{
  options = {
    storage.btrfs.baseSubvolumes = mkOption {
      description = ''
        Base Btrfs subvolume definitions shared across all profiles.
        Defines the standard subvolumes with their mount points and options.
      '';
      type = types.attrs;
      default = {
        # Root filesystem subvolume
        "@" = {
          mountpoint = "/";
          mountOptions = [
            "noatime"
            "space_cache=v2"
          ];
        };

        # Home directory subvolume
        "@home" = {
          mountpoint = "/home";
          mountOptions = [
            "noatime"
            "space_cache=v2"
          ];
        };

        # Nix store subvolume
        "@nix" = {
          mountpoint = "/nix";
          mountOptions = [
            "noatime"
            "space_cache=v2"
          ];
        };

        # System logs subvolume
        "@log" = {
          mountpoint = "/var/log";
          mountOptions = [
            "noatime"
            "space_cache=v2"
          ];
        };
      };
    };
  };

  config = {
    # Export base subvolumes for use by disko modules
    # This allows disko modules to import and extend these definitions
  };
}
