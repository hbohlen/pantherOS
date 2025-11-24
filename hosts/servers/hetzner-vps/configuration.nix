# hosts/servers/hetzner-vps/configuration.nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware.nix
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
      # Reference: op://pantherOS/tailscale/authKey
      tailscaleAuthKey = {
        reference = "op://pantherOS/tailscale/authKey";
        path = "/etc/tailscale/auth-key";
        owner = "root";
        group = "root";
        mode = "0600";
        services = [ "tailscaled" ];
      };

      # SSH public key for root user from your pantherOS vault
      # Reference: op://pantherOS/SSH/"public key"
      rootSshKeys = {
        reference = "op://pantherOS/SSH/public key";
        path = "/root/.ssh/authorized_keys_opnix";
        owner = "root";
        group = "root";
        mode = "0600";
      };

      # SSH public key for hbohlen user from your pantherOS vault
      # Reference: op://pantherOS/SSH/"public key"
      userSshKeys = {
        reference = "op://pantherOS/SSH/public key";
        path = "/home/hbohlen/.ssh/authorized_keys_opnix";
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
    # Allow Tailscale traffic
    trustedInterfaces = [ "tailscale0" ];
    # Allow Tailscale UDP port
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # User configuration
  # SSH keys are now managed by OpNix from 1Password
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      config.services.onepassword-secrets.secretPaths.rootSshKeys
    ];
  };

  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keyFiles = [
      config.services.onepassword-secrets.secretPaths.userSshKeys
    ];
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

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    tmux
    tailscale  # Tailscale CLI
    _1password # 1Password CLI
  ];

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # State version
  system.stateVersion = "25.05";
}
