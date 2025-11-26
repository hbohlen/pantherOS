# modules/default.nix
# Main aggregator for all NixOS modules

{
  imports = [
    ./packages
    ./environment
    ./users
  ];
}