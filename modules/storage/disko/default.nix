# modules/storage/disko/default.nix
# Disko Disk Layout Modules
# Defines Btrfs subvolume layouts for different hardware profiles

{ ... }:

{
  imports = [
    # Individual disko layouts (Task Group 3)
    ./laptop-disk.nix
    ./dual-nvme-disk.nix
    ./server-disk.nix
  ];
}
