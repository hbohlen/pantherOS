# modules/storage/profiles/yoga.nix
# Yoga Single-NVMe Light Laptop Profile
# Lenovo Yoga or similar single-NVMe travel laptop
#
# Hardware Profile:
# - Single NVMe SSD (typically 512GB-1TB)
# - Simplified subvolume structure for travel/light use
# - Minimal configuration with essential subvolumes only
#
# Features:
# - Single-NVMe disk layout
# - SSD optimization for NVMe performance
# - Minimal subvolume set (no separate dev-projects)
# - Laptop snapshot policy (7/4/12)
# - Hardware detection for single-NVMe systems

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.profiles.yoga;
in
{
  options = {
    storage.profiles.yoga = {
      enable = mkOption {
        description = "Enable Yoga single-NVMe laptop profile";
        type = types.bool;
        default = false;
      };

      enableDatabases = mkOption {
        description = "Enable PostgreSQL and Redis subvolumes (disabled by default for laptops)";
        type = types.bool;
        default = false;
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
    storage.profile = "yoga";
    storage.hostType = "laptop";
    storage.hardwareProfile = "single-nvme";

    # ===== DISK LAYOUT =====
    imports = [
      ../disko/laptop-disk.nix
      ../btrfs/ssd-optimization.nix
      ../snapshots/default.nix
    ];

    # Enable single-NVMe laptop disk layout
    storage.disks.laptop = {
      enable = true;
      device = "/dev/nvme0n1";
      enableDatabases = cfg.enableDatabases;
    };

    # ===== SSD OPTIMIZATION =====
    # Enable SSD-specific optimizations for NVMe drives
    storage.btrfs.ssdOptimization = true;
    storage.btrfs.ssdAutodefrag = false;  # Optional: enable for long-term defragmentation

    # ===== SNAPSHOT POLICY =====
    # Laptop snapshot retention: 7 daily, 4 weekly, 12 monthly
    # Same as Zephyrus but simplified structure
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
    # Yoga detection: Check for single nvme device
    # This will be integrated with facter.json in hardware detection module
    storage.hardware.detection = {
      singleNVMe = true;
      expectedDevices = [ "/dev/nvme0n1" ];
      profileMatch = "yoga";
    };

    # ===== DOCUMENTATION =====
    # Profile configuration summary
    system.nixosDocumentation = {
      storageProfile = {
        host = "Yoga (Single-NVMe Laptop)";
        layout = "laptop-disk";
        disk = "/dev/nvme0n1";
        databases = if cfg.enableDatabases then "enabled" else "disabled";
        ssdOptimization = "enabled (ssd flag, discard=async)";
        subvolumeStructure = "minimal (no separate dev-projects)";
        snapshotRetention = "7 daily / 4 weekly / 12 monthly";
        useCase = "travel & light development";
      };
    };
  };
}
