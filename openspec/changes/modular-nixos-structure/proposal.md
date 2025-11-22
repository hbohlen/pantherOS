# Change: Modular NixOS Structure with Single-Purpose Files

## Why

pantherOS currently has a monolithic NixOS configuration structure that lacks proper modularity and maintainability. The existing configuration files are growing increasingly complex, making it difficult to manage, debug, and extend. This change proposal introduces a modular structure following NixOS best practices with single-purpose files and default.nix aggregation patterns, which will dramatically improve maintainability, reusability, and scalability of the configuration system.

## What Changes

- Restructure the entire NixOS configuration into modular, single-purpose files
- Implement default.nix files in subdirectories to aggregate related modules
- Establish clear separation of concerns with files serving specific purposes
- Implement proper import patterns using directory-based imports
- Create standardized module templates following NixOS module system conventions
- Update all host configurations to use the new modular structure
- Establish module organization conventions for services, hardware, programs, and system settings
- Implement module testing and validation framework for modular components

## Impact

- Improved maintainability: Changes to specific functionality are isolated to single-purpose files
- Enhanced reusability: Modular components can be reused across different host configurations
- Better scalability: Adding new functionality follows established patterns without bloating single files
- Reduced cognitive load: Developers can focus on specific modules without understanding the entire configuration
- Affected specs: All NixOS configuration-related specs will follow new modular patterns
- Affected code: Host configurations in hosts/ directory, home configurations in home/ directory
- Prerequisite for: Future feature development, configuration testing, and advanced module composition

---

# ADDED Requirements

## Requirement: Modular Directory Structure

The system SHALL provide a well-organized directory structure following NixOS module system best practices with single-purpose files and default.nix aggregation.

#### Scenario: Directory structure implementation
- **WHEN** modular structure is implemented
- **THEN** directory structure SHALL follow pattern: hosts/, home/, modules/ with subdirectories containing single-purpose .nix files
- **AND** each subdirectory SHALL contain a default.nix file that aggregates imports for that category

#### Scenario: Directory import pattern
- **WHEN** main configuration imports directories
- **THEN** imports SHALL reference subdirectories directly (e.g., ./programs, ./services) rather than individual files
- **AND** subdirectory default.nix files SHALL import all relevant modules in that category

## Requirement: Single-Purpose Module Files

The system SHALL ensure each module file serves a single, well-defined purpose and follows the NixOS module pattern.

#### Scenario: Module purpose definition
- **WHEN** creating new modules
- **THEN** each file SHALL focus on configuring a specific service, program, or system aspect
- **AND** module names SHALL clearly indicate their purpose (e.g., git.nix, browsers.nix, i3.nix)

#### Scenario: Module structure compliance
- **WHEN** modules are defined
- **THEN** each module SHALL follow standard NixOS structure with options and config attributes
- **AND** modules SHALL use proper option types, descriptions, and default values

## Requirement: Default.nix Aggregation Pattern

The system SHALL implement default.nix files in subdirectories to aggregate imports and simplify main configurations.

#### Scenario: Subdirectory aggregation
- **WHEN** a subdirectory contains multiple module files
- **THEN** the subdirectory SHALL have a default.nix file that imports all relevant modules
- **AND** main configurations SHALL import the subdirectory directly rather than individual files

#### Scenario: Default.nix content
- **WHEN** creating default.nix files
- **THEN** they SHALL contain an imports attribute with all relevant module files in that category
- **AND** they SHALL return a proper NixOS module structure { imports = [ ... ]; }

## Requirement: Module Composition Standards

The system SHALL establish standards for how modules are composed and combined to build complete configurations.

#### Scenario: Module dependency management
- **WHEN** modules depend on each other
- **THEN** dependencies SHALL be managed through proper import relationships
- **AND** circular dependencies SHALL be avoided through proper module design

#### Scenario: Conditional module activation
- **WHEN** modules should only be active under certain conditions
- **THEN** they SHALL use mkIf conditionals to enable/disable functionality
- **AND** they SHALL properly handle configuration dependencies

## Requirement: Configuration Migration

The system SHALL provide a migration path from current monolithic configuration to the new modular structure.

#### Scenario: Migration approach
- **WHEN** migrating existing configuration
- **THEN** functionality SHALL be preserved while reorganizing into modular structure
- **AND** each existing configuration block SHALL be moved to appropriate single-purpose module

#### Scenario: Backward compatibility
- **WHEN** migration is in progress
- **THEN** both old and new structures SHALL function during transition
- **AND** final implementation SHALL fully utilize new modular patterns

## Requirement: Module Documentation Standards

The system SHALL maintain documentation standards for all modular components to ensure maintainability.

#### Scenario: Module documentation
- **WHEN** creating modules
- **THEN** each module SHALL include documentation about its purpose and configuration options
- **AND** option definitions SHALL include clear descriptions for future maintainers

#### Scenario: Module usage examples
- **WHEN** modules are created
- **THEN** documentation SHALL include example usage patterns
- **AND** complex modules SHALL include configuration examples

## Requirement: Module Testing Framework

The system SHALL implement a testing framework to validate modular components and their interactions.

#### Scenario: Module validation
- **WHEN** modules are created or modified
- **THEN** automated tests SHALL verify module syntax and structure
- **AND** tests SHALL validate option types and configurations

#### Scenario: Integration testing
- **WHEN** multiple modules are combined
- **THEN** tests SHALL verify that modules work together without conflicts
- **AND** tests SHALL validate that module dependencies are properly handled

## Requirement: Host-Specific Configuration Integration

The system SHALL allow host-specific configurations to leverage the modular structure effectively.

#### Scenario: Host configuration structure
- **WHEN** defining host configurations
- **THEN** they SHALL import relevant modules through directory-based imports
- **AND** host-specific settings SHALL be applied on top of modular foundation

#### Scenario: Host module customization
- **WHEN** hosts need specific configurations
- **THEN** they SHALL use module options to customize behavior rather than duplicating functionality
- **AND** customizations SHALL follow same modular principles for consistency