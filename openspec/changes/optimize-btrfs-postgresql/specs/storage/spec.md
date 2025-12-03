## ADDED Requirements

### Requirement: PostgreSQL Database Subvolume

The system SHALL provide a dedicated btrfs subvolume optimized for PostgreSQL database storage with proper nodatacow placement for data files.

#### Scenario: Database Performance Optimization

- **GIVEN** PostgreSQL database workload with moderate to high transaction rates
- **WHEN** database writes are performed on nodatacow subvolume
- **THEN** write performance SHALL be 15-25% better than CoW configuration
- **AND** space allocation SHALL accommodate 200GB database with 50% growth buffer

#### Scenario: Coexistence with Container Workloads

- **GIVEN** both PostgreSQL and container workloads are running
- **WHEN** both database and container subvolumes are active
- **THEN** each SHALL use appropriate nodatacow/compression settings
- **AND** disk space SHALL be allocated efficiently between workloads

### Requirement: Database Compression Strategy

The database subvolume SHALL use minimal compression to avoid CPU overhead while still providing space savings for non-database files.

#### Scenario: Compression Trade-off

- **GIVEN** PostgreSQL database with mixed read/write workload
- **WHEN** compression is set to zstd:1 level
- **THEN** CPU overhead SHALL be <5% for database operations
- **AND** space savings SHALL be 10-15% for database files

### Requirement: Backup and Snapshot Strategy

The system SHALL support both btrfs snapshots and logical database dumps for comprehensive data protection.

#### Scenario: Crash Recovery

- **GIVEN** database crash requiring recovery
- **WHEN** btrfs snapshot rollback is performed
- **THEN** recovery time SHALL be <2 minutes for snapshot-based recovery
- **AND** data loss SHALL be limited to snapshots taken within RPO window

#### Scenario: Logical Backup Validation

- **GIVEN** scheduled logical dump is performed
- **WHEN** dump completion is verified
- **THEN** dump integrity SHALL be validated within 30 seconds
- **AND** dump files SHALL be stored on separate subvolume for isolation

## MODIFIED Requirements

### Requirement: Hetzner VPS Disk Layout

The existing hetzner-vps disk layout SHALL be modified to include PostgreSQL-specific subvolume configuration.

#### Scenario: New Subvolume Integration

- **GIVEN** existing btrfs subvolume structure for development workloads
- **WHEN** PostgreSQL subvolume is added to layout
- **THEN** existing subvolumes SHALL remain functional
- **AND** total disk usage SHALL not exceed 95% capacity
- **AND** mount options SHALL be optimized for database performance

## REMOVED Requirements

### Requirement: Generic Container Optimization

**Reason**: Container subvolume optimization SHALL be refined to coexist with database workload without conflicts
**Migration**: Container workloads continue on nodatacow with updated compression settings
