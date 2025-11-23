{
  disko.devices = {
    disk = {
      # First NVMe drive - System
      "nvme0n1" = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition
            bios-boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            
            # ESP (EFI System Partition)
            esp = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
              priority = 2;
            };
            
            # Swap partition
            swap = {
              size = "32G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
              };
              priority = 3;
            };
            
            # Btrfs root partition
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
      
      # Second NVMe drive - Data/Games
      "nvme1n1" = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@data" = {
                    mountpoint = "/data";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@games" = {
                    mountpoint = "/games";
                    mountOptions = [ "compress=zstd" "noatime" ];
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
