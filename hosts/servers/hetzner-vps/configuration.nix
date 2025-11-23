{ config, pkgs, ... }:
{
  imports = [ ./disko.nix ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "hetzner-vps";
  networking.useDHCP = true;

  users.users.root.initialPassword = "changeme";

  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "changeme";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY1sAb258Lkkw+6yl4M/YtbT3izNxFIP8Ag+UxEoipv"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEe67lx5ILCFuGNN7nNGZJai0aQe5jFNJbEjqql2Szft"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL85xrOJYwZOR297WkW/w5QuEA8o5i4ykPd+YWlTGxM"
    ];
  };

  # Optional: Add key to root user as a backup
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY1sAb258Lkkw+6yl4M/YtbT3izNxFIP8Ag+UxEoipv"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEe67lx5ILCFuGNN7nNGZJai0aQe5jFNJbEjqql2Szft"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL85xrOJYwZOR297WkW/w5QuEA8o5i4ykPd+YWlTGxM" # <--- SAME KEY HERE
  ];

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.systemPackages = with pkgs; [ vim ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.05";
}
