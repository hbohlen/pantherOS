## 1. IPC Command Structure Documentation

- [ ] 1.1 Document base IPC command syntax: `dms ipc <module> <action> [args...]`
- [ ] 1.2 Document available IPC modules list
- [ ] 1.3 Document common IPC action patterns (toggle, increment, decrement)
- [ ] 1.4 Document IPC response and error handling
- [ ] 1.5 Provide examples of IPC command execution

## 2. Core Module IPC Documentation

- [ ] 2.1 Document spotlight (application launcher) IPC: toggle action
- [ ] 2.2 Document notifications IPC: toggle action
- [ ] 2.3 Document settings IPC: toggle action
- [ ] 2.4 Document notepad IPC: toggle action
- [ ] 2.5 Document lock IPC: lock action
- [ ] 2.6 Document powermenu IPC: toggle action
- [ ] 2.7 Document night (mode) IPC: toggle action

## 3. Audio Control IPC Documentation

- [ ] 3.1 Document audio increment IPC: `dms ipc audio increment <percentage>`
- [ ] 3.2 Document audio decrement IPC: `dms ipc audio decrement <percentage>`
- [ ] 3.3 Document audio mute IPC: `dms ipc audio mute`
- [ ] 3.4 Document audio micmute IPC: `dms ipc audio micmute`
- [ ] 3.5 Provide examples with typical percentage values (3, 5, 10)

## 4. Conditional Feature IPC Documentation

- [ ] 4.1 Document processlist IPC: toggle action (requires enableSystemMonitoring)
- [ ] 4.2 Document clipboard IPC: toggle action (requires enableClipboard)
- [ ] 4.3 Document brightness IPC: increment/decrement with percentage and device (requires enableBrightnessControl)
- [ ] 4.4 Document feature requirement checks for conditional modules

## 5. Brightness Control IPC Documentation

- [ ] 5.1 Document brightness increment: `dms ipc brightness increment <percentage> <device>`
- [ ] 5.2 Document brightness decrement: `dms ipc brightness decrement <percentage> <device>`
- [ ] 5.3 Document device parameter usage (empty string for default)
- [ ] 5.4 Provide examples for different brightness adjustment levels
- [ ] 5.5 Document hardware key integration (XF86MonBrightnessUp/Down)

## 6. Niri Compositor Keybinding Documentation

- [ ] 6.1 Document niri keybinding syntax with config.lib.niri.actions.spawn
- [ ] 6.2 Document Mod key usage in niri bindings
- [ ] 6.3 Document hotkey-overlay.title for keybinding descriptions
- [ ] 6.4 Document allow-when-locked for system controls
- [ ] 6.5 Provide complete niri keybinding examples for all IPC modules
- [ ] 6.6 Document conditional keybindings using lib.attrsets.optionalAttrs
- [ ] 6.7 Document hardware key mappings (XF86Audio*, XF86MonBrightness*)

## 7. Hyprland Compositor Keybinding Documentation

- [ ] 7.1 Document Hyprland keybinding syntax
- [ ] 7.2 Document bind and binde directives
- [ ] 7.3 Provide Hyprland keybinding examples for all IPC modules
- [ ] 7.4 Document Hyprland-specific modifier keys
- [ ] 7.5 Document hardware key integration in Hyprland

## 8. Sway Compositor Keybinding Documentation

- [ ] 8.1 Document sway keybinding syntax
- [ ] 8.2 Document bindsym directive
- [ ] 8.3 Provide sway keybinding examples for all IPC modules
- [ ] 8.4 Document sway-specific modifier keys
- [ ] 8.5 Document hardware key integration in sway

## 9. Custom Keybinding Configuration

- [ ] 9.1 Document how to create custom keybinding configurations
- [ ] 9.2 Provide examples of custom keyboard shortcuts
- [ ] 9.3 Document keybinding conflict resolution
- [ ] 9.4 Document how to disable default keybindings (niri.enableKeybinds = false)
- [ ] 9.5 Provide examples of advanced keybinding patterns

## 10. IPC Command Reference

- [ ] 10.1 Create comprehensive IPC command reference table
- [ ] 10.2 Document each command with module, action, parameters, and description
- [ ] 10.3 Provide usage examples for each command
- [ ] 10.4 Document feature dependencies for conditional commands
- [ ] 10.5 Include quick reference guide for common commands

## 11. Integration and Scripting

- [ ] 11.1 Document IPC usage in shell scripts
- [ ] 11.2 Provide automation examples using IPC
- [ ] 11.3 Document IPC integration with external tools
- [ ] 11.4 Document programmatic control patterns
- [ ] 11.5 Provide examples of complex IPC workflows

## 12. Troubleshooting

- [ ] 12.1 Document common IPC communication errors
- [ ] 12.2 Document keybinding not working troubleshooting
- [ ] 12.3 Document compositor-specific issues
- [ ] 12.4 Document IPC permission issues
- [ ] 12.5 Provide debugging steps for IPC problems
