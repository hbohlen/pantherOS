# Backup Strategy for Btrfs - Spec

## ADDED Requirements

### Requirement: Tiered Backup Procedures
The system SHALL implement different backup procedures for different data criticality tiers.

#### Scenario: Critical Data Backup
- **WHEN** data is classified as critical
- **THEN** the system implements both local and remote backup with short RPO/RTO requirements

#### Scenario: Standard Data Backup
- **WHEN** data is classified as standard
- **THEN** the system implements local backup with longer RPO/RTO requirements

### Requirement: Backup Method Selection
The system SHALL select appropriate backup methods based on data type and requirements.

#### Scenario: Subvolume Backup Method
- **WHEN** backing up btrfs subvolumes
- **THEN** the system uses btrfs send/receive for efficient incremental backups

#### Scenario: Database Backup Integration
- **WHEN** backing up database files
- **THEN** the system coordinates with database-native backup tools for consistency

### Requirement: Local vs Remote Backup Decision
The system SHALL determine appropriate balance between local and remote backups based on host type and requirements.

#### Scenario: VPS Remote Backup Priority
- **WHEN** host type is VPS
- **THEN** the system prioritizes remote backups for disaster recovery

#### Scenario: Laptop Local Backup Priority
- **WHEN** host type is laptop
- **THEN** the system emphasizes local backups due to connectivity constraints