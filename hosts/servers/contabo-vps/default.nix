# hosts/servers/contabo-vps/default.nix
# Optimized configuration for Contabo Cloud VPS
# Supports: Programming (Python, Node, Rust, Go), Containers, AI tools
#
# NOTE: Network interface name will be updated after running setup script
# Likely ens* or enp*s* - will be detected in facter.json

{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../../modules
  ];

  # Hostname
  networking.hostName = "contabo-vps";

  # Bootloader - GRUB with BIOS support (Contabo likely uses BIOS like OVH)
  # Will be adjusted to UEFI if needed based on facter output
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # Will be updated after facter
    efiSupport = false;  # Change to true if UEFI detected
    extraConfig = ''
      serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
      terminal_input serial console
      terminal_output serial console
    '';
  };

  # Locale and timezone
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Network configuration with systemd-networkd
  # Network interface will be detected after running setup script
  # Likely eth0, ens3, enp1s0, or similar
  networking.useDHCP = false; # Disable to avoid conflict with systemd.network
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "eth0"; # PLACEHOLDER: Update with actual interface from facter
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true;
    };
    linkConfig.RequiredForOnline = "routable";
  };

  # 1Password OpNix - Secret Management
  # Using your pantherOS vault
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    secrets = {
      # Tailscale authentication key from your pantherOS vault
      tailscaleAuthKey = {
        reference = "op://pantherOS/tailscale/authKey";
        path = "/etc/tailscale/auth-key";
        owner = "root";
        group = "root";
        mode = "0600";
        services = [ "tailscaled" ];
      };

      # SSH public key for root user
      rootSshKeys = {
        reference = "op://pantherOS/SSH/public key";
        path = "/root/.ssh/authorized_keys";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      # SSH public key for hbohlen user
      userSshKeys = {
        reference = "op://pantherOS/SSH/public key";
        path = "/home/hbohlen/.ssh/authorized_keys";
        owner = "hbohlen";
        group = "users";
        mode = "0600";
      };
    };
  };

  # Tailscale VPN - using OpNix-managed auth key
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    authKeyFile = config.services.onepassword-secrets.secretPaths.tailscaleAuthKey;
  };

  # Firewall - allow Tailscale and SSH
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # SSH configuration - hardened
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Home Manager - User environment management
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".hm-bak";
    users.hbohlen = {
      # Basic home configuration
      home = {
        username = "hbohlen";
        homeDirectory = "/home/hbohlen";
        stateVersion = "25.05";
      };

      # Enable XDG base directory specification
      xdg.enable = true;

      # OpenCode.ai configuration using xdg.configFile
      xdg.configFile."opencode" = {
        source = ../../../home/hbohlen/opencode;
        recursive = true;
      };

      # Additional packages not covered by terminal-tools module
      home.packages = with pkgs; [
        # AI coding assistant
        opencode
      ];

      # Basic home-manager configuration
      programs = {
        home-manager.enable = true;
      };
    };
  };

  # Podman - Container runtime
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Docker CLI compatibility
    defaultNetwork.settings.dns_enabled = true;

    # Podman uses /var/lib/containers which is on @containers subvolume
    # with nodatacow for optimal performance
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Optimize nix store
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Kernel parameters for development server performance
  boot.kernel.sysctl = {
    # Memory and swappiness optimization
    "vm.swappiness" = 10; # Prefer RAM over swap
    "vm.dirty_ratio" = 5; # Aggressive writeback for containers
    "vm.dirty_background_ratio" = 2;

    # TCP optimization for development workloads
    "net.ipv4.tcp_tw_reuse" = 1;

    # Container-friendly networking settings
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "net.ipv4.ip_forward" = 1;

    # Increase file descriptors for containers and builds
    "fs.file-max" = 2097152;
    "fs.inotify.max_user_watches" = 524288;
  };

  # System limits for development workloads
  security.pam.loginLimits = [
    { domain = "*"; item = "nofile"; type = "-"; value = "262144"; }
    { domain = "*"; item = "nproc"; type = "-"; value = "262144"; }
  ];

  # Optimize journald for performance and retention
  services.journald = {
    extraConfig = ''
      Storage=persistent
      SystemMaxUse=500M
      RuntimeMaxUse=100M
      MaxRetentionSec=30day
      Compress=yes
    '';
  };

  # Periodic cache cleanup service
  systemd.services.clean-old-caches = {
    description = "Clean old cache files";
    script = ''
      # Clean caches older than 30 days
      ${pkgs.fd}/bin/fd -t f -d 3 --changed-before 30d . /home/hbohlen/.cache --exec rm -f {} \; || true

      # Clean old logs
      ${pkgs.systemd}/bin/journalctl --vacuum-time=30d
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.clean-old-caches = {
    description = "Clean old cache files weekly";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  # Periodic btrfs filesystem maintenance
  systemd.services.btrfs-maintenance = {
    description = "Btrfs filesystem maintenance";
    script = ''
      # Enable autodefrag on development subvolumes (non-aggressive)
      ${pkgs.btrfs-progs}/bin/btrfs property set -ts / autodefrag on || true

      # Run balance on root filesystem (non-blocking, only data/metadata)
      ${pkgs.btrfs-progs}/bin/btrfs balance start -d -m / || true
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.btrfs-maintenance = {
    description = "Btrfs filesystem maintenance timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
      RandomizedDelaySec = "1h"; # Spread load if multiple systems
    };
  };

  # State version - DO NOT CHANGE after installation
  system.stateVersion = "25.05";
}
