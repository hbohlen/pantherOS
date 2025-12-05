# modules/storage/profiles/default.nix
# Host Profile Compositions
# Composes disk layouts, mount options, and policies per host type

{ ... }:

{
  imports = [
    # Task Group 5: Complete host profiles
    ./zephyrus.nix      # Dual-NVMe development laptop
    ./yoga.nix          # Single-NVMe light laptop
    ./hetzner.nix       # Production VPS with databases
    ./contabo.nix       # Staging VPS (production mirror)
    ./ovh.nix           # Utility VPS (simplified)
  ];
}
