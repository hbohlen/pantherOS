{ lib, ... }:

{
  disko.devices = {
    disk = {
      # SYSTEM_DISK: Single 200 GiB disk (QEMU HARDDISK)
      main = {
        device = lib.mkDefault "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "100M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = [ "umask=0077" ];
                mountpoint = "/boot/efi";
              };
            };
            boot = {
              size = "1G";
              type = "8300";
              content = {
                type = "filesystem";
                format = "ext4";
                mountOptions = [ "noatime" ];
                mountpoint = "/boot";
              };
            };
            btrfs-system = {
              size = "100%";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];  # Force mkfs.btrfs
                # Btrfs subvolumes will be mounted by NixOS
                # VM optimization: Use 'ssd' instead of 'ssd_spread' for virtual disks
                mountOptions = [
                  "noatime"
                  "space_cache=v2"
                  # Removed autodefrag for VM (hypervisor handles fragmentation)
                ];
                subvolumes = {
                  root = {
                    mountpoint = "/";
                    mountOptions = [ "subvol=root" ];
                  };
                  home = {
                    mountpoint = "/home";
                    mountOptions = [ "subvol=home" ];
                  };
                  var = {
                    mountpoint = "/var";
                    mountOptions = [ "subvol=var" ];
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
