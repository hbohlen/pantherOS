# modules/window-managers/niri/layout.nix
# Niri layout and workspace configuration

{ config, lib, ... }:

with lib;

let
  cfg = config.programs.niri;
in {
  config = mkIf cfg.enable {
    programs.niri.settings = {
      layout = {
        # Center focused column
        center-focused-column = "never";
        
        # Gaps configuration
        gaps = 8;
        
        # Column width presets
        preset-column-widths = [
          { proportion = 1.0; }
          { proportion = 0.5; }
          { proportion = 0.33; }
          { proportion = 0.25; }
        ];

        # Default column width
        default-column-width = { proportion = 0.5; };

        # Focus ring configuration
        focus-ring = {
          width = 4;
          active-color = "0x88c0d0";
          inactive-color = "0x4c566a";
        };

        # Border configuration
        border = {
          width = 2;
          active-color = "0x88c0d0";
          inactive-color = "0x4c566a";
        };

        # Shadow configuration
        drop-shadow = {
          enable = true;
          offset-x = 2;
          offset-y = 2;
          blur-radius = 4;
          color = "0x00000088";
        };
      };

      # Animation settings
      animations = {
        enable = true;
        slowdown = 1.0;
        workspace-switch = {
          duration-ms = 250;
          curve = "ease-out-cubic";
        };
        window-open = {
          duration-ms = 200;
          curve = "ease-out-cubic";
        };
        window-close = {
          duration-ms = 200;
          curve = "ease-in-cubic";
        };
      };

      # Cursor settings
      cursor = {
        x-cursor-theme = "Adwaita";
        x-cursor-size = 24;
        hide-when-typing = true;
      };
    };
  };
}