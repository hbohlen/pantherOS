# hosts/yoga/disko.nix
# Disk partitioning configuration for Yoga laptop
# TODO: Customize based on actual disk layout and requirements
# This is a template - modify device paths and partitioning as needed

{
  disko.devices = {
    disk = {
      main = {
        # Placeholder device for configuration testing
        # TODO: Replace with actual disk device path from `ls /dev/disk/by-id/`
        device = "/dev/disk/by-id/placeholder-device";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # ESP - UEFI Boot Partition
            ESP = {
              size = "512M";
              type = "EF00"; # UEFI partition type
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077" # Secure boot partition
                ];
              };
            };

            # Root - Btrfs with subvolumes
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" "-L" "nixos-yoga" ];

                subvolumes = {
                  # Root filesystem
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # Nix store
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd:1"
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # Home directory
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };

                  # Swap (if needed)
                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = [
                      "nodatacow"
                      "compress=no"
                      "noatime"
                    ];
                    swap.swapfile.size = "8G"; # 8GB swap for laptop
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