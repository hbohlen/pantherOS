# Firewall Specification

## ADDED Requirements

### Requirement: Firewall Rule Management
The system SHALL provide declarative firewall configuration using nftables with support for zones, rules, and port management.

#### Scenario: Default firewall is configured
- **WHEN** firewall module is enabled
- **THEN** SSH port (22) is allowed by default
- **AND** all other incoming traffic is dropped
- **AND** outgoing traffic is allowed
- **AND** firewall starts automatically on boot

#### Scenario: Open port for service
- **WHEN** a port is added to allowed ports
- **THEN** firewall rule is created for TCP/UDP
- **AND** rule takes effect immediately
- **AND** port is accessible from configured sources

#### Scenario: Zone-based firewall rules
- **WHEN** network zones are configured (trusted, public, dmz)
- **THEN** different rule sets apply per zone
- **AND** traffic between zones is controlled
- **AND** zone assignments can be per-interface

### Requirement: Firewall Logging and Monitoring
The system SHALL log firewall events and provide monitoring capabilities for security analysis.

#### Scenario: Log dropped packets
- **WHEN** packets are dropped by firewall
- **THEN** events are logged with source, destination, and reason
- **AND** log volume can be rate-limited
- **AND** logs are accessible via journalctl

#### Scenario: Monitor firewall statistics
- **WHEN** querying firewall statistics
- **THEN** packet counts and byte counts are available per rule
- **AND** statistics can be exported for monitoring
- **AND** connection tracking information is accessible

### Requirement: Firewall Safety
The system SHALL prevent firewall misconfigurations that could lock out system access.

#### Scenario: SSH protection during changes
- **WHEN** firewall rules are updated
- **THEN** SSH access is always maintained
- **AND** rule validation occurs before activation
- **AND** rollback is possible if rules fail

#### Scenario: Validate firewall configuration
- **WHEN** firewall configuration is built
- **THEN** syntax and semantics are validated
- **AND** rule conflicts are detected
- **AND** warnings are issued for overly permissive rules
