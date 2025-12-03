{lib, ...}: {
  # Disko configuration for Hetzner VPS
  # Hardware: Single 458GB virtio_scsi disk in KVM environment
  # Strategy: BTRFS with subvolumes for optimal snapshot/backup management

  disko.devices = {
    disk = {
      vda = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["defaults"];
              };
            };
            btrfs = {
              size = "100%";
              type = "8300";
              content = {
                type = "btrfs";
                # BTRFS subvolume layout optimized for production VPS
                subvolumes = {
                  # Root filesystem
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=@root"
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  # User data (separate for backup granularity)
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=@home"
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  # Nix store (separate for atomic updates)
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=@nix"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  # System variables
                  "@var" = {
                    mountpoint = "/var";
                    mountOptions = [
                      "subvol=@var"
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  # Application caches
                  "@cache" = {
                    mountpoint = "/var/cache";
                    mountOptions = [
                      "subvol=@cache"
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  # Log files
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "subvol=@log"
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  # Temporary files
                  "@tmp" = {
                    mountpoint = "/var/tmp";
                    mountOptions = [
                      "subvol=@tmp"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  # Persistent configuration (backups)
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "subvol=@persist"
                      "compress=zstd"
                      "noatime"
                      "discard=async"
                    ];
                  };
                  # PostgreSQL database (CRITICAL: nodatacow for performance)
                  "@postgresql" = {
                    mountpoint = "/var/lib/postgresql";
                    mountOptions = [
                      "subvol=@postgresql"
                      "nodatacow"
                      "noatime"
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

  # Environment-specific configuration notes:
  # - virtio_scsi: discard=async for optimal SSD TRIM support
  # - KVM: compression reduces I/O pressure on limited memory (3.6GB)
  # - nodatacow on PostgreSQL: Critical for database performance
  # - Single disk strategy: No RAID (KVM limitation), use BTRFS snapshots instead
}
