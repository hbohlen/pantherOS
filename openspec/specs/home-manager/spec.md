## ADDED Requirements
### Requirement: Home Manager Integration
The system SHALL provide declarative user environment management through Home Manager.

#### Scenario: Home Manager flake input available
- **WHEN** flake.nix is evaluated
- **THEN** home-manager input is available for user configuration

#### Scenario: Home Manager module loaded
- **WHEN** NixOS configuration is built
- **THEN** home-manager module is imported and configured

#### Scenario: User configuration block exists
- **WHEN** system configuration loads
- **THEN** home-manager.users.hbohlen configuration block is defined</content>
<parameter name="filePath">openspec/changes/add-home-manager-setup/specs/home-manager/spec.md