# hosts/zephyrus/default.nix
# Basic host configuration for zephyrus
# TODO: Update with specific hardware requirements once facter report is available
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    # ./disko.nix  # Commented out for configuration testing
    ../../modules
  ];

  # Hostname
  networking.hostName = "zephyrus";

  # Bootloader - GRUB with UEFI support
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  # Locale and timezone
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Network configuration
  networking.useDHCP = lib.mkDefault true;

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # User configuration - will be imported from modules
  # home-manager configuration will be added when user setup is complete

  # Basic file systems for configuration testing
  # TODO: Replace with actual disko configuration for production
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # State version
  system.stateVersion = "25.05";
}