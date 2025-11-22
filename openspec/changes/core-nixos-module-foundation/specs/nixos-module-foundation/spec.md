## ADDED Requirements

### Requirement: NixOS Module Foundation Structure

The system SHALL provide a complete, organized `modules/nixos/` directory structure following single-concern principles and 2025 NixOS best practices.

#### Scenario: Module directory creation
- **WHEN** foundation is implemented
- **THEN** complete `modules/nixos/` structure SHALL exist with core/, services/, security/, filesystems/, and hardware/ subdirectories

#### Scenario: Module import patterns
- **WHEN** host configurations are updated
- **THEN** all imports SHALL use relative paths and follow established dependency patterns

### Requirement: Core System Modules

The system SHALL provide fundamental system modules for boot configuration, systemd management, and base NixOS settings.

#### Scenario: Core module activation
- **WHEN** host imports core modules
- **THEN** system SHALL have properly configured bootloader, systemd settings, and base system configuration

#### Scenario: Boot configuration
- **WHEN** boot module is enabled
- **THEN** system SHALL be configured with appropriate bootloader settings, kernel parameters, and initrd configuration

#### Scenario: Systemd optimization
- **WHEN** systemd module is enabled
- **THEN** system SHALL have optimized systemd services, proper journald configuration, and service management

### Requirement: Security Module Structure

The system SHALL provide a comprehensive security module structure to enable the security-hardening-improvements proposal.

#### Scenario: Security module foundation
- **WHEN** security modules are implemented
- **THEN** structure SHALL support firewall configuration, SSH hardening, systemd service hardening, and kernel security parameters

#### Scenario: Firewall integration
- **WHEN** security module is enabled
- **THEN** system SHALL have configurable firewall rules supporting Tailscale-only access and host-specific policies

#### Scenario: SSH hardening
- **WHEN** SSH security module is enabled
- **THEN** SSH SHALL be configured with modern security practices, key management, and access controls

### Requirement: Service Module Structure

The system SHALL provide a service module structure for network services and system daemons.

#### Scenario: Tailscale integration
- **WHEN** Tailscale module is enabled
- **THEN** system SHALL have properly configured Tailscale with exit node settings, ACL support, and mesh networking

#### Scenario: Service management
- **WHEN** service modules are imported
- **THEN** each service SHALL be independently configurable with proper dependency management

### Requirement: Filesystem Module Structure

The system SHALL provide a filesystem module structure to enable the btrfs-impermanence-snapshots proposal.

#### Scenario: Btrfs module foundation
- **WHEN** filesystem modules are implemented
- **THEN** structure SHALL support Btrfs optimization, impermanence configuration, and snapshot management

#### Scenario: Mount management
- **WHEN** filesystem module is enabled
- **THEN** system SHALL have properly configured mount points, subvolume management, and SSD optimizations

### Requirement: Hardware-Specific Module Structure

The system SHALL provide hardware-specific module organization for different host classifications.

#### Scenario: Hardware module organization
- **WHEN** hardware modules are implemented
- **THEN** structure SHALL separate workstation, server, and shared hardware configurations

#### Scenario: Host classification
- **WHEN** hardware module is imported
- **THEN** system SHALL apply appropriate hardware-specific settings based on host type

### Requirement: Module Design Patterns

The system SHALL establish consistent module design patterns using proper NixOS module system conventions.

#### Scenario: Option design
- **WHEN** creating modules
- **THEN** all modules SHALL use `mkEnableOption` for enable/disable and `mkOption` for configuration with proper types and defaults

#### Scenario: Dependency management
- **WHEN** modules depend on each other
- **THEN** dependencies SHALL be explicitly managed with `mkIf` conditions and proper import ordering

### Requirement: Module Documentation Framework

The system SHALL provide a documentation framework for all NixOS modules.

#### Scenario: Module documentation
- **WHEN** modules are created
- **THEN** each module category SHALL have comprehensive documentation with usage examples and option descriptions

#### Scenario: API documentation
- **WHEN** module options are defined
- **THEN** all options SHALL have clear descriptions, types, and example configurations

### Requirement: Module Testing Framework

The system SHALL provide a testing framework for NixOS modules to ensure reliability and prevent regressions.

#### Scenario: Module validation
- **WHEN** modules are modified
- **THEN** automated tests SHALL validate module compilation, option types, and basic functionality

#### Scenario: Integration testing
- **WHEN** multiple modules are combined
- **THEN** tests SHALL verify module interactions and dependency resolution

### Requirement: Host Configuration Migration

The system SHALL provide a migration path for existing host configurations to use the new module structure.

#### Scenario: Configuration migration
- **WHEN** host configurations are updated
- **THEN** existing functionality SHALL be preserved while using new modular structure

#### Scenario: Backward compatibility
- **WHEN** migration is in progress
- **THEN** system SHALL support both old and new configuration patterns during transition period