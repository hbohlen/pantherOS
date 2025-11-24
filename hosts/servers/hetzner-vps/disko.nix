{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/virtio-disk0";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
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
                    mountOptions = [
                      "nodatacow"
                      "compress=no"
                      "noatime"
                      "space_cache=v2"
                    ];
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

  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 4096;
    }
  ];

  system.activationScripts."05-prepare-swapfile" = {
    deps = [ "specialfs" ];
    text = ''
      if ! mountpoint -q /swap; then
        exit 0
      fi

      if command -v btrfs >/dev/null 2>&1; then
        btrfs property set -ts /swap compression none || true
      fi

      chattr +C /swap || true

      desired_size=$((4096 * 1024 * 1024))
      recreate=false

      if [ -f /swap/swapfile ]; then
        current_size=$(stat -c '%s' /swap/swapfile)

        if ! lsattr /swap/swapfile | grep -q ' C'; then
          recreate=true
        elif [ "$current_size" -ne "$desired_size" ]; then
          recreate=true
        fi
      else
        recreate=true
      fi

      if [ "$recreate" = true ]; then
        swapoff /swap/swapfile 2>/dev/null || true
        rm -f /swap/swapfile
        truncate -s 0 /swap/swapfile
        chattr +C /swap/swapfile || true

        if command -v btrfs >/dev/null 2>&1; then
          btrfs property set /swap/swapfile compression none || true
        fi

        truncate -s 4096M /swap/swapfile
        chmod 600 /swap/swapfile
        mkswap /swap/swapfile
      fi
    '';
  };
}
