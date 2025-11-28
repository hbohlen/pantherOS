## ADDED Requirements

### Requirement: Terminal Utilities Available

The system SHALL provide modern terminal utilities for efficient development workflows.

#### Scenario: fzf fuzzy finder available

- **WHEN** user runs fzf command
- **THEN** fuzzy finding functionality is available

#### Scenario: eza enhanced ls available

- **WHEN** user runs eza command
- **THEN** enhanced file listing is available

#### Scenario: fish shell available

- **WHEN** user runs fish command
- **THEN** fish shell starts successfully

### Requirement: Fish Default Shell

The system SHALL set fish as the default shell while maintaining bash compatibility.

#### Scenario: Fish is default shell

- **WHEN** hbohlen user logs in
- **THEN** fish shell is the active shell

#### Scenario: Bash remains available

- **WHEN** user explicitly runs bash
- **THEN** bash shell is available for compatibility</content>
  <parameter name="filePath">openspec/changes/add-terminal-tools/specs/terminal-tools/spec.md
