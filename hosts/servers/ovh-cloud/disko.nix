{ config, lib, ... }:

# Disko configuration for OVH Cloud VPS
# Secondary server for redundancy
# Similar to hetzner-vps but adapted for OVH infrastructure

{
  disko.devices = {
    disk = {
      "vda" = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition
            bios-boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            
            # ESP (1GB)
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
              priority = 2;
            };
            
            # Swap (8GB) - Smaller for secondary server
            swap = {
              size = "8G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
              };
              priority = 3;
            };
            
            # Btrfs root with impermanence
            root = {
              size = "100%";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = [
                  # Permanent subvolumes
                  {
                    name = "nix";
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  }
                  
                  {
                    name = "persist";
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd:3" "noatime" ];
                  }
                  
                  {
                    name = "log";
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd:3" "noatime" ];
                  }
                  
                  {
                    name = "services";
                    mountpoint = "/var/lib/services";
                    mountOptions = [ "compress=zstd:2" "noatime" ];
                  }
                  
                  # Ephemeral root
                  {
                    name = "root";
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd:3" "noatime" ];
                  }
                  
                  # Snapshots
                  {
                    name = "snapshots";
                    mountpoint = "/.snapshots";
                    mountOptions = [ "compress=zstd:3" "noatime" ];
                  }
                ];
              };
              priority = 4;
            };
          };
        };
      };
    };
  };
}
