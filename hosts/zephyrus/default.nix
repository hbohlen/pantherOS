# hosts/zephyrus/default.nix
# ASUS ROG Zephyrus G15 Configuration
# Uses hybrid approach: nixos-hardware base + custom optimizations
# See meta.nix for detailed hardware configuration
{ lib, pkgs, ... }:

{
  imports = [
    ./meta.nix # Hybrid hardware configuration (nixos-hardware base + custom optimizations)
    ./disko.nix # Disk partitioning configuration
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

  # File systems configured by disko.nix
  # Hardware configuration: see meta.nix (comprehensive ASUS ROG Zephyrus G15 support)

   # DankMaterialShell - Material design shell environment
   programs.dankMaterialShell = {
     enable = true;
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
   ];

   # Set ghostty as default terminal
   xdg.terminal-exec.settings.default = [ "ghostty.desktop" ];
   environment.sessionVariables.TERMINAL = "ghostty";

   # Home Manager configuration
   home-manager.users.hbohlen = import ../../home/hbohlen/home.nix;

   # State version
   system.stateVersion = "25.05";
}
