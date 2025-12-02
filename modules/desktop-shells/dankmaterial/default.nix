# modules/desktop-shells/dankmaterial/default.nix
# DankMaterialShell system module

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
<<<<<<< HEAD

=======
  imports = [
    ./core.nix
    ./quickshell.nix
    ./theme.nix
    ./widgets.nix
    ./services.nix
    ./polkit.nix
  ];
>>>>>>> fb6e70feb688b42a718986987a6900480bdf1d32
  options.programs.dankmaterial = {
    enable = mkEnableOption "DankMaterialShell desktop environment";
    
    package = mkOption {
      type = types.package;
      default = pkgs.dankmaterialshell;
      description = "The DankMaterialShell package to use";
    };

    enableWidgets = mkOption {
      type = types.bool;
      default = true;
      description = "Enable default DankMaterialShell widgets";
    };

    enableServices = mkOption {
      type = types.bool;
      default = true;
      description = "Enable DankMaterialShell system services";
    };
  };

  config = mkIf cfg.enable {
    # Add DankMaterialShell to system packages
    environment.systemPackages = [
      cfg.package
      pkgs.qt6.qtwayland
      pkgs.qt6.qtsvg
      pkgs.qt6.qtdeclarative
      pkgs.qt6.qtquickcontrols2
      pkgs.qt6.qtmultimedia
      pkgs.qt6.qtgraphicaleffects
    ];

    # Enable Qt Wayland platform
    environment.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    };

    # Ensure proper Qt theme integration
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = {
        name = "adwaita-dark";
        package = pkgs.adwaita-qt;
      };
    };

    # Enable required services for DankMaterialShell
    services = {
      # Audio control for widgets
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };





      # Power management
      power-profiles-daemon.enable = true;

      # Upower for battery monitoring
      upower.enable = true;

      # Geoclue for location services
      geoclue2.enable = true;
    };

    # User groups for hardware access
    users.groups = {
      audio = {};
      video = {};
      input = {};
      network = {};
    };

    # Systemd user services for DankMaterialShell
    systemd.user.services.dankmaterial = {
      description = "DankMaterialShell Desktop Environment";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/dankmaterial";
        Restart = "on-failure";
        RestartSec = 1;
        Environment = [
          "QT_QPA_PLATFORM=wayland"
          "XDG_CURRENT_DESKTOP=DankMaterialShell"
          "XDG_SESSION_DESKTOP=dankmaterial"
        ];
      };
    };

    # XDG desktop integration
    xdg = {
      # autostart = {
      #   "dankmaterial.desktop".enable = true;
      # };

      # icons = {
      #   enable = true;
      #   theme = "Papirus-Dark";
      # };

      menus = {
        enable = true;
      };
    };

    # Enable required portals for Qt applications
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-qt
      ];
      configPackages = with pkgs; [
        cfg.package
      ];
    };
  };
}