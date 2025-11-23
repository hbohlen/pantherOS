{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../../modules/shared/users/hbohlen.nix
  ];

  networking.hostName = "ovh-vps";
  nixpkgs.config.allowUnfree = true;
  fileSystems."/" = {
    device = "/dev/disk/by-label/ovh-root";
    fsType = "ext4";
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  system.stateVersion = "25.05";
}
