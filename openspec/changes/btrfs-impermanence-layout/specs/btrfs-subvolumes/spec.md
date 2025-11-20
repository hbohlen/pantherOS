# Btrfs Subvolumes Specification

## ADDED Requirements

### Flat Btrfs Subvolume Structure

**Requirement**: Create 8 Btrfs subvolumes using flat layout with `@subvolume` naming convention for 480GB NVMe partition.

**Subvolume Layout**:
```nix
{
  disko.devices.disk.sda.content.btrfs.subvolumes = [
    # Ephemeral root subvolume
    {
      name = "root";
      mountpoint = "/";
      compress = "zstd:3";
    }
    
    # Persistent package cache
    {
      name = "nix";
      mountpoint = "/nix";
      compress = "zstd:1";
      neededForBoot = true;
    }
    
    # Persistent application data
    {
      name = "persist";
      mountpoint = "/persist";
      compress = "zstd:3";
      neededForBoot = true;
    }
    
    # System and application logs
    {
      name = "log";
      mountpoint = "/var/log";
      compress = "zstd:3";
      neededForBoot = true;
    }
    
    # Container storage
    {
      name = "containers";
      mountpoint = "/var/lib/containers";
      compress = "zstd:1";
      mountOptions = [ "nodatacow" ];
    }
    
    # Caddy proxy data
    {
      name = "caddy";
      mountpoint = "/var/lib/caddy";
      compress = "zstd:3";
      neededForBoot = true;
    }
    
    # Btrfs snapshots
    {
      name = "snapshots";
      mountpoint = "/.snapshots";
      compress = "zstd:3";
    }
    
    # Impermanence rotation archive
    {
      name = "old_roots";
      mountpoint = "/btrfs_tmp/old_roots";
      compress = "zstd:3";
    }
  ];
}
```

**Naming Convention**: Flat layout with `@name` syntax for simple management.

**Rationale**: Flat layout provides simpler snapshot restoration, easier mount point management, and clear separation of concerns.

#### Scenario: Subvolume Creation Order
**Given**: Fresh Btrfs partition on 480GB NVMe SSD  
**When**: Subvolumes are created during installation  
**Then**:
- All 8 subvolumes created with correct names
- Mount points established for each subvolume
- Compression settings applied appropriately
- Dependencies respected for neededForBoot subvolumes

#### Scenario: Mount Point Verification
**Given**: All subvolumes created successfully  
**When**: System boots and mounts subvolumes  
**Then**:
- Each subvolume mounts at correct path
- Mount options applied correctly
- Compression active for all subvolumes
- neededForBoot subvolumes available during early boot

### Root Subvolume - Ephemeral System

**Requirement**: Create ephemeral root subvolume that gets wiped on every boot.

**Configuration**:
```nix
{
  name = "root";
  mountpoint = "/";
  compress = "zstd:3";
  # Ephemeral - wiped via impermanence
}
```

**Mount Point**: `/` - System root directory  
**Purpose**: All system files that get wiped on boot  
**Lifecycle**: Deleted and recreated by impermanence script

#### Scenario: Root Subvolume Wipe
**Given**: System has been running with changes  
**When**: System reboots  
**Then**:
- Root subvolume wiped clean
- Old root moved to old_roots with timestamp
- Fresh root subvolume created
- System starts in clean state

#### Scenario: System State Reset
**Given**: System has accumulated configuration changes  
**When**: Impermanence rotation occurs  
**Then**:
- All changes wiped except /persist directories
- System behaves as fresh installation
- No configuration drift accumulation
- Clean state ensures stability

### Nix Subvolume - Package Cache

**Requirement**: Create persistent subvolume for Nix package store with fast compression.

**Configuration**:
```nix
{
  name = "nix";
  mountpoint = "/nix";
  compress = "zstd:1";
  neededForBoot = true;
}
```

**Purpose**: Nix store with derivations, profiles, and packages  
**Persistence**: Critical for system functionality  
**Compression**: zstd:1 for fast decompression  
**Boot Dependency**: Required during early boot

#### Scenario: Package Installation
**Given**: User installs new packages  
**When**: Nix operations write to /nix  
**Then**:
- Fast compression minimizes space usage
- Fast decompression for frequent access
- Data persists across reboots
- Boot process can access Nix store

#### Scenario: System Updates
**Given**: NixOS system update available  
**When**: System update installs new packages  
**Then**:
- Old packages remain available
- Space efficient storage via compression
- Fast access to package metadata
- System rollback possible

### Persist Subvolume - Application Data

**Requirement**: Create persistent subvolume for application and user data.

**Configuration**:
```nix
{
  name = "persist";
  mountpoint = "/persist";
  compress = "zstd:3";
  neededForBoot = true;
}
```

**Purpose**: All data that survives reboots  
**Content**: Configuration files, user data, application state  
**Compression**: zstd:3 balanced compression  
**Boot Dependency**: Required for system services

#### Scenario: Application Configuration Persistence
**Given**: User configures application settings  
**When**: Application writes config to /persist  
**Then**:
- Configuration persists across reboots
- Balanced compression saves space
- Available during early boot
- Application state maintained

#### Scenario: Data Recovery
**Given**: Application data needs backup  
**When**: Backup tools access /persist  
**Then**:
- All persistent data accessible in single location
- Compression doesn't interfere with backup
- Snapshot-friendly for backup operations
- Clear separation from ephemeral data

### Log Subvolume - System Logs

**Requirement**: Create persistent subvolume for system and application logs.

**Configuration**:
```nix
{
  name = "log";
  mountpoint = "/var/log";
  compress = "zstd:3";
  neededForBoot = true;
}
```

**Purpose**: Persistent system and application logs  
**Behavior**: High write frequency, variable file sizes  
**Compression**: zstd:3 for space efficiency  
**Boot Dependency**: Required for logging services

#### Scenario: Log Aggregation
**Given**: Multiple services writing logs  
**When**: Log rotation and aggregation occurs  
**Then**:
- All logs stored in dedicated subvolume
- Compression reduces disk usage
- Persistent storage for audit trails
- System logs survive reboots

#### Scenario: Debugging and Analysis
**Given**: System issues require log analysis  
**When**: Administrator accesses /var/log  
**Then**:
- Complete log history available
- Compressed storage doesn't impact access
- Persistent across reboots for analysis
- Clear separation from other data

### Containers Subvolume - Podman Storage

**Requirement**: Create subvolume for container storage with performance optimization.

**Configuration**:
```nix
{
  name = "containers";
  mountpoint = "/var/lib/containers";
  compress = "zstd:1";
  mountOptions = [ "nodatacow" ];
}
```

**Purpose**: Container images, volumes, and overlayfs data  
**Performance**: nodatacow for database workloads  
**Compression**: zstd:1 for fast access  
**Workload**: Database containers, persistent containers

#### Scenario: Database Containers
**Given**: Database container running in Podman  
**When**: Database performs I/O operations  
**Then**:
- nodatacow provides maximum I/O performance
- Database files not fragmented by copy-on-write
- Fast access to container layers
- Optimal performance for containerized databases

#### Scenario: Container Image Management
**Given**: Multiple container images stored  
**When**: Images are pulled and stored  
**Then**:
- Fast compression for image layers
- nodatacow not applied to image storage
- Space efficient storage
- Quick container startup

### Caddy Subvolume - Reverse Proxy Data

**Requirement**: Create subvolume for Caddy proxy configuration and certificates.

**Configuration**:
```nix
{
  name = "caddy";
  mountpoint = "/var/lib/caddy";
  compress = "zstd:3";
  neededForBoot = true;
}
```

**Purpose**: SSL certificates, proxy configuration, logs  
**Critical**: Required for HTTPS services  
**Compression**: zstd:3 for certificate storage  
**Boot Dependency**: Needed early for service startup

#### Scenario: SSL Certificate Management
**Given**: Caddy manages SSL certificates  
**When**: Certificate updates occur  
**Then**:
- Certificates persist across reboots
- Fast renewal process with compression
- Critical service data secured
- Automatic HTTPS capabilities maintained

#### Scenario: Proxy Configuration Persistence
**Given**: Caddy proxy configured for services  
**When**: System boots  
**Then**:
- Proxy configuration available immediately
- SSL certificates loaded correctly
- Services accessible via proxy
- Configuration survives reboots

### Snapshots Subvolume - Btrfs Backups

**Requirement**: Create subvolume for Btrfs point-in-time snapshots.

**Configuration**:
```nix
{
  name = "snapshots";
  mountpoint = "/.snapshots";
  compress = "zstd:3";
}
```

**Purpose**: Point-in-time backups of other subvolumes  
**Behavior**: Read-only snapshots  
**Compression**: zstd:3 for snapshot storage  
**Usage**: Manual and automated backup operations

#### Scenario: Manual Snapshot Creation
**Given**: Administrator creates system snapshot  
**When**: Snapshot command executed  
**Then**:
- Read-only snapshot created in snapshots subvolume
- Compression applied to snapshot metadata
- System state preserved at point-in-time
- Easy rollback capability established

#### Scenario: Automated Backup System
**Given**: Backup system creates periodic snapshots  
**When**: Scheduled backup occurs  
**Then**:
- Snapshots stored efficiently in dedicated subvolume
- Space optimization via compression
- Automated retention policies possible
- Reliable backup infrastructure

### Old Roots Subvolume - Impermanence Archive

**Requirement**: Create subvolume for storing old root snapshots.

**Configuration**:
```nix
{
  name = "old_roots";
  mountpoint = "/btrfs_tmp/old_roots";
  compress = "zstd:3";
}
```

**Purpose**: Archive old root subvolumes for rollback  
**Retention**: 30 days with automatic cleanup  
**Naming**: Timestamp-based naming convention  
**Accessibility**: Mounted at /btrfs_tmp for management

#### Scenario: Old Root Archive
**Given**: System reboots with impermanence  
**When**: Old root is moved to archive  
**Then**:
- Old root subvolume moved with timestamp
- Accessible for rollback operations
- Compressed storage reduces space usage
- 30-day retention policy applied

#### Scenario: Rollback Recovery
**Given**: System needs rollback to previous state  
**When**: Administrator initiates rollback  
**Then**:
- Old root accessible via /btrfs_tmp/old_roots
- Previous system state available
- Clean rollback process
- System state restoration possible

## MODIFIED Requirements

### Subvolume Creation Order

**Requirement**: Create subvolumes in dependency order considering neededForBoot flags.

**Creation Order**:
1. Root, nix, persist, log, caddy (neededForBoot)
2. containers, snapshots, old_roots (optional)

**Rationale**: neededForBoot subvolumes must be available early in boot process.

#### Scenario: Boot Process Dependencies
**Given**: System boots with impermanence configuration  
**When**: Boot loader mounts root  
**Then**:
- neededForBoot subvolumes mounted before systemd
- Boot process succeeds without issues
- Optional subvolumes mounted later
- Dependency order respected

### Mount Option Dependencies

**Requirement**: Apply mount options based on subvolume workload characteristics.

**Option Groups**:
- **Universal**: noatime, ssd, space_cache=v2, discard=async
- **Fast**: compress=zstd:1 for nix, containers
- **Balanced**: compress=zstd:3 for most subvolumes
- **Performance**: nodatacow for containers database storage

#### Scenario: Mount Performance Optimization
**Given**: Subvolumes mounted with various options  
**When**: System operates under different workloads  
**Then**:
- Each subvolume optimized for its workload
- Fast access for frequently accessed data
- Balanced compression for mixed workloads
- Performance options for database containers

## REMOVED Requirements

### Nested Subvolume Layout
**Removed**: Nested subvolume structure (e.g., @/data/persist)

**Rationale**: Flat layout provides simpler management and restoration.

#### Scenario: Snapshot Restoration
**Given**: Need to restore snapshot  
**When**: Restoration command executed  
**Then**:
- Flat structure easier to understand
- Simple snapshot creation and deletion
- Direct mount point mapping
- No complex path relationships

### Single Compression Level
**Removed**: Uniform compression across all subvolumes

**Rationale**: Different workloads benefit from different compression levels.

#### Scenario: Performance Optimization
**Given**: Various data types with different access patterns  
**When**: Data is accessed and stored  
**Then**:
- Performance-critical data gets fast compression
- Balanced data gets efficient compression
- Database containers get nodatacow
- Optimized for specific workload characteristics

## Implementation Details

### Btrfs Configuration
```nix
{
  btrfsConfig = {
    label = "nixos";
    features = [ "block-group-tree" ];
  };
}
```

### Universal Mount Options
All subvolumes include:
- `noatime`: Reduce metadata writes
- `ssd`: Btrfs SSD optimizations
- `space_cache=v2`: Efficient space management
- `discard=async`: Non-blocking TRIM

### Subvolume Dependencies
- **Root**: None (created first)
- **Nix, Persist, Log, Caddy**: Needed for boot
- **Containers**: Optional but performance critical
- **Snapshots**: Optional, used by backup systems
- **Old Roots**: Optional, used by impermanence

### Compression Selection
- **zstd:1**: Fast compression/decompression for frequently accessed data
- **zstd:3**: Balanced compression for mixed workloads
- **nodatacow**: Disable copy-on-write for database performance

---

**Integration**: This specification provides the subvolume structure that enables impermanence integration in the next capability specification.
