# modules/storage/btrfs/default.nix
# Btrfs Configuration Modules
# Manages subvolumes, mount options, and compression settings

{ ... }:

{
  imports = [
    # Btrfs management modules
    ./subvolumes.nix
    ./mount-options.nix
    ./compression.nix
    ./database-enforcement.nix
    ./ssd-optimization.nix
  ];
}
