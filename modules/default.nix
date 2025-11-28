# modules/default.nix
# Main aggregator for all NixOS modules

{
  imports = [
    ./packages
    ./environment
    ./users
    # ./home-manager  # Only imported in home-manager context, not here
    # ./home  # Disabled for now - using xdg.configFile directly
  ];
}
