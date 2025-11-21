# Server Btrfs Impermanence Technical Specification

**Change ID**: server-btrfs-impermanence  
**Type**: Technical Specification  
**Status**: Draft  
**Created**: 2025-11-21  
**Author**: hbohlen  

## Overview

This specification defines the technical implementation of Btrfs-based impermanence for server environments, providing detailed requirements for subvolume layout, snapshot management, and performance optimization.

## Requirements

### Functional Requirements

#### FR-001: Subvolume Management
- The system SHALL create separate subvolumes for persistent and ephemeral data
- The system SHALL support flat subvolume layout for atomic snapshots
- The system SHALL provide configurable subvolume options per workload type

#### FR-002: Impermanence Implementation
- The system SHALL reset ephemeral subvolumes on each boot
- The system SHALL preserve specified paths across reboots
- The system SHALL backup current state before cleanup

#### FR-003: Snapshot Automation
- The system SHALL create automated snapshots on configurable schedule
- The system SHALL enforce retention policies automatically
- The system SHALL support manual snapshot creation

#### FR-004: Performance Optimization
- The system SHALL optimize mount options for server workloads
- The system SHALL support multiple performance modes
- The system SHALL tune kernel parameters for I/O optimization

#### FR-005: Monitoring Integration
- The system SHALL provide metrics for snapshot operations
- The system SHALL generate alerts for failures
- The system SHALL integrate with existing observability stack

### Non-Functional Requirements

#### NFR-001: Performance
- Snapshot creation SHALL complete within 30 seconds
- Rollback operations SHALL complete within 2 minutes
- I/O performance SHALL improve by at least 20%

#### NFR-002: Reliability
- System uptime SHALL exceed 99.9%
- Data integrity SHALL be maintained through checksums
- Recovery procedures SHALL be tested and documented

#### NFR-003: Maintainability
- Configuration SHALL be fully declarative
- Components SHALL be modular and reusable
- Documentation SHALL be comprehensive and current

#### NFR-004: Scalability
- Solution SHALL support additional servers with minimal changes
- Performance SHALL scale with available resources
- Storage overhead SHALL not exceed 15%

## Architecture

### Subvolume Layout

```
BTRFS ROOT (800GB)
├── PERMANENT SUBVOLUMES
│   ├── /nix              (Package Store - Critical)
│   ├── /persist          (Persistent Data - Critical)
│   ├── /var/log          (System Logs - Important)
│   ├── /var/lib/services (Service Data - Critical)
│   ├── /var/lib/caddy   (SSL/Certs - Critical)
│   ├── /var/backup       (Backup Storage - Important)
│   └── /var/lib/containers (Container Data - Service)
├── EPHEMERAL SUBVOLUMES
│   ├── /root             (System Root - Ephemeral)
│   ├── /var/cache        (App Caches - Temporary)
│   └── /var/tmp          (Temp Storage - Temporary)
└── ARCHIVE SUBVOLUMES
    ├── /.snapshots        (Snapshot Storage - Backup Only)
    └── /btrfs_tmp/old_roots (Root Archive - 30-day)
```

### Mount Options Matrix

| Subvolume | Compression | CoW | SSD | Cache | Use Case |
|------------|-------------|------|------|--------|----------|
| /nix | zstd:1 | Yes | v2 | Fast package access |
| /persist | zstd:3 | Yes | v2 | Config compression |
| /var/log | zstd:3 | Yes | v2 | Log compression |
| /var/lib/services | zstd:2 | Yes | v2 | Balanced service data |
| /var/lib/caddy | zstd:3 | Yes | v2 | SSL cert compression |
| /var/backup | zstd:3 | Yes | v2 | Backup compression |
| /var/lib/containers | zstd:1 | No | v2 | Database optimization |
| /root | zstd:3 | Yes | v2 | System files |
| /var/cache | zstd:3 | Yes | v2 | Cache compression |
| /var/tmp | zstd:1 | No | v2 | Temp performance |
| /.snapshots | zstd:3 | Yes | v2 | Snapshot storage |
| /btrfs_tmp/old_roots | zstd:3 | Yes | v2 | Archive compression |

### Performance Modes

#### Balanced Mode (Default)
- Compression: Mixed zstd:1-3 based on workload
- Kernel tuning: Standard server parameters
- Use case: General purpose server workloads

#### I/O-Optimized Mode
- Compression: Favor speed over ratio (zstd:1-2)
- Kernel tuning: Aggressive I/O parameters
- Use case: Database and container workloads

#### Space-Optimized Mode
- Compression: Maximum compression (zstd:3)
- Kernel tuning: Space-efficient parameters
- Use case: Storage-constrained environments

## Implementation Details

### Module Structure

```
modules/shared/filesystems/
├── server-btrfs.nix           # Main integration module
├── server-impermanence.nix    # Impermanence implementation
└── server-snapshots.nix       # Snapshot management
```

### Systemd Services

#### server-impermanence-setup.service
- **Purpose**: Pre-boot impermanence setup
- **Trigger**: initrd.target
- **Actions**: Backup, cleanup, restore persistent data
- **Timeout**: 60 seconds

#### server-snapshots.service
- **Purpose**: Create automated snapshots
- **Trigger**: Timer-based
- **Actions**: Snapshot critical subvolumes
- **Timeout**: 30 seconds

#### server-snapshots-cleanup.service
- **Purpose**: Enforce retention policies
- **Trigger**: Daily timer
- **Actions**: Delete expired snapshots
- **Timeout**: 120 seconds

#### btrfs-maintenance.service
- **Purpose**: Filesystem maintenance
- **Trigger**: Weekly timer
- **Actions**: Balance, scrub, optimize
- **Timeout**: 300 seconds

### Kernel Parameters

#### I/O Optimization
```bash
# Database/container workloads
vm.vfs_cache_pressure = 50      # Preserve cache
vm.dirty_ratio = 80            # Large write buffers
vm.dirty_background_ratio = 15   # Background writes
vm.swappiness = 1              # Minimize swap
```

#### General Server
```bash
# Memory management
vm.overcommit_memory = 1         # Allow overcommit
vm.min_free_kbytes = 65536     # Free memory reserve

# Btrfs tuning
fs.inotify.max_user_watches = 524288  # File monitoring
```

## Security Considerations

### Access Control
- Persistent subvolumes: Restricted to root and service accounts
- Ephemeral subvolumes: Root access only
- Snapshot directory: Read-only for non-root users

### Data Protection
- All snapshots: Read-only by default
- Critical data: Multiple backup layers
- Archive encryption: Optional LUKS integration

### Audit Trail
- All operations: Logged to systemd journal
- Snapshot events: Persistent audit log
- Configuration changes: Git-tracked

## Testing Requirements

### Unit Tests
- Subvolume creation and deletion
- Snapshot creation and restoration
- Mount option application
- Performance mode switching

### Integration Tests
- Complete impermanence cycle
- Service compatibility validation
- Monitoring integration verification
- Recovery procedure testing

### Performance Tests
- I/O throughput benchmarks
- Snapshot timing measurements
- Storage efficiency analysis
- Resource utilization monitoring

### Stress Tests
- High-frequency snapshot creation
- Large file operations
- Concurrent container workloads
- Recovery under load

## Monitoring Metrics

### System Metrics
- Snapshot creation time and success rate
- Rollback time and success rate
- Storage utilization and efficiency
- I/O performance and throughput

### Business Metrics
- System uptime and availability
- Mean time to recovery (MTTR)
- Operational efficiency indicators
- Cost optimization metrics

### Alert Conditions
- Snapshot creation failure
- Rollback operation failure
- Storage space exhaustion
- Performance degradation

## Deployment Procedures

### Initial Deployment
1. **Preparation**
   - Backup existing system
   - Validate configuration syntax
   - Prepare rollback plan

2. **Implementation**
   - Deploy new modules
   - Update host configuration
   - Test in staging environment

3. **Activation**
   - Schedule maintenance window
   - Deploy to production
   - Monitor initial operations

### Update Procedures
1. **Testing**
   - Build and validate locally
   - Test in non-production
   - Verify compatibility

2. **Deployment**
   - Update configuration
   - Restart services as needed
   - Monitor for issues

### Recovery Procedures
1. **Snapshot Rollback**
   - Identify appropriate snapshot
   - Unmount affected subvolumes
   - Restore from snapshot

2. **Emergency Recovery**
   - Boot from maintenance mode
   - Manual filesystem operations
   - Service restoration

## Documentation Requirements

### Technical Documentation
- Module API reference
- Configuration options guide
- Troubleshooting procedures
- Performance tuning guide

### Operational Documentation
- Daily operation procedures
- Maintenance task lists
- Emergency response plans
- Contact escalation procedures

### User Documentation
- Quick start guide
- Best practices guide
- FAQ and common issues
- Training materials

## Maintenance Requirements

### Regular Tasks
- Daily: Monitor snapshot operations
- Weekly: Review performance metrics
- Monthly: Btrfs maintenance tasks
- Quarterly: System review and updates

### Continuous Improvement
- Performance optimization based on metrics
- Feature enhancement based on requirements
- Documentation updates with system changes
- Training updates for team members

## Compliance Requirements

### Data Protection
- GDPR compliance for personal data
- Data retention policy enforcement
- Secure deletion of expired data
- Audit trail maintenance

### Operational Compliance
- Change management procedures
- Documentation standards
- Testing requirements
- Security standards

---

**Specification Status**: Draft  
**Review Date**: TBD  
**Approval Date**: TBD  
**Implementation Date**: TBD  
**Last Updated**: 2025-11-21