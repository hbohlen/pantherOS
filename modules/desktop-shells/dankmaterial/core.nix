# modules/desktop-shells/dankmaterial/core.nix
# Core DankMaterialShell configuration

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf cfg.enable {
    # Core environment variables for DankMaterialShell
    environment.sessionVariables = {
      XDG_CURRENT_DESKTOP = "DankMaterialShell";
      XDG_SESSION_DESKTOP = "dankmaterial";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GDK_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    # Enable core system services
    services = {
      # Display manager integration
      displayManager = {
        defaultSession = "dankmaterial";
        sessionPackages = [ cfg.package ];
      };

      # Core system services
      dbus.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
      upower.enable = true;
      power-profiles-daemon.enable = true;
    };

    # Required system packages
    environment.systemPackages = with pkgs; [
      # Core dependencies
      wayland
      wayland-protocols
      wayland-utils
      
      # Qt dependencies
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtquickcontrols2
      qt6.qtgraphicaleffects
      qt6.qtsvg
      qt6.qtmultimedia
      
      # Theme and icons
      papirus-icon-theme
      adwaita-qt
      adwaita-icon-theme
      
      # System integration
      xdg-utils
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-qt
      
      # Audio and multimedia
      pipewire
      wireplumber
      pulseaudio
      
      # Network and connectivity
      networkmanager
      blueman
      
      # Power and hardware
      brightnessctl
      tlp
    ];

    # Enable user services
    systemd.user = {
      # DankMaterialShell main service
      services.dankmaterial-core = {
        description = "DankMaterialShell Core Service";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/dankmaterial --core";
          Restart = "on-failure";
          RestartSec = 1;
          Environment = [
            "XDG_CURRENT_DESKTOP=DankMaterialShell"
            "QT_QPA_PLATFORM=wayland"
          ];
        };
      };

      # QuickShell service for QML components
      services.quickshell = {
        description = "QuickShell QML Runtime";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.quickshell}/bin/quickshell";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };
    };

    # XDG desktop entry
    environment.etc."xdg/autostart/dankmaterial.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=DankMaterialShell
      Comment=Material Design desktop shell
      Exec=${cfg.package}/bin/dankmaterial
      TryExec=${cfg.package}/bin/dankmaterial
      Icon=dankmaterial
      Terminal=false
      Categories=System;Core;
      StartupNotify=false
      X-GNOME-Autostart-Phase=Initialization
      X-KDE-autostart-after=panel
    '';
  };
}