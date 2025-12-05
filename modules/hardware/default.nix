# modules/hardware/default.nix
# Aggregates all hardware-specific NixOS modules

{
  imports = [
    ./asus-rog.nix
    ./detection-scripts.nix
  ];
}
