{ config, lib, pkgs, ... }:

{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../modules/nixos/hardware/zephyrus.nix
  ];
  
  # Basic system configuration
  networking.hostName = "zephyrus";
  
  # Enable essential services for performance workstation
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
