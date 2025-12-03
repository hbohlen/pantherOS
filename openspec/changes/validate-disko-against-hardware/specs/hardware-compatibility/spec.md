# Hardware Compatibility Validation - Spec

## ADDED Requirements

### Requirement: Device Path Validation
The system SHALL verify that all device paths referenced in the proposed disko.nix configuration actually exist in the hardware as reported in facter.json.

#### Scenario: Non-existent Device Path
- **WHEN** the proposed disko.nix references a device path that doesn't exist in facter.json
- **THEN** the system reports this as a critical issue that will prevent deployment

#### Scenario: Device Path Mismatch
- **WHEN** the proposed device type (SSD vs HDD) doesn't match the actual hardware
- **THEN** the system reports potential performance or configuration issues

### Requirement: Partition Scheme Appropriateness
The system SHALL evaluate whether the proposed partition scheme is appropriate for the host type and storage characteristics.

#### Scenario: Laptop Partitioning for Server
- **WHEN** a proposed configuration uses laptop-specific optimizations on a server
- **THEN** the system suggests more appropriate server-oriented partitioning

#### Scenario: Partition Size Exceeds Capacity
- **WHEN** the proposed partition sizes exceed the actual disk capacity
- **THEN** the system reports this as a critical configuration error

### Requirement: Hardware-Specific Optimization Check
The system SHALL validate that mount options and configurations align with the hardware capabilities documented in facter.json.

#### Scenario: SSD-Specific Options on HDD
- **WHEN** SSD-specific mount options (like discard=async) are applied to traditional HDD
- **THEN** the system flags this as inappropriate for the hardware

#### Scenario: NVMe Optimizations on SATA
- **WHEN** NVMe-specific optimizations are applied to SATA storage
- **THEN** the system recommends more appropriate options for the hardware