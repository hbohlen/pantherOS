{ config, lib, ... }:

# Disko configuration for ASUS ROG Zephyrus M16
# Performance workstation for heavy development workflows
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
            # ESP (2GB) - Larger for dual-boot scenarios
            esp = {
              size = "2G";
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
            
            # Swap (32GB) - Sized to match typical RAM for hibernation capability
            # NOTE: Adjust this size based on actual RAM when deploying.
            # For hibernation support, swap should be >= RAM size.
            # Run 'free -h' on the target system to determine correct size.
            swap = {
              size = "32G";
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
                    mountOptions = [ "compress=zstd:2" "noatime" ];
                  }
                  
                  # Development directory with less compression
                  {
                    name = "dev";
                    mountpoint = "/home/dev";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  }
                  
                  # Nix store - performance optimized
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
                  
                  # Container storage
                  {
                    name = "containers";
                    mountpoint = "/var/lib/containers";
                    mountOptions = [ "compress=zstd:1" "noatime" "nodatacow" ];
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
