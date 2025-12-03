## Purpose

This specification defines the standards and requirements for NixOS configuration files in the PantherOS system, ensuring code quality, consistency, and maintainability across all host configurations.
## Requirements
### Requirement: Personal Device Host Support with Facter

The system SHALL support configuration of personal devices (zephyrus and yoga) with dedicated host directories containing default.nix, hardware.nix, disko.nix, and meta.nix files generated using facter.

#### Scenario: Host directories with meta.nix exist

- **WHEN** personal device hosts are configured
- **THEN** /hosts/zephyrus/ and /hosts/yoga/ directories exist with default.nix, hardware.nix, disko.nix, and meta.nix files

#### Scenario: Facter-based hardware scanning prerequisite

- **WHEN** implementing hardware.nix and disko.nix
- **THEN** facter must be used to scan hardware and generate meta.nix files first

#### Scenario: Meta.nix structured data

- **WHEN** facter collects hardware specs
- **THEN** meta.nix contains structured Nix attribute sets for CPU, RAM, storage, network, and GPU information

#### Scenario: Configuration isolation

- **WHEN** personal device configurations are built
- **THEN** they remain isolated from server configurations

#### Scenario: Build validation

- **WHEN** host configurations are created
- **THEN** they build successfully without errors

### Requirement: Code Quality
All NixOS configuration files SHALL be free of unresolved TODO comments. Outstanding work SHALL be documented with inline comments explaining the context and any blockers.

#### Scenario: TODO comments resolved
- **WHEN** reviewing configuration files
- **THEN** no TODO comments exist without proper context or documentation
- **AND** any known issues are documented with clear explanations

#### Scenario: Unfinished work documented
- **WHEN** a feature cannot be implemented immediately
- **THEN** it is documented with a comment explaining the reason
- **AND** alternatives or workarounds are noted if available

### Requirement: Configuration Consistency
All server configurations SHALL import the common modules directory to ensure consistent functionality across all hosts.

#### Scenario: Module imports are consistent
- **WHEN** comparing server configurations
- **THEN** all hosts import the ../../modules directory
- **AND** configuration structure is uniform across hosts

#### Scenario: Configuration changes are applied uniformly
- **WHEN** a new module is added to the modules directory
- **THEN** all server hosts automatically include it via the modules import
- **AND** no manual synchronization is required

### Requirement: Commented Code Documentation
All commented configuration blocks SHALL include inline documentation explaining why they are disabled and under what conditions they should be enabled.

#### Scenario: Commented code has clear purpose
- **WHEN** reviewing commented configuration blocks
- **THEN** each block has a comment explaining its purpose
- **AND** activation requirements or conditions are documented

#### Scenario: Modules have descriptive headers
- **WHEN** opening a module file
- **THEN** a header comment describes the module's purpose
- **AND** usage examples or notes are provided where helpful

