{ config, lib, ... }:

{
  imports = [
    ./server-impermanence.nix
    ./server-snapshots.nix
  ];
  
  config = {
    # Btrfs configuration will be completed in Task 1.2
  };
}