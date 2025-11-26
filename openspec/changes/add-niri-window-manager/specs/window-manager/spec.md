## ADDED Requirements

### Requirement: Niri Window Manager
The system SHALL provide Niri as the default window manager on personal devices (zephyrus and yoga), offering a scrollable-tiling Wayland compositor for efficient window management.

#### Scenario: Window Manager Activation
- **WHEN** a user logs into a personal device (zephyrus or yoga)
- **THEN** Niri window manager is automatically started
- **AND** provides scrollable-tiling window management

#### Scenario: DankMaterialShell Integration
- **WHEN** Niri is enabled on personal devices
- **THEN** DankMaterialShell keybindings are automatically configured for Niri
- **AND** DankMaterialShell launches automatically with Niri

#### Scenario: Polkit Agent Conflict Resolution
- **WHEN** Niri is integrated with DankMaterialShell on personal devices
- **THEN** niri-flake's default polkit agent is disabled
- **AND** DankMaterialShell's built-in polkit agent is used exclusively
- **AND** no polkit agent conflicts occur during system operation

#### Scenario: Personal Device Scope
- **WHEN** Niri window manager is configured
- **THEN** it only affects personal devices (zephyrus, yoga)
- **AND** server configurations (hetzner-vps, ovh-vps) remain unchanged

#### Scenario: Flake Input Management
- **WHEN** Niri is added to the system
- **THEN** niri flake input is properly configured with nixpkgs follows
- **AND** homeModules are imported in personal device configurations