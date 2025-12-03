# Backup Automation Specification

## ADDED Requirements

### Requirement: Automated Snapshot Creation
The system SHALL automatically create Btrfs snapshots on a configured schedule with retention policies.

#### Scenario: Hourly snapshots are created
- **WHEN** the hourly snapshot timer triggers
- **THEN** a new snapshot is created for each configured subvolume
- **AND** snapshot is named with timestamp
- **AND** old hourly snapshots beyond retention period are pruned

#### Scenario: Snapshot retention policy is enforced
- **WHEN** retention policy is applied
- **THEN** last 24 hourly snapshots are kept
- **AND** last 7 daily snapshots are kept
- **AND** last 4 weekly snapshots are kept
- **AND** last 12 monthly snapshots are kept (GFS scheme)

### Requirement: Remote Backup Synchronization
The system SHALL synchronize backups to remote storage with encryption and compression.

#### Scenario: Backup to Backblaze B2
- **WHEN** remote backup is triggered
- **THEN** latest snapshot is encrypted using OpNix
- **AND** encrypted backup is uploaded to Backblaze B2 (S3-compatible)
- **AND** incremental backup only transfers changed data
- **AND** upload progress is logged

#### Scenario: Backup to remote server via rsync
- **WHEN** rsync backup is triggered
- **THEN** snapshot is synced to remote server
- **AND** rsync uses SSH for secure transfer
- **AND** bandwidth can be limited
- **AND** interrupted transfers can resume

### Requirement: Backup Verification
The system SHALL verify backup integrity and periodically test restore procedures.

#### Scenario: Verify backup after creation
- **WHEN** a backup completes
- **THEN** checksums are validated
- **AND** backup metadata is verified
- **AND** verification status is recorded
- **AND** failures trigger alerts

#### Scenario: Test restore procedure
- **WHEN** periodic restore test is scheduled
- **THEN** a sample restore is performed (dry-run or to test location)
- **AND** restored data is compared with source
- **AND** restore success/failure is logged
- **AND** test results are reported

### Requirement: Restore Capabilities
The system SHALL provide tools and procedures for restoring from backups at various granularities.

#### Scenario: Restore individual files
- **WHEN** restoring specific files
- **THEN** user can browse available snapshots/backups
- **AND** files can be restored to original or alternate location
- **AND** file permissions and ownership are preserved
- **AND** restore operation is logged

#### Scenario: Full system restore
- **WHEN** performing full system restore
- **THEN** documented procedure guides the process
- **AND** system can boot from restored snapshot
- **AND** all data and configuration are recovered
- **AND** restore verification confirms system integrity

### Requirement: Backup Monitoring
The system SHALL monitor backup operations and alert on failures or anomalies.

#### Scenario: Alert on backup failure
- **WHEN** a backup operation fails
- **THEN** alert is sent via configured channels
- **AND** failure details are logged
- **AND** failed backup is retried automatically (with backoff)

#### Scenario: Monitor backup staleness
- **WHEN** checking backup freshness
- **THEN** alert is sent if last successful backup is older than threshold
- **AND** alert includes time since last backup
- **AND** recommended actions are provided

#### Scenario: Track backup metrics
- **WHEN** backup completes
- **THEN** duration, size, and transfer rate are recorded
- **AND** metrics are available for trending
- **AND** anomalies in backup patterns are detected
