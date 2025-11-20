# Mount Configuration Specification

## ADDED Requirements

### Universal Mount Options

**Requirement**: Apply universal Btrfs mount options to all subvolumes for SSD optimization and performance.

**Universal Options**:
```nix
{
  mountOptions = [
    "noatime"        # Disable access time updates
    "ssd"            # Enable SSD-specific optimizations
    "space_cache=v2" # Efficient space management
    "discard=async"  # Non-blocking TRIM operations
  ];
}
```

**Rationale**: These options optimize performance and longevity across all subvolumes regardless of specific workload.

#### Scenario: SSD Optimization
**Given**: Btrfs filesystem on NVMe SSD  
**When**: Subvolumes mounted with universal options  
**Then**:
- Access time updates disabled (reduces writes)
- SSD-specific optimizations applied
- Efficient space management for large filesystems
- Non-blocking TRIM operations prevent I/O stalls

#### Scenario: Space Management
**Given**: Large filesystem with many subvolumes  
**When**: System operates under various workloads  
**Then**:
- Space cache v2 optimizes space allocation
- Noatime reduces metadata writes
- Discard operations don't block system
- Overall system responsiveness maintained

### Compression Level Configuration

**Requirement**: Configure specific compression levels per subvolume based on workload characteristics.

**Compression Configuration**:
```nix
{
  # Fast compression for performance-critical data
  "nix" = { compress = "zstd:1"; };
  "containers" = { compress = "zstd:1"; };
  
  # Balanced compression for general data
  "root" = { compress = "zstd:3"; };
  "persist" = { compress = "zstd:3"; };
  "log" = { compress = "zstd:3"; };
  "caddy" = { compress = "zstd:3"; };
  "snapshots" = { compress = "zstd:3"; };
  "old_roots" = { compress = "zstd:3"; };
}
```

**Compression Levels**:
- **zstd:1**: Fast compression/decompression for frequent access
- **zstd:3**: Balanced compression for mixed workloads
- **nodatacow**: Disabled copy-on-write for database performance

#### Scenario: Frequent Nix Package Access
**Given**: User frequently accesses Nix packages  
**When**: System reads /nix data  
**Then**:
- Fast compression enables quick decompression
- Package access remains responsive
- Space savings without performance penalty
- Optimized for read-heavy workloads

#### Scenario: Database Container I/O
**Given**: Database container performing intensive I/O  
**When**: Database reads/writes data  
**Then**:
- nodatacow prevents copy-on-write overhead
- Direct I/O performance maintained
- Database operations remain fast
- Optimized for write-heavy database workloads

### NeededForBoot Configuration

**Requirement**: Mark critical subvolumes as neededForBoot for proper initialization order.

**Critical Subvolumes**:
```nix
{
  "nix" = { neededForBoot = true; };
  "persist" = { neededForBoot = true; };
  "log" = { neededForBoot = true; };
  "caddy" = { neededForBoot = true; };
}
```

**Rationale**: These subvolumes are required during early boot process before systemd can mount them.

#### Scenario: Early Boot Process
**Given**: System boots and initializes  
**When**: Boot process accesses system services  
**Then**:
- neededForBoot subvolumes mounted early
- Nix store accessible for package loading
- Persistent data available for services
- Log system operational immediately

#### Scenario: Service Startup
**Given**: Systemd services starting during boot  
**When**: Services need persistent data  
**Then**:
- /persist subvolume already mounted
- Configuration files accessible
- Service startup succeeds without delays
- Log service operational for early messages

### Management Mount Point

**Requirement**: Create management mount at /btrfs_tmp for subvolume management and impermanence operations.

**Configuration**:
```nix
{
  mountPoints = {
    "/btrfs_tmp" = {
      device = "/dev/sda4";
      fsType = "btrfs";
      options = [
        "subvol=/"
        "noatime"
        "ssd"
        "space_cache=v2"
        "discard=async"
      ];
    };
  };
}
```

**Purpose**: Enable access to entire Btrfs filesystem for management operations.

#### Scenario: Subvolume Management
**Given**: Administrator needs to manage subvolumes  
**When**: System operational  
**Then**:
- Full Btrfs filesystem accessible at /btrfs_tmp
- All subvolumes readable and writable
- Management commands can reference subvolumes
- Impermanence operations have filesystem access

#### Scenario: Impermanence Operations
**Given**: System boots with impermanence  
**When**: Root rotation occurs  
**Then**:
- Management mount provides filesystem access
- Old roots accessible via /btrfs_tmp/old_roots/
- Root operations can reference all subvolumes
- Cleanup operations can target old snapshots

## MODIFIED Requirements

### Performance-Based Option Selection

**Requirement**: Select mount options based on specific subvolume workload characteristics.

**Workload-Specific Options**:
- **Performance Critical**: `nodatacow` for database containers
- **Space Critical**: Higher compression levels
- **I/O Intensive**: `discard=async` for all subvolumes
- **Boot Critical**: `neededForBoot` for service dependencies

**Rationale**: Different subvolumes have different performance and reliability requirements.

#### Scenario: Database Workload Optimization
**Given**: Subvolume handling database files  
**When**: Database performs I/O operations  
**Then**:
- nodatacow eliminates copy-on-write overhead
- Compression disabled for direct I/O
- Maximum database performance achieved
- No fragmentation from COW operations

#### Scenario: Log Write Optimization
**Given**: Subvolume handling high-frequency log writes  
**When**: System generates many log entries  
**Then**:
- Compression balances space and CPU usage
- Noatime reduces metadata writes
- Async discard prevents I/O stalls
- Log performance maintained

### Boot Dependency Resolution

**Requirement**: Order subvolume mounts based on boot dependencies and service requirements.

**Mount Order Logic**:
1. **System Critical**: root (always first)
2. **Service Dependencies**: nix, persist, log, caddy (neededForBoot)
3. **Application Optional**: containers, snapshots, old_roots

**Resolution Strategy**: Use NixOS mount dependencies to ensure proper order.

#### Scenario: Service Initialization
**Given**: Systemd attempting to start services  
**When**: Boot process begins  
**Then**:
- System-critical subvolumes mount first
- Service dependencies satisfied in order
- No mount race conditions
- Services start with required data available

#### Scenario: Optional Subvolume Handling
**Given**: Subvolumes not needed for boot  
**When**: System completes primary boot  
**Then**:
- Optional subvolumes mount later
- Boot process not blocked
- Application functionality added progressively
- System remains responsive

## REMOVED Requirements

### Uniform Mount Options
**Removed**: Same mount options applied to all subvolumes regardless of workload.

**Rationale**: Workload-specific optimization provides better performance and resource utilization.

#### Scenario: Workload Optimization
**Given**: Various subvolume workloads  
**When**: Mount options applied  
**Then**:
- Each subvolume optimized for its specific workload
- Performance matches workload characteristics
- Resource usage optimized per subvolume
- System efficiency maximized

### Hardcoded Compression Levels
**Removed**: Single compression level for entire filesystem.

**Rationale**: Different data types benefit from different compression strategies.

#### Scenario: Data Type Optimization
**Given**: Different data types in various subvolumes  
**When**: Compression applied  
**Then**:
- Fast compression for frequently accessed data
- Balanced compression for mixed workloads
- No compression for database performance
- Optimal balance of speed and space

## Implementation Details

### Mount Option Combinations

#### Universal Base Options
```nix
"noatime,ssd,space_cache=v2,discard=async"
```

#### Fast Compression Variant
```nix
"noatime,ssd,space_cache=v2,discard=async,compress=zstd:1"
```

#### Balanced Compression Variant
```nix
"noatime,ssd,space_cache=v2,discard=async,compress=zstd:3"
```

#### Performance Variant (databases)
```nix
"noatime,ssd,space_cache=v2,discard=async,nodatacow"
```

### Mount Order Dependencies
```
1. root (/) - System root
2. nix (/nix) - Package store
3. persist (/persist) - Application data
4. log (/var/log) - System logs
5. caddy (/var/lib/caddy) - Proxy data
6. containers (/var/lib/containers) - Container storage
7. snapshots (/.snapshots) - Backup snapshots
8. old_roots (/btrfs_tmp/old_roots) - Impermanence archive
```

### Performance Impact Analysis

#### Read Performance
- **Compressed Data**: Slight overhead from decompression
- **Fast Compression**: Minimal impact on frequent reads
- **Database Operations**: nodatacow provides maximum speed

#### Write Performance  
- **Compression**: CPU overhead balanced by reduced I/O
- **Async Discard**: No write stalls from TRIM operations
- **Noatime**: Reduces metadata write overhead

#### Space Efficiency
- **zstd:1**: ~20% space savings
- **zstd:3**: ~35% space savings
- **Overall**: 30-40% typical compression ratio

### Verification Commands
```bash
# Verify mount options
mount | grep btrfs

# Check compression ratios
compsize -x /

# Monitor space usage
btrfs filesystem usage /

# Check mount order
systemd-analyze plot > boot.svg

# Verify subvolume mount status
btrfs subvolume list /
```

### Error Handling
- **Mount Failure**: System boots with degraded functionality
- **Compression Failure**: Falls back to uncompressed mode
- **Option Invalid**: Mount uses safe defaults
- **Dependency Missing**: Boot continues with available services

### Integration Points
- **systemd-fstab-generator**: Creates mount units automatically
- **initramfs**: Includes mount requirements in early boot
- **NixOS configuration**: Declarative mount option specification
- **Disko**: Creates filesystem structure during installation

---

**Integration**: This specification ensures optimal mount configuration across all subvolumes while maintaining system reliability and performance.
