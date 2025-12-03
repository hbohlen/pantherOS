# Snapshot Strategy for Btrfs - Spec

## ADDED Requirements

### Requirement: Data-Centric Snapshot Policies
The system SHALL create different snapshot policies based on data criticality tiers and RPO/RTO requirements.

#### Scenario: Critical Data Snapshot Frequency
- **WHEN** subvolumes contain critical data (databases, system configs)
- **THEN** the system applies high-frequency snapshot policies (hourly or real-time)

#### Scenario: Non-Critical Data Snapshot Frequency
- **WHEN** subvolumes contain non-critical data (logs, caches)
- **THEN** the system applies low-frequency snapshot policies (daily or weekly)

### Requirement: Space-Aware Retention Policies
The system SHALL calculate retention policies based on available disk space and data criticality.

#### Scenario: Limited Disk Space Retention
- **WHEN** available disk space is limited
- **THEN** the system creates conservative retention policies prioritizing recent snapshots

#### Scenario: Ample Disk Space Retention
- **WHEN** ample disk space is available
- **THEN** the system creates extended retention policies for long-term recovery options

### Requirement: Host-Type Adaptive Scheduling
The system SHALL adapt snapshot scheduling based on host type (laptop/server/VPS).

#### Scenario: Laptop Snapshot Scheduling
- **WHEN** host type is identified as laptop
- **THEN** the system schedules snapshots considering battery life and intermittent power

#### Scenario: Server Snapshot Scheduling
- **WHEN** host type is identified as server
- **THEN** the system schedules snapshots with consistent time-based intervals