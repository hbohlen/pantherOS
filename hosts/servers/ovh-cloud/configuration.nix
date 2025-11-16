{ config, pkgs, ... }:

{
  imports = [
    ./disko.nix
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    "${builtins.fetchGit {
      url = "https://github.com/numtide/nix-ai-tools";
      ref = "master";
    }}/nixos/claude.nix"
    opnix.nixosModule
  ];

  # Btrfs filesystem configuration with optimized subvolumes
  # Enable Btrfs support
  boot.supportedFilesystems = [ "btrfs" ];

  # File system definitions with Btrfs subvolumes
  # Single disk setup: /dev/sda (200 GiB) with Btrfs partition
  fileSystems = let
    # Btrfs partition created by disko.nix (3rd partition on /dev/sda)
    btrfsDev = "/dev/sda3";
  in {
    # Root subvolume - using the "root" subvolume created by disko
    "/" = {
      device = btrfsDev;
      fsType = "btrfs";
      options = [
        "subvol=root"
        "compress=zstd:2"
        "noatime"
        "space_cache=v2"
        "ssd"
      ];
    };

    # Boot partition - single disk setup (2nd partition on /dev/sda)
    "/boot" = {
      device = "/dev/sda2";
      fsType = "ext4";
    };

    # EFI System Partition - single disk (1st partition on /dev/sda)
    "/boot/efi" = {
      device = "/dev/sda1";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    # Home directory - using the "home" subvolume created by disko
    "/home" = {
      device = btrfsDev;
      fsType = "btrfs";
      options = [
        "subvol=home"
        "compress=zstd:2"
        "noatime"
        "space_cache=v2"
      ];
    };

    # System tmp - tmpfs (in-memory for speed)
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "size=16G" "noatime" "mode=1777" ];
    };
  };

  # Boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;
  boot.kernelParams = [ "console=ttyS0" ];

  # Network configuration
  networking.hostName = "ovh-cloud";
  networking.useDHCP = true;
  networking.firewall.enable = true;

  # OpNix configuration (1Password integration)
  opnix = {
    enable = true;
    vault = "pantherOS";  # Change to your 1Password vault name
    1password = {
      enabled = true;
      # Will use default 1Password CLI configuration
    };
  };

  # Enable SSH with key-only authentication
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    challengeResponseAuthentication = false;
  };

  # SSH keys from 1Password (via OpNix)
  users.users.root.openssh.authorizedKeys.keys = with config.opnix.secrets; [
    (op.read "op://pantherOS/yogaSSH/public key")
    (op.read "op://pantherOS/zephyrusSSH/public key")
    (op.read "op://pantherOS/phoneSSH/public key")
    (op.read "op://pantherOS/desktopSSH/public key")
  ];

  # Admin user
  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = with config.opnix.secrets; [
      (op.read "op://pantherOS/yogaSSH/public key")
      (op.read "op://pantherOS/zephyrusSSH/public key")
      (op.read "op://pantherOS/phoneSSH/public key")
      (op.read "op://pantherOS/phoneSSH/public key")
      (op.read "op://pantherOS/desktopSSH/public key")
    ];
  };

  # Enable sudo for wheel group
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Timezone and locale
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Basic system packages (system-level tools only)
  environment.systemPackages = with pkgs; [
    htop
    unzip
    zip
    openssh
    # Dev tools (system-level build tools)
    gcc
    make
    pkg-config
  ];

  # Enable Nix features
  # Optimize Nix for virtualized development environment
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;

    # Build optimizations
    cores = 8;                        # Match vCPU count
    max-jobs = 4;                     # Parallel builds (avoid over-subscription)
    reserved-build-cores = 2;         # Keep 2 cores for system

    # I/O optimizations for VM
    fsync = false;                    # Faster builds in VM (lower durability)
    use-sqlite-wal = false;           # Better for virtualized filesystems

    # Development-specific settings
    builders-use-substitutes = true;  # Use binary cache when available
  };

  # Podman container runtime with btrfs storage for optimal VM performance
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    extraPackages = [
      pkgs.podman-tui  # Optional: TUI for Podman
    ];

    # Btrfs storage driver - native performance in virtualized environment
    storage = {
      driver = "btrfs";
      runRoot = "/var/lib/containers/storage-run";
      graphRoot = "/var/lib/containers/storage";
      # Btrfs-specific mount options for container workloads
      extraOptions = [
        # Use balanced compression for containers
        "btrfs.mount_options=compress=zstd:2,noatime"
      ];
    };

    # Network configuration for containers
    defaultNetwork.settings = {
      dns = {
        enabled = true;
      };
    };
  };

  # Allow Podman to manage containers as regular user
  users.users.hbohlen.extraGroups = [ "wheel" "networkmanager" "podman" ];

  # Ensure fuse-overlayfs is available for non-root users
  systemd.user.services.podman-auto-update = {
    description = "Podman auto-update service";
    serviceConfig = {
      ExecStart = "${pkgs.podman}/bin/podman auto-update";
      Type = "oneshot";
    };
    wantedBy = [ "default.target" ];
  };

  # Tailscale configuration with auth key from OpNix
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    authKeyFile = config.opnix.secrets.opnix-1password."op://pantherOS/tailscale/authKey".path;
  };

  # Allow Tailscale through firewall
  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ 41641 ];
  };

  # Auto-connect Tailscale with systemd service
  systemd.services.tailscale-autoconnect = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscale up --auth-key=${config.opnix.secrets.opnix-1password."op://pantherOS/tailscale/authKey".path} --hostname=ovh-cloud";
      Type = "oneshot";
      RemainAfterExit = true;
    };
    enable = true;
  };

  # 1Password CLI is already included in the main systemPackages above

  # Claude Code configuration (via nix-ai-tools)
  services.claude = {
    enable = true;
    package = pkgs.claude;
  };

  # Set up development directory
  system.activationScripts.setupDevDirectory = {
    text = ''
      if [ ! -d /home/hbohlen/dev ]; then
        mkdir -p /home/hbohlen/dev
        chown hbohlen:hbohlen /home/hbohlen/dev
      fi
    '';
    deps = [ ];
  };

  # I/O Scheduler Optimization for Virtio Devices (OVH VPS / KVM/QEMU)
  # Set optimal I/O scheduler for virtualized environment
  systemd.services.optimize-virtio-io = {
    description = "Optimize I/O scheduler for virtio devices";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udevd.service" ];
    serviceConfig = {
      ExecStart = let
        # Find virtio devices and set 'mq-deadline' scheduler for optimal performance
        script = pkgs.writeScript "optimize-virtio-io" ''
          #!/bin/sh
          # Virtio devices in KVM/QEMU benefit from 'mq-deadline' scheduler
          # This provides better I/O performance than the default CFQ in VMs

          # Optimize virtio block devices (vd*)
          for dev in /sys/block/vd*; do
            if [ -d "$dev" ]; then
              devname=$(basename "$dev")
              # Set scheduler to 'mq-deadline' for virtio (best for virtualized storage)
              echo mq-deadline > "$dev/queue/scheduler" 2>/dev/null || true
              echo "Set I/O scheduler to mq-deadline for $devname"

              # Optimize read-ahead for mixed workloads
              echo 4096 > "$dev/queue/read_ahead_kb" 2>/dev/null || true

              # Enable request merging for better throughput
              echo 0 > "$dev/queue/nomerges" 2>/dev/null || true

              echo "Optimized $devname: scheduler=mq-deadline, read_ahead=4096"
            fi
          done

          # Also optimize any other block devices (fallback)
          for dev in /sys/block/sd*; do
            if [ -d "$dev" ]; then
              devname=$(basename "$dev")
              # Use mq-deadline for SATA and other devices in VMs
              echo mq-deadline > "$dev/queue/scheduler" 2>/dev/null || true
              echo "Set I/O scheduler to mq-deadline for $devname"
            fi
          done
        '';
      in "${script}";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # VM-Specific Optimizations for OVH VPS / KVM/QEMU
  # Enhance performance for development workloads in virtualized environment
  systemd.services.vm-optimizations = {
    description = "Apply VM-specific performance optimizations";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = let
        script = pkgs.writeScript "vm-optimizations" ''
          #!/bin/sh
          # Virtual memory optimizations for development workloads
          # With 23.4 GiB RAM, we can reduce swap usage significantly

          # Set swappiness to minimum - only use swap when absolutely necessary
          if [ -f /proc/sys/vm/swappiness ]; then
            echo 10 > /proc/sys/vm/swappiness 2>/dev/null || true
            echo "VM swappiness set to 10"
          fi

          # Optimize vfs cache pressure - keep more inodes/dentries in cache
          if [ -f /proc/sys/vm/vfs_cache_pressure ]; then
            echo 50 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null || true
            echo "VM vfs_cache_pressure set to 50"
          fi

          # Tune dirty page handling for better I/O behavior
          if [ -f /proc/sys/vm/dirty_ratio ]; then
            echo 15 > /proc/sys/vm/dirty_ratio 2>/dev/null || true
            echo "VM dirty_ratio set to 15"
          fi

          if [ -f /proc/sys/vm/dirty_background_ratio ]; then
            echo 5 > /proc/sys/vm/dirty_background_ratio 2>/dev/null || true
            echo "VM dirty_background_ratio set to 5"
          fi

          # Increase zram size for faster tmp operations
          # Current: 8 GiB, increasing to 16 GiB for development workloads
          if [ -b /dev/zram0 ]; then
            echo 16G > /sys/block/zram0/disksize 2>/dev/null || true
            echo "ZRAM size increased to 16 GiB"
          fi

          # Optimize readahead for development workloads
          for dev in /sys/block/sd* /sys/block/vd*; do
            if [ -d "$dev" ]; then
              devname=$(basename "$dev")
              # Set read-ahead to 4096 KB for mixed read/write workloads
              echo 4096 > "$dev/queue/read_ahead_kb" 2>/dev/null || true
            fi
          done

          echo "VM optimizations applied successfully"
        '';
      in "${script}";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Btrfs Maintenance - Enable auto-scrub for data integrity
  services.btrfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
      extraOptions = [ "--check" ];
    };
  };

  # Btrfs Quota Management
  # Enable quotas for better subvolume space management
  systemd.services.btrfs-quota-enable = {
    description = "Enable Btrfs quota on root";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = let
        script = pkgs.writeScript "btrfs-quota-enable" ''
          #!/bin/sh
          # Get the btrfs device
          btrfs device scan 2>/dev/null || true
          btrfs quota enable / 2>/dev/null || true
        '';
      in "${script}";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # System state version
  system.stateVersion = "25.05";

  # Optional: Enable automatic updates (uncomment if desired)
  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;
}
