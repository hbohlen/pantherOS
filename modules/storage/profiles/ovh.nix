# modules/storage/profiles/ovh.nix
# OVH Utility VPS Profile
# OVH VPS for utility/experimental workloads
#
# Hardware Profile:
# - Single VPS disk (~200GB)
# - Utility/experimental server
# - Simplified structure with minimal subvolumes
#
# Features:
# - Server disk layout with smaller utility disk (~200GB)
# - Database subvolumes disabled by default (can enable if needed)
# - Simplified subvolume structure (core subvolumes only)
# - Server snapshot policy (30/12/12)
# - Hardware detection for ~200GB VPS disk

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.profiles.ovh;
in
{
  options = {
    storage.profiles.ovh = {
      enable = mkOption {
        description = "Enable OVH utility VPS profile";
        type = types.bool;
        default = false;
      };

      diskSize = mkOption {
        description = "OVH VPS disk size (approximately 200GB)";
        type = types.str;
        default = "200GB";
      };

      swapSize = mkOption {
        description = "Swap file size for utility server";
        type = types.str;
        default = "2G";
      };

      enableDatabases = mkOption {
        description = "Enable PostgreSQL and Redis subvolumes (disabled by default for utility server)";
        type = types.bool;
        default = false;
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
    storage.profile = "ovh";
    storage.hostType = "vps";
    storage.hardwareProfile = "utility-vps";

    # ===== DISK LAYOUT =====
    imports = [
      ../disko/server-disk.nix
      ../snapshots/default.nix
    ];

    # Enable server disk layout with utility disk size
    # Databases disabled by default (can enable if utility server needs databases)
    storage.disks.server = {
      enable = true;
      device = "/dev/sda";
      diskSize = cfg.diskSize;
      enableDatabases = cfg.enableDatabases;
      swapSize = cfg.swapSize;
    };

    # ===== DATABASE ENFORCEMENT (conditional) =====
    # Only enforce if databases are enabled
    storage.btrfs.enforceDatabaseNodatacow = cfg.enableDatabases;

    # ===== SNAPSHOT POLICY =====
    # Server snapshot retention: 30 daily, 12 weekly, 12 monthly
    # Same as other servers for consistent backup strategy
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
    };

    # ===== HARDWARE DETECTION =====
    # OVH detection: Check for ~200GB VPS disk
    # This will be integrated with facter.json in hardware detection module
    storage.hardware.detection = {
      vps = true;
      expectedDiskSize = "~200GB";
      expectedDevice = "/dev/sda";
      profileMatch = "ovh";
    };

    # ===== UTILITY-SPECIFIC CONFIGURATION =====
    # Utility server database configuration (only if enabled)
    storage.databases = lib.mkIf cfg.enableDatabases {
      postgresql = {
        enable = true;
        dataDirectory = "/var/lib/postgresql";
        backupPath = "/var/backups/postgresql";
        snapshotCompatible = true;
        utilityMode = true;
      };
      redis = {
        enable = true;
        dataDirectory = "/var/lib/redis";
        backupPath = "/var/backups/redis";
        snapshotCompatible = true;
        utilityMode = true;
      };
    };

    # ===== UTILITY-SPECIFIC SETTINGS =====
    # Additional configuration for utility/experimental environment
    storage.environment = {
      type = "utility";
      experimental = true;
      simplifiedStructure = true;
      databasesDefault = false;
      lightweightProfile = true;
    };

    # ===== SUBDIRECTORY RESTRICTIONS =====
    # For smaller disk, we might want to restrict some subvolumes
    storage.spaceManagement = {
      monitorUsage = true;
      warnAtPercent = 80;
      criticalAtPercent = 90;
    };

    # ===== DOCUMENTATION =====
    # Profile configuration summary
    system.nixosDocumentation = {
      storageProfile = {
        host = "OVH (Utility VPS)";
        layout = "server-disk";
        disk = "/dev/sda (~200GB)";
        databases = if cfg.enableDatabases then "enabled (optional)" else "disabled (simplified)";
        databasesNodatacow = if cfg.enableDatabases then "enforced (if enabled)" else "not applicable";
        swapSize = cfg.swapSize;
        ssdOptimization = "enabled (discard=async)";
        snapshotRetention = "30 daily / 12 weekly / 12 monthly";
        useCase = "utility/experimental server";
        environment = "utility/experimental";
        profileType = "lightweight/simplified";
        diskStrategy = "minimal footprint";
      };
    };
  };
}
