{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.backup;
in {
  options.services.backup = {
    enable = mkEnableOption "Enable automated backup infrastructure";

    # Backup configuration
    frequency = mkOption {
      type = types.enum [ "hourly" "daily" "weekly" "monthly" ];
      default = "daily";
      description = "Backup frequency";
    };

    retention = mkOption {
      type = types.int;
      default = 30;
      description = "Number of backups to retain";
    };

    # Backup targets
    targets = {
      home = mkOption {
        type = types.bool;
        default = true;
        description = "Backup user home directory";
      };

      system = mkOption {
        type = types.bool;
        default = true;
        description = "Backup system configuration";
      };

      databases = mkOption {
        type = types.bool;
        default = true;
        description = "Backup databases";
      };

      containers = mkOption {
        type = types.bool;
        default = true;
        description = "Backup container data";
      };
    };

    # Storage locations
    storage = {
      local = mkOption {
        type = types.bool;
        default = true;
        description = "Enable local backups";
      };

      remote = mkOption {
        type = types.bool;
        default = false;
        description = "Enable remote backups";
      };

      s3 = mkOption {
        type = types.bool;
        default = false;
        description = "Enable S3-compatible remote backups";
      };
    };

    # Compression and encryption
    compression = mkOption {
      type = types.enum [ "none" "gzip" "xz" "zstd" ];
      default = "gzip";
      description = "Compression algorithm for backups";
    };

    encryption = mkOption {
      type = types.bool;
      default = true;
      description = "Enable backup encryption";
    };
  };

  config = mkIf cfg.enable {
    imports = [
      ./btrfs.nix
      ./restic.nix
      ./borg.nix
    ];

    # Backup system packages
    environment.systemPackages = with pkgs; [
      # Backup tools
      btrbk
      borgbackup
      restic
      rsync
      duplicity

      # Compression
      gzip
      xz
      zstd

      # Encryption
      gpg

      # Monitoring
      htop
      iotop
    ];

    # Create backup directories
    system.activationScripts.create-backup-dirs = ''
      if [ ! -d "/var/backups" ]; then
        mkdir -p /var/backups/{local,remote,temp}
        chmod 750 /var/backups
        chown root:root /var/backups
      fi

      if [ ! -d "/etc/backups" ]; then
        mkdir -p /etc/backups/{configs,scripts,logs}
        chmod 755 /etc/backups
      fi
    '';

    # Environment variables
    environment.sessionVariables = {
      BACKUP_ROOT = "/var/backups";
      BACKUP_CONFIG = "/etc/backups";
      BACKUP_FREQUENCY = cfg.frequency;
      BACKUP_RETENTION = toString cfg.retention;
    };

    # Btrfs snapshot configuration
    systemd.services.btrfs-snapshots = {
      description = "Btrfs snapshot service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeScript "btrfs-snapshots" ''
          #!/bin/sh
          set -e

          # Create Btrfs snapshots of root filesystem
          TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
          SNAPSHOT_DIR="/.snapshots/${TIMESTAMP}"

          if btrfs subvolume snapshot / "${SNAPSHOT_DIR}" 2>/dev/null || true; then
            echo "Created Btrfs snapshot: ${SNAPSHOT_DIR}"
          fi

          # Clean up old snapshots
          btrfs subvolume list /.snapshots | \
            awk '/path .*/ {print $NF}' | \
            sort -r | \
            tail -n +$((cfg.retention + 1)) | \
            xargs -r -I {} btrfs subvolume delete "/.snapshots/{}" || true
        '';
      };
    };

    # Backup scheduling
    systemd.timers.btrfs-snapshot-timer = {
      description = "Btrfs snapshot timer";
      wantedBy = [ "multi-user.target" ];
      timerConfig = {
        OnCalendar = lib.mkIf (cfg.frequency == "hourly") "hourly";
        OnCalendar = lib.mkIf (cfg.frequency == "daily") "daily";
        OnCalendar = lib.mkIf (cfg.frequency == "weekly") "weekly";
        OnCalendar = lib.mkIf (cfg.frequency == "monthly") "monthly";
        Persistent = true;
      };
      partOf = [ "btrfs-snapshots.service" ];
    };

    # Documentation
    environment.etc."backups/README".text = ''
      # Backup Configuration

      This directory contains the backup infrastructure configuration.

      ## Backup Types

      - **Btrfs Snapshots**: Automatic filesystem snapshots
      - **Restic Backups**: Encrypted, deduplicated backups
      - **Borg Backups**: Deduplicated backups with compression

      ## Backup Locations

      - Local: `/var/backups/local/`
      - Remote: `/var/backups/remote/`
      - Temporary: `/var/backups/temp/`

      ## Configuration

      Backup frequency: ${cfg.frequency}
      Retention period: ${cfg.retention} backups
      Compression: ${cfg.compression}
      Encryption: ${lib.boolToString cfg.encryption}

      ## Usage

      Manual backup:
        btrbk run

      List snapshots:
        btrbk list

      Restore from backup:
        btrbk restore /path/to/snapshot

      For more information, see the backup documentation.
    '';
  };
}
