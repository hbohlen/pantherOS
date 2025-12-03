# Design Snapshot and Backup Strategy for Btrfs Layout - Design

## Architectural Overview

The system will implement a comprehensive btrfs snapshot and backup strategy framework that adapts to different host types, data criticality levels, and resource constraints. The architecture includes modules for data classification, strategy generation, snapshot scheduling, backup procedures, and recovery operations.

## Components

### 1. Data Criticality Classifier
- Categorizes subvolumes into different criticality tiers (critical, important, standard, temporary)
- Evaluates RPO (Recovery Point Objective) requirements for each tier
- Assesses RTO (Recovery Time Objective) requirements for each tier
- Outputs criticality profile for strategy generation

### 2. Resource Analyzer
- Evaluates available disk space and total disk size
- Calculates space overhead for different snapshot strategies
- Assesses I/O capabilities for backup operations
- Determines appropriate backup scheduling based on system resources

### 3. Snapshot Strategy Generator
- Creates snapshot schedules based on data criticality and RPO requirements
- Defines retention policies considering available disk space
- Plans snapshot naming conventions and organization
- Determines which subvolumes to snapshot together vs separately

### 4. Backup Strategy Generator
- Designs backup procedures (send/receive vs rsync vs native DB tools)
- Determines local vs remote backup strategies
- Plans backup scheduling to minimize system impact
- Creates backup verification procedures

### 5. Recovery Runbook Generator
- Creates file-level restore procedures for different scenarios
- Designs system rollback procedures for different host types
- Builds database-specific recovery procedures
- Documents emergency recovery procedures

### 6. Validation System
- Creates automated backup verification procedures
- Designs periodic testing schedules for different backup types
- Builds validation scripts to ensure backup integrity
- Provides reporting for backup success/failure

## Data Flow

1. Input: Host type, data criticality tiers, RPO/RTO requirements, disk size and free space
2. Criticality Analysis: Classify subvolumes by data importance and requirements
3. Resource Analysis: Evaluate hardware constraints and available space
4. Strategy Generation: Create snapshot and backup strategies based on inputs
5. Schedule Planning: Determine optimal timing for operations
6. Validation Integration: Plan for verification procedures
7. Output: Complete snapshot/backup strategy with procedures and runbooks

## Key Algorithms

### Data Criticality Classification
- Critical (RPO: minutes, RTO: minutes): Database files, system configs, user documents
- Important (RPO: hours, RTO: hours): Development files, application data
- Standard (RPO: daily, RTO: daily): Logs, caches, temporary files
- Temporary (RPO: none, RTO: none): /tmp, swap

### Snapshot Frequency Determination
- Hourly: Critical data on production systems
- Daily: Important data, standard data on critical hosts
- Weekly: Standard data on non-critical hosts
- Monthly: Archive data, compliance requirements

### Retention Policy Calculation
- Critical: Keep hourly snapshots for 7 days, daily for 30 days, weekly for 90 days
- Important: Keep daily snapshots for 14 days, weekly for 60 days
- Standard: Keep daily snapshots for 7 days, weekly for 30 days

## Technology Stack

- Nix/NixOS for configuration management and domain-specific language
- Standard Nixpkgs libraries for data processing and utility functions
- btrfs-progs for snapshot operations
- Standard NixOS modules for backup services (timeshift, snapper, or custom solution)
- Systemd timers for scheduled operations
- Standard backup tools (rsync, rclone, etc.) for off-system backup

## Implementation Patterns

### Adaptive Strategy Design
- Different strategies for laptop vs server vs VPS hosts
- Adjustments based on available disk space
- Flexible RPO/RTO accommodations

### Hierarchical Backup Approach
- Frequent local snapshots for quick recovery
- Less frequent remote backups for disaster recovery
- Different retention policies for different backup types

## Host Type Considerations

### Laptop
- Battery-aware scheduling for backup operations
- Consider network availability for remote backups
- Prioritize local snapshots due to mobility
- Longer retention on local snapshots due to limited online backup windows

### Server
- Predictable scheduling for consistent backup windows
- Multiple backup tiers (local and remote)
- Automated verification and monitoring
- Integration with monitoring systems

### VPS
- Network-aware backup procedures
- Efficient use of limited storage
- Remote backup prioritization
- Consider cost implications of storage/transfer

## Data Tier Strategies

### Critical Data (Database files, system configs, user documents)
- RPO: minutes to hours depending on system
- RTO: minutes to hours depending on system
- Snapshot: Hourly to daily
- Retention: Long-term with multiple tiers
- Backup: Both local and remote with frequent sync

### Important Data (Development files, application data)
- RPO: Hours to daily
- RTO: Hours to daily
- Snapshot: Daily to weekly
- Retention: Medium-term
- Backup: Local primary, remote secondary

### Standard Data (Logs, caches, system files)
- RPO: Daily to weekly
- RTO: Daily to weekly
- Snapshot: Weekly to monthly
- Retention: Short-term
- Backup: Primarily local or minimal remote

### Temporary Data (/tmp, swap, caches)
- RPO: None or minimal
- RTO: None or minimal
- Snapshot: Minimal to none
- Retention: Minimal
- Backup: None

## Recovery Procedures

### File-Level Restore
- Procedures for restoring individual files from snapshots
- Tools and commands for navigation of btrfs snapshots
- Access permissions and security considerations

### System Rollback
- Procedures for rolling back entire subvolumes
- Boot configuration considerations for snapshot-based rollback
- Verification procedures after rollback

### Database Restore
- Special procedures for databases that require quiescing
- Coordination with database-native backup tools
- Transaction log considerations

## Testing and Validation

### Automated Verification
- Scripts to periodically verify backup integrity
- Comparison of backup metadata with source data
- Automated reporting of backup status

### Periodic Testing
- Regular restore tests to verify backup usability
- Simulation of different failure scenarios
- Documentation of test results and improvement areas