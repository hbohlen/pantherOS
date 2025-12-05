# hosts/servers/ovh-vps/default.nix
# Optimized configuration for OVH VPS
# Supports: Programming, Containers, AI tools
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../../../modules
  ];

  # Hostname
  networking.hostName = "ovh-vps";

  # Bootloader - GRUB with BIOS support (OVH VPS uses BIOS, not UEFI)
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # BIOS boot to disk
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
  # OVH VPS uses ens3 interface
  networking.useDHCP = false; # Disable to avoid conflict with systemd.network
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "ens3";
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
        services = ["tailscaled"];
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
    allowedTCPPorts = [22];
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  # User configuration
  users.users.root = {
    # OpNix writes to /root/.ssh/authorized_keys
  };

  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [
      "wheel" # sudo access
      "podman" # container management
      "docker" # docker CLI compat
    ];
    # OpNix writes to /home/hbohlen/.ssh/authorized_keys
  };

  # Ensure directories exist for subvolume mounts
  system.activationScripts.createSubvolumeDirs = {
    text = ''
      # Create user subvolume mount points with correct ownership
      mkdir -p /home/hbohlen/{dev,.config,.local,.cache,.ai-tools}
      chown -R hbohlen:users /home/hbohlen/{dev,.config,.local,.cache,.ai-tools}
      chmod 755 /home/hbohlen/{dev,.config,.local,.cache,.ai-tools}

      # Create AI tools structure
      mkdir -p /home/hbohlen/.ai-tools/claude-code
      chown -R hbohlen:users /home/hbohlen/.ai-tools

      # Ensure .ssh exists with correct permissions
      mkdir -p /root/.ssh /home/hbohlen/.ssh
      chmod 700 /root/.ssh /home/hbohlen/.ssh
      chown root:root /root/.ssh
      chown hbohlen:users /home/hbohlen/.ssh

      # Create cache subdirectories for language tools
      mkdir -p /home/hbohlen/.cache/{npm,cargo,rustup,go,go-build,pip}
      chown -R hbohlen:users /home/hbohlen/.cache

      # Create local directories
      mkdir -p /home/hbohlen/.local/{bin,share,state}
      chown -R hbohlen:users /home/hbohlen/.local
    '';
    deps = ["users"];
  };

  # Sudo configuration - passwordless for wheel group
  security.sudo.wheelNeedsPassword = false;

  # SSH configuration - hardened
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
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

  # Environment variables for XDG base directories and dev tools
  environment.sessionVariables = {
    # XDG Base Directory specification
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # Language-specific cache locations (use ~/.cache subvolume)
    NPM_CONFIG_CACHE = "$HOME/.cache/npm";
    CARGO_HOME = "$HOME/.cache/cargo";
    RUSTUP_HOME = "$HOME/.cache/rustup";
    GOPATH = "$HOME/.cache/go";
    GOCACHE = "$HOME/.cache/go-build";
    PIP_CACHE_DIR = "$HOME/.cache/pip";

    # Development directory
    PROJECTS_DIR = "$HOME/dev";

    # Editor
    EDITOR = lib.mkForce "vim";
    VISUAL = lib.mkForce "vim";
  };

  # System packages - core utilities and development tools
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    git
    curl
    wget
    htop
    btop # Better top
    tmux
    screen
    ripgrep # Fast grep
    fd # Fast find
    jq # JSON processor

    # Network tools
    tailscale
    _1password-cli

    # Development tools
    gcc
    gnumake
    pkg-config

    # Container tools
    podman-compose
    buildah # Container image builder
    skopeo # Container image tool

    # Btrfs tools
    btrfs-progs
    compsize # Check compression ratios

    # System monitoring
    iotop
    ncdu # Disk usage analyzer
    duf # Modern df
  ];

  # Development environments (optional - can be per-project with flakes)
  # Note: It's recommended to use project-specific development environments via Nix flakes
  # rather than installing languages system-wide. This keeps the system clean and allows
  # per-project version control. Uncomment the languages below only if you need them
  # available globally for quick scripting or system administration tasks.
  # environment.systemPackages = with pkgs; [
  #   # Python
  #   # python3
  #   # python3Packages.pip
  #   # python3Packages.virtualenv
  #
  #   # Node.js
  #   # nodejs_20
  #   # nodePackages.npm
  #   # nodePackages.pnpm
  #
  #   # Rust
  #   # rustc
  #   # cargo
  #   # rustfmt
  #   # clippy
  #
  #   # Go
  #   # go
  # ];

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Optimize nix store
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
  };

  # Automatic btrfs snapshots (optional but recommended)
  # Note: Enable this to automatically create daily snapshots of important subvolumes.
  # This provides a simple recovery mechanism for accidental deletions or system issues.
  # Snapshots are stored locally on the same filesystem, so this is NOT a backup solution.
  # For true backups, use btrbk with remote targets or a separate backup tool.
  # services.btrbk = {
  #   enable = true;
  #   instances.daily = {
  #     onCalendar = "daily";
  #     settings = {
  #       snapshot_preserve = "14d";     # Keep 14 days
  #       snapshot_preserve_min = "3d";  # Minimum 3 days
  #
  #       volume."/" = {
  #         subvolume = {
  #           "@dev" = {
  #             snapshot_dir = ".snapshots-dev";
  #           };
  #           "@config" = {
  #             snapshot_dir = ".snapshots-config";
  #           };
  #           "@home" = {
  #             snapshot_dir = ".snapshots-home";
  #           };
  #         };
  #       };
  #     };
  #   };
  # };

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
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  # State version - DO NOT CHANGE after installation
  system.stateVersion = "25.05";
}
