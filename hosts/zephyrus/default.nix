{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./disko.nix
    ../../modules/shared/users/hbohlen.nix
  ];

  # Basic system configuration
  networking.hostName = "zephyrus";
  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = "25.05";
}
