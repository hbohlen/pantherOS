# Example NixOS test configuration for GitHub Copilot
# This file demonstrates a minimal NixOS configuration that can be used for testing

{ config, pkgs, lib, ... }:

{
  # Basic system configuration
  system.stateVersion = "25.05";

  # Networking
  networking = {
    hostName = "nixos-test";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    
    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # User configuration
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here for testing
      # "ssh-ed25519 AAAAC3... user@host"
    ];
  };

  # Sudo configuration
  security.sudo.wheelNeedsPassword = false;

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
    };
    
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Essential tools
    vim
    git
    wget
    curl
    htop
    tmux
    
    # Nix tools
    nix-tree
    nixpkgs-fmt
    
    # Network tools
    rsync
    openssh
  ];

  # Services
  services = {
    # Enable periodic TRIM for SSDs
    fstrim.enable = true;
    
    # Enable the NixOS firewall
    firewall.enable = true;
  };

  # Boot configuration (minimal example)
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    cleanTmpDir = true;
  };

  # Time zone
  time.timeZone = "UTC";

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
}
