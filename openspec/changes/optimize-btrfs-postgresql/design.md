# Btrfs PostgreSQL Optimization Design

## Context

- **Hardware**: Hetzner VPS with 458GB virtio_scsi disk, 22GB RAM, AMD EPYC 12-core
- **Current Setup**: Btrfs with development-optimized subvolumes
- **Target**: PostgreSQL production database workload
- **Constraints**: Data safety priority, ~95% disk utilization ceiling

## Goals / Non-Goals

- **Goals**: Optimize I/O performance, ensure data safety, enable fast recovery
- **Non-Goals**: Change filesystem type, modify CPU/RAM allocation

## Analysis: CoW vs nodatacow for PostgreSQL

### CoW (Copy-on-Write) - Default btrfs behavior

**Pros:**

- Automatic data versioning and crash consistency
- Efficient snapshot creation (instant, low overhead)
- Self-healing and checksumming
- Better for mixed read/write workloads

**Cons for PostgreSQL:**

- Write amplification during database writes (data + metadata duplicated)
- Slower write performance due to CoW overhead
- PostgreSQL WAL already provides crash consistency, making CoW redundant

### nodatacow - Direct I/O without CoW

**Pros:**

- Direct, sequential writes without CoW overhead
- 15-25% better write performance for database workloads
- Less write amplification
- Better for write-heavy workloads like PostgreSQL

**Cons:**

- Loses btrfs self-healing and automatic checksumming
- Requires external backup/snapshot strategy
- No automatic crash consistency (relying on PostgreSQL WAL)

## Decision: Hybrid Approach

- **@postgres-data**: nodatacow for PostgreSQL data files
- **@postgres-wal**: nodatacow for Write-Ahead Log
- **@postgres-backup**: CoW with compression for backup files
- **Keep existing**: @containers, @nix, @dev (modified as needed)

## Subvolume Strategy

### Recommended Subvolumes

```
@postgres-data    (/var/lib/postgresql)    - nodatacow, minimal compression
@postgres-wal     (/var/lib/postgresql/wal) - nodatacow, no compression
@postgres-backup  (/var/backups/postgres)   - CoW, zstd:3 compression
```

### Space Allocation (458GB disk)

- **System + existing subvolumes**: ~200GB
- **PostgreSQL data**: 150GB (allows 200GB database)
- **PostgreSQL WAL**: 20GB (separate for performance)
- **PostgreSQL backups**: 50GB
- **Reserved space**: 38GB (8% for btrfs and growth)

## Mount Options Analysis

### @postgres-data Mount Options

```
nodatacow           # Critical: eliminate CoW overhead
compress=zstd:1     # Minimal compression for space savings
noatime            # Don't update access times
space_cache=v2     # Modern space management
discard=async      # SSD TRIM support
```

### @postgres-wal Mount Options

```
nodatacow           # Critical: WAL needs fast sequential writes
compress=no         # No compression for WAL (writes every second)
noatime            # Don't update access times
```

## Backup and Recovery Strategy

### Layer 1: btrfs Snapshots (Fast Recovery)

- **Frequency**: Every 2 hours during business hours
- **Retention**: 24 hourly, 7 daily, 4 weekly
- **RTO**: <2 minutes for snapshot rollback
- **RPO**: Max 2 hours data loss

### Layer 2: Logical Dumps (Reliable Backup)

- **Frequency**: Daily full dump, hourly incremental
- **Retention**: 30 daily, 12 monthly
- **Storage**: Separate @postgres-backup subvolume
- **Validation**: Automated integrity checks

## Performance Expectations vs ext4

### Expected Performance

- **Write Performance**: 15-25% faster than ext4 (nodatacow advantage)
- **Read Performance**: Comparable to ext4 (<5% difference)
- **Space Efficiency**: 10-15% overhead vs ext4 (compression benefits)
- **Snapshot Performance**: Instant vs ext4 (minutes for LVM snapshots)

### Trade-offs

- **CPU Usage**: +3-5% for compression/decompression
- **Memory**: +100-200MB for btrfs metadata
- **Complexity**: Higher (requires PostgreSQL knowledge for recovery)

## Migration Strategy

1. **Fresh Install Required**: Subvolume changes require full reinstall
2. **Data Migration**: Logical backup/restore from existing PostgreSQL
3. **Rollback Plan**: Keep current system on separate boot entry
4. **Validation**: Run pgbench before/after for performance verification

## Risks / Trade-offs

- **Risk**: Data corruption without btrfs checksums → Mitigation: PostgreSQL WAL + logical backups
- **Risk**: Performance regression if misconfigured → Mitigation: Extensive testing and monitoring
- **Risk**: Complexity increase → Mitigation: Clear documentation and automation

## Open Questions

- Database size and growth projections needed for final space allocation
- Transaction rate requirements for precise performance optimization
- RPO/RTO requirements for backup frequency tuning
- Whether to use bare-metal PostgreSQL or containerized deployment
