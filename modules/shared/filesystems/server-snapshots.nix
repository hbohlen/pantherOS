{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.serverImpermanence;
in
{
  config = mkIf cfg.enable {
    # Automated snapshot service
    systemd.services."server-snapshots" = {
      enable = true;
      serviceConfig = {
        Type = "oneshot";
      };
      
      script = ''
        #!/bin/sh
        set -e
        
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        SNAPDIR="/.snapshots"
        
        # Create snapshots directory
        mkdir -p $SNAPDIR
        
        # Snapshot critical subvolumes
        echo "Creating server snapshots at $TIMESTAMP"
        
        # Root snapshot (for rollback)
        btrfs subvolume snapshot -r / $SNAPDIR/root-$TIMESTAMP
        
        # Persistent data snapshots
        if [ "${cfg.snapshotPolicy.scope}" = "critical" ] || [ "${cfg.snapshotPolicy.scope}" = "all" ]; then
          btrfs subvolume snapshot -r /persist $SNAPDIR/persist-$TIMESTAMP
          btrfs subvolume snapshot -r /var/lib/services $SNAPDIR/services-$TIMESTAMP
          btrfs subvolume snapshot -r /var/lib/caddy $SNAPDIR/caddy-$TIMESTAMP
        fi
        
        echo "Snapshots created: $TIMESTAMP"
      '';
    };
    
    # Snapshot timer based on policy
    systemd.timers."server-snapshots" = {
      enable = true;
      timerConfig = {
        OnCalendar = cfg.snapshotPolicy.frequency;
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    
    # Snapshot cleanup service
    systemd.services."server-snapshots-cleanup" = {
      enable = true;
      after = [ "server-snapshots.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
      
      script = let
        retentionDays = cfg.snapshotPolicy.retention;
      in ''
        #!/bin/sh
        set -e
        
        echo "Cleaning old snapshots (retention: ${retentionDays})"
        
        # Clean root snapshots
        find /.snapshots -name "root-*" -type d -mtime +${retentionDays} -exec btrfs subvolume delete {} \; 2>/dev/null || true
        
        # Clean persistent snapshots
        if [ "${cfg.snapshotPolicy.scope}" = "critical" ] || [ "${cfg.snapshotPolicy.scope}" = "all" ]; then
          find /.snapshots -name "persist-*" -type d -mtime +${retentionDays} -exec btrfs subvolume delete {} \; 2>/dev/null || true
          find /.snapshots -name "services-*" -type d -mtime +${retentionDays} -exec btrfs subvolume delete {} \; 2>/dev/null || true
          find /.snapshots -name "caddy-*" -type d -mtime +${retentionDays} -exec btrfs subvolume delete {} \; 2>/dev/null || true
        fi
        
        # Clean old root archives
        find /btrfs_tmp/old_roots -name "root-*" -type d -mtime +30 -exec btrfs subvolume delete {} \; 2>/dev/null || true
        
        echo "Snapshot cleanup completed"
      '';
    };
    
    # Cleanup timer (daily)
    systemd.timers."server-snapshots-cleanup" = {
      enable = true;
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    
    # Btrfs maintenance service
    systemd.services."btrfs-maintenance" = {
      enable = true;
      serviceConfig = {
        Type = "oneshot";
      };
      
      script = ''
        #!/bin/sh
        set -e
        
        echo "Running Btrfs maintenance"
        
        # Balance filesystem (monthly)
        if [ $(date +%d) = "01" ]; then
          echo "Balancing Btrfs filesystem"
          btrfs balance start /
        fi
        
        # Scrub for data integrity (weekly)
        if [ $(date +%u) = "0" ]; then
          echo "Scrubbing Btrfs filesystem for data integrity"
          btrfs scrub start /
        fi
        
        echo "Btrfs maintenance completed"
      '';
    };
    
    # Maintenance timer
    systemd.timers."btrfs-maintenance" = {
      enable = true;
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}