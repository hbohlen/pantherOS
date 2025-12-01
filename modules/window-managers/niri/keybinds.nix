# modules/window-managers/niri/keybinds.nix
# Niri window manager keybindings

{ config, lib, ... }:

with lib;

let
  cfg = config.programs.niri;
in {
  config = mkIf (cfg.enable && cfg.enableKeybinds) {
    programs.niri.settings.binds = {
      # Super + Shift + Q to quit Niri
      "Super+Shift+Q".action.quit = [];

      # Super + Enter to open terminal
      "Super+Enter".action.spawn = [ "alacritty" ];

      # Super + D for app launcher
      "Super+D".action.spawn = [ "fuzzel" ];

      # Window navigation
      "Super+Left".action.focus-column-left = [];
      "Super+Right".action.focus-column-right = [];
      "Super+Up".action.focus-window-up = [];
      "Super+Down".action.focus-window-down = [];

      # Window movement
      "Super+Shift+Left".action.move-column-left = [];
      "Super+Shift+Right".action.move-column-right = [];
      "Super+Shift+Up".action.move-window-up = [];
      "Super+Shift+Down".action.move-window-down = [];

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

      # Floating window operations
      "Super+Shift+Space".action.toggle-floating = [];

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
    };
  };
}