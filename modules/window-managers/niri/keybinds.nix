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

      # Workspace management
      "Super+1".action.focus-workspace = 1;
      "Super+2".action.focus-workspace = 2;
      "Super+3".action.focus-workspace = 3;
      "Super+4".action.focus-workspace = 4;
      "Super+5".action.focus-workspace = 5;

      # Window operations
      "Super+F".action.maximize-column = [];
      "Super+Shift+F".action.fullscreen-window = [];
      "Super+Space".action.center-column = [];
      "Super+Shift+Space".action.toggle-floating = [];

      # Volume control
      "XF86AudioRaiseVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ];
      "XF86AudioLowerVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
      "XF86AudioMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];

      # Brightness control
      "XF86MonBrightnessUp".action.spawn = [ "brightnessctl" "set" "10%+" ];
      "XF86MonBrightnessDown".action.spawn = [ "brightnessctl" "set" "10%-" ];

      # Screenshot
      "Print".action.spawn = [ "grimblast" "--notify" "copy" "area" ];
      "Super+Print".action.spawn = [ "grimblast" "--notify" "copy" "output" ];

      # System controls
      "Super+Ctrl+L".action.spawn = [ "loginctl" "lock-session" ];
      "Super+Ctrl+Q".action.spawn = [ "wlogout" ];
    };
  };
}