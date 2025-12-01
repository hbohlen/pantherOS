## ADDED Requirements

### Requirement: Ghostty Terminal Available

The system SHALL provide ghostty as the primary terminal emulator on personal devices.

#### Scenario: Ghostty package installed

- **WHEN** user runs ghostty command on personal devices
- **THEN** ghostty terminal emulator starts successfully

#### Scenario: Ghostty is default terminal

- **WHEN** user launches terminal on personal devices
- **THEN** ghostty is the default terminal emulator

### Requirement: Terminal Integration Maintained

The system SHALL maintain integration between ghostty and existing shell/tools configuration.

#### Scenario: Fish shell integration

- **WHEN** ghostty is launched
- **THEN** fish shell is available with existing configuration

#### Scenario: Terminal utilities available

- **WHEN** user needs fuzzy finding or enhanced listing
- **THEN** fzf and eza remain available within ghostty

### Requirement: Personal Device Scope

The system SHALL apply ghostty configuration only to personal devices.

#### Scenario: Personal devices affected

- **WHEN** deploying to zephyrus or yoga hosts
- **THEN** ghostty is configured as default terminal

#### Scenario: Server configurations unchanged

- **WHEN** deploying to hetzner-vps host
- **THEN** existing terminal configuration remains unchanged</content>
  <parameter name="filePath">openspec/changes/set-ghostty-as-default-terminal/specs/terminal-emulator/spec.md
