## ADDED Requirements

### Requirement: Module Size Limits

The system SHALL maintain module files below 250 lines of code (excluding comments and blank lines) to ensure maintainability and clarity.

#### Scenario: Large module detection

- **WHEN** a module file exceeds 250 lines
- **THEN** it should be evaluated for decomposition into smaller, focused modules
- **AND** logical groupings should be identified for splitting

#### Scenario: Module organization

- **WHEN** splitting a large module
- **THEN** create a subdirectory with the module name
- **AND** split into focused component files
- **AND** maintain a main aggregator file that imports the components

### Requirement: Module Decomposition

The system SHALL decompose large modules into focused, single-responsibility components.

#### Scenario: Widget decomposition

- **WHEN** desktop-shells/dankmaterial/widgets.nix is refactored
- **THEN** create widgets/ subdirectory with focused modules
- **AND** each widget type has its own module file
- **AND** main widgets.nix imports all widget modules

#### Scenario: Service decomposition

- **WHEN** desktop-shells/dankmaterial/services.nix is refactored
- **THEN** create services/ subdirectory with focused modules
- **AND** each service category has its own module file
- **AND** main services.nix imports all service modules

#### Scenario: Dotfiles decomposition

- **WHEN** home-manager/dotfiles/opencode-ai.nix is refactored
- **THEN** create opencode/ subdirectory with logical sections
- **AND** split into config.nix, agents.nix, workflows.nix, aliases.nix
- **AND** main opencode-ai.nix imports all sections

### Requirement: Backward Compatibility

The system SHALL maintain backward compatibility during module refactoring.

#### Scenario: Import compatibility

- **WHEN** modules are refactored
- **THEN** existing imports continue to work without changes
- **AND** no functionality is lost or broken

#### Scenario: Configuration compatibility

- **WHEN** module structure changes
- **THEN** all existing configurations remain valid
- **AND** no host configurations need updating due to refactoring
