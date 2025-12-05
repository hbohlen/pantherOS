# NixOS Configuration Snippets for Zephyrus Dual-Disk Setup
# Complementary configurations to support the complete disko.nix deployment
{
  config,
  pkgs,
  ...
}: {
  # === SSD MAINTENANCE: fstrim.timer ===
  # Optimized for dual NVMe SSD configuration
  services.fstrim = {
    enable = true;
    interval = "weekly";
    extraArgs = ["--verbose"];
  };

  systemd.timers.fstrim = {
    wantedBy = ["multi-user.target"];
    partOf = ["fstrim.service"];
  };

  # === PODMAN CONFIGURATION ===
  # Optimized for secondary disk container storage
  virtualisation.podman = {
    enable = true;
    storage = {
      driver = "overlay";
      runRoot = "/var/lib/containers/run";
      graphRoot = "/var/lib/containers/storage";
      dataRoot = "/var/lib/containers";
    };

    dockerCompat = true;
    enableNvidia = false;

    # Add additional arguments for development containers
    extraPackages = [pkgs.podman];
  };

  # === SNAPSHOT TOOLING INTEGRATION ===
  # Basic snapper configuration for system snapshots
  services.snapper = {
    enable = true;
    configs = {
      "root" = {
        description = "Root filesystem snapshots";
        SUBVOLUME = "/";
        cleanupPolicy = "number";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 10;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 0;
        TIMELINE_LIMIT_MONTHLY = 0;
        TIMELINE_LIMIT_YEARLY = 0;
        NUMBER_CLEANUP = true;
        NUMBER_LIMIT = 50;
        NUMBER_LIMIT_IMPORTANT = 10;
      };
      "home" = {
        description = "Home directory snapshots";
        SUBVOLUME = "/home";
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
        TIMELINE_LIMIT_HOURLY = 5;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 4;
        NUMBER_CLEANUP = true;
        NUMBER_LIMIT = 20;
        NUMBER_LIMIT_IMPORTANT = 5;
      };
    };
  };

  # Enable automatic snapshot creation
  systemd.timers.snapper-timeline = {
    wantedBy = ["multi-user.target"];
  };

  systemd.services.snapper-timeline = {
    wantedBy = ["multi-user.target"];
    partOf = ["snapper-timeline.timer"];
  };

  # === BTRFS MAINTENANCE ===
  # Periodic btrfs filesystem checks and balancing
  systemd.services.btrfs-maintenance = {
    description = "Btrfs filesystem maintenance";
    script = ''
      # Check filesystem consistency (non-destructive)
      btrfs check --check-data-csum /dev/nvme0n1p2 || true
      btrfs check --check-data-csum /dev/nvme1n1p1 || true

      # Balance data if needed (>10% unused)
      btrfs balance start --bg -dusage=10 /dev/nvme0n1p2 || true
      btrfs balance start --bg -dusage=10 /dev/nvme1n1p1 || true

      # Defragment active subvolumes
      btrfs filesystem defrag -r -v /home || true
      btrfs filesystem defrag -r -v /home/hbohlen/dev || true
      btrfs filesystem defrag -r -v /var/lib/containers || true
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  # Run maintenance weekly
  systemd.timers.btrfs-maintenance = {
    wantedBy = ["multi-user.target"];
    timerConfig = {
      OnCalendar = "Sun 03:00";
      Persistent = true;
    };
  };
}
