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

The system SHALL manage all required and optional dependencies for DankMaterialShell features through the common.nix module.

#### Scenario: Core Dependencies

- **WHEN** DankMaterialShell is enabled
- **THEN** Quickshell is installed as the core framework via cfg.quickshell.package
- **AND** dgop flake input is configured with proper nixpkgs follows
- **AND** dmsCli is included from dmsPkgs
- **AND** material-symbols, inter, and fira-code fonts are installed
- **AND** ddcutil, qt5ct, and qt6ct are included for Qt theming

#### Scenario: Optional Feature Dependencies

- **WHEN** optional features are enabled
- **THEN** cava is available when cfg.enableAudioWavelength is true
- **AND** cliphist and wl-clipboard are available when cfg.enableClipboard is true
- **AND** matugen is available when cfg.enableDynamicTheming is true
- **AND** kdePackages.qtmultimedia is available when cfg.enableSystemSound is true
- **AND** glib and networkmanager are available when cfg.enableVPN is true
- **AND** brightnessctl is available when cfg.enableBrightnessControl is true
- **AND** hyprpicker is available when cfg.enableColorPicker is true
- **AND** khal is available when cfg.enableCalendarEvents is true

#### Scenario: Compositor Integration

- **WHEN** niri compositor is used
- **THEN** niri-flake can be optionally configured
- **AND** DankMaterialShell provides niri-specific integration via homeModules.dankMaterialShell.niri

### Requirement: DankMaterialShell Feature Configuration

The system SHALL provide comprehensive feature toggles for DankMaterialShell configuration on both NixOS and home-manager modules.

#### Scenario: Systemd Service Configuration (NixOS)

- **WHEN** systemd integration is configured on NixOS module
- **THEN** systemd.user.services.dms is created with description "DankMaterialShell"
- **AND** service is part of graphical-session.target
- **AND** ExecStart runs dmsCli with "run --session" arguments
- **AND** restartTriggers are set to common.qmlPath when cfg.systemd.restartIfChanged is true
- **AND** Restart policy is set to "on-failure"

#### Scenario: Systemd Service Configuration (Home-Manager)

- **WHEN** systemd integration is configured on home-manager module
- **THEN** systemd.user.services.dms is created with Description "DankMaterialShell"
- **AND** service is part of config.wayland.systemd.target
- **AND** X-Restart-Triggers is set to common.qmlPath when cfg.systemd.restartIfChanged is true
- **AND** ExecStart runs dmsCli with "run --session" arguments
- **AND** Install.WantedBy is set to config.wayland.systemd.target

#### Scenario: Core Feature Toggles

- **WHEN** core features are configured via options.nix
- **THEN** programs.dankMaterialShell.enableSystemMonitoring (default: true) controls dgop dependency
- **AND** programs.dankMaterialShell.enableClipboard (default: true) controls cliphist and wl-clipboard
- **AND** programs.dankMaterialShell.enableBrightnessControl (default: true) controls brightnessctl
- **AND** programs.dankMaterialShell.enableColorPicker (default: true) controls hyprpicker

#### Scenario: Visual and Theme Features

- **WHEN** visual features are configured via options.nix
- **THEN** programs.dankMaterialShell.enableDynamicTheming (default: true) controls matugen
- **AND** programs.dankMaterialShell.enableAudioWavelength (default: true) controls cava
- **AND** programs.dankMaterialShell.enableSystemSound (default: true) controls kdePackages.qtmultimedia

#### Scenario: Integration Features

- **WHEN** integration features are configured via options.nix
- **THEN** programs.dankMaterialShell.enableVPN (default: true) controls glib and networkmanager
- **AND** programs.dankMaterialShell.enableCalendarEvents (default: true) controls khal

#### Scenario: Feature Toggle Defaults

- **WHEN** DankMaterialShell is enabled without explicit feature configuration
- **THEN** all feature toggles default to true
- **AND** all optional dependencies are installed by default

### Requirement: DankMaterialShell Niri Integration

The system SHALL provide seamless integration with the niri Wayland compositor through the niri.nix module.

#### Scenario: Niri Prerequisites

- **WHEN** enabling niri integration
- **THEN** niri-flake input must be configured in flake inputs
- **AND** the niri home-manager module must be imported
- **AND** niri-flake's NixOS module automatically includes the home-manager module

#### Scenario: Niri Module Import

- **WHEN** using niri integration
- **THEN** both dankMaterialShell.homeModules.dankMaterialShell.default and dankMaterialShell.homeModules.dankMaterialShell.niri modules are imported
- **AND** niri-specific options become available (niri.enableKeybinds, niri.enableSpawn)

#### Scenario: Niri Keybindings

- **WHEN** programs.dankMaterialShell.niri.enableKeybinds is true
- **THEN** programs.niri.settings.binds are configured with DMS IPC commands
- **AND** Mod+Space toggles spotlight (application launcher)
- **AND** Mod+N toggles notification center
- **AND** Mod+Comma toggles settings
- **AND** Mod+P toggles notepad
- **AND** Super+Alt+L locks screen
- **AND** Mod+X toggles power menu
- **AND** XF86Audio keys control volume and mute
- **AND** Mod+Alt+N toggles night mode
- **AND** Mod+M toggles process list when enableSystemMonitoring is true
- **AND** Mod+V toggles clipboard when enableClipboard is true
- **AND** XF86MonBrightness keys control brightness when enableBrightnessControl is true

#### Scenario: Niri Auto-start

- **WHEN** programs.dankMaterialShell.niri.enableSpawn is true
- **THEN** programs.niri.settings.spawn-at-startup includes "dms run" command
- **AND** wl-paste clipboard watcher is started when enableClipboard is true

#### Scenario: Polkit Agent Conflict Resolution

- **WHEN** using DankMaterialShell's built-in polkit agent with niri-flake's NixOS module
- **THEN** systemd.user.services.niri-flake-polkit.enable must be set to false
- **AND** this prevents conflicts between polkit agents

### Requirement: DankMaterialShell Customization

The system SHALL support advanced customization through custom Quickshell packages, default settings, and plugin architecture via home.nix module.

#### Scenario: Custom Quickshell Package

- **WHEN** a custom Quickshell version is needed
- **THEN** programs.dankMaterialShell.quickshell.package can be set via lib.mkPackageOption
- **AND** the custom package replaces the default Quickshell installation
- **AND** programs.quickshell.package is automatically set to cfg.quickshell.package

#### Scenario: Quickshell Config Integration (Home-Manager Only)

- **WHEN** DankMaterialShell is enabled on home-manager
- **THEN** programs.quickshell.enable is set to true
- **AND** programs.quickshell.configs.dms is set to common.qmlPath
- **AND** DMS configuration is registered with Quickshell

#### Scenario: Default Settings Configuration (Home-Manager Only)

- **WHEN** programs.dankMaterialShell.default.settings is configured with jsonFormat type
- **THEN** xdg.configFile."DankMaterialShell/default-settings.json" is created
- **AND** default settings include theme, dynamicTheming, and other options
- **AND** settings are only read if settings.json doesn't exist
- **AND** existing user configuration is never overridden

#### Scenario: Default Session State (Home-Manager Only)

- **WHEN** programs.dankMaterialShell.default.session is configured with jsonFormat type
- **THEN** xdg.stateFile."DankMaterialShell/default-session.json" is created
- **AND** default session state is only read if session.json doesn't exist

#### Scenario: Plugin Installation (Home-Manager Only)

- **WHEN** programs.dankMaterialShell.plugins is configured as attrsOf submodule
- **THEN** each plugin has enable (bool) and src (path) options
- **AND** xdg.configFile."DankMaterialShell/plugins/${name}" links to plugin.src
- **AND** only enabled plugins are linked
- **AND** plugins are managed declaratively through Nix

## ADDED Requirements

### Requirement: DankMaterialShell Greeter Support

The system SHALL provide a DankMaterialShell-based greeter for login screens via greeter.nix module.

#### Scenario: Greeter Configuration

- **WHEN** programs.dankMaterialShell.greeter.enable is true
- **THEN** services.greetd.enable is set to true by default
- **AND** greeter runs with specified compositor (niri, hyprland, or sway)
- **AND** dms-greeter script is generated with proper paths and commands

#### Scenario: Greeter Compositor Selection

- **WHEN** greeter compositor is configured
- **THEN** programs.dankMaterialShell.greeter.compositor.name must be one of ["niri" "hyprland" "sway"]
- **AND** programs.dankMaterialShell.greeter.compositor.customConfig can provide compositor-specific config
- **AND** compositor package is included in PATH for greeter script

#### Scenario: Greeter Configuration Files

- **WHEN** greeter config files are needed
- **THEN** programs.dankMaterialShell.greeter.configFiles lists paths to copy
- **AND** programs.dankMaterialShell.greeter.configHome can specify user home for standard DMS config locations
- **AND** settings.json, session.json, and dms-colors.json are copied to /var/lib/dmsgreeter

#### Scenario: Greeter User Setup

- **WHEN** greeter is enabled
- **THEN** user for greetd default_session must exist
- **AND** /var/lib/dmsgreeter directory is created with correct permissions
- **AND** systemd tmpfiles configures directory ownership

#### Scenario: Greeter Logging

- **WHEN** programs.dankMaterialShell.greeter.logs.save is enabled
- **THEN** greeter output is saved to logs.path (default: /tmp/dms-greeter.log)

#### Scenario: Greeter Deprecated Options

- **WHEN** old greeter options are used
- **THEN** programs.dankMaterialShell.greeter.compositor.extraConfig is removed with migration message
- **AND** users are directed to use compositor.customConfig instead

### Requirement: DankMaterialShell Option Migration

The system SHALL handle deprecated and renamed options gracefully with clear migration paths.

#### Scenario: Removed Night Mode Option

- **WHEN** old enableNightMode option is referenced
- **THEN** lib.mkRemovedOptionModule is used with message "Night mode is now always available."
- **AND** users are informed night mode is built-in

#### Scenario: Renamed Systemd Option

- **WHEN** old enableSystemd option is referenced
- **THEN** lib.mkRenamedOptionModule redirects to programs.dankMaterialShell.systemd.enable
- **AND** configuration continues to work with new option path

### Requirement: DankMaterialShell Module Documentation References

The system SHALL maintain clear references to module documentation for advanced configuration.

#### Scenario: Module File References

- **WHEN** users need advanced configuration options
- **THEN** NixOS module documentation is available at distro/nix/nixos.nix
- **AND** home-manager module documentation is available at distro/nix/home.nix
- **AND** niri module documentation is available at distro/nix/niri.nix
- **AND** common options documentation is available at distro/nix/options.nix
- **AND** greeter module documentation is available at distro/nix/greeter.nix

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
