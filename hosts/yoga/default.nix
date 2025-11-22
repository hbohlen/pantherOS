{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # Basic system configuration
  networking.hostName = "yoga";

  # System state version
  system.stateVersion = "24.11";
}
