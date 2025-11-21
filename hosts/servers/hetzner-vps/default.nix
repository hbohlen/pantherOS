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
  system.stateVersion = "25.05";

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
  # IMPERMANENCE CONFIGURATION
  # ============================================
  # Impermanence: Ephemeral root that gets wiped on every boot
  # Persistent data survives in /persist subvolume
  # Old roots archived for 30-day rollback capability
  #
  # How it works:
  # 1. Before boot: Archive current root snapshot with timestamp
  # 2. Delete old root subvolume
  # 3. Create fresh root subvolume
  # 4. Clean up roots older than 30 days
  # 5. Files in /persist are copied to new root

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    # Mount Btrfs filesystem to temporary mount point
    mkdir -p /mnt
    mount -t btrfs -o subvol=/ /dev/sda /mnt

    # Create old_roots directory if it doesn't exist
    mkdir -p /mnt/old_roots

    # Archive current root snapshot if it exists
    if btrfs subvolume list /mnt | grep -q 'path root'; then
      timestamp=$(date +%Y%m%d_%H%M%S)
      btrfs subvolume snapshot /mnt/root "/mnt/old_roots/old_root_$timestamp"
    fi

    # Delete old @root subvolume
    if btrfs subvolume list /mnt | grep -q 'path root'; then
      btrfs subvolume delete /mnt/root
    fi

    # Create fresh @root subvolume
    btrfs subvolume create /mnt/root

    # Clean up old roots older than 30 days
    find /mnt/old_roots -name 'old_root_*' -type d -mtime +30 -exec btrfs subvolume delete {} \; 2>/dev/null || true

    # Unmount temporary mount
    umount /mnt

    # Force remount of root
    echo "Initiating impermanence rotation..."
    for i in {1..10}; do
      if mountpoint -q /; then
        umount / || true
        break
      fi
      sleep 1
    done

    # Trigger remount
    systemctl restart tmp.mount || true
  '';
}
