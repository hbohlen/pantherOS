# disko.nix - Complete Zephyrus dual-disk configuration
# ASUS ROG Zephyrus G15 with dual NVMe SSDs (Crucial 2TB + Micron 1TB)
# Optimized for heavy development workloads: Zed IDE, Podman, Ghostty, Fish, Niri
{
  disko.devices = {
    disk = {
      # Primary Disk: Crucial P3 2TB (CT2000P310SSD8)
      # Used for: System root, user home, and active development projects
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f" "-L" "ZEPHYRUS_ROOT"];
                subvolumes = {
                  # Root filesystem - essential for system operation
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                      "defaults"
                    ];
                  };
                  # User home directory and configuration
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                      "defaults"
                    ];
                  };
                  # Active development projects directory
                  "@dev-projects" = {
                    mountpoint = "/home/hbohlen/dev";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                      "ssd"
                      "defaults"
                    ];
                  };
                  # Nix store - separate for atomic updates and rollback
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "nodatacow" # Disable copy-on-write for Nix store performance
                      "defaults"
                    ];
                  };
                  # System variables and logs
                  "@var" = {
                    mountpoint = "/var";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                      "defaults"
                    ];
                  };
                };
              };
            };
          };
        };
      };

      # Secondary Disk: Micron 2450 1TB (Micron_2450_MTFDKBA1T0TFK)
      # Used for: Container storage, caches, and backup data
      nvme1n1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f" "-L" "ZEPHYRUS_STORAGE"];
                subvolumes = {
                  # Podman container storage - high I/O workload
                  "@containers" = {
                    mountpoint = "/var/lib/containers";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                      "ssd"
                      "space_cache=v2"
                      "defaults"
                    ];
                  };
                  # System cache directories
                  "@cache" = {
                    mountpoint = "/var/cache";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                      "defaults"
                    ];
                  };
                  # Podman image cache - separate management
                  "@podman-cache" = {
                    mountpoint = "/var/cache/podman";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                      "defaults"
                    ];
                  };
                  # System snapshots and backup data
                  "@snapshots" = {
                    mountpoint = "/var/lib/snapper";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                      "defaults"
                    ];
                  };
                  # Temporary data and build artifacts
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "no_exec"
                      "defaults"
                    ];
                  };
                  # User cache directories
                  "@user-cache" = {
                    mountpoint = "/home/hbohlen/.cache";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                      "autodefrag"
                      "defaults"
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
}
