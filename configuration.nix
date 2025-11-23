{ config, pkgs, ... }:

{
  imports = [ ];

  # Boot
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  # Networking
  networking = {
    hostName = "hetzner-vps";
    useDHCP = true;
    firewall.enable = true;
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Your SSH key - GET YOUR PUBLIC KEY WITH: cat ~/.ssh/id_ed25519.pub
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY1sAb258Lkkw+6yl4M/YtbT3izNxFIP8Ag+UxEoipv"
  ];

  # Tailscale
  services.tailscale.enable = true;

  # Basic packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    htop
  ];

  # Nix settings
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  system.stateVersion = "25.05";
}
