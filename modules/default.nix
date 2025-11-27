# modules/default.nix
# Main aggregator for all NixOS modules

{
  imports = [
    ./packages
    ./environment
    ./users
    # ./home  # Disabled for now - using xdg.configFile directly
  ];
}