# hosts/zephyrus/default.nix
# ASUS ROG Zephyrus G15 Configuration
# Uses hybrid approach: nixos-hardware base + custom optimizations
# See meta.nix for detailed hardware configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./meta.nix           # Hybrid hardware configuration (nixos-hardware base + custom optimizations)
    # ./disko.nix        # Commented out for configuration testing
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

  # Basic file systems for configuration testing
  # Hardware configuration: see meta.nix (comprehensive ASUS ROG Zephyrus G15 support)
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