# modules/storage/profiles/zephyrus.nix
# Zephyrus Dual-NVMe Development Laptop Profile
# ASUS ROG Zephyrus or similar dual-NVMe development laptop
#
# Hardware Profile:
# - Dual NVMe SSDs (2TB primary + 1TB secondary)
# - Primary pool: System, development, databases
# - Secondary pool: Containers, caches, snapshots, temp
#
# Features:
# - Dual-NVMe disk layout with workload separation
# - SSD optimization for NVMe performance
# - @dev-projects with nodatacow for fast Nix builds
# - Laptop snapshot policy (7/4/12)
# - Hardware detection for dual-NVMe systems

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.profiles.zephyrus;
in
{
  options = {
    storage.profiles.zephyrus = {
      enable = mkOption {
        description = "Enable Zephyrus dual-NVMe laptop profile";
        type = types.bool;
        default = false;
      };

      enableDatabases = mkOption {
        description = "Enable PostgreSQL and Redis subvolumes (disabled by default for laptops)";
        type = types.bool;
        default = false;
      };

      devProjectsNodatacow = mkOption {
        description = "Use nodatacow for @dev-projects subvolume for faster Nix builds";
        type = types.bool;
        default = true;
      };

      snapshotPolicy = mkOption {
        description = "Snapshot retention policy for laptop (daily/weekly/monthly)";
        type = types.attrs;
        default = {
          daily = 7;
          weekly = 4;
          monthly = 12;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # ===== PROFILE METADATA =====
    storage.profile = "zephyrus";
    storage.hostType = "laptop";
    storage.hardwareProfile = "dual-nvme";

    # ===== DISK LAYOUT =====
    imports = [
      ../disko/dual-nvme-disk.nix
      ../btrfs/ssd-optimization.nix
      ../snapshots/default.nix
    ];

    # Enable dual-NVMe disk layout
    storage.disks.dualNvme = {
      enable = true;
      primaryDevice = "/dev/nvme0n1";
      secondaryDevice = "/dev/nvme1n1";
      enableDatabases = cfg.enableDatabases;
    };

    # ===== SSD OPTIMIZATION =====
    # Enable SSD-specific optimizations for NVMe drives
    storage.btrfs.ssdOptimization = true;
    storage.btrfs.ssdAutodefrag = false;  # Optional: enable for long-term defragmentation

    # ===== CUSTOM MOUNT OPTIONS =====
    # Override @dev-projects to use nodatacow for faster Nix builds
    storage.btrfs.customMountOptions = lib.mkIf cfg.devProjectsNodatacow {
      "@dev-projects" = [
        "noatime"
        "space_cache=v2"
        "discard=async"
        "ssd"
        "nodatacow"  # Faster file builds without CoW overhead
      ];
    };

    # ===== SNAPSHOT POLICY =====
    # Laptop snapshot retention: 7 daily, 4 weekly, 12 monthly
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
    # Zephyrus detection: Check for dual nvme devices
    # This will be integrated with facter.json in hardware detection module
    storage.hardware.detection = {
      dualNVMe = true;
      expectedDevices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
      profileMatch = "zephyrus";
    };

    # ===== DOCUMENTATION =====
    # Profile configuration summary
    system.nixosDocumentation = {
      storageProfile = {
        host = "Zephyrus (Dual-NVMe Laptop)";
        layout = "dual-nvme-disk";
        primaryPool = "/dev/nvme0n1 - System & Development";
        secondaryPool = "/dev/nvme1n1 - Containers & Caches";
        databases = if cfg.enableDatabases then "enabled" else "disabled";
        ssdOptimization = "enabled (ssd flag, discard=async)";
        devProjectsMode = if cfg.devProjectsNodatacow then "nodatacow (fast builds)" else "standard (compressed)";
        snapshotRetention = "7 daily / 4 weekly / 12 monthly";
      };
    };
  };
}
