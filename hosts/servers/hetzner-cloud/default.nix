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
  };

  # Allow wheel group to sudo without password
  # Safe because auth is via Tailscale identity
  security.sudo.wheelNeedsPassword = false;

  # ============================================
  # 1PASSWORD CLI & OPNIX
  # ============================================
  # How they fit together:
  # 1. 1Password CLI (op) - Command-line interface to 1Password vaults
  # 2. OpNix - NixOS module that uses 'op' to inject secrets at build time
  #
  # Workflow:
  # 1. Store secrets in 1Password (API keys, tokens, etc.)
  # 2. Reference in Nix config: op://<vault>/<item>/<field>
  # 3. OpNix fetches and injects during nixos-rebuild
  #
  # Benefits:
  # - Secrets never in git
  # - Single source of truth
  # - Easy rotation
  # - Audit trail in 1Password

  # Install 1Password CLI
  # (Will be combined with AI tools below)

  # Enable OpNix - fetches secrets from 1Password during build
  # Requires OP_SERVICE_ACCOUNT_TOKEN environment variable
  # Service account: pantherOS
  # Vault: pantherOS
  services.opnix = {
    enable = true;
  };

  # Define secrets fetched from 1Password
  age.secrets = {
    # Tailscale authentication key
    # Used for automated Tailscale connection on boot
    tailscale-auth-key = {
      source = "op://pantherOS/tailscale/authKey";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  # SSH public keys from 1Password
  # These are injected into user's authorized_keys
  # Note: Field names with spaces must be quoted
  users.users.hbohlen.openssh.authorizedKeys.keys = [
    # Yoga workstation
    (builtins.readFile (pkgs.runCommand "yoga-ssh-key" {} ''
      ${pkgs._1password-cli}/bin/op read 'op://pantherOS/yogaSSH/"public key"' > $out
    ''))

    # Zephyrus workstation
    (builtins.readFile (pkgs.runCommand "zephyrus-ssh-key" {} ''
      ${pkgs._1password-cli}/bin/op read 'op://pantherOS/zephyrusSSH/"public key"' > $out
    ''))

    # Desktop
    (builtins.readFile (pkgs.runCommand "desktop-ssh-key" {} ''
      ${pkgs._1password-cli}/bin/op read 'op://pantherOS/desktopSSH/"public key"' > $out
    ''))

    # Phone
    (builtins.readFile (pkgs.runCommand "phone-ssh-key" {} ''
      ${pkgs._1password-cli}/bin/op read 'op://pantherOS/phoneSSH/"public key"' > $out
    ''))
  ];

  # ============================================
  # AI CODING TOOLS
  # ============================================
  # Installation strategy: System packages vs Home Manager
  #
  # System packages (environment.systemPackages):
  # - Available to all users
  # - Managed by root/nixos-rebuild
  # - Good for: CLI tools, daemons, system utilities
  #
  # Home Manager (home.packages):
  # - Per-user configuration
  # - User can customize without root
  # - Good for: User-specific tools, dotfiles integration
  #
  # Decision: System packages for AI tools because:
  # 1. Single user server - no need for per-user config
  # 2. Simpler management - one rebuild updates everything
  # 3. AI tools are CLI-based, no user-specific config needed

  environment.systemPackages = with pkgs; [
    # 1Password CLI (secrets management)
    _1password-cli

    # AI Development Tools from nix-ai-tools
    inputs.nix-ai-tools.packages.${pkgs.system}.opencode
    inputs.nix-ai-tools.packages.${pkgs.system}.claude-code

    # Shell
    fish

    # Essential utilities
    git
    curl
    wget
    htop
    tree
  ];

  # Enable fish shell system-wide
  programs.fish.enable = true;

  # ============================================
  # 1PASSWORD SSH AGENT
  # ============================================
  # 1Password as SSH agent provides:
  # 1. Fallback authentication if Tailscale SSH fails
  # 2. SSH key management via 1Password
  # 3. Biometric authentication support (from devices)
  # 4. Centralized key storage and rotation
  #
  # SSH Keys available in 1Password vault:
  # - yogaSSH (Lenovo Yoga workstation)
  # - zephyrusSSH (ASUS ROG Zephyrus workstation)
  # - desktopSSH (Desktop)
  # - phoneSSH (Mobile device)

  programs._1password = {
    enable = true;
  };

  programs._1password-gui = {
    enable = false;  # Server - no GUI needed
  };

  # Configure SSH to use 1Password agent as fallback
  # This allows SSH connections using keys stored in 1Password
  programs.ssh = {
    enable = true;
    extraConfig = ''
      # Use 1Password SSH agent as fallback
      # Primary: Tailscale SSH (identity-based)
      # Fallback: 1Password SSH agent + authorized keys
      IdentityAgent ~/.1password/agent.sock
    '';
  };
}
