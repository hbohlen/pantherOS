# hosts/servers/hetzner-vps/default.nix
# Optimized configuration for development server
# Supports: Programming (Python, Node, Rust, Go), Containers, AI tools
{ config, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ../../../modules
  ];

  # Hostname
  networking.hostName = "hetzner-vps";

  # Bootloader - GRUB with UEFI support
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
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
  # Your Hetzner server uses eth0
  networking.useDHCP = false; # Disable to avoid conflict with systemd.network
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "eth0";
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

      # Disable version mismatch warning
      nixpkgs.config.allowUnfree = true;
      home.enableNixpkgsReleaseCheck = false;

      # Enable XDG base directory specification
      xdg.enable = true;

      # OpenCode.ai configuration using xdg.configFile
      # This links the opencode directory to ~/.config/opencode
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

  # Development environments (optional - can be per-project with flakes)
  # Uncomment the languages you want available system-wide
  # environment.systemPackages = with pkgs; [
  #   # Python
  #   python3
  #   python3Packages.pip
  #   python3Packages.virtualenv
  #
  #   # Node.js
  #   nodejs_20
  #   nodePackages.npm
  #   nodePackages.pnpm
  #
  #   # Rust
  #   rustc
  #   cargo
  #   rustfmt
  #   clippy
  #
  #   # Go
  #   go
  #
  #   # LSP servers
  #   nodePackages.typescript-language-server
  #   python3Packages.python-lsp-server
  #   rust-analyzer
  #   gopls
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
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Automatic btrfs snapshots (optional but recommended)
  # Uncomment to enable
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
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  # State version - DO NOT CHANGE after installation
  system.stateVersion = "25.05";
}
