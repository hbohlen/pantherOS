{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # Basic system configuration
  networking.hostName = "zephyrus";

  # System state version
  system.stateVersion = "24.11";
}
