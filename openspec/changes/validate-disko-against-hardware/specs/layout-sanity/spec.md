# Layout Sanity Validation - Spec

## ADDED Requirements

### Requirement: Essential Subvolume Detection
The system SHALL identify if essential subvolumes are missing from the proposed configuration.

#### Scenario: Missing Root Subvolume
- **WHEN** the proposed configuration lacks a root subvolume
- **THEN** the system reports this as a critical issue that would make the system unbootable

#### Scenario: Missing Nix Subvolume
- **WHEN** the proposed configuration doesn't separate the Nix store
- **THEN** the system recommends this separation as an important best practice

### Requirement: Subvolume Over-fragmentation Check
The system SHALL detect when subvolumes are unnecessarily fragmented, creating management overhead without clear benefits.

#### Scenario: Excessive Small Subvolumes
- **WHEN** the configuration creates many small, single-purpose subvolumes
- **THEN** the system suggests consolidation where appropriate

#### Scenario: Inappropriate Separation
- **WHEN** frequently accessed subvolumes are unnecessarily separated
- **THEN** the system suggests consolidation to improve I/O patterns

### Requirement: Data Separation Validation
The system SHALL check that different data types are appropriately separated where needed for performance, security, or management.

#### Scenario: System/User Data Mixing
- **WHEN** system files and user files are not separated into different subvolumes
- **THEN** the system recommends separation for better management and security

#### Scenario: Database/Log Co-location
- **WHEN** database files and log files are inappropriately co-located
- **THEN** the system suggests separation for better performance and recovery