{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/hardware/lenovo/yoga/audio.nix
    ../../modules/nixos/hardware/lenovo/yoga/touchpad.nix
    ../../modules/nixos/hardware/lenovo/yoga/power.nix
  ];

  # Enable Lenovo Yoga hardware modules
  pantherOS.hardware.lenovo.yoga = {
    audio.enable = true;
    touchpad.enable = true;
    power.enable = true;
  };
}
