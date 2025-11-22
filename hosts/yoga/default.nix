{ config, lib, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../modules/nixos/hardware/yoga.nix
  ];
  
  # Basic system configuration
  networking.hostName = "yoga";
  
  # Enable essential services for workstation
  pantherOS = {
    services = {
      ssh.enable = lib.mkDefault true;
      tailscale.enable = lib.mkDefault true;
    };
    
    security = {
      firewall.enable = lib.mkDefault true;
    };
  };
  
  # System state version
  # WARNING: Changing this value may break your system.
  # Read the NixOS release notes before changing.
  system.stateVersion = "24.11";
}
