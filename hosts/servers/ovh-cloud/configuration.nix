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
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;
    };
  };

  # Admin user
  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "podman" ];
    openssh.authorizedKeys.keys = [
      # Yoga laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL85xrOJYwZOR297WkW/w5QuEA8o5i4ykPd+YWlTGxM"
      # Phone
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEe67lx5ILCFuGNN7nNGZJai0aQe5jFNJbEjqql2Szft"
      # Desktop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIOaBiJ/Gr+sWkyhZlLH2QrrZb13VxhTrpUoOTbr8gxS"
      # Zephyrus laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY1sAb258Lkkw+6yl4M/YtbT3izNxFIP8Ag+UxEoipv"
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
  # NOTE: Dev tools (gcc, gnumake, pkg-config) commented out for initial deployment
  # Uncomment after successful deployment
  environment.systemPackages = with pkgs; [
    htop
    unzip
    zip
    openssh
    # gcc
    # gnumake
    # pkg-config
  ];

  # System state version
  system.stateVersion = "25.05";
}