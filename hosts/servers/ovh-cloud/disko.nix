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
          partitions = [
            {
              name = "ESP";
              size = "100M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = [ "umask=0077" ];
                mountpoint = "/boot/efi";
              };
            }
            {
              name = "boot";
              size = "1G";
              type = "8300";
              content = {
                type = "filesystem";
                format = "ext4";
                mountOptions = [ "noatime" ];
                mountpoint = "/boot";
              };
            }
            {
              name = "btrfs-system";
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
                subvolumes = [
                  {
                    name = "root";
                    mountpoint = "/";
                    mountOptions = [ "subvol=root" ];
                  }
                  {
                    name = "home";
                    mountpoint = "/home";
                    mountOptions = [ "subvol=home" ];
                  }
                  {
                    name = "var";
                    mountpoint = "/var";
                    mountOptions = [ "subvol=var" ];
                  }
                ];
              };
            }
          ];
        };
      };
    };
  };
}
