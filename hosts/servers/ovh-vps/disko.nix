# disko.nix - Optimized for OVH VPS
# Server: OVH VPS (200GB NVMe)
# Workloads: Development server, containers, AI tools
#
# Subvolume Strategy:
# - Separate subvolumes for different workload types
# - Optimized compression per workload
# - Container-optimized storage (nodatacow)
# - Cache and temp data in dedicated subvolumes
# - Easy snapshot and backup management

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition (required for BIOS boot)
            biosBoot = {
              size = "2M";
              type = "21686148-6449-6E6F-744E-656564454649"; # BIOS boot partition type
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = null; # Not mounted
              };
            };

            # Boot partition - ext4 for BIOS boot
            boot = {
              size = "1G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };

            # Root - Btrfs with subvolumes
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" "-L" "nixos" ]; # Force and label

                # Btrfs subvolumes - organized by workload type
                subvolumes = {
                  # ===== SYSTEM SUBVOLUMES =====

                  # Root filesystem - minimal, mostly configs
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd:3"  # Good compression for system files
                      "noatime"          # Performance: don't update access times
                      "space_cache=v2"   # Modern space cache
                      "discard=async"    # SSD: async TRIM
                    ];
                  };

                  # Nix store - largest space consumer
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd:1"  # Light compression (lots of similar files)
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # System logs
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd:3"  # Logs compress very well
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # System cache (package manager caches, etc.)
                  "@var-cache" = {
                    mountpoint = "/var/cache";
                    mountOptions = [
                      "compress=zstd:1"  # Light compression, frequently rewritten
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # Temporary files
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [
                      "compress=no"      # Temp files, speed over space
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # ===== CONTAINER SUBVOLUMES =====

                  # Podman containers - optimized for container performance
                  "@containers" = {
                    mountpoint = "/var/lib/containers";
                    mountOptions = [
                      "nodatacow"        # CRITICAL: CoW kills container performance
                      "compress=no"      # Container images already compressed
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # ===== USER HOME SUBVOLUMES =====

                  # User home - general files, dotfiles, configs
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd:3"  # Good compression for user files
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # ===== DEVELOPMENT SUBVOLUMES =====

                  # Main development directory - ALL your programming projects
                  "@dev" = {
                    mountpoint = "/home/hbohlen/dev";
                    mountOptions = [
                      "compress=zstd:3"  # Source code compresses very well
                      "noatime"          # Performance for file operations
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # User config files - .config, .local/share, dotfiles
                  "@config" = {
                    mountpoint = "/home/hbohlen/.config";
                    mountOptions = [
                      "compress=zstd:3"  # Config files compress well
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # Local user data and state
                  "@local" = {
                    mountpoint = "/home/hbohlen/.local";
                    mountOptions = [
                      "compress=zstd:2"  # Mixed content, medium compression
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # User cache - npm, cargo, go, pip, etc.
                  "@user-cache" = {
                    mountpoint = "/home/hbohlen/.cache";
                    mountOptions = [
                      "compress=zstd:1"  # Frequently rewritten, light compression
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # ===== AI TOOLS DATA =====

                  # Claude Code data/models
                  "@ai-tools" = {
                    mountpoint = "/home/hbohlen/.ai-tools";
                    mountOptions = [
                      "compress=zstd:1"  # AI models don't compress well
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # ===== SWAP SUBVOLUME =====

                  # Swap file subvolume
                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = [
                      "nodatacow"        # Required for swap
                      "compress=no"      # No compression for swap
                      "noatime"
                    ];
                    swap.swapfile.size = "8G"; # 8GB swap (matches current zram)
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