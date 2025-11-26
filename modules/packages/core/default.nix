# modules/packages/core/default.nix
{ pkgs, ... }:

{
  # Core system packages - essential utilities and tools
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    git
    curl
    wget
    htop
    btop           # Better top
    tmux
    screen
    ripgrep        # Fast grep
    fd             # Fast find
    jq             # JSON processor

    # Network tools
    tailscale
    _1password-cli

    # Container tools
    podman-compose
    buildah        # Container image builder
    skopeo         # Container image tool

    # Btrfs tools
    btrfs-progs
    compsize       # Check compression ratios

    # System monitoring
    iotop
    ncdu           # Disk usage analyzer
    duf            # Modern df

    # Shells
    fish           # Fish shell (for user shell configuration)
    bash           # Keep bash available for compatibility
  ];
}