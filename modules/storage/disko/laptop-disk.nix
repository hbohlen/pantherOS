# modules/storage/disko/laptop-disk.nix
# Single-NVMe Laptop Disk Layout
# Compatible with Yoga laptop and similar single-NVMe systems
# Parameterized by disk device path
#
# Features:
# - EFI partition (512MB) for UEFI boot
# - Btrfs root partition with optimized subvolumes for laptop workloads
# - Subvolumes optimized for containers, backups, and development
# - Optional database subvolumes (disabled by default)

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.disks.laptop;

  # Common mount options for SSDs
  ssdMountOptions = [
    "noatime"
    "space_cache=v2"
    "discard=async"
    "ssd"
  ];
in
{
  options = {
    storage.disks.laptop = {
      enable = mkOption {
        description = "Enable laptop disk layout";
        type = types.bool;
        default = false;
      };

      device = mkOption {
        description = "NVMe device path (e.g., /dev/nvme0n1)";
        type = types.str;
        default = "/dev/nvme0n1";
      };

      enableDatabases = mkOption {
        description = "Enable PostgreSQL and Redis subvolumes";
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      disk = {
        ${cfg.device} = {
          type = "disk";
          device = cfg.device;
          content = {
            type = "gpt";
            partitions = {
              # EFI System Partition
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

              # Btrfs Root Partition
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-L"
                    "nixos-laptop"
                  ];

                  # Btrfs Subvolumes for Laptop Workloads
                  subvolumes = {
                    # ===== SYSTEM SUBVOLUMES =====

                    # Root filesystem
                    "@" = {
                      mountpoint = "/";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # Nix store - optimized for package manager
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:1"
                      ];
                    };

                    # Home directory
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # System logs
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

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

                    # ===== BACKUP SUBVOLUMES =====

                    # Local backups directory
                    "@backups" = {
                      mountpoint = "/var/backups";
                      mountOptions = ssdMountOptions ++ [
                        "compress=zstd:2"
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
      };
    };
  };
}
