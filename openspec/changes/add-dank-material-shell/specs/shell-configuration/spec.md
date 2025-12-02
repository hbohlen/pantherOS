## MODIFIED Requirements

### Requirement: DankMaterialShell Integration

The system SHALL provide DankMaterialShell as the default shell configuration on personal devices with comprehensive installation methods and dependency management.

#### Scenario: Flake-based Installation

- **WHEN** adding DankMaterialShell to the system
- **THEN** dgop and dankMaterialShell flake inputs are configured in flake.nix
- **AND** nixpkgs follows are properly set for both inputs
- **AND** the system supports both NixOS module and home-manager module installation methods

#### Scenario: NixOS Module Installation

- **WHEN** using the NixOS module installation method
- **THEN** the dankMaterialShell.nixosModules.dankMaterialShell module is imported
- **AND** packages are installed system-wide
- **AND** quickshell configs are placed in /etc/xdg/quickshell/dms

#### Scenario: Home-Manager Module Installation

- **WHEN** using the home-manager module installation method
- **THEN** the dankMaterialShell.homeModules.dankMaterialShell.default module is imported
- **AND** per-user installation is configured
- **AND** plugins, default settings, and default session configuration are supported

#### Scenario: Personal Device Scope

- **WHEN** DankMaterialShell is configured
- **THEN** it only affects personal devices (zephyrus, yoga)
- **AND** server configurations (hetzner-vps, ovh-vps) remain unchanged

### Requirement: DankMaterialShell Dependencies

The system SHALL manage all required and optional dependencies for DankMaterialShell features.

#### Scenario: Core Dependencies

- **WHEN** DankMaterialShell is enabled
- **THEN** Quickshell is installed as the core framework
- **AND** dgop flake input is configured with proper nixpkgs follows

#### Scenario: Optional Feature Dependencies

- **WHEN** optional features are enabled
- **THEN** cava is available for audio visualizer widget
- **AND** cliphist and wl-clipboard are available for clipboard history
- **AND** matugen is available for Material Design color palette generation
- **AND** qt6-multimedia is available for system sound feedback
- **AND** dsearch is available for filesystem search engine

#### Scenario: Compositor Integration

- **WHEN** niri compositor is used
- **THEN** niri-flake can be optionally configured
- **AND** DankMaterialShell provides niri-specific integration options

### Requirement: DankMaterialShell Feature Configuration

The system SHALL provide comprehensive feature toggles for DankMaterialShell configuration on both NixOS and home-manager modules.

#### Scenario: Systemd Service Configuration

- **WHEN** systemd integration is configured
- **THEN** programs.dankMaterialShell.systemd.enable controls auto-start functionality
- **AND** programs.dankMaterialShell.systemd.restartIfChanged controls automatic restart on configuration changes

#### Scenario: Core Feature Toggles

- **WHEN** core features are configured
- **THEN** enableSystemMonitoring controls system monitoring widgets with dgop
- **AND** enableClipboard controls clipboard history manager
- **AND** enableBrightnessControl controls backlight/brightness controls
- **AND** enableColorPicker controls color picker tool functionality

#### Scenario: Visual and Theme Features

- **WHEN** visual features are configured
- **THEN** enableDynamicTheming controls wallpaper-based theming with matugen
- **AND** enableAudioWavelength controls audio visualizer with cava
- **AND** enableSystemSound controls system sound effects with qt6-multimedia

#### Scenario: Integration Features

- **WHEN** integration features are configured
- **THEN** enableVPN controls VPN management widget
- **AND** enableCalendarEvents controls calendar integration with khal

### Requirement: DankMaterialShell Niri Integration

The system SHALL provide seamless integration with the niri Wayland compositor when configured.

#### Scenario: Niri Prerequisites

- **WHEN** enabling niri integration
- **THEN** niri-flake input must be configured in flake inputs
- **AND** the niri home-manager module must be imported
- **AND** niri-flake's NixOS module automatically includes the home-manager module

#### Scenario: Niri Module Import

- **WHEN** using niri integration
- **THEN** both dankMaterialShell.homeModules.dankMaterialShell.default and dankMaterialShell.homeModules.dankMaterialShell.niri modules are imported
- **AND** niri-specific features become available

#### Scenario: Niri Keybindings

- **WHEN** programs.dankMaterialShell.niri.enableKeybinds is true
- **THEN** automatic keybinding configuration is applied for launcher, notifications, settings, and all DankMaterialShell features

#### Scenario: Niri Auto-start

- **WHEN** programs.dankMaterialShell.niri.enableSpawn is true
- **THEN** DankMaterialShell automatically starts with niri compositor

#### Scenario: Polkit Agent Conflict Resolution

- **WHEN** using DankMaterialShell's built-in polkit agent with niri-flake's NixOS module
- **THEN** systemd.user.services.niri-flake-polkit.enable must be set to false
- **AND** this prevents conflicts between polkit agents

### Requirement: DankMaterialShell Customization

The system SHALL support advanced customization through custom Quickshell packages, default settings, and plugin architecture.

#### Scenario: Custom Quickshell Package

- **WHEN** a custom Quickshell version is needed
- **THEN** programs.dankMaterialShell.quickshell.package can be set to a custom package
- **AND** the custom package replaces the default Quickshell installation

#### Scenario: Default Settings Configuration (Home-Manager Only)

- **WHEN** programs.dankMaterialShell.default.settings is configured
- **THEN** default theme, dynamicTheming, and other settings are pre-configured
- **AND** settings are only applied if files don't already exist
- **AND** existing user configuration is never overridden

#### Scenario: Default Session State (Home-Manager Only)

- **WHEN** programs.dankMaterialShell.default.session is configured
- **THEN** session state defaults are set
- **AND** defaults are only applied on first launch

#### Scenario: Plugin Installation (Home-Manager Only)

- **WHEN** programs.dankMaterialShell.plugins are configured
- **THEN** plugins can be enabled declaratively with src path
- **AND** plugins are installed and managed by the system

## ADDED Requirements

### Requirement: DankMaterialShell Module Documentation References

The system SHALL maintain clear references to module documentation for advanced configuration.

#### Scenario: Module File References

- **WHEN** users need advanced configuration options
- **THEN** NixOS module documentation is available at distro/nix/nixos.nix
- **AND** home-manager module documentation is available at distro/nix/home.nix
- **AND** niri module documentation is available at distro/nix/niri.nix
- **AND** common options documentation is available at distro/nix/options.nix

### Requirement: DankMaterialShell System Rebuild Process

The system SHALL support proper rebuild processes for both installation methods.

#### Scenario: Home-Manager Standalone Rebuild

- **WHEN** using home-manager standalone installation
- **THEN** changes are applied with `home-manager switch` command

#### Scenario: NixOS with Home-Manager Rebuild

- **WHEN** using NixOS with home-manager as a module
- **THEN** changes are applied with `sudo nixos-rebuild switch` command

### Requirement: DankMaterialShell Troubleshooting Support

The system SHALL provide clear troubleshooting guidance for common issues.

#### Scenario: Auto-start Troubleshooting

- **WHEN** DankMaterialShell doesn't start automatically
- **THEN** either systemd.enable must be true for systemd-based startup
- **OR** niri.enableSpawn must be true for niri-managed startup

#### Scenario: Missing Dependencies Troubleshooting

- **WHEN** a feature isn't working
- **THEN** the corresponding enable option must be set to true
- **AND** each feature's dependencies are automatically installed when enabled

#### Scenario: Keybindings Conflict Resolution

- **WHEN** niri.enableKeybinds conflicts with existing niri configuration
- **THEN** the option can be disabled
- **AND** manual keybinding configuration can be used instead
- **AND** examples are available in the Keybinds & IPC guide
