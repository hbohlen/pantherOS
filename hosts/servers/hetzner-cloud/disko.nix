{ lib, ... }:

{
  disko.devices = {
    disk = {
      # Hetzner cloud typically uses /dev/sda for the main disk
      main = {
        device = lib.mkDefault "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = [ "umask=0077" ];
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
                # Cloud server optimization: Use 'ssd' for cloud storage
                mountOptions = [
                  "noatime"
                  "space_cache=v2"
                  "compress=zstd"
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