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

        # Screenshot
        "Print" = { spawn = [ "grimblast" "--notify" "copy" "area" ]; };
        "Mod+Print" = { spawn = [ "grimblast" "--notify" "copy" "output" ]; };

        # System controls
        "Mod+Ctrl+L" = { spawn = [ "loginctl" "lock-session" ]; };
        "Mod+Ctrl+Q" = { spawn = [ "wlogout" ]; };
      };
    };
  };
}