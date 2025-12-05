# modules/desktop-shells/dankmaterial/polkit.nix
# mate-polkit integration for DankMaterialShell

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf cfg.enable {
    # Enable polkit
    security.polkit = {
      enable = true;
      
      # Custom polkit rules for DankMaterialShell
      extraConfig = ''
        // DankMaterialShell polkit rules
        polkit.addRule(function(action, subject) {
          // Allow DankMaterialShell to manage system settings
          if (action.id.indexOf("org.freedesktop.") === 0 &&
              subject.user === subject.user) {
            return polkit.Result.YES;
          }
          
          // Allow power management actions
          if (["org.freedesktop.login1.power-off",
               "org.freedesktop.login1.reboot",
               "org.freedesktop.login1.suspend",
               "org.freedesktop.login1.hibernate"].indexOf(action.id) !== -1 &&
              subject.user === subject.user) {
            return polkit.Result.YES;
          }
          
          // Allow network management
          if (["org.freedesktop.NetworkManager.",
               "org.freedesktop.ModemManager."].some(prefix => 
               action.id.startsWith(prefix)) &&
              subject.user === subject.user) {
            return polkit.Result.YES;
          }
          
          // Allow Bluetooth management
          if (action.id.startsWith("org.bluez.") &&
              subject.user === subject.user) {
            return polkit.Result.YES;
          }
          
          // Allow display management
          if (["org.freedesktop.ColorManager.",
               "org.freedesktop.Settings."].some(prefix => 
               action.id.startsWith(prefix)) &&
              subject.user === subject.user) {
            return polkit.Result.YES;
          }
          
          // Allow printing actions
          if (action.id.startsWith("org.cups.") &&
              subject.user === subject.user) {
            return polkit.Result.YES;
          }
          
          // Allow mounting/unmounting
          if (["org.freedesktop.udisks2.",
               "org.freedesktop.DeviceKit.Disks."].some(prefix => 
               action.id.startsWith(prefix)) &&
              subject.user === subject.user) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    # Install mate-polkit as the sole polkit authentication agent
    environment.systemPackages = with pkgs; [
      mate-polkit
      polkit
    ];

    # Systemd user service for mate-polkit
    systemd.user.services.polkit-mate-authentication-agent-1 = {
      description = "MATE Polkit Authentication Agent for DankMaterialShell";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        Environment = [
          "XDG_CURRENT_DESKTOP=DankMaterialShell"
          "GTK_THEME=Adwaita:dark"
        ];
      };
    };

    # Disable other polkit agents to ensure mate-polkit is the only one
    systemd.user.services.polkit-gnome-authentication-agent-1.enable = false;
    systemd.user.services.polkit-kde-authentication-agent-1.enable = false;
    systemd.user.services.xfce-polkit.enable = false;

    # Environment variables for polkit
    environment.sessionVariables = {
      POLKIT_AUTH_AGENT = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
    };

    # XDG autostart for mate-polkit
    environment.etc."xdg/autostart/polkit-mate-authentication-agent-1.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=MATE PolicyKit Authentication Agent
      Comment=PolicyKit Authentication Agent for MATE
      Exec=${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1
      TryExec=${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1
      Icon=dialog-password
      Terminal=false
      Categories=System;Security;
      X-GNOME-Autostart-Phase=Initialization
      X-KDE-autostart-after=panel
      NotShowIn=KDE;
      NoDisplay=true
      OnlyShowIn=DankMaterialShell;
    '';

    # Ensure mate-polkit starts before other services
    systemd.user.services."graphical-session-pre".wantedBy = lib.mkForce [ "graphical-session.target" ];
    systemd.user.services."graphical-session-pre".after = [ "polkit-mate-authentication-agent-1.service" ];

    # D-Bus configuration for mate-polkit
    services.dbus = {
      enable = true;
      packages = with pkgs; [
        mate-polkit
      ];
    };

    # Polkit configuration for DankMaterialShell
    environment.etc."polkit-1/localauthority/50-dankmaterial.conf".text = ''
      [Configuration]
      AdminIdentities=unix-user:0;unix-group:wheel
      AdminIdentities=unix-user:root
    '';

    # Ensure proper permissions for mate-polkit
    security.wrappers.polkit-mate-authentication-agent-1 = {
      owner = "root";
      group = "root";
      source = "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
    };
  };
}