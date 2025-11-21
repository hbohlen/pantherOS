{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.serverImpermanence;
  timestamp = "date +%Y%m%d-%H%M%S";
  excludePaths = concatStringsSep " " cfg.excludePaths;
in
{
  options.pantherOS.serverImpermanence = {
    enable = mkEnableOption "Server-optimized impermanence with Btrfs snapshots";
    
    excludePaths = mkOption {
      type = types.listOf types.str;
      default = [
        "/persist"
        "/nix"
        "/var/log"
        "/var/lib/services"
        "/var/lib/caddy"
        "/var/backup"
        "/var/lib/containers"
        "/btrfs_tmp"
      ];
      description = "Paths to preserve across reboots";
    };
    
    snapshotPolicy = mkOption {
      type = types.attrsOf types.str;
      default = {
        frequency = "6h";
        retention = "30d";
        scope = "critical";
      };
      description = "Automated snapshot policy";
    };
    
    performanceMode = mkOption {
      type = types.enum [ "balanced" "io-optimized" "space-optimized" ];
      default = "balanced";
      description = "Performance tuning mode for server workloads";
    };
  };
  
  config = mkIf cfg.enable {
    # Pre-boot impermanence setup
    systemd.services."server-impermanence-setup" = {
      enable = true;
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      
      script = ''
        #!/bin/sh
        set -e
        
        echo "Starting server impermanence setup"
        echo "Performance mode: ${cfg.performanceMode}"
        
        # Backup current root if it exists and isn't empty
        if [ -d "/root" ] && [ "$(ls -A /root 2>/dev/null)" ]; then
          echo "Creating backup snapshot: root-$(date +%Y%m%d-%H%M%S)"
          btrfs subvolume snapshot / /btrfs_tmp/old_roots/root-$(date +%Y%m%d-%H%M%S)
        fi
        
        # Delete existing root (will be recreated)
        btrfs subvolume delete / || true
        
        # Create new clean root
        btrfs subvolume create /root
        
        # Restore persistent data
        for path in ${excludePaths}; do
          if [ -e "$path" ]; then
            echo "Preserving $path"
            mkdir -p "/root$path"
            cp -a "$path" "/root$path"
          fi
        done
        
        # Apply performance optimizations
        case "${cfg.performanceMode}" in
          "io-optimized")
            echo "Applying I/O optimizations"
            echo 8192 > /proc/sys/vm/dirty_background_ratio
            echo 160 > /proc/sys/vm/dirty_ratio
            echo 5 > /proc/sys/vm/vfs_cache_pressure
            ;;
          "space-optimized")
            echo "Applying space optimizations"
            btrfs property set /root compression=zstd:3
            ;;
          "balanced"|*)
            echo "Applying balanced optimizations"
            # Default balanced settings
            ;;
        esac
        
        echo "Server impermanence setup completed"
      '';
    };
    
    # Required packages
    environment.systemPackages = with pkgs; [
      btrfs-progs
      coreutils
      findutils
    ];
    
    # Kernel parameters for server optimization
    boot.kernel.sysctl = {
      # Btrfs performance tuning
      "vm.vfs_cache_pressure" = mkIf (cfg.performanceMode == "io-optimized") 50;
      "vm.dirty_ratio" = mkIf (cfg.performanceMode == "io-optimized") 80;
      "vm.dirty_background_ratio" = mkIf (cfg.performanceMode == "io-optimized") 15;
      
      # General server optimizations
      "vm.swappiness" = 1;
      "vm.overcommit_memory" = 1;
    };
  };
}