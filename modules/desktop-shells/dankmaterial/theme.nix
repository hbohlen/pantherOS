# modules/desktop-shells/dankmaterial/theme.nix
# Material Design theming for DankMaterialShell

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
  
  # Material Design color palette
  materialColors = {
    primary = "#6200EE";
    primaryVariant = "#3700B3";
    secondary = "#03DAC6";
    secondaryVariant = "#018786";
    background = "#121212";
    surface = "#1E1E1E";
    error = "#CF6679";
    onPrimary = "#FFFFFF";
    onSecondary = "#000000";
    onBackground = "#FFFFFF";
    onSurface = "#FFFFFF";
    onError = "#000000";
  };

  # Dark theme variant
  darkColors = {
    primary = "#BB86FC";
    primaryVariant = "#6200EE";
    secondary = "#03DAC6";
    background = "#121212";
    surface = "#1E1E1E";
    error = "#CF6679";
  };
in {
  config = mkIf cfg.enable {
    # GTK theme configuration
    # GTK theme configuration - managed via Home Manager
    # gtk = {
    #   enable = true;
    #   theme = {
    #     name = "Adwaita-dark";
    #     package = pkgs.gnome.gnome-themes-extra;
    #   };
    #   iconTheme = {
    #     name = "Papirus-Dark";
    #     package = pkgs.papirus-icon-theme;
    #   };
    #   font = {
    #     name = "Inter";
    #     size = 11;
    #   };
    # };

    # Qt theme configuration
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = {
        name = "adwaita-dark";
        package = pkgs.adwaita-qt;
      };
    };

    # Cursor theme
    environment.sessionVariables = {
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "24";
    };

    # Font configuration
    fonts = {
      packages = with pkgs; [
        inter
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        font-awesome
      ];
      
      fontconfig = {
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Inter" "Noto Sans" ];
          monospace = [ "JetBrains Mono" ];
        };
      };
    };

    # Material Design theme files
    environment.etc."xdg/gtk-3.0/gtk.css".text = ''
      /* Material Design GTK theme */
      @define-color primary ${materialColors.primary};
      @define-color primary_variant ${materialColors.primaryVariant};
      @define-color secondary ${materialColors.secondary};
      @define-color background ${materialColors.background};
      @define-color surface ${materialColors.surface};
      @define-color error ${materialColors.error};
      @define-color on_primary ${materialColors.onPrimary};
      @define-color on_background ${materialColors.onBackground};
      @define-color on_surface ${materialColors.onSurface};

      /* Window styling */
      window {
        background-color: @background;
        color: @on_background;
      }

      /* Header bar */
      headerbar {
        background-color: @primary;
        color: @on_primary;
        border: none;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
      }

      /* Buttons */
      button {
        background-color: @surface;
        color: @on_surface;
        border: 1px solid alpha(@on_surface, 0.12);
        border-radius: 4px;
        padding: 8px 16px;
        font-weight: 500;
        text-transform: uppercase;
        transition: all 0.2s ease;
      }

      button:hover {
        background-color: alpha(@primary, 0.08);
      }

      button:active {
        background-color: alpha(@primary, 0.16);
      }

      /* Entry fields */
      entry {
        background-color: alpha(@on_surface, 0.04);
        color: @on_surface;
        border: 1px solid alpha(@on_surface, 0.12);
        border-radius: 4px;
        padding: 8px 12px;
      }

      entry:focus {
        border-color: @primary;
        box-shadow: 0 0 0 2px alpha(@primary, 0.2);
      }
    '';

    # Qt QuickControls2 Material theme
    environment.etc."qt6ct/colors/dankmaterial.conf".text = ''
      [Colors]
      window=${materialColors.background}
      windowtext=${materialColors.onBackground}
      base=${materialColors.surface}
      basetext=${materialColors.onSurface}
      button=${materialColors.primary}
      buttontext=${materialColors.onPrimary}
      highlight=${materialColors.secondary}
      highlightedtext=${materialColors.onSecondary}
      tooltip=${materialColors.surface}
      tooltiptext=${materialColors.onSurface}
    '';

    # Material Design icon theme
    environment.systemPackages = with pkgs; [
      # Icon themes
      papirus-icon-theme
      adwaita-icon-theme
      material-design-icons
      
      # Font packages
      inter
      jetbrains-mono
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      
      # Theme tools
      qt6ct
      lxappearance
    ];

    # System theme integration
    programs.dconf.enable = true;

    # Material Design wallpaper
    environment.etc."dankmaterial/wallpaper.jpg".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/AvengeMedia/DankMaterialShell/main/assets/wallpapers/material-dark.jpg";
      sha256 = "1p6x8j3r5k2v9q8w4n7x6l3m2z1f4a5b6c7d8e9f0g1h2i3j4k5l6";
    };

    # Theme configuration for DankMaterialShell
    environment.etc."dankmaterial/theme.json".text = builtins.toJSON {
      colors = materialColors;
      darkColors = darkColors;
      fonts = {
        primary = "Inter";
        monospace = "JetBrains Mono";
        sizes = {
          small = 11;
          medium = 13;
          large = 16;
          xlarge = 20;
        };
      };
      spacing = {
        xs = 4;
        sm = 8;
        md = 16;
        lg = 24;
        xl = 32;
      };
      borderRadius = {
        small = 4;
        medium = 8;
        large = 12;
      };
      shadows = {
        elevation1 = "0 1px 3px rgba(0, 0, 0, 0.12)";
        elevation2 = "0 2px 6px rgba(0, 0, 0, 0.16)";
        elevation3 = "0 4px 12px rgba(0, 0, 0, 0.20)";
      };
    };
  };
}