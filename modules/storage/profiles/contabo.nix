# modules/storage/profiles/contabo.nix
# Contabo Staging VPS Profile
# Contabo VPS staging environment mirroring production
#
# Hardware Profile:
# - Single VPS disk (~536GB)
# - Staging environment (mirror of production)
# - Same subvolumes as Hetzner for compatibility
#
# Features:
# - Server disk layout with staging-sized disk (~536GB)
# - Database subvolumes enabled (PostgreSQL, Redis)
# - Structure mirrors Hetzner for realistic staging
# - Server snapshot policy (30/12/12)
# - Hardware detection for ~536GB VPS disk

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.profiles.contabo;
in
{
  options = {
    storage.profiles.contabo = {
      enable = mkOption {
        description = "Enable Contabo staging VPS profile";
        type = types.bool;
        default = false;
      };

      diskSize = mkOption {
        description = "Contabo VPS disk size (approximately 536GB)";
        type = types.str;
        default = "536GB";
      };

      swapSize = mkOption {
        description = "Swap file size for staging server";
        type = types.str;
        default = "4G";
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
    storage.profile = "contabo";
    storage.hostType = "vps";
    storage.hardwareProfile = "staging-vps";

    # ===== DISK LAYOUT =====
    imports = [
      ../disko/server-disk.nix
      ../btrfs/database-enforcement.nix
      ../snapshots/default.nix
    ];

    # Enable server disk layout with staging disk size
    # Staging mirrors production structure for realistic testing
    storage.disks.server = {
      enable = true;
      device = "/dev/sda";
      diskSize = cfg.diskSize;
      enableDatabases = true;  # Same as Hetzner for staging compatibility
      swapSize = cfg.swapSize;
    };

    # ===== DATABASE ENFORCEMENT =====
    # Enforce nodatacow on database subvolumes (mirrors production)
    storage.btrfs.enforceDatabaseNodatacow = true;

    # ===== SNAPSHOT POLICY =====
    # Server snapshot retention: 30 daily, 12 weekly, 12 monthly
    # Same as production for realistic backup/restore testing
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
      # Staging can use same database snapshot strategy as production
      databases = {
        preSnapshot = "flush-caches";
        postSnapshot = "verify-integrity";
      };
    };

    # ===== HARDWARE DETECTION =====
    # Contabo detection: Check for ~536GB VPS disk
    # This will be integrated with facter.json in hardware detection module
    storage.hardware.detection = {
      vps = true;
      expectedDiskSize = "~536GB";
      expectedDevice = "/dev/sda";
      profileMatch = "contabo";
    };

    # ===== DATABASE SPECIFIC CONFIGURATION =====
    # PostgreSQL and Redis configuration for staging
    # Mirrors production configuration
    storage.databases = {
      postgresql = {
        enable = true;
        dataDirectory = "/var/lib/postgresql";
        backupPath = "/var/backups/postgresql";
        snapshotCompatible = true;
        stagingMode = true;  # Indicates this is staging environment
      };
      redis = {
        enable = true;
        dataDirectory = "/var/lib/redis";
        backupPath = "/var/backups/redis";
        snapshotCompatible = true;
        stagingMode = true;
      };
    };

    # ===== STAGING-SPECIFIC SETTINGS =====
    # Additional configuration for staging environment
    storage.environment = {
      type = "staging";
      mirrors = "production";  # Structure mirrors production
      testingMode = true;
      backupRetention = "relaxed";  # Can afford more relaxed policies if needed
    };

    # ===== DOCUMENTATION =====
    # Profile configuration summary
    system.nixosDocumentation = {
      storageProfile = {
        host = "Contabo (Staging VPS)";
        layout = "server-disk";
        disk = "/dev/sda (~536GB)";
        databases = "PostgreSQL & Redis (enabled)";
        databasesNodatacow = "enforced (production mirror)";
        swapSize = cfg.swapSize;
        ssdOptimization = "enabled (discard=async)";
        snapshotRetention = "30 daily / 12 weekly / 12 monthly";
        useCase = "staging environment (production mirror)";
        environment = "staging/testing";
        backupStrategy = "realistic (mirrors production)";
      };
    };
  };
}
