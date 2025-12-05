{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf (cfg.enable && cfg.enableServices) {
    # Required system packages
    environment.systemPackages = with pkgs; [
      # Audio tools
      pulseaudio
      pamixer
      pavucontrol
      easyeffects

      # Network tools
      networkmanager
      iwgtk
      blueman
      bluez-tools

      # Power management
      tlp
      auto-cpufreq
      power-profiles-daemon

      # System monitoring
      lm_sensors
      acpi
      htop
      btop

      # File management
      gvfs
      udisks2
      nfs-utils

      # Bluetooth
      bluez
      bluez-tools

      # Printing
      cups
      system-config-printer

      # Time and date
      chrony

      # Location services
      geoclue2

      # Display management
      kanshi
      wlr-randr

      # System utilities
      dbus
      polkit
      xdg-utils
    ];

    # User groups for hardware access
    users.groups = {
      audio = {};
      video = {};
      input = {};
      network = {};
      bluetooth = {};
      lp = {};
      scanner = {};
      disk = {};
    };
  };
}
