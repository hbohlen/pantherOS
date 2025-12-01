# modules/window-managers/niri/outputs.nix
# Niri output and display configuration

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.niri;
in {
  config = mkIf cfg.enable {
    programs.niri.settings = {
      # Output configuration for different display setups
      output = {
        # Laptop internal display (eDP-1)
        "eDP-1" = mkDefault {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.0;
          };
          position = { x = 0; y = 0; };
          scale = 1.0;
          transform = "normal";
        };

        # External HDMI display
        "HDMI-A-1" = mkDefault {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.0;
          };
          position = { x = 1920; y = 0; };
          scale = 1.0;
          transform = "normal";
        };
      };

      # Variable refresh rate support
      variable-refresh-rate = true;

      # Power management
      prefer-no-crtc = false;
    };

    # Required packages for display management
    environment.systemPackages = with pkgs; [
      wlr-randr          # Wayland output management
      kanshi            # Automatic display configuration
      grimblast         # Screenshot utility
      slurp             # Region selection
      brightnessctl      # Brightness control
      wlsunset          # Night light
    ];

    # Enable kanshi for automatic display configuration
    services.kanshi = {
      enable = true;
      profiles = {
        # Laptop only
        laptop = {
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080@60Hz";
              position = "0,0";
              scale = 1.0;
            }
          ];
        };

        # External monitor only
        external = {
          outputs = [
            {
              criteria = "HDMI-A-1";
              mode = "1920x1080@60Hz";
              position = "0,0";
              scale = 1.0;
            }
          ];
        };

        # Dual monitor setup
        dual = {
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080@60Hz";
              position = "0,0";
              scale = 1.0;
            }
            {
              criteria = "HDMI-A-1";
              mode = "1920x1080@60Hz";
              position = "1920,0";
              scale = 1.0;
            }
          ];
        };
      };
    };

    # Night light configuration
    services.wlsunset = {
      enable = true;
      temperature = {
        day = 6500;
        night = 3700;
      };
      gamma = 1.0;
      latitude = 40.7128;  # New York (default)
      longitude = -74.0060;
    };
  };
}