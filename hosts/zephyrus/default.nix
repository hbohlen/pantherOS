# hosts/zephyrus/default.nix
# ASUS ROG Zephyrus G15 Configuration
# Uses hybrid approach: nixos-hardware base + custom optimizations
# See meta.nix for detailed hardware configuration
{ lib, pkgs, ... }:

{
  imports = [
    # ./hardware-facter.nix # Hardware detection from facter.json
    ./hardware.nix # Hardware baseline configuration
    ./meta.nix # Hybrid hardware configuration (nixos-hardware base + custom optimizations)
    ./disko.nix # Disk partitioning configuration
    ../../modules
  ];

  disabledModules = [ "programs/wayland/niri.nix" ];



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

  # File systems configured by disko.nix
  # Hardware configuration: see meta.nix (comprehensive ASUS ROG Zephyrus G15 support)

   # DankMaterialShell - Material design shell environment
   # TODO: Fix network/build issues with DankMaterialShell Go dependencies
   programs.dankMaterialShell = {
     enable = false;
     enableSystemMonitoring = true;
     enableClipboard = true;
     enableVPN = true;
     enableBrightnessControl = true;
     enableColorPicker = true;
     enableDynamicTheming = true;
     enableAudioWavelength = true;
     enableCalendarEvents = true;
     enableSystemSound = true;
   };

   # Niri window manager
   services.displayManager.defaultSession = "niri";

  # Hardware monitoring and ASUS ROG tools
  environment.systemPackages = with pkgs; [
    # Hardware monitoring
    nvtopPackages.full
    intel-gpu-tools
    pciutils
    usbutils

    # ASUS ROG tools
    asusctl

    # Performance monitoring
    powertop

    # Network tools
    iwd
    wirelesstools

     # Ghostty terminal emulator
     ghostty

    # Custom hardware tools
    (pkgs.callPackage ./scripts/default.nix {})
   ];

   # Set ghostty as default terminal
   xdg.terminal-exec.settings.default = [ "ghostty.desktop" ];
   environment.sessionVariables.TERMINAL = "ghostty";

   # Home Manager configuration
   home-manager.users.hbohlen = import ../../home/hbohlen/home.nix;

   # Shell Environment
   programs.fish.enable = true;

   # Authentication & Security - 1Password integration
   # Using custom wrapper module (modules/security/1password.nix) that configures
   # NixOS built-in programs._1password and programs._1password-gui per:
   # https://developer.1password.com/docs/cli/get-started/#install
   programs.onepassword-desktop = {
     enable = true;
     polkitPolicyOwners = [ "hbohlen" ];
   };

   # Development Environment
   virtualisation.podman = {
     enable = true;
     dockerCompat = true;
     defaultNetwork.settings.dns_enabled = true;
   };

   # State version
   system.stateVersion = "25.05";
}
