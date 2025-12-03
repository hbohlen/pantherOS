# Subvolume Layout for Podman - Spec

## ADDED Requirements

### Requirement: Container Storage Subvolume Creation
The system SHALL create dedicated subvolumes for Podman container storage with appropriate mount options and separation from other system components.

#### Scenario: Container Root Subvolume Creation
- **WHEN** configuring Podman on btrfs
- **THEN** the system creates a dedicated subvolume for /var/lib/containers with optimal mount options

#### Scenario: Container Volume Subvolume Creation
- **WHEN** persistent container volumes are needed
- **THEN** the system provides options for dedicated volume subvolumes with appropriate settings

### Requirement: Mount Option Optimization
The system SHALL apply appropriate mount options for container storage subvolumes based on performance and reliability requirements.

#### Scenario: Nodatacow Application for Container Storage
- **WHEN** optimizing for container performance
- **THEN** the system applies nodatacow option to appropriate container storage areas

#### Scenario: Compression Strategy for Container Storage
- **WHEN** balancing space efficiency and performance for containers
- **THEN** the system applies appropriate compression settings for different container storage needs

### Requirement: Performance-Oriented Layout
The system SHALL design subvolume layouts that optimize for container I/O patterns, including image pulls, container creation, and volume access.

#### Scenario: Image Storage Optimization
- **WHEN** storing container images
- **THEN** the system configures storage with options optimized for image layer access patterns

#### Scenario: Volume Access Optimization
- **WHEN** accessing container volumes
- **THEN** the system configures storage with options optimized for container workload I/O patterns