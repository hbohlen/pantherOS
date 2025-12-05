# modules/window-managers/default.nix
# Window manager modules aggregator
# Note: Niri is now provided by nixpkgs as programs.niri
# Custom niri module disabled to avoid conflicts with nixpkgs

{
  imports = [
    # TODO: Add your custom window manager module here
    # ./niri  # Disabled: use built-in programs.niri from nixpkgs instead
  ];
}
