## ADDED Requirements
### Requirement: Development Environment Setup
The system SHALL provide a properly configured development environment with XDG compliance.

#### Scenario: XDG directories configured
- **WHEN** user logs in
- **THEN** XDG_CONFIG_HOME points to ~/.config
- **AND** XDG_CACHE_HOME points to ~/.cache
- **AND** XDG_DATA_HOME points to ~/.local/share

#### Scenario: Language caches optimized
- **WHEN** development tools run
- **THEN** npm cache uses ~/.cache/npm
- **AND** cargo home uses ~/.cache/cargo
- **AND** pip cache uses ~/.cache/pip

#### Scenario: Directory structure created
- **WHEN** system activates
- **THEN** user directories exist with correct permissions
- **AND** .ssh directories have 700 permissions
- **AND** cache directories are owned by user

#### Scenario: Editor configured
- **WHEN** EDITOR variable is used
- **THEN** it defaults to nvim
- **AND** VISUAL also uses nvim</content>
<parameter name="filePath">openspec/implemented/development-environment/spec.md