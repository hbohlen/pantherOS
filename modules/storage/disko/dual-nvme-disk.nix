# modules/storage/disko/dual-nvme-disk.nix
# Dual-NVMe Laptop Disk Layout
# Compatible with Zephyrus laptop and similar dual-NVMe systems
# Implements separate disk pools for optimized workload separation
#
# Architecture:
# - Primary Pool (nvme0n1): System, development projects, databases
# - Secondary Pool (nvme1n1): Containers, caches, snapshots, temp data
# - Pools are separate (NOT RAID1) for dedicated performance
#
# Features:
# - Two EFI partitions (one per disk) for redundancy
# - Workload-optimized subvolume placement
# - Optional database subvolumes on primary pool

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.disks.dualNvme;

  # Common mount options for NVMe SSDs
  ssdMountOptions = [
    "noatime"
    "space_cache=v2"
    "discard=async"
    "ssd"
  ];
in
{
  options = {
    storage.disks.dualNvme = {
      enable = mkOption {
        description = "Enable dual-NVMe disk layout";
        type = types.bool;
        default = false;
      };

      primaryDevice = mkOption {
        description = "Primary NVMe device path";
        type = types.str;
        default = "/dev/nvme0n1";
      };

      secondaryDevice = mkOption {
        description = "Secondary NVMe device path";
        type = types.str;
        default = "/dev/nvme1n1";
      };

      enableDatabases = mkOption {
        description = "Enable PostgreSQL and Redis subvolumes on primary pool";
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      # ===== PRIMARY POOL (nvme0n1) =====
      # Purpose: System, development work, databases
      disk = {
        ${cfg.primaryDevice} = {
          type = "disk";
          device = cfg.primaryDevice;
          content = {
            type = "gpt";
            partitions = {
              # EFI System Partition on primary disk
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "defaults"
                    "umask=0077"
                  ];
                };
              };

              # Btrfs Root Partition on primary disk
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-L"
                    "nixos-primary"
                  ];

                  # Primary Pool Subvolumes - Development & System
                  subvolumes = {
                    # ===== SYSTEM SUBVOLUMES =====

                    # Root filesystem
                    "@" = {
                      mountpoint = "/";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # Home directory
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # Development projects - fast access for builds
                    "@dev-projects" = {
                      mountpoint = "/home/hbohlen/dev";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # Nix store - fast reads for package builds
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:1"
                      ];
                    };

                    # ===== DATABASE SUBVOLUMES (OPTIONAL) =====

                    # PostgreSQL database - nodatacow for database integrity
                    "@postgresql" = lib.mkIf cfg.enableDatabases {
                      mountpoint = "/var/lib/postgresql";
                      mountOptions = [
                        "nodatacow"
                        "compress=no"
                        "noatime"
                        "space_cache=v2"
                        "discard=async"
                        "ssd"
                      ];
                    };

                    # Redis database - nodatacow for database integrity
                    "@redis" = lib.mkIf cfg.enableDatabases {
                      mountpoint = "/var/lib/redis";
                      mountOptions = [
                        "nodatacow"
                        "compress=no"
                        "noatime"
                        "space_cache=v2"
                        "discard=async"
                        "ssd"
                      ];
                    };
                  };
                };
              };
            };
          };
        };

        # ===== SECONDARY POOL (nvme1n1) =====
        # Purpose: Containers, caches, snapshots, temp data
        ${cfg.secondaryDevice} = {
          type = "disk";
          device = cfg.secondaryDevice;
          content = {
            type = "gpt";
            partitions = {
              # EFI System Partition on secondary disk (backup boot)
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  # Note: Secondary ESP is not mounted by default
                  # Provides redundancy if primary ESP fails
                };
              };

              # Btrfs Secondary Pool
              secondary = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-L"
                    "nixos-secondary"
                  ];

                  # Secondary Pool Subvolumes - Containers & Caches
                  subvolumes = {
                    # ===== CONTAINER SUBVOLUMES =====

                    # Podman/Docker containers - nodatacow for performance
                    "@containers" = {
                      mountpoint = "/var/lib/containers";
                      mountOptions = [
                        "nodatacow"
                        "compress=no"
                        "noatime"
                        "space_cache=v2"
                        "discard=async"
                        "ssd"
                      ];
                    };

                    # Podman cache - fast access for container image layers
                    "@podman-cache" = {
                      mountpoint = "/var/lib/containers/.cache";
                      mountOptions = [
                        "nodatacow"
                        "compress=no"
                        "noatime"
                        "space_cache=v2"
                        "discard=async"
                        "ssd"
                      ];
                    };

                    # ===== CACHE SUBVOLUMES =====

                    # General cache - npm, cargo, pip, etc.
                    "@cache" = {
                      mountpoint = "/var/cache";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:1"
                      ];
                    };

                    # User cache - dotfile caches, browser caches
                    "@user-cache" = {
                      mountpoint = "/home/hbohlen/.cache";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:1"
                      ];
                    };

                    # ===== SNAPSHOT SUBVOLUMES =====

                    # Btrfs snapshots directory
                    "@snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:2"
                      ];
                    };

                    # ===== TEMPORARY SUBVOLUMES =====

                    # Temporary files - no compression for speed
                    "@tmp" = {
                      mountpoint = "/tmp";
                      mountOptions = ssdMountOptions ++ [
                        "compress=no"
                      ];
                    };

                    # System logs on secondary pool
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
