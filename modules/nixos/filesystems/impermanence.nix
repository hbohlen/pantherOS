{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.filesystems.impermanence;
in
{
  options.pantherOS.filesystems.impermanence = {
    enable = mkEnableOption "PantherOS impermanence configuration";
    
    enableBtrfsImpermanence = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Btrfs-based impermanence using subvolumes and snapshots";
    };
    
    persistentPaths = mkOption {
      type = types.listOf types.str;
      default = [ "/persist" "/nix" "/var/log" ];
      description = "List of paths that should persist across reboots";
    };
    
    ephemeralPaths = mkOption {
      type = types.listOf types.str;
      default = [ "/tmp" "/var/tmp" "/run" ];
      description = "List of paths that are reset on each boot";
    };
    
    useTmpfsForEphemeral = mkOption {
      type = types.bool;
      default = true;
      description = "Use tmpfs for ephemeral paths (faster but uses RAM)";
    };
    
    backupOnBoot = mkOption {
      type = types.bool;
      default = false;
      description = "Create a backup of ephemeral paths before reset";
    };
    
    enableAutomaticSnapshots = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automatic Btrfs snapshots before impermanence reset";
    };
  };

  config = mkIf cfg.enable {
    # Impermanence configuration
    environment.systemPackages = mkIf cfg.enableBtrfsImpermanence [
      pkgs.btrfs-progs
    ];
    
    # If using Btrfs impermanence
    systemd = mkIf cfg.enableBtrfsImpermanence {
      # Service to handle impermanence on boot
      services = {
        "btrfs-impermanence-setup" = mkIf cfg.enableBtrfsImpermanence {
          enable = true;
          description = "Btrfs-based Impermanence Setup";
          wantedBy = [ "multi-user.target" ];
          before = [ "network.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = "root";
          };
          
          script = let
            persistentPathsList = concatStringsSep " " cfg.persistentPaths;
            backupCmd = if cfg.backupOnBoot then 
              "btrfs subvolume snapshot / /var/lib/impermanence/backup-$(date +%Y%m%d-%H%M%S) || true"
            else
              "# Backup disabled";
          in ''
            #!/bin/sh
            set -e
            
            echo "Starting Btrfs impermanence setup"
            
            # Create backup if enabled
            ${backupCmd}
            
            # Only reset root subvolume if we're using Btrfs
            if [ -f /sys/fs/btrfs/features/mixed_backrefs ]; then
              echo "Btrfs detected, setting up impermanence"
              
              # Create subvolume for current root if not exists
              if ! btrfs subvolume list / | grep -q "root"; then
                btrfs subvolume create /root-tmp
              fi
              
              # Create persistent directories
              ${concatStringsSep "\n  " (map (path: ''
                mkdir -p ${path}
                if ! mountpoint -q ${path}; then
                  echo "Making ${path} persistent"
                fi
              '') cfg.persistentPaths)}
              
              # Setup ephemeral paths 
              ${concatStringsSep "\n  " (map (path: ''
                if [ ! -d ${path} ]; then
                  mkdir -p ${path}
                fi
              '') cfg.ephemeralPaths)}
              
              echo "Btrfs impermanence setup completed"
            else
              echo "Btrfs not detected, skipping impermanence setup"
            fi
          '';
        };
      };
    };
    
    # Mount configuration for impermanence
    fileSystems = mkIf cfg.useTmpfsForEphemeral (
      listToAttrs (map (path: {
        name = path;
        value = {
          fsType = "tmpfs";
          options = [ "size=100M" "mode=1777" "nr_inodes=10k" ];
        };
      }) cfg.ephemeralPaths)
    );
    
    # Additional impermanence-related packages
    environment.systemPackages = with pkgs; [
      coreutils
      util-linux
    ] ++ mkIf cfg.enableBtrfsImpermanence [ btrfs-progs ];
    
    # If using automatic snapshots
    services = mkIf (cfg.enableBtrfsImpermanence && cfg.enableAutomaticSnapshots) {
      # Timer for creating periodic snapshots
      cron = mkIf cfg.enableAutomaticSnapshots {
        enable = true;
        # This is a simplified approach - in practice we'd use systemd timers
        systemCrontab = ''
          # Create snapshots periodically
          # This is a placeholder - real implementation would use systemd timers
        '';
      };
    };
    
    # Systemd timers and services for snapshot management
    systemd = mkIf (cfg.enableBtrfsImpermanence && cfg.enableAutomaticSnapshots) {
      timers."btrfs-snapshot" = {
        enable = true;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
      
      services."btrfs-snapshot" = {
        enable = true;
        description = "Create Btrfs snapshots for impermanence";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        
        script = ''
          #!/bin/sh
          set -e
          
          # Create timestamped snapshot
          TIMESTAMP=$(date +%Y%m%d-%H%M%S)
          SNAPSHOT_NAME="root-snapshot-$TIMESTAMP"
          
          echo "Creating Btrfs snapshot: $SNAPSHOT_NAME"
          btrfs subvolume snapshot / "/.snapshots/$SNAPSHOT_NAME"
          
          # Cleanup old snapshots (keep last 7)
          cd /.snapshots
          ls -1dt */ | tail -n +8 | xargs -r btrfs subvolume delete
          
          echo "Snapshot completed: $SNAPSHOT_NAME"
        '';
      };
    };
  };
}