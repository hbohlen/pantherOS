{
  disko.devices = {
    disk = {
      "sda" = {
        type = "disk";
        device = "/dev/sda";
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
              size = "100%";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  "hetzner-nixos"
                  "-O"
                  "block-group-tree"
                ];

                subvolumes = {
                  # ===== PERMANENT SUBVOLUMES =====
                  nix = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:1" ];
                  };

                  persist = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd:3" ];
                  };

                  log = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd:3" ];
                  };

                  services = {
                    mountpoint = "/var/lib/services";
                    mountOptions = [ "compress=zstd:2" ];
                  };

                  caddy = {
                    mountpoint = "/var/lib/caddy";
                    mountOptions = [ "compress=zstd:3" ];
                  };

                  backup = {
                    mountpoint = "/var/backup";
                    mountOptions = [ "compress=zstd:3" ];
                  };

                  containers = {
                    mountpoint = "/var/lib/containers";
                    mountOptions = [
                      "compress=zstd:1"
                      "nodatacow"
                    ];
                  };

                  # ===== EPHEMERAL SUBVOLUMES =====
                  root = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd:3" ];
                  };

                  cache = {
                    mountpoint = "/var/cache";
                    mountOptions = [ "compress=zstd:3" ];
                  };

                  tmp = {
                    mountpoint = "/var/tmp";
                    mountOptions = [
                      "compress=zstd:1"
                      "nodatacow"
                    ];
                  };

                  # ===== ARCHIVE SUBVOLUMES =====
                  snapshots = {
                    mountpoint = "/.snapshots";
                    mountOptions = [ "compress=zstd:3" ];
                  };

                  old_roots = {
                    mountpoint = "/btrfs_tmp/old_roots";
                    mountOptions = [ "compress=zstd:3" ];
                  };
                };
              };
              priority = 4;
            };
          };
        };
      };
    };
  };
}
