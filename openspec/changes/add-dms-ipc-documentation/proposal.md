# Change: Add DankMaterialShell IPC and Keybindings Documentation

## Why

To provide comprehensive documentation for DankMaterialShell's IPC (Inter-Process Communication) system and keybinding configuration, enabling users to customize and extend DMS functionality through programmatic control and keyboard shortcuts across different Wayland compositors (niri, Hyprland, sway).

## What Changes

- Document DankMaterialShell IPC command structure and available commands
- Document all IPC modules (spotlight, notifications, settings, notepad, lock, powermenu, audio, night, processlist, clipboard, brightness)
- Provide keybinding examples for niri, Hyprland, and sway compositors
- Document IPC command syntax: `dms ipc <module> <action> [args...]`
- Include comprehensive examples for each IPC module
- Document audio control IPC (increment, decrement, mute, micmute)
- Document brightness control IPC with device selection
- Document conditional keybindings based on feature toggles
- Provide troubleshooting guidance for IPC communication
- Create reference documentation for all available IPC commands and parameters
- Document integration with compositor-specific keybinding systems
- Include examples of custom keybinding configurations
- Document hotkey-overlay integration for niri compositor
- **DEPENDENCY**: Requires `add-dank-material-shell` change to be completed first

## Dependencies

- Depends on: `add-dank-material-shell` (must be completed first)

## Impact

- Affected specs: shell-configuration (new IPC and keybindings documentation)
- Affected code:
  - Documentation files for IPC command reference
  - Example configuration snippets for niri, Hyprland, sway
  - Integration guides for compositor keybinding systems
- Provides clear reference for all IPC commands and their parameters
- Enables users to create custom keybinding configurations
- Supports automation and scripting through IPC interface
- Does not affect existing functionality, only adds documentation
- Improves discoverability of DMS features through comprehensive command reference
