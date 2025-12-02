## ADDED Requirements

### Requirement: 1Password Integration Module

The system SHALL provide a standardized 1Password integration module following official 1Password developer documentation.

#### Scenario: Module creation

- **WHEN** configuring 1Password on personal devices
- **THEN** a reusable module is available at `modules/security/1password.nix`
- **AND** the module follows the pattern from https://developer.1password.com/docs/cli/get-started/#install
- **AND** the module enables both CLI and GUI components

#### Scenario: Polkit integration

- **WHEN** enabling 1Password GUI
- **THEN** polkitPolicyOwners configuration is required
- **AND** polkit service is automatically enabled
- **AND** system authentication works correctly
- **AND** only mate-polkit is used as the authentication agent
- **AND** conflicting polkit agents (gnome, kde, xfce) are disabled

### Requirement: Consistent Personal Device Configuration

The system SHALL apply consistent 1Password configuration across all personal devices.

#### Scenario: Zephyrus configuration

- **WHEN** zephyrus host is configured
- **THEN** 1Password module is enabled with user hbohlen as polkit owner
- **AND** both CLI and GUI are available
- **AND** system authentication is properly integrated

#### Scenario: Yoga configuration

- **WHEN** yoga host is configured
- **THEN** 1Password module is enabled with user hbohlen as polkit owner
- **AND** both CLI and GUI are available
- **AND** system authentication is properly integrated

### Requirement: Server Configuration Separation

The system SHALL maintain separate 1Password configuration for servers using OpNix.

#### Scenario: Server secret management

- **WHEN** configuring servers (hetzner-vps, ovh-vps)
- **THEN** services.onepassword-secrets (OpNix) is used instead of desktop module
- **AND** CLI is available via package if needed
- **AND** GUI is not installed on servers
- **AND** secrets are managed through OpNix service

### Requirement: Mate-Polkit as Sole Authentication Agent

The system SHALL ensure mate-polkit is the only polkit authentication agent running.

#### Scenario: Polkit agent exclusivity

- **WHEN** 1Password security module is enabled
- **THEN** mate-polkit is configured as the authentication agent
- **AND** gnome-polkit is explicitly disabled
- **AND** kde-polkit is explicitly disabled
- **AND** xfce-polkit is explicitly disabled
- **AND** no conflicting polkit agents can start

#### Scenario: Integration with existing modules

- **WHEN** niri or DankMaterialShell modules configure mate-polkit
- **THEN** 1Password module does not interfere with mate-polkit setup
- **AND** both modules cooperate to ensure mate-polkit exclusivity
- **AND** no duplicate polkit agents are started

### Requirement: Documentation and Best Practices

The system SHALL document 1Password integration patterns and usage.

#### Scenario: Module documentation

- **WHEN** developers need to configure 1Password
- **THEN** module documentation explains configuration options
- **AND** examples show proper usage patterns
- **AND** official 1Password documentation links are provided

#### Scenario: Personal vs server guidance

- **WHEN** choosing 1Password configuration approach
- **THEN** documentation clarifies when to use desktop module (personal devices)
- **AND** when to use OpNix service (servers)
- **AND** differences between approaches are explained
