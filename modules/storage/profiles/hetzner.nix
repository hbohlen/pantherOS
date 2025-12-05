# modules/storage/profiles/hetzner.nix
# Hetzner Production VPS Profile
# Hetzner VPS with production database workloads
#
# Hardware Profile:
# - Single VPS disk (~458GB)
# - Production database server
# - PostgreSQL and Redis workloads
#
# Features:
# - Server disk layout with production-sized disk
# - Database subvolumes enabled (PostgreSQL, Redis)
# - All database subvolumes enforce nodatacow
# - Server snapshot policy (30/12/12)
# - Hardware detection for ~458GB VPS disk

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.profiles.hetzner;
in
{
  options = {
    storage.profiles.hetzner = {
      enable = mkOption {
        description = "Enable Hetzner production VPS profile";
        type = types.bool;
        default = false;
      };

      diskSize = mkOption {
        description = "Hetzner VPS disk size (approximately 458GB)";
        type = types.str;
        default = "458GB";
      };

      swapSize = mkOption {
        description = "Swap file size for production server";
        type = types.str;
        default = "8G";
      };

      snapshotPolicy = mkOption {
        description = "Snapshot retention policy for server (daily/weekly/monthly)";
        type = types.attrs;
        default = {
          daily = 30;
          weekly = 12;
          monthly = 12;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # ===== PROFILE METADATA =====
    storage.profile = "hetzner";
    storage.hostType = "vps";
    storage.hardwareProfile = "production-vps";

    # ===== DISK LAYOUT =====
    imports = [
      ../disko/server-disk.nix
      ../btrfs/database-enforcement.nix
      ../snapshots/default.nix
    ];

    # Enable server disk layout with production disk size
    storage.disks.server = {
      enable = true;
      device = "/dev/sda";
      diskSize = cfg.diskSize;
      enableDatabases = true;  # PostgreSQL and Redis enabled for production
      swapSize = cfg.swapSize;
    };

    # ===== DATABASE ENFORCEMENT =====
    # Enforce nodatacow on database subvolumes
    storage.btrfs.enforceDatabaseNodatacow = true;

    # ===== SNAPSHOT POLICY =====
    # Server snapshot retention: 30 daily, 12 weekly, 12 monthly
    # Aggressive retention for production database recovery
    storage.snapshots = {
      enable = true;
      retention = cfg.snapshotPolicy;
      timeline = {
        daily = true;
        weekly = true;
        monthly = true;
      };
      schedule = {
        daily = "02:00";
        weekly = "Sun 03:00";
        monthly = "1 04:00";
      };
      # Production servers need more frequent snapshots for PITR
      databases = {
        preSnapshot = "flush-caches";
        postSnapshot = "verify-integrity";
      };
    };

    # ===== HARDWARE DETECTION =====
    # Hetzner detection: Check for ~458GB VPS disk
    # This will be integrated with facter.json in hardware detection module
    storage.hardware.detection = {
      vps = true;
      expectedDiskSize = "~458GB";
      expectedDevice = "/dev/sda";
      profileMatch = "hetzner";
    };

    # ===== DATABASE SPECIFIC CONFIGURATION =====
    # PostgreSQL and Redis configuration for production
    storage.databases = {
      postgresql = {
        enable = true;
        dataDirectory = "/var/lib/postgresql";
        backupPath = "/var/backups/postgresql";
        snapshotCompatible = true;
      };
      redis = {
        enable = true;
        dataDirectory = "/var/lib/redis";
        backupPath = "/var/backups/redis";
        snapshotCompatible = true;
      };
    };

    # ===== DOCUMENTATION =====
    # Profile configuration summary
    system.nixosDocumentation = {
      storageProfile = {
        host = "Hetzner (Production VPS)";
        layout = "server-disk";
        disk = "/dev/sda (~458GB)";
        databases = "PostgreSQL & Redis (enabled)";
        databasesNodatacow = "enforced (production requirement)";
        swapSize = cfg.swapSize;
        ssdOptimization = "enabled (discard=async)";
        snapshotRetention = "30 daily / 12 weekly / 12 monthly";
        useCase = "production database server";
        rpo = "15-30 minutes";
        rto = "aggressive (30 minutes)";
      };
    };
  };
}
