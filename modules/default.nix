# modules/default.nix
# Main aggregator for all NixOS modules

{
  imports = [
    ./packages
    ./environment
    ./users
    ./window-managers
    ./desktop-shells
    ./development
    ./security
    ./ci
    # Note: Custom window manager modules can be added here if needed
    # ./home-manager  # Only imported in home-manager context, not here
    # ./home  # Disabled for now - using xdg.configFile directly
  ];
}
