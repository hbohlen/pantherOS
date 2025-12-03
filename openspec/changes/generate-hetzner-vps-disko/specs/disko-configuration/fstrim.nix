{
  lib,
  pkgs,
  ...
}: {
  # fstrim service for Hetzner VPS
  # Optimizes SSD performance on virtio_scsi with discard=async

  services.fstrim = {
    enable = true;
    # Run weekly fstrim (optimized for VPS environment)
    interval = "weekly";
  };

  # Manual fstrim script for all subvolumes
  environment.etc."fstrim-all.sh" = {
    text = ''
      #!/bin/sh
      # Manual fstrim script for all BTRFS subvolumes
      set -e

      echo "Running fstrim on all BTRFS subvolumes..."
      fstrim -v /
      fstrim -v /home
      fstrim -v /nix
      fstrim -v /var
      fstrim -v /var/cache
      fstrim -v /var/log
      fstrim -v /var/tmp
      fstrim -v /persist
      fstrim -v /var/lib/postgresql
      echo "fstrim completed successfully"
    '';
    mode = "755";
  };

  # Systemd service for manual fstrim of all filesystems
  systemd.services.fstrim-all = {
    description = "Manual fstrim for all BTRFS filesystems";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/etc/fstrim-all.sh";
    };
    wantedBy = ["multi-user.target"];
  };

  # Enable as alias
  home-manager.users.hbohlen.home.file."bin/fstrim-all".text = "${pkgs.util-linux}/bin/fstrim"; # Placeholder
}
