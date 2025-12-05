# storage/default.nix
# Storage, Snapshots & Backup Foundation Module
# Aggregates all storage-related submodules

{ ... }:

{
  imports = [
    ./core.nix
    ./profiles
    ./disko
    ./btrfs
    ./snapshots
    ./backup
    ./monitoring
  ];
}
