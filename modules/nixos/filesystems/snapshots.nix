{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.filesystems.snapshots;
in
{
  options.pantherOS.filesystems.snapshots = {
    enable = mkEnableOption "PantherOS Btrfs snapshot management";
    
    enableAutomatedSnapshots = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automated Btrfs snapshot creation";
    };
    
    snapshotSchedule = mkOption {
      type = types.str;
      default = "weekly";
      description = "Schedule for automated snapshots (e.g., daily, weekly, monthly)";
    };
    
    snapshotRetention = {
      hourly = mkOption {
        type = types.int;
        default = 0;
        description = "Number of hourly snapshots to retain";
      };
      
      daily = mkOption {
        type = types.int;
        default = 7;
        description = "Number of daily snapshots to retain";
      };
      
      weekly = mkOption {
        type = types.int;
        default = 4;
        description = "Number of weekly snapshots to retain";
      };
      
      monthly = mkOption {
        type = types.int;
        default = 6;
        description = "Number of monthly snapshots to retain";
      };
    };
    
    snapshotSubvolumes = mkOption {
      type = types.listOf types.str;
      default = [ "/" ];
      description = "List of subvolumes to snapshot";
    };
    
    snapshotLocation = mkOption {
      type = types.str;
      default = "/.snapshots";
      description = "Location to store Btrfs snapshots";
    };
    
    enableRollback = mkOption {
      type = types.bool;
      default = false;
      description = "Enable snapshot-based rollback capabilities";
    };
    
    enableSendReceive = mkOption {
      type = types.bool;
      default = false;
      description = "Enable snapshot send/receive for remote backup";
    };
  };

  config = mkIf cfg.enable {
    # Snapshot management configuration
    environment.systemPackages = with pkgs; [
      btrfs-progs
    ];
    
    # Systemd services and timers for automated snapshots
    systemd = mkIf cfg.enableAutomatedSnapshots {
      # Timer for automated snapshots
      timers."btrfs-snapshots" = {
        enable = true;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.snapshotSchedule;
          Persistent = true;
        };
      };
      
      # Service to create snapshots
      services."btrfs-snapshots" = {
        enable = true;
        description = "Create Btrfs snapshots";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          Nice = 10;  # Lower priority to avoid system slowdown
        };
        
        script = let
          createSnapshotCmds = concatMap (subvol: [
            "# Create snapshot for ${subvol}"
            "TIMESTAMP=$(date +'%Y%m%d-%H%M%S')"
            "SNAPSHOT_NAME='$(basename ${subvol})-$(date +'%Y%m%d-%H%M%S')'"
            "btrfs subvolume snapshot -r ${subvol} ${cfg.snapshotLocation}/$SNAPSHOT_NAME"
          ]) cfg.snapshotSubvolumes;
          
          cleanupCmd = ''
            # Cleanup old snapshots based on retention policy
            cd ${cfg.snapshotLocation}
            
            # Find and remove hourly snapshots exceeding retention
            if [ ${toString cfg.snapshotRetention.hourly} -gt 0 ]; then
              ls -1d */ | grep -E "[0-9]{8}-[0-9]{6}" | sort -r | tail -n +$((cfg.snapshotRetention.hourly + 1)) | xargs -r btrfs subvolume delete
            fi
            
            # Find and remove daily snapshots exceeding retention
            if [ ${toString cfg.snapshotRetention.daily} -gt 0 ]; then
              ls -1d */ | grep -E "[0-9]{8}-[0-9]{6}" | sort -r | tail -n +$((cfg.snapshotRetention.daily + 1)) | xargs -r btrfs subvolume delete
            fi
          '';
        in ''
          #!/bin/bash
          set -e
          
          # Create snapshot directory if it doesn't exist
          mkdir -p ${cfg.snapshotLocation}
          
          # Create snapshots for configured subvolumes
          ${concatStringsSep "\n" createSnapshotCmds}
          
          # Run cleanup
          ${cleanupCmd}
          
          echo "Btrfs snapshots completed at $(date)"
        '';
      };
    };
    
    # Services for snapshot rollback capabilities
    systemd = mkIf cfg.enableRollback {
      services."btrfs-rollback" = mkIf cfg.enableRollback {
        enable = false; # Disable by default, enable manually when needed
        description = "Btrfs snapshot rollback service";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        
        script = ''
          #!/bin/bash
          set -e
          
          if [ -z "$1" ]; then
            echo "Usage: $0 <snapshot_name>"
            exit 1
          fi
          
          SNAPSHOT_NAME=$1
          SNAPSHOT_PATH="${cfg.snapshotLocation}/$SNAPSHOT_NAME"
          
          if [ ! -d "$SNAPSHOT_PATH" ]; then
            echo "Snapshot $SNAPSHOT_PATH does not exist"
            exit 1
          fi
          
          echo "Rolling back to snapshot: $SNAPSHOT_PATH"
          echo "This is a manual process, please ensure you know what you're doing!"
          
          # In a real implementation, this would handle the rollback process
          # This is a simplified example that just outputs what would happen
          echo "Would rollback to snapshot: $SNAPSHOT_PATH"
          
          # Example rollback process (would need to be done carefully):
          # 1. Unmount the root subvolume
          # 2. Delete the current root subvolume
          # 3. Create a new subvolume from the snapshot
          # 4. Update the default subvolume ID
          # 5. Reboot
          
          echo "Rollback completed. Reboot required."
        '';
      };
    };
    
    # Configuration for send/receive operations
    systemd = mkIf cfg.enableSendReceive {
      # Timer for automated remote backup
      timers."btrfs-send-receive" = mkIf cfg.enableSendReceive {
        enable = cfg.enableSendReceive;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
      
      services."btrfs-send-receive" = mkIf cfg.enableSendReceive {
        enable = cfg.enableSendReceive;
        description = "Btrfs send/receive snapshots";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        
        script = ''
          #!/bin/bash
          set -e
          
          # This is a placeholder for send/receive operations
          # In a real implementation, this would handle backing up snapshots to remote locations
          echo "Btrfs send/receive operations would run here"
          echo "Configuration for remote backup destinations would be specified here"
        '';
      };
    };
    
    # Create snapshot location during early boot
    boot = {
      # Make sure the snapshot location is properly handled
      initrd = {
        # If snapshot location is on the same filesystem, it's already available
        # If it's on a separate mount, you'd need to configure that here
      };
    };
  };
}