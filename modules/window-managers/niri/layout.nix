# modules/window-managers/niri/layout.nix
# Niri layout and workspace configuration

{ config, lib, ... }:

with lib;

let
  cfg = config.programs.niri;
in {
  config = mkIf cfg.enable {
    programs.niri.settings = {
<<<<<<< HEAD # FIX:
=======
      # Workspace configuration
      workspaces = [
        { name = "1"; }
        { name = "2"; }
        { name = "3"; }
        { name = "4"; }
        { name = "5"; }
        { name = "6"; }
        { name = "7"; }
        { name = "8"; }
        { name = "9"; }
      ];

      # Layout presets
>>>>>>> fb6e70feb688b42a718986987a6900480bdf1d32 # FIX:
      layout = {
        # Center focused column
        center-focused-column = "never";

        # Gaps configuration
        gaps = 8;

<<<<<<< HEAD # FIX:
        # Column width presets
        preset-column-widths = [
          { proportion = 1.0; }
          { proportion = 0.5; }
          { proportion = 0.33; }
          { proportion = 0.25; }
======= # FIX:
        # Strut configuration for panels
        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };
        # Column width presets
        preset-column-widths = [
          { proportion = 1.0; }  # Full width
          { proportion = 0.5; }  # Half width
          { proportion = 0.33; } # Third width
          { proportion = 0.25; } # Quarter width
          { fixed = 640; }      # Fixed 640px
          { fixed = 800; }      # Fixed 800px
          { fixed = 1024; }     # Fixed 1024px
          { fixed = 1280; }     # Fixed 1280px
>>>>>>> fb6e70feb688b42a718986987a6900480bdf1d32 # FIX:
        ];

        # Default column width
        default-column-width = { proportion = 0.5; };

        # Focus ring configuration
        focus-ring = {
          width = 4;
<<<<<<< HEAD # FIX:
          active-color = "0x88c0d0";
          inactive-color = "0x4c566a";
=======
          active-color = "0x88c0d0";  # Nord blue
          inactive-color = "0x4c566a"; # Nord dark gray
          active-gradient = {
            from = "0x88c0d0";
            to = "0x81a1c1";
            angle = 45;
          };
>>>>>>> fb6e70feb688b42a718986987a6900480bdf1d32 # FIX:
        };

        # Border configuration
        border = {
          width = 2;
<<<<<<< HEAD # FIX:
          active-color = "0x88c0d0";
          inactive-color = "0x4c566a";
=======
          active-color = "0x88c0d0";  # Nord blue
          inactive-color = "0x4c566a"; # Nord dark gray
          active-gradient = {
            from = "0x88c0d0";
            to = "0x81a1c1";
            angle = 45;
          };
>>>>>>> fb6e70feb688b42a718986987a6900480bdf1d32 # FIX:
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
