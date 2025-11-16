{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./disko.nix
  ];

  # Boot configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;
  boot.kernelParams = [ "console=ttyS0" ];

  # Network configuration
  networking.hostName = "ovh-cloud";
  networking.useDHCP = true;

  # Enable SSH with key-only authentication
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    challengeResponseAuthentication = false;
  };

  # Admin user
  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "podman" ];
    openssh.authorizedKeys.keys = [
      # TODO: Add SSH keys here
    ];
  };

  # Enable sudo for wheel group
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Timezone and locale
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Console configuration
  console.font = "Lat2-Terminus16";
  console.keyMap = "us";

  # Basic packages
  environment.systemPackages = with pkgs; [
    htop
    unzip
    zip
    openssh
    gcc
    gnumake
    pkg-config
  ];

  # System state version
  system.stateVersion = "25.05";
}