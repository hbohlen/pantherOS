{ config, lib, ... }:

# Disko configuration for Lenovo Yoga 7 2-in-1
# Mobile workstation with battery optimization focus
# Based on docs/architecture/disk-layouts.md

{
  disko.devices = {
    disk = {
      "nvme0n1" = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # ESP (1GB) - Multiple kernel support for mobility
            esp = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
              priority = 1;
            };
            
            # Swap (16GB) - Matches RAM for hibernation
            swap = {
              size = "16G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
              };
              priority = 2;
            };
            
            # Btrfs root (remaining space)
            root = {
              size = "100%";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = [
                  # Ephemeral system root
                  {
                    name = "root";
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd:3" "noatime" ];
                  }
                  
                  # Persistent home directory
                  {
                    name = "home";
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd:3" "noatime" ];
                  }
                  
                  # Nix store - fast access
                  {
                    name = "nix";
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  }
                  
                  # Persistent data
                  {
                    name = "persist";
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd:3" "noatime" ];
                  }
                  
                  # Logs
                  {
                    name = "log";
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd:3" "noatime" ];
                  }
                ];
              };
              priority = 3;
            };
          };
        };
      };
    };
  };
}
