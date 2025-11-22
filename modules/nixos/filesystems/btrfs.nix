{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.filesystems.btrfs;
in
{
  options.pantherOS.filesystems.btrfs = {
    enable = mkEnableOption "PantherOS Btrfs filesystem configuration";
    
    enableAutoscrub = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic scrubbing of Btrfs volumes";
    };
    
    autoscrubSettings = {
      interval = mkOption {
        type = types.str;
        default = "weekly";
        description = "How often to scrub Btrfs filesystems";
      };
      
      fileSystems = mkOption {
        type = types.listOf types.str;
        default = [ "/" ];
        description = "List of Btrfs filesystems to scrub";
      };
    };
    
    enableAutotrim = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic trimming of Btrfs volumes";
    };
    
    defaultMountOptions = {
      compression = mkOption {
        type = types.str;
        default = "zstd:1";
        description = "Default compression algorithm for Btrfs";
      };
      
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to include default mount options";
      };
    };
    
    extraMountOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Additional mount options for Btrfs";
    };
    
    enableSnapshots = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Btrfs snapshot management";
    };
  };

  config = mkIf cfg.enable {
    # Btrfs filesystem configuration
    fileSystems = mkIf cfg.defaultMountOptions.enable {
      # Apply default Btrfs mount options to root filesystem
      "/".options = mkIf (cfg.defaultMountOptions.enable && cfg.defaultMountOptions.compression != "") [
        "compress=${cfg.defaultMountOptions.compression}"
        "noatime"
        "ssd"
        "space_cache=v2"
        "discard=async"
      ] ++ cfg.extraMountOptions;
    };
    
    # Btrfs-specific services
    services.btrfs = {
      autoScrub = mkIf cfg.enableAutoscrub {
        enable = cfg.enableAutoscrub;
        interval = cfg.autoscrubSettings.interval;
        fileSystems = cfg.autoscrubSettings.fileSystems;
      };
    };
    
    # Additional Btrfs tools for management
    environment.systemPackages = with pkgs; [
      btrfs-progs
    ];
    
    # Enable automatic TRIM if supported
    services.fstrim = mkIf cfg.enableAutotrim {
      enable = cfg.enableAutotrim;
      interval = "weekly";
    };
    
    # Additional Btrfs-related kernel modules
    boot = {
      kernelModules = [ "btrfs" ];
      
      # Enable Btrfs in initrd if needed
      initrd = {
        supportedFilesystems = mkIf cfg.enable [ "btrfs" ];
      };
    };
    
    # For impermanence and snapshot features, make sure necessary tools are available
    environment.systemPackages = mkIf cfg.enableSnapshots (with pkgs; [
      btrfs-progs
    ]);
  };
}