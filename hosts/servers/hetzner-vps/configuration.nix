{ pkgs, ... }:
{
  # Boot configuration for Hetzner KVM
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];

  boot.kernelParams = [ "console=ttyS0,115200" ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    extraConfig = ''
      serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
      terminal_input serial console
      terminal_output serial console
    '';
  };

  networking.hostName = "hetzner-vps";
  networking.useNetworkd = true;

  # Use systemd.network instead of networking.useDHCP
  systemd.network = {
    enable = true;
    networks."10-en" = {
      matchConfig.Name = "en*";
      networkConfig.DHCP = "yes";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY1sAb258Lkkw+6yl4M/YtbT3izNxFIP8Ag+UxEoipv"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEe67lx5ILCFuGNN7nNGZJai0aQe5jFNJbEjqql2Szft"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL85xrOJYwZOR297WkW/w5QuEA8o5i4ykPd+YWlTGxM"
  ];

  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBY1sAb258Lkkw+6yl4M/YtbT3izNxFIP8Ag+UxEoipv"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEe67lx5ILCFuGNN7nNGZJai0aQe5jFNJbEjqql2Szft"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKL85xrOJYwZOR297WkW/w5QuEA8o5i4ykPd+YWlTGxM"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.systemPackages = with pkgs; [
    vim
    git
    curl
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "25.05";
}
