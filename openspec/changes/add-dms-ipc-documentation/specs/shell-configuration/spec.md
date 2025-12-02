## ADDED Requirements

### Requirement: DankMaterialShell IPC Command Structure

The system SHALL provide a comprehensive IPC (Inter-Process Communication) interface for programmatic control of DankMaterialShell features.

#### Scenario: IPC Command Syntax

- **WHEN** executing IPC commands
- **THEN** command format is: `dms ipc <module> <action> [args...]`
- **AND** module specifies the DMS component to control
- **AND** action specifies the operation to perform
- **AND** args provides optional parameters specific to the action

#### Scenario: Available IPC Modules

- **WHEN** using IPC interface
- **THEN** core modules include: spotlight, notifications, settings, notepad, lock, powermenu, night
- **AND** audio module is available for volume control
- **AND** conditional modules include: processlist (requires enableSystemMonitoring), clipboard (requires enableClipboard), brightness (requires enableBrightnessControl)

#### Scenario: IPC Command Execution

- **WHEN** IPC command is executed
- **THEN** command is sent to running DankMaterialShell instance
- **AND** response or error is returned
- **AND** command execution can be integrated into keybindings or scripts

### Requirement: Core Module IPC Commands

The system SHALL provide IPC commands for controlling core DankMaterialShell interface modules.

#### Scenario: Application Launcher Control

- **WHEN** controlling spotlight module
- **THEN** `dms ipc spotlight toggle` toggles application launcher visibility
- **AND** command can be bound to Mod+Space or custom keybinding

#### Scenario: Notification Center Control

- **WHEN** controlling notifications module
- **THEN** `dms ipc notifications toggle` toggles notification center visibility
- **AND** command can be bound to Mod+N or custom keybinding

#### Scenario: Settings Panel Control

- **WHEN** controlling settings module
- **THEN** `dms ipc settings toggle` toggles settings panel visibility
- **AND** command can be bound to Mod+Comma or custom keybinding

#### Scenario: Notepad Control

- **WHEN** controlling notepad module
- **THEN** `dms ipc notepad toggle` toggles notepad visibility
- **AND** command can be bound to Mod+P or custom keybinding

#### Scenario: Lock Screen Control

- **WHEN** controlling lock module
- **THEN** `dms ipc lock lock` activates lock screen
- **AND** command can be bound to Super+Alt+L or custom keybinding

#### Scenario: Power Menu Control

- **WHEN** controlling powermenu module
- **THEN** `dms ipc powermenu toggle` toggles power menu visibility
- **AND** command can be bound to Mod+X or custom keybinding

#### Scenario: Night Mode Control

- **WHEN** controlling night module
- **THEN** `dms ipc night toggle` toggles night mode
- **AND** command can be bound to Mod+Alt+N or custom keybinding
- **AND** command can be allowed when screen is locked

### Requirement: Audio Control IPC Commands

The system SHALL provide IPC commands for controlling system audio through DankMaterialShell.

#### Scenario: Volume Increment

- **WHEN** increasing system volume
- **THEN** `dms ipc audio increment <percentage>` increases volume
- **AND** percentage parameter specifies volume change amount (e.g., 3, 5, 10)
- **AND** command can be bound to XF86AudioRaiseVolume
- **AND** command can be allowed when screen is locked

#### Scenario: Volume Decrement

- **WHEN** decreasing system volume
- **THEN** `dms ipc audio decrement <percentage>` decreases volume
- **AND** percentage parameter specifies volume change amount (e.g., 3, 5, 10)
- **AND** command can be bound to XF86AudioLowerVolume
- **AND** command can be allowed when screen is locked

#### Scenario: Audio Mute Toggle

- **WHEN** toggling audio mute
- **THEN** `dms ipc audio mute` toggles system audio mute state
- **AND** command can be bound to XF86AudioMute
- **AND** command can be allowed when screen is locked

#### Scenario: Microphone Mute Toggle

- **WHEN** toggling microphone mute
- **THEN** `dms ipc audio micmute` toggles microphone mute state
- **AND** command can be bound to XF86AudioMicMute
- **AND** command can be allowed when screen is locked

### Requirement: Brightness Control IPC Commands

The system SHALL provide IPC commands for controlling display brightness when enableBrightnessControl is true.

#### Scenario: Brightness Increment

- **WHEN** increasing display brightness
- **THEN** `dms ipc brightness increment <percentage> <device>` increases brightness
- **AND** percentage parameter specifies brightness change amount (e.g., 5, 10)
- **AND** device parameter specifies target device (empty string for default)
- **AND** command can be bound to XF86MonBrightnessUp
- **AND** command can be allowed when screen is locked

#### Scenario: Brightness Decrement

- **WHEN** decreasing display brightness
- **THEN** `dms ipc brightness decrement <percentage> <device>` decreases brightness
- **AND** percentage parameter specifies brightness change amount (e.g., 5, 10)
- **AND** device parameter specifies target device (empty string for default)
- **AND** command can be bound to XF86MonBrightnessDown
- **AND** command can be allowed when screen is locked

### Requirement: Conditional Feature IPC Commands

The system SHALL provide IPC commands for optional features that depend on configuration toggles.

#### Scenario: Process List Control

- **WHEN** enableSystemMonitoring is true
- **THEN** `dms ipc processlist toggle` toggles process list visibility
- **AND** command can be bound to Mod+M or custom keybinding
- **AND** command is only available when system monitoring is enabled

#### Scenario: Clipboard Manager Control

- **WHEN** enableClipboard is true
- **THEN** `dms ipc clipboard toggle` toggles clipboard manager visibility
- **AND** command can be bound to Mod+V or custom keybinding
- **AND** command is only available when clipboard is enabled

### Requirement: Niri Compositor Keybinding Integration

The system SHALL provide seamless integration with niri compositor keybinding system through programs.niri.settings.binds configuration.

#### Scenario: Niri Keybinding Syntax

- **WHEN** configuring niri keybindings
- **THEN** bindings use config.lib.niri.actions.spawn for IPC commands
- **AND** format is: spawn "dms" "ipc" "<module>" "<action>" [args...]
- **AND** keybinding includes hotkey-overlay.title for user-visible description
- **AND** allow-when-locked can be set for system-level controls

#### Scenario: Niri Default Keybindings

- **WHEN** programs.dankMaterialShell.niri.enableKeybinds is true
- **THEN** Mod+Space is bound to spotlight toggle
- **AND** Mod+N is bound to notifications toggle
- **AND** Mod+Comma is bound to settings toggle
- **AND** Mod+P is bound to notepad toggle
- **AND** Super+Alt+L is bound to lock screen
- **AND** Mod+X is bound to powermenu toggle
- **AND** XF86Audio* keys are bound to audio controls
- **AND** Mod+Alt+N is bound to night mode toggle

#### Scenario: Niri Conditional Keybindings

- **WHEN** configuring conditional features in niri
- **THEN** lib.attrsets.optionalAttrs is used for feature-gated bindings
- **AND** Mod+M is bound to processlist when cfg.enableSystemMonitoring is true
- **AND** Mod+V is bound to clipboard when cfg.enableClipboard is true
- **AND** XF86MonBrightness* keys are bound when cfg.enableBrightnessControl is true

#### Scenario: Niri Custom Keybindings

- **WHEN** programs.dankMaterialShell.niri.enableKeybinds is false
- **THEN** automatic keybindings are not applied
- **AND** user can define custom keybindings manually
- **AND** user can reference IPC command examples for custom configuration

### Requirement: Hyprland Compositor Keybinding Integration

The system SHALL provide keybinding examples for Hyprland compositor configuration.

#### Scenario: Hyprland Keybinding Syntax

- **WHEN** configuring Hyprland keybindings
- **THEN** bind directive is used for standard keybindings
- **AND** binde directive is used for repeatable actions (volume, brightness)
- **AND** format is: bind = <modifiers>, <key>, exec, dms ipc <module> <action> [args...]

#### Scenario: Hyprland Example Keybindings

- **WHEN** setting up DMS keybindings in Hyprland
- **THEN** documentation provides example bindings for all IPC modules
- **AND** examples include modifier key specifications
- **AND** examples include hardware key mappings
- **AND** examples show conditional binding patterns

### Requirement: Sway Compositor Keybinding Integration

The system SHALL provide keybinding examples for sway compositor configuration.

#### Scenario: Sway Keybinding Syntax

- **WHEN** configuring sway keybindings
- **THEN** bindsym directive is used for keybindings
- **AND** format is: bindsym <modifiers>+<key> exec dms ipc <module> <action> [args...]

#### Scenario: Sway Example Keybindings

- **WHEN** setting up DMS keybindings in sway
- **THEN** documentation provides example bindings for all IPC modules
- **AND** examples include modifier key specifications
- **AND** examples include hardware key mappings
- **AND** examples show conditional binding patterns

### Requirement: IPC Command Reference Documentation

The system SHALL provide comprehensive reference documentation for all IPC commands and their usage.

#### Scenario: Command Reference Table

- **WHEN** users need IPC command reference
- **THEN** documentation includes table with columns: Module, Action, Parameters, Description, Example
- **AND** each IPC command is documented with clear usage examples
- **AND** feature dependencies are noted for conditional commands

#### Scenario: Quick Reference Guide

- **WHEN** users need quick IPC command lookup
- **THEN** documentation provides quick reference with common commands
- **AND** reference includes most frequently used keybindings
- **AND** reference shows typical parameter values

### Requirement: IPC Scripting and Automation

The system SHALL support IPC usage in shell scripts and automation workflows.

#### Scenario: Shell Script Integration

- **WHEN** using IPC in shell scripts
- **THEN** commands can be executed from command line
- **AND** return codes indicate success or failure
- **AND** error messages provide troubleshooting information

#### Scenario: Automation Examples

- **WHEN** automating DMS control
- **THEN** documentation provides examples of common automation patterns
- **AND** examples include conditional execution
- **AND** examples show integration with external tools

### Requirement: IPC Troubleshooting Documentation

The system SHALL provide troubleshooting guidance for IPC-related issues.

#### Scenario: IPC Communication Errors

- **WHEN** IPC commands fail
- **THEN** troubleshooting checks if DMS is running
- **AND** troubleshooting verifies command syntax
- **AND** troubleshooting checks for feature toggle requirements

#### Scenario: Keybinding Issues

- **WHEN** keybindings don't work
- **THEN** troubleshooting verifies compositor configuration
- **AND** troubleshooting checks for keybinding conflicts
- **AND** troubleshooting tests manual IPC command execution
- **AND** troubleshooting verifies compositor restart after configuration changes
