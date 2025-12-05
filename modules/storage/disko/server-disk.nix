# modules/storage/disko/server-disk.nix
# Server Disk Layout for VPS Hosts
# Compatible with Hetzner, Contabo, and OVH VPS systems
# Parameterized by disk device and size
#
# Features:
# - Single Btrfs pool with comprehensive subvolume structure
# - Optimized for production server workloads
# - Separate subvolumes for containers, databases, and caching
# - Swap file support
# - Optional database subvolumes (PostgreSQL, Redis)
#
# Host Profiles:
# - Hetzner: ~458GB production VPS
# - Contabo: ~536GB staging VPS
# - OVH: ~200GB utility VPS

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.disks.server;

  # Common mount options for VPS (typically SSD-based)
  serverMountOptions = [
    "noatime"
    "space_cache=v2"
    "discard=async"
  ];
in
{
  options = {
    storage.disks.server = {
      enable = mkOption {
        description = "Enable server disk layout";
        type = types.bool;
        default = false;
      };

      device = mkOption {
        description = "Server disk device path (e.g., /dev/sda or /dev/vda)";
        type = types.str;
        default = "/dev/sda";
      };

      diskSize = mkOption {
        description = "Total disk size in bytes (for documentation and validation)";
        type = types.str;
        default = "500GB";
        example = "500GB";
      };

      enableDatabases = mkOption {
        description = "Enable PostgreSQL and Redis subvolumes";
        type = types.bool;
        default = false;
      };

      swapSize = mkOption {
        description = "Swap file size";
        type = types.str;
        default = "4G";
        example = "8G";
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
                    "nixos-server"
                  ];

                  # Comprehensive Subvolume Structure for VPS
                  subvolumes = {
                    # ===== SYSTEM SUBVOLUMES =====

                    # Root filesystem
                    "@" = {
                      mountpoint = "/";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # Nix store - centralized package management
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:1"
                      ];
                    };

                    # System logs - centralized logging
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # System cache - package manager caches, build caches
                    "@var-cache" = {
                      mountpoint = "/var/cache";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:1"
                      ];
                    };

                    # Temporary files
                    "@tmp" = {
                      mountpoint = "/tmp";
                      mountOptions = serverMountOptions ++ [
                        "compress=no"
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
                      ];
                    };

                    # ===== USER HOME SUBVOLUMES =====

                    # User home directory
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # Development directory
                    "@dev" = {
                      mountpoint = "/home/hbohlen/dev";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # User configuration files
                    "@config" = {
                      mountpoint = "/home/hbohlen/.config";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:3"
                      ];
                    };

                    # Local user data
                    "@local" = {
                      mountpoint = "/home/hbohlen/.local";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:2"
                      ];
                    };

                    # User cache - npm, cargo, pip, go, etc.
                    "@user-cache" = {
                      mountpoint = "/home/hbohlen/.cache";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:1"
                      ];
                    };

                    # ===== AI TOOLS SUBVOLUMES =====

                    # AI tools data and models (Claude Code, OpenCode.AI, etc.)
                    "@ai-tools" = {
                      mountpoint = "/home/hbohlen/.ai-tools";
                      mountOptions = serverMountOptions ++ [
                        "compress=zstd:1"
                      ];
                    };

                    # ===== SWAP SUBVOLUME =====

                    # Swap file subvolume
                    "@swap" = {
                      mountpoint = "/swap";
                      mountOptions = [
                        "nodatacow"
                        "compress=no"
                        "noatime"
                      ];
                      swap.swapfile.size = cfg.swapSize;
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
