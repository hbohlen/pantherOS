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

        # Window resizing
        "Mod+Control+Left" = { focus-column-left-or-monitor = []; };
        "Mod+Control+Right" = { focus-column-right-or-monitor = []; };
        "Mod+Control+Up" = { focus-monitor-up = []; };
        "Mod+Control+Down" = { focus-monitor-down = []; };

        # Workspace management
        "Mod+1" = { focus-workspace = 1; };
        "Mod+2" = { focus-workspace = 2; };
        "Mod+3" = { focus-workspace = 3; };
        "Mod+4" = { focus-workspace = 4; };
        "Mod+5" = { focus-workspace = 5; };
        "Mod+6" = { focus-workspace = 6; };
        "Mod+7" = { focus-workspace = 7; };
        "Mod+8" = { focus-workspace = 8; };
        "Mod+9" = { focus-workspace = 9; };

        "Mod+Shift+1" = { consume-window-into-column = []; };
        "Mod+Shift+2" = { consume-or-expel-window-left = []; };
        "Mod+Shift+3" = { consume-or-expel-window-right = []; };

        # Window operations
        "Mod+F" = { maximize-column = []; };
        "Mod+Shift+F" = { fullscreen-window = []; };
        "Mod+Space" = { center-column = []; };

        # Volume control
        "XF86AudioRaiseVolume" = { spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ]; };
        "XF86AudioLowerVolume" = { spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ]; };
        "XF86AudioMute" = { spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ]; };

        # Brightness control
        "XF86MonBrightnessUp" = { spawn = [ "brightnessctl" "set" "10%+" ]; };
        "XF86MonBrightnessDown" = { spawn = [ "brightnessctl" "set" "10%-" ]; };

        # Layout switching
        "Mod+Comma" = { set-layout = "accordion"; };
        "Mod+Period" = { set-layout = "columns"; };
        "Mod+Slash" = { set-layout = "spirals"; };
        "Mod+Backslash" = { set-layout = "struts"; };

        # Window closing
        "Mod+Shift+C" = { close-window = []; };

        # Media control
        "XF86AudioPlay" = { spawn = [ "playerctl" "play-pause" ]; };
        "XF86AudioNext" = { spawn = [ "playerctl" "next" ]; };
        "XF86AudioPrev" = { spawn = [ "playerctl" "previous" ]; };

        # Screenshot
        "Print" = { spawn = [ "grimblast" "--notify" "copy" "area" ]; };
        "Mod+Print" = { spawn = [ "grimblast" "--notify" "copy" "output" ]; };

        # Application launcher
        "Mod+R" = { spawn = [ "anyrun" ]; };

        # System controls
        "Mod+Ctrl+L" = { spawn = [ "loginctl" "lock-session" ]; };
        "Mod+Ctrl+Q" = { spawn = [ "wlogout" ]; };

        # Configuration reload
        "Mod+Shift+R" = { spawn = [ "niri" "msg" "debug" "windows" ]; };
      };
    };
  };
}
