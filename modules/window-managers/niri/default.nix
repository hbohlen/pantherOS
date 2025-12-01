# modules/window-managers/niri/default.nix
# Niri window manager system module

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.niri;
in {
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./layout.nix
    ./outputs.nix
  ];

  options.programs.niri = {
    enable = mkEnableOption "Niri Wayland compositor";
    
    package = mkOption {
      type = types.package;
      default = pkgs.niri;
      description = "The Niri package to use";
    };

    enableKeybinds = mkOption {
      type = types.bool;
      default = true;
      description = "Enable default Niri keybinds";
    };
  };

  config = mkIf cfg.enable {
    # Enable Niri as the window manager
    programs.niri = {
      enable = true;
      package = cfg.package;
    };

    # Required system packages for Niri
    environment.systemPackages = with pkgs; [
      cfg.package
      xdg-desktop-portal-niri
      wlroots
    ];

    # Enable Wayland support
    programs.xwayland.enable = true;

    # XDG desktop portals for proper Wayland integration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-niri
      ];
      xdgOpenUsePortal = true;
    };

<<<<<<< HEAD
    # Configure mate-polkit as the sole polkit authentication agent
=======
    # Configure mate-polkit as sole polkit authentication agent
>>>>>>> feature/niri-dankmaterial-integration
    security.polkit.enable = true;
    systemd.user.services.polkit-mate = {
      description = "MATE Polkit Authentication Agent";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };

    # Ensure no other polkit agents are running
    systemd.user.services.polkit-gnome.enable = false;
    systemd.user.services.polkit-kde.enable = false;
  };
}