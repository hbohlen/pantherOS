# hosts/servers/hetzner-vps/disko.nix
{
  disko.devices = {
    disk.main = {
      type = "disk";
      # Using stable by-id path - this is specific to your server
      # If you rebuild the server, you'll need to update this ID
      device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_107063565";
      content = {
        type = "gpt";
        partitions = {
          # EFI System Partition - 512MB is standard
          ESP = {
            priority = 1;
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          # Root partition with btrfs - uses remaining space
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" "-L" "nixos" ];
              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "space_cache=v2"
                  ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "space_cache=v2"
                  ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                    "space_cache=v2"
                  ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [
                    "compress=zstd:3"
                    "noatime"
                    "space_cache=v2"
                  ];
                };
                "@swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = "4G";
                };
                "@containers" = {
                  mountpoint = "/var/lib/containers";
                  mountOptions = [
                    "nodatacow"
                    "noatime"
                    "space_cache=v2"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
