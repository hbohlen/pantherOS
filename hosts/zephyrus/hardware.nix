{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/nixos/hardware/asus/zephyrus/gpu.nix
    ../../modules/nixos/hardware/asus/zephyrus/performance.nix
  ];

  # Enable Asus Zephyrus hardware modules
  pantherOS.hardware.asus.zephyrus = {
    gpu.enable = true;
    performance.enable = true;
  };
}
