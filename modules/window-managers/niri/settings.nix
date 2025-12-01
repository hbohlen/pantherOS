# modules/window-managers/niri/settings.nix
# Core Niri configuration settings

{ config, lib, ... }:

with lib;

let
  cfg = config.programs.niri;
in {
  config = mkIf cfg.enable {
    programs.niri.settings = {
      # Input configuration
      input = {
        keyboard = {
          repeat-delay = 600;
          repeat-rate = 25;
          track-layout = "window";
        };
        
        touchpad = {
          tap = true;
          dwt = true;
          disable-while-typing = true;
          click-method = "clickfinger";
        };
        
        mouse = {
          accel-profile = "flat";
        };
      };

      # Output configuration
      output = {
        "eDP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.0;
          };
          position = { x = 0; y = 0; };
          scale = 1.0;
        };
      };

      # Layout configuration
      layout = {
        focus-ring = {
          enable = true;
          width = 4;
          active-color = "0x88c0d0";
          inactive-color = "0x4c566a";
        };
        
        border = {
          enable = true;
          width = 2;
          active-color = "0x88c0d0";
          inactive-color = "0x4c566a";
        };

        gaps = 8;
        
        preset-column-widths = [
          { proportion = 1.0; }
          { proportion = 0.5; }
          { proportion = 0.33; }
          { proportion = 0.25; }
        ];

        default-column-width = { proportion = 0.5; };
      };

      # Window rules
      window-rules = [
        # Floating windows for dialogs
        {
          match.app-id = "^org.freedesktop.impl.desktopchooser.*$";
          open-floating = true;
        }
        {
          match.app-id = "^org.gnome.*dialog.*$";
          open-floating = true;
        }
        {
          match.app-id = "^.*notification.*$";
          open-floating = true;
        }

        # Specific application rules
        {
          match.app-id = "^pavucontrol$";
          open-floating = true;
          default-column-width = { proportion = 0.33; };
        }
        {
          match.app-id = "^blueman-manager$";
          open-floating = true;
          default-column-width = { proportion = 0.33; };
        }
      ];

      # Animations
      animations = {
        enable = true;
        slowdown = 1.0;
      };

      # Cursor configuration
      cursor = {
        x-cursor-theme = "Adwaita";
        x-cursor-size = 24;
      };

      # Hotkey overlay
      hotkey-overlay = {
        skip-at-startup = true;
      };

      # Environment variables
      spawn-at-startup = [
        { command = [ "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP" ]; }
      ];
    };
  };
}