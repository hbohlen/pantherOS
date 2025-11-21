{
  disko.devices = {
    disk = {
      "sda" = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition for compatibility
            bios-boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            
            # ESP (1GB) - Single kernel, server focused
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
            
            # Swap (32GB) - Matches RAM for hibernation capability
            swap = {
              size = "32G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
              };
              priority = 3;
            };
            
            # Btrfs root with impermanence
            root = {
              size = "max";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                btrfsConfig = {
                  label = "hetzner-nixos";
                  features = [ "block-group-tree" ];
                };
                
                subvolumes = [
                  # ===== PERMANENT SUBVOLUMES =====
                  {
                    name = "nix";
                    mountpoint = "/nix";
                    compress = "zstd:1";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "persist";
                    mountpoint = "/persist";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "log";
                    mountpoint = "/var/log";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "services";
                    mountpoint = "/var/lib/services";
                    compress = "zstd:2";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "caddy";
                    mountpoint = "/var/lib/caddy";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "backup";
                    mountpoint = "/var/backup";
                    compress = "zstd:3";
                  }
                  
                  {
                    name = "containers";
                    mountpoint = "/var/lib/containers";
                    compress = "zstd:1";
                    mountOptions = [ "nodatacow" ];
                  }
                  
                  # ===== EPHEMERAL SUBVOLUMES =====
                  {
                    name = "root";
                    mountpoint = "/";
                    compress = "zstd:3";
                  }
                  
                  {
                    name = "cache";
                    mountpoint = "/var/cache";
                    compress = "zstd:3";
                  }
                  
                  {
                    name = "tmp";
                    mountpoint = "/var/tmp";
                    compress = "zstd:1";
                    mountOptions = [ "nodatacow" ];
                  }
                  
                  # ===== ARCHIVE SUBVOLUMES =====
                  {
                    name = "snapshots";
                    mountpoint = "/.snapshots";
                    compress = "zstd:3";
                  }
                  
                  {
                    name = "old_roots";
                    mountpoint = "/btrfs_tmp/old_roots";
                    compress = "zstd:3";
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