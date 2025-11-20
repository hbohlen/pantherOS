# Design: Btrfs Partition Layout with Impermanence

## Architectural Overview

This design implements a comprehensive Btrfs partition layout optimized for Hetzner Cloud CPX52 infrastructure with impermanence support. The configuration provides a clean, ephemeral system state with explicitly managed persistent data.

## Design Principles

### 1. Ephemeral by Default, Explicit Persistence
**Principle**: System state should be ephemeral unless explicitly configured to persist.

**Rationale**: This reduces configuration drift, attack surface, and operational complexity. Root filesystem is wiped every boot, forcing deliberate decisions about data persistence.

**Implementation**: 
- Root subvolume wiped via `boot.initrd.postDeviceCommands`
- Persistent paths explicitly declared in `/persist` subvolume
- Old roots preserved for 30-day rollback window

### 2. Workload-Specific Optimization
**Principle**: Each subvolume should be optimized for its specific workload characteristics.

**Rationale**: Different data types have different access patterns, write frequencies, and performance requirements.

**Implementation**:
- `/nix` - Fast compression for frequent small file access
- `/var/log` - Balanced compression for variable-size log files
- `/var/lib/containers` - nodatacow for database performance
- `/var/lib/caddy` - Balanced compression for SSL certificates

### 3. SSD Longevity and Performance
**Principle**: Minimize write amplification and optimize for NVMe characteristics.

**Rationale**: NVMe SSDs have finite write cycles. Compression and optimal TRIM reduce wear.

**Implementation**:
- `compress=zstd` - 30-40% space savings reduces writes
- `discard=async` - Non-blocking TRIM operations
- `noatime` - Reduces metadata writes
- `ssd` - Btrfs SSD-specific optimizations

## Partition Strategy

### GPT Partition Table Benefits
- **LBA Addressing**: Works with large NVMe drives
- **Metadata Checksums**: Detects corruption
- **Partition Alignment**: Optimal for 4KB sectors
- **Legacy Boot Support**: GRUB compatibility

### Partition Sizing

#### BIOS Boot (1MB)
- **Minimum Required**: GRUB requires 1MB for core.img
- **Format**: EF02 (BIOS boot partition)
- **Location**: First partition for compatibility

#### EFI System Partition (1GB)
- **Rationale**: Accommodates multiple kernel generations
- **Space Calculation**: ~200MB per kernel + initrd
- **Security**: umask=0077, fmask=0077, dmask=0077

#### Swap (32GB)
- **Size**: 1.33x RAM (32GB RAM → 32GB swap)
- **Purpose**: System suspend and memory pressure
- **Security**: `randomEncryption=true`
- **Resume**: Enabled for faster boot recovery

#### Root Btrfs (~447GB)
- **Space Allocation**: Remaining disk space
- **Features**: `block-group-tree` (modern Btrfs feature)

## Subvolume Design

### Flat vs Nested Layout Choice

**Decision**: Flat layout with `@subvolume` naming convention.

**Alternatives Considered**:
1. Nested: `@/subvol/nested` structure
2. Flat: `@subvolume` simple structure

**Rationale**:
- **Simplicity**: Easier to understand and manage
- **Snapshot Compatibility**: Flat snapshots are easier to restore
- **Mount Simplicity**: Direct `@subvolume` → `/mount` mapping
- **Performance**: No nesting overhead

### Subvolume Purposes

#### Root (@root) - Ephemeral
- **Purpose**: System root that gets wiped on boot
- **Contents**: `/etc`, `/bin`, `/usr`, etc.
- **Lifecycle**: Wiped by impermanence script
- **Mount Options**: `compress=zstd:3,noatime,ssd,space_cache=v2,discard=async`

#### Nix (@nix) - Persistent Package Store
- **Purpose**: Nix package cache and derivations
- **Persistence**: Critical for system functionality
- **Size**: Can grow to hundreds of GB
- **Compression**: zstd:1 (fast decompression for frequent access)
- **NeededForBoot**: true (required during early boot)

#### Persist (@persist) - Persistent Data
- **Purpose**: All user and service data that survives reboots
- **Contents**: Configuration files, application data
- **Security**: Contains sensitive persistent data
- **NeededForBoot**: true

#### Log (@log) - System Logs
- **Purpose**: Persistent system and application logs
- **Behavior**: High write frequency, variable size
- **Strategy**: Could be ephemeral with logrotate, but persistent for debugging
- **NeededForBoot**: true

#### Containers (@containers) - Podman Storage
- **Purpose**: Container images, volumes, and overlayfs
- **Performance**: `nodatacow` for database container performance
- **Size**: Can grow large with container images
- **Compression**: zstd:1 (fast access to container layers)

#### Caddy (@caddy) - Caddy Data
- **Purpose**: SSL certificates, configuration
- **Critical**: Required for HTTPS services
- **Security**: Contains sensitive cryptographic material
- **NeededForBoot**: true

#### Snapshots (@snapshots) - Btrfs Snapshots
- **Purpose**: Point-in-time backups
- **Behavior**: Read-only snapshots of other subvolumes
- **Retention**: Manual or automated cleanup required

#### Old Roots (@old_roots) - Impermanence Archive
- **Purpose**: Store old root subvolumes for rollback
- **Retention**: 30 days via automated cleanup
- **Structure**: Timestamped subvolumes from impermanence rotation

## Mount Options Strategy

### Universal Options
All subvolumes use these base options:
- `noatime`: Reduce metadata writes (no access time updates)
- `ssd`: Enable Btrfs SSD-specific optimizations
- `space_cache=v2`: Efficient space management on large filesystems
- `compress=zstd`: Compression with configurable levels

### Compression Level Selection

**Level 1 (Fast)**: `/nix`, `/containers`
- **Workload**: Frequent reads, small files
- **Priority**: Performance over compression ratio
- **Trade-off**: Less space savings, faster access

**Level 3 (Balanced)**: `@root`, `@persist`, `@log`, `@caddy`, `@snapshots`, `@old_roots`
- **Workload**: Mixed read/write, variable file sizes
- **Priority**: Balanced performance and space
- **Trade-off**: Good compression ratio with acceptable CPU usage

**no compression (nodatacow)**: `/containers` (selected paths)
- **Workload**: Database files, VM images
- **Priority**: Maximum I/O performance
- **Trade-off**: No space savings, direct I/O

### Special Mount Options

#### `discard=async`
- **Function**: TRIM/UNMAP for SSD space reclamation
- **Behavior**: Non-blocking (async) operation
- **Benefit**: No I/O stalls during normal operations
- **Performance**: Critical for maintaining responsiveness

#### `neededForBoot`
- **Function**: Ensure subvolume is mounted before systemd attempts to access
- **Use Cases**: `/nix`, `/persist`, `/log`, `/caddy`
- **Failure Impact**: System boot failure if not mounted

## Impermanence Integration

### Root Wipe Mechanism
**Tool**: `boot.initrd.postDeviceCommands` in NixOS configuration

**Process**:
1. Btrfs subvolume list identifies `@root` snapshot
2. `@root` is deleted and recreated fresh
3. Old `@root` snapshot moved to `@old_roots` with timestamp

### Old Root Retention
**Retention Policy**: 30 days
**Cleanup**: Automated script runs on every boot
**Naming Convention**: `old_root_<timestamp>`

### Persistence Declaration
**Pattern**: Files to persist must be in `/persist` or bound mounts
**Example**: `/persist/etc/machine-id` for persistent machine ID
**Validation**: Check with `mount | grep btrfs` and `btrfs subvolume list`

## Security Considerations

### Data Isolation
- **Separate Subvolumes**: Different security policies per data type
- **Log Isolation**: Persistent logs don't expose transient data
- **Container Isolation**: Container data separated from system

### Encryption Points
- **Swap Encryption**: `randomEncryption=true` for swap partition
- **Persistent Data**: Can be added later with LUKS if required
- **At-Rest Protection**: Full disk encryption possible with LUKS on Btrfs

### Attack Surface Reduction
- **Ephemeral Root**: Reduces persistent malware capabilities
- **Clean State**: No leftover configuration files from previous states
- **Audit Trail**: Logs preserved for security analysis

## Performance Analysis

### Compression Impact
- **zstd Level 1**: ~20% space savings, minimal CPU overhead
- **zstd Level 3**: ~35% space savings, moderate CPU overhead
- **Overall**: 30-40% space reduction across filesystem

### I/O Patterns
- **Read-Heavy**: `/nix`, `/containers` benefit from compression
- **Write-Heavy**: `/log` performance maintained with compression
- **Random I/O**: Database containers with `nodatacow`

### SSD Optimization
- **Write Reduction**: Compression reduces write amplification
- **TRIM Efficiency**: Async discard prevents I/O stalls
- **Wear Leveling**: `ssd` option optimizes for wear patterns

## Recovery and Maintenance

### Snapshot Strategy
- **Automatic**: Before impermanence rotation
- **Manual**: Before major system changes
- **Retention**: Old roots kept for 30 days

### Monitoring Points
- **Space Usage**: `btrfs filesystem usage`
- **Compression Ratios**: `compsize -x /`
- **Snapshot Count**: `btrfs subvolume list / | grep old_root`
- **Mount Options**: `mount | grep btrfs`

### Maintenance Procedures
- **Balance**: Periodic `btrfs balance start` if fragmentation high
- **Scrub**: `btrfs scrub start` for data integrity checks
- **Old Root Cleanup**: Automatic via impermanence script

## Integration Points

### With Existing Change: nixos-base-hetzner-vps
- **Dependencies**: Disk layout required before base config
- **Integration**: Host configuration imports disko.nix
- **Testing**: VM test with both changes together

### With Future Changes
- **OpenCode Services**: Will use `/var/lib/containers` for Podman
- **Caddy Configuration**: Will use `/var/lib/caddy` for certificates
- **Backup System**: Will snapshot from `/.snapshots`

### With NixOS Installation
- **Disko Pattern**: Standard disko usage for production NixOS
- **Installation Flow**: `nix flake install --system x86_64-linux`
- **Verification**: `nixos-rebuild switch` with this configuration

## Alternative Designs Considered

### 1. Traditional Ext4
**Rejected**: No snapshot capability, no compression, no subvolumes

### 2. LVM + Btrfs
**Rejected**: Added complexity, nested snapshot hierarchy
**Advantage of Flat**: Simpler recovery and understanding

### 3. Nested Btrfs Subvolumes
**Rejected**: Complex mount paths, snapshot restoration complexity
**Advantage of Flat**: Direct subvolume mapping

### 4. No Compression
**Rejected**: Significant space waste, increased write amplification
**Why zstd**: Good compression ratios with fast decompression

### 5. Separate Filesystems
**Rejected**: No snapshot consistency across filesystem boundaries
**Why Btrfs**: Consistent snapshots across all data

## Success Metrics

### Technical
- [ ] All subvolumes mount successfully
- [ ] Compression ratios > 30% across filesystem
- [ ] No I/O stalls from discard operations
- [ ] Root wipes cleanly on boot (< 10 seconds)

### Operational
- [ ] Easy snapshot creation and restoration
- [ ] Simple backup procedures
- [ ] Clear understanding of persistent vs ephemeral data
- [ ] No boot failures due to mount issues

### Security
- [ ] Ephemeral root reduces attack persistence
- [ ] Log persistence supports audit requirements
- [ ] Minimal attack surface from clean state
- [ ] Sensitive data properly isolated

---

**Design Rationale**: This configuration optimizes for production server operations with impermanence benefits while maintaining performance and usability. The flat subvolume structure provides simplicity without sacrificing the power of Btrfs features.
