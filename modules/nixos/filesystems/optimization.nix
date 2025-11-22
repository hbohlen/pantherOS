{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.filesystems.optimization;
in
{
  options.pantherOS.filesystems.optimization = {
    enable = mkEnableOption "PantherOS filesystem optimization";
    
    enableSSDOptimization = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SSD-specific optimizations";
    };
    
    enableBtrfsOptimization = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Btrfs-specific optimizations";
    };
    
    enableMountPointOptimization = mkOption {
      type = types.bool;
      default = true;
      description = "Enable mount point-specific optimizations";
    };
    
    optimizationProfile = mkOption {
      type = types.enum [ "balanced" "performance" "storage-efficiency" "durability" ];
      default = "balanced";
      description = "Optimization profile for filesystems";
    };
    
    # I/O scheduler settings
    ioScheduler = {
      device = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Device to apply I/O scheduler to (null for all SSDs)";
      };
      
      scheduler = mkOption {
        type = types.enum [ "none" "mq-deadline" "bfq" ];
        default = "mq-deadline";
        description = "I/O scheduler to use";
      };
    };
    
    # Btrfs-specific settings
    btrfsSettings = {
      enableCompression = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Btrfs compression";
      };
      
      compressionAlgorithm = mkOption {
        type = types.enum [ "zstd" "lzo" "zlib" ];
        default = "zstd";
        description = "Btrfs compression algorithm";
      };
      
      compressionLevel = mkOption {
        type = types.int;
        default = 1;
        description = "Btrfs compression level (for zstd)";
      };
      
      enableSpaceCache = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Btrfs space cache";
      };
      
      enableFsync = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Btrfs fsync for data integrity";
      };
    };
    
    # Mount-specific optimizations
    mountPointOptimizations = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          noatime = mkOption {
            type = types.bool;
            default = false;
            description = "Enable noatime for this mount point";
          };
          
          compression = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Compression setting for this mount point";
          };
          
          ssd = mkOption {
            type = types.bool;
            default = false;
            description = "Enable SSD optimizations for this mount point";
          };
        };
      });
      default = {};
      description = "Mount-point specific optimizations";
    };
  };

  config = mkIf cfg.enable {
    # Filesystem optimization configuration
    environment.systemPackages = with pkgs; [
      util-linux  # For tuning utilities
      hdparm      # For SSD tuning
      btrfs-progs # For Btrfs management
    ];
    
    # Apply mount point optimizations
    fileSystems = mkIf cfg.enableMountPointOptimization (
      mapAttrs (mountPoint: opts: {
        options = []
          ++ (mkIf opts.noatime [ "noatime" ])
          ++ (mkIf opts.compression [ "compress=${opts.compression}" ])
          ++ (mkIf opts.ssd [ "ssd" ]);
      }) cfg.mountPointOptimizations
    );
    
    # Kernel parameters for filesystem optimizations
    boot = {
      kernel.sysctl = mkIf cfg.enableSSDOptimization {
        # Scheduler settings for SSDs
        "vm.swappiness" = mkIf (cfg.optimizationProfile == "performance" || cfg.optimizationProfile == "balanced") 1;
        "vm.vfs_cache_pressure" = mkIf (cfg.optimizationProfile == "performance") 50;
        "vm.dirty_ratio" = mkIf (cfg.optimizationProfile == "durability") 5;
        "vm.dirty_background_ratio" = mkIf (cfg.optimizationProfile == "durability") 2;
      };
      
      # I/O scheduler configuration
      extraModprobeConfig = mkIf (cfg.ioScheduler.device != null) ''
        # Set I/O scheduler for specific device
        options ${cfg.ioScheduler.device} scheduler=${cfg.ioScheduler.scheduler}
      '';
      
      # I/O scheduler configuration for all NVMe SSDs
      initrd = {
        # Set I/O scheduler in initramfs
        availableKernelModules = [ "nvme" ];
        postDeviceCommands = mkIf (cfg.ioScheduler.scheduler != "none") ''
          for dev in /sys/block/nvme*; do
            [ -e "$dev" ] || continue
            echo ${cfg.ioScheduler.scheduler} > "$dev/queue/scheduler"
          done
          
          # Apply to SD/MMC devices too if needed
          for dev in /sys/block/sd*; do
            [ -e "$dev" ] && echo ${cfg.ioScheduler.scheduler} > "$dev/queue/scheduler"
          done
        '';
      };
    };
    
    # Btrfs-specific optimizations
    fileSystems = mkIf (cfg.enableBtrfsOptimization && cfg.btrfsSettings.enableCompression) {
      # These would apply to Btrfs mounts - in practice, these would be added to
      # individual mount options rather than to the root filesystem directly
      # unless we're customizing all Btrfs mounts
    };
    
    # Systemd services for ongoing optimization
    systemd = {
      # Service to apply optimizations at runtime
      services."filesystem-optimization" = {
        enable = cfg.enable;
        description = "Apply filesystem optimizations";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        
        script = let
          schedulerSetting = if cfg.ioScheduler.device != null 
            "echo ${cfg.ioScheduler.scheduler} > /sys/block/${cfg.ioScheduler.device}/queue/scheduler"
          else
            ''
              # Set scheduler for all NVMe drives
              for dev in /sys/block/nvme*; do
                [ -e "$dev" ] || continue
                echo ${cfg.ioScheduler.scheduler} > "$dev/queue/scheduler"
              done
              
              # Set scheduler for all SATA SSDs
              for dev in /sys/block/sd*; do
                [ -e "$dev" ] && echo ${cfg.ioScheduler.scheduler} > "$dev/queue/scheduler"
              done
            '';
          
          optimizationCmds = [
            "# Apply filesystem optimizations"
            "${schedulerSetting}"
            ''
              # Adjust swappiness based on profile
              echo ${if cfg.optimizationProfile == "performance" || cfg.optimizationProfile == "balanced" then "1" else "10"} > /proc/sys/vm/swappiness
            ''
          ];
        in ''
          #!/bin/sh
          set -e
          
          ${concatStringsSep "\n" optimizationCmds}
          
          echo "Filesystem optimizations applied"
        '';
      };
    };
    
    # Additional optimization based on profile
    system.activationScripts = mkIf cfg.enable {
      # Custom activation script to apply optimizations during system activation
      "filesystem-optimizations" = let
        optimizationScript = if cfg.optimizationProfile == "performance" then
          "# Performance-oriented optimizations"
        else if cfg.optimizationProfile == "storage-efficiency" then
          "# Storage efficiency optimizations (more compression, less caching)"
        else if cfg.optimizationProfile == "durability" then
          "# Durability-oriented optimizations (frequent syncs, etc.)"
        else  # balanced
          "# Balanced optimizations";
      in
        "${optimizationScript}";
    };
  };
}