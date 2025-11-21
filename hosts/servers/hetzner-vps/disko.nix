# hosts/servers/hetzner-cloud/disko.nix
# Declarative disk configuration for Hetzner Cloud VPS
#
# Hardware: 457.8GB SSD (/dev/sda)
# Architecture: GPT with BIOS boot, ESP, and Btrfs root
{ config, lib, ... }:

{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition - Required for GRUB on GPT disks
            # Hetzner Cloud VMs use BIOS boot, not pure UEFI
            bios-boot = {
              size = "1M";
              type = "EF02";  # BIOS boot partition type
              priority = 1;   # First partition on disk
            };

            # EFI System Partition - Boot loader and kernels
            # 512M is sufficient for single-kernel server configuration
            esp = {
              size = "512M";
              type = "EF00";  # EFI System Partition type
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"  # Restrict access to root only
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
              priority = 2;
            };

            # Btrfs root partition - Remaining space (~457GB)
            root = {
              size = "100%";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  # ============================================
                  # ROOT SUBVOLUME - System files
                  # ============================================
                  # Purpose: Core system files and configuration
                  # Why: Separating root allows for impermanence (ephemeral root)
                  # and easy system snapshots without including user data
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # HOME SUBVOLUME - User data
                  # ============================================
                  # Purpose: User home directories and dotfiles
                  # Why: Separate snapshots for user data, independent backup
                  # retention from system, and quotas if needed
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # DEV SUBVOLUME - Development projects
                  # ============================================
                  # Purpose: Code repositories and development work
                  # Why: Separate from home for targeted snapshots before
                  # major changes, different compression (code compresses well),
                  # and potential different backup frequency
                  "/home/dev" = {
                    mountpoint = "/home/hbohlen/dev";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # NIX SUBVOLUME - Nix store
                  # ============================================
                  # Purpose: /nix/store and Nix database
                  # Why: Critical for boot, needs to be mounted early,
                  # high read traffic but low writes, compress well
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # VAR SUBVOLUME - Variable data
                  # ============================================
                  # Purpose: /var for service data, state, spool
                  # Why: Separate from root for independent snapshots,
                  # services often have different retention needs
                  "/var" = {
                    mountpoint = "/var";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # LOG SUBVOLUME - System logs
                  # ============================================
                  # Purpose: /var/log for all logging
                  # Why: High write frequency with small sequential writes,
                  # nodatacow improves performance for constant appending,
                  # separate retention from system state
                  "/var/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "noatime"
                      "nodatacow"
                      "nodatasum"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # CACHE SUBVOLUME - Application caches
                  # ============================================
                  # Purpose: /var/cache for package caches, build caches
                  # Why: Can be cleared without data loss, separate from
                  # snapshots (no point backing up caches), good compression
                  "/var/cache" = {
                    mountpoint = "/var/cache";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # CONTAINERS SUBVOLUME - Podman/Docker storage
                  # ============================================
                  # Purpose: Container images, layers, and volumes
                  # Why: nodatacow because container storage does many
                  # random writes (database in container = disaster with COW),
                  # separate for easy cleanup and migration
                  "/var/lib/containers" = {
                    mountpoint = "/var/lib/containers";
                    mountOptions = [
                      "noatime"
                      "nodatacow"
                      "nodatasum"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # SWAP SUBVOLUME - Swapfile location
                  # ============================================
                  # Purpose: Contains the swapfile
                  # Why: Btrfs requires nodatacow for swapfiles,
                  # separate subvolume allows easy swapfile management
                  # without affecting other data
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "4G";
                    mountOptions = [
                      "noatime"
                      "nodatacow"
                      "nodatasum"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # PERSIST SUBVOLUME - Persistent application data
                  # ============================================
                  # Purpose: Configuration and data that survives reboots
                  # Why: Critical for service continuity with impermanence
                  # Contains: machine-id, SSH keys, service configs, secrets
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };

                  # ============================================
                  # OLD_ROOTS SUBVOLUME - Impermanence rollback archive
                  # ============================================
                  # Purpose: Archive of old root subvolumes for rollback
                  # Why: 30-day retention for system recovery with impermanence
                  # Naming: old_root_YYYYMMDD_HHMMSS format
                  "/btrfs_tmp/old_roots" = {
                    mountpoint = "/btrfs_tmp/old_roots";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };
                };
              };
              priority = 3;
            };
          };
        };
      };
    };
  };
}
