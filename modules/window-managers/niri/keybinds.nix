# modules/window-managers/niri/keybinds.nix
# Niri window manager keybindings

{ config, lib, ... }:

with lib;

let
  cfg = config.programs.niri;
in {
  config = mkIf (cfg.enable && cfg.enableKeybinds) {
    programs.niri.settings = {
      binds = {
        # Super + Shift + Q to quit Niri
        "Mod+Shift+Q" = { quit = []; };

        # Super + Enter to open terminal
        "Mod+Return" = { spawn = [ "alacritty" ]; };

        # Super + D for app launcher
        "Mod+D" = { spawn = [ "fuzzel" ]; };

        # Window navigation
        "Mod+Left" = { focus-column-left = []; };
        "Mod+Right" = { focus-column-right = []; };
        "Mod+Up" = { focus-window-up = []; };
        "Mod+Down" = { focus-window-down = []; };

        # Window movement
        "Mod+Shift+Left" = { move-column-left = []; };
        "Mod+Shift+Right" = { move-column-right = []; };
        "Mod+Shift+Up" = { move-window-up = []; };
        "Mod+Shift+Down" = { move-window-down = []; };

<<<<<<< HEAD
        # Workspace management
        "Mod+1" = { focus-workspace = 1; };
        "Mod+2" = { focus-workspace = 2; };
        "Mod+3" = { focus-workspace = 3; };
        "Mod+4" = { focus-workspace = 4; };
        "Mod+5" = { focus-workspace = 5; };

        # Window operations
        "Mod+F" = { max-column = []; };
        "Mod+Shift+F" = { fullscreen-window = []; };
        "Mod+Space" = { center-column = []; };
        "Mod+Shift+Space" = { toggle-floating = []; };

        # Volume control
        "XF86AudioRaiseVolume" = { spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ]; };
        "XF86AudioLowerVolume" = { spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ]; };
        "XF86AudioMute" = { spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ]; };

        # Brightness control
        "XF86MonBrightnessUp" = { spawn = [ "brightnessctl" "set" "10%+" ]; };
        "XF86MonBrightnessDown" = { spawn = [ "brightnessctl" "set" "10%-" ]; };
=======
      # Window resizing
      "Super+Control+Left".action.focus-column-left-or-monitor = [];
      "Super+Control+Right".action.focus-column-right-or-monitor = [];
      "Super+Control+Up".action.focus-monitor-up = [];
      "Super+Control+Down".action.focus-monitor-down = [];
      # Workspace management
      "Super+1".action.focus-workspace = 1;
      "Super+2".action.focus-workspace = 2;
      "Super+3".action.focus-workspace = 3;
      "Super+4".action.focus-workspace = 4;
      "Super+5".action.focus-workspace = 5;
      "Super+6".action.focus-workspace = 6;
      "Super+7".action.focus-workspace = 7;
      "Super+8".action.focus-workspace = 8;
      "Super+9".action.focus-workspace = 9;

      "Super+Shift+1".action.consume-window-into-column = [];
      "Super+Shift+2".action.consume-or-expel-window-left = [];
      "Super+Shift+3".action.consume-or-expel-window-right = [];

      # Window operations
      "Super+F".action.maximize-column = [];
      "Super+Shift+F".action.fullscreen-window = [];
      "Super+Space".action.center-column = [];
>>>>>>> fb6e70feb688b42a718986987a6900480bdf1d32

        # Screenshot
        "Print" = { spawn = [ "grimblast" "--notify" "copy" "area" ]; };
        "Mod+Print" = { spawn = [ "grimblast" "--notify" "copy" "output" ]; };

<<<<<<< HEAD
        # System controls
        "Mod+Ctrl+L" = { spawn = [ "loginctl" "lock-session" ]; };
        "Mod+Ctrl+Q" = { spawn = [ "wlogout" ]; };
      };
=======
      # Layout switching
      "Super+Comma".action.set-layout = "accordion";
      "Super+Period".action.set-layout = "columns";
      "Super+Slash".action.set-layout = "spirals";
      "Super+Backslash".action.set-layout = "struts";

      # Window closing
      "Super+Shift+C".action.close-window = [];
      # Volume control
      "XF86AudioRaiseVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ];
      "XF86AudioLowerVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
      "XF86AudioMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];

      # Brightness control
      "XF86MonBrightnessUp".action.spawn = [ "brightnessctl" "set" "10%+" ];
      "XF86MonBrightnessDown".action.spawn = [ "brightnessctl" "set" "10%-" ];

      # Media control
      "XF86AudioPlay".action.spawn = [ "playerctl" "play-pause" ];
      "XF86AudioNext".action.spawn = [ "playerctl" "next" ];
      "XF86AudioPrev".action.spawn = [ "playerctl" "previous" ];
      # Screenshot
      "Print".action.spawn = [ "grimblast" "--notify" "copy" "area" ];
      "Super+Print".action.spawn = [ "grimblast" "--notify" "copy" "output" ];

      # Application launcher
      "Super+R".action.spawn = [ "anyrun" ];

      # System controls
      "Super+Ctrl+L".action.spawn = [ "loginctl" "lock-session" ];
      "Super+Ctrl+Q".action.spawn = [ "wlogout" ];

      # Configuration reload
      "Super+Shift+R".action.spawn = [ "niri" "msg" "debug" "windows" ];
>>>>>>> fb6e70feb688b42a718986987a6900480bdf1d32
    };
  };
}