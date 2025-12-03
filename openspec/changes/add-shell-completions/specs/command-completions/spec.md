# Command Completions Specification

## ADDED Requirements

### Requirement: Shell Completion System
The system SHALL provide comprehensive tab completions for all custom commands and tools in Fish shell.

#### Scenario: Complete custom command
- **WHEN** user types a custom command and presses Tab
- **THEN** available subcommands and options are suggested
- **AND** suggestions include descriptions
- **AND** completion is context-aware (e.g., only valid options)

#### Scenario: Complete command arguments
- **WHEN** user is completing command arguments
- **THEN** valid argument values are suggested dynamically
- **AND** completion includes file paths when appropriate
- **AND** invalid arguments are not suggested

### Requirement: Dynamic Resource Completion
The system SHALL provide dynamic completions for system resources like services, containers, and hosts.

#### Scenario: Complete systemd service names
- **WHEN** completing a systemctl command
- **THEN** list of available services is provided
- **AND** running vs stopped services are distinguished
- **AND** service descriptions are shown

#### Scenario: Complete container names
- **WHEN** completing podman container commands
- **THEN** running container names are suggested
- **AND** container IDs are included as alternatives
- **AND** stopped containers are available for relevant commands

#### Scenario: Complete hostname for SSH
- **WHEN** completing ssh or remote commands
- **THEN** configured hosts from SSH config are suggested
- **AND** hosts from /etc/hosts are included
- **AND** recently used hosts are prioritized

### Requirement: Tool-Specific Completions
The system SHALL integrate completions for all installed development and system tools.

#### Scenario: OpenCode command completion
- **WHEN** completing opencode commands
- **THEN** agents, workflows, and commands are suggested
- **AND** available skills are listed
- **AND** configuration options are completed

#### Scenario: NixOS command completion
- **WHEN** completing nix or nixos- commands
- **THEN** flake references are suggested
- **AND** attribute paths are completed
- **AND** common flags and options are available

### Requirement: Completion Performance
The system SHALL ensure completions respond quickly without noticeable lag.

#### Scenario: Fast completion response
- **WHEN** user requests completions
- **THEN** suggestions appear within 100ms
- **AND** expensive completions are cached
- **AND** cache is invalidated appropriately

#### Scenario: Cached dynamic completions
- **WHEN** dynamic completions are requested
- **THEN** cached results are used if still valid
- **AND** cache refreshes in background if stale
- **AND** cache invalidation is triggered by relevant events

### Requirement: Completion Discoverability
The system SHALL make completions discoverable and helpful for learning commands.

#### Scenario: Display completion descriptions
- **WHEN** viewing completions
- **THEN** each option includes a brief description
- **AND** descriptions explain option purpose
- **AND** examples are shown for complex completions

#### Scenario: Alias completion works transparently
- **WHEN** using aliased commands
- **THEN** completions for underlying command are available
- **AND** alias-specific behavior is preserved
- **AND** descriptions reference the alias name
