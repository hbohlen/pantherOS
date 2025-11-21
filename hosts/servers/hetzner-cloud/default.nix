# hosts/servers/hetzner-cloud/default.nix
#
# Minimal NixOS configuration for Hetzner Cloud VPS
# Purpose: Personal development server with AI coding tools
# Access: Tailscale-only (no public SSH)
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Disk configuration
    ./disko.nix

    # Hardware configuration (generate with nixos-generate-config)
    ./hardware.nix

    # OpNix for 1Password secrets management
    inputs.opnix.nixosModules.default
  ];

  # ============================================
  # SYSTEM IDENTITY
  # ============================================
  networking.hostName = "hetzner-vps";

  # ============================================
  # BOOT CONFIGURATION
  # ============================================
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    efiSupport = true;
    efiInstallAsRemovable = true;  # Hetzner compatibility
  };

  # Placeholder - update after installation
  system.stateVersion = "24.05";

  # ============================================
  # TAILSCALE NETWORKING
  # ============================================
  # Why Tailscale SSH instead of regular SSH:
  # 1. Zero-config - no port forwarding, no dynamic DNS
  # 2. Identity-based auth - Tailscale handles authentication
  # 3. End-to-end encrypted - even Tailscale can't see traffic
  # 4. No public IP exposure - only reachable via Tailnet
  # 5. MagicDNS - access via hetzner-vps.tailnet-name.ts.net

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";  # Allow as exit node if needed

    # Use auth key from 1Password for automated authentication
    # Key stored at: op://pantherOS/tailscale/authKey
    authKeyFile = config.age.secrets.tailscale-auth-key.path;

    # Enable Tailscale SSH - replaces OpenSSH for remote access
    # Auth is handled by Tailscale identity, not SSH keys
    extraUpFlags = [
      "--ssh"
      "--accept-dns=false"  # Keep local DNS resolution
    ];
  };

  # ============================================
  # OPENSSH CONFIGURATION
  # ============================================
  # OpenSSH is still installed for:
  # 1. Emergency local access (Hetzner console)
  # 2. Git operations (git@github.com)
  # 3. Fallback if Tailscale is down
  #
  # IMPORTANT: Firewall restricts SSH to Tailnet only

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      KbdInteractiveAuthentication = false;
    };
    # Only listen on Tailscale interface
    listenAddresses = [
      { addr = "100.64.0.0/10"; port = 22; }  # Tailscale CGNAT range
    ];
  };

  # ============================================
  # FIREWALL CONFIGURATION
  # ============================================
  # Why this structure:
  # 1. Default deny - only explicitly allowed ports open
  # 2. Tailscale interface trusted - all Tailnet traffic allowed
  # 3. Public interface restricted - only Tailscale handshake
  #
  # Result: Server is invisible on public internet but fully
  # accessible to authenticated Tailnet members

  networking.firewall = {
    enable = true;

    # Public interface: Only allow Tailscale to establish connection
    allowedUDPPorts = [ 41641 ];  # Tailscale WireGuard port

    # Trust the Tailscale interface completely
    trustedInterfaces = [ "tailscale0" ];

    # No TCP ports on public interface
    allowedTCPPorts = [ ];

    # Enable connection tracking for stateful firewall
    checkReversePath = "loose";  # Required for Tailscale
  };

  # ============================================
  # USER CONFIGURATION
  # ============================================
  # Minimal user setup for server administration
  # Authentication via Tailscale SSH (no password needed)

  users.users.hbohlen = {
    isNormalUser = true;
    description = "Henning Bohlen";
    extraGroups = [
      "wheel"       # sudo access
      "docker"      # container management (if using Docker)
      "podman"      # container management (if using Podman)
    ];

    # No password - auth via Tailscale SSH identity
    # For emergency access, use Hetzner console with root
    hashedPassword = null;

    # Default shell
    shell = pkgs.fish;

    # SSH public keys from 1Password (fallback access)
    # Primary access: Tailscale SSH
    # Fallback: 1Password SSH agent + these keys
    openssh.authorizedKeys.keys = [
      # SSH keys managed via OpNix from 1Password vault
      # op://pantherOS/yogaSSH/public key
      # op://pantherOS/zephyrusSSH/public key
      # op://pantherOS/desktopSSH/public key
      # op://pantherOS/phoneSSH/public key
      # These will be injected by OpNix during build
    ];
  };

  # Allow wheel group to sudo without password
  # Safe because auth is via Tailscale identity
  security.sudo.wheelNeedsPassword = false;
}
