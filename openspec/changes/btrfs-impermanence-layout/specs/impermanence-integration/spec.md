# Impermanence Integration Specification

## ADDED Requirements

### Root Subvolume Wipe on Boot

**Requirement**: Implement impermanence script that wipes root subvolume on every boot and archives old roots with timestamps.

**Configuration**:
```nix
{
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    # Mount Btrfs filesystem
    mkdir -p /mnt
    mount -t btrfs -o subvol=/ /dev/sda4 /mnt
    
    # Archive current root snapshot if it exists
    if btrfs subvolume list /mnt | grep -q 'path root'; then
      timestamp=$(date +%Y%m%d_%H%M%S)
      btrfs subvolume snapshot /mnt/root "/mnt/old_roots/old_root_$timestamp"
    fi
    
    # Delete old @root subvolume
    if btrfs subvolume list /mnt | grep -q 'path root'; then
      btrfs subvolume delete /mnt/root
    fi
    
    # Create fresh @root subvolume
    btrfs subvolume create /mnt/root
    
    # Clean up old roots older than 30 days
    find /mnt/old_roots -name 'old_root_*' -type d -mtime +30 -exec btrfs subvolume delete {} \; 2>/dev/null || true
    
    # Unmount
    umount /mnt
    
    # Force remount of root
    echo "Initiating impermanence rotation..."
    for i in {1..10}; do
      if mountpoint -q /; then
        umount / || true
        break
      fi
      sleep 1
    done
    
    # Trigger remount
    systemctl restart tmp.mount || true
  '';
}
```

**Process Flow**:
1. Mount Btrfs filesystem at temporary mount point
2. Archive current root snapshot with timestamp
3. Delete old root subvolume
4. Create fresh root subvolume
5. Clean up roots older than 30 days
6. Unmount and trigger remount

**Rationale**: Ensures clean system state on every boot while preserving rollback capability for 30 days.

#### Scenario: Normal Boot with Impermanence
**Given**: System running with changes to root filesystem  
**When**: System reboots  
**Then**:
- Current root archived to old_roots with timestamp
- Root subvolume wiped and recreated fresh
- Old roots older than 30 days cleaned up
- System boots with clean state
- Rollback capability preserved

#### Scenario: First Boot After Installation
**Given**: Fresh NixOS installation with impermanence config  
**When**: System boots for first time  
**Then**:
- No existing root subvolume to archive
- Fresh root subvolume created
- System operates normally
- No errors from missing previous state

### Old Root Retention Policy

**Requirement**: Implement automatic cleanup of old roots older than 30 days with timestamp-based naming.

**Retention Policy**:
- **Keep**: Old roots for 30 days
- **Naming**: `old_root_YYYYMMDD_HHMMSS` format
- **Cleanup**: Automated during each boot
- **Storage**: Located in `/btrfs_tmp/old_roots/`

**Command**:
```bash
find /mnt/old_roots -name 'old_root_*' -type d -mtime +30 -exec btrfs subvolume delete {} \; 2>/dev/null || true
```

**Rationale**: 30-day retention provides adequate rollback window while preventing indefinite storage accumulation.

#### Scenario: Old Root Cleanup
**Given**: Multiple old root snapshots with various ages  
**When**: Cleanup command executes  
**Then**:
- Roots older than 30 days deleted automatically
- Recent snapshots (0-30 days) preserved
- Space reclaimed from old snapshots
- Rolling 30-day window maintained

#### Scenario: Manual Rollback Access
**Given**: System issue requires rollback  
**When**: Administrator needs to access old root  
**Then**:
- Old roots accessible via /btrfs_tmp/old_roots/
- Timestamps allow identification of specific state
- Recent snapshots available for 30 days
- Clear naming convention for identification

### Persistence Declaration Mechanism

**Requirement**: Define explicit persistence patterns for files that must survive root wipe.

**Persistence Pattern**:
```nix
{
  environment.persistence."/persist" = {
    hideMountPoint = true;
    directories = [
      "/etc/machine-id"
      "/home/hbohlen/.ssh"
      "/var/lib/caddy"
      "/var/lib/containers"
    ];
  };
}
```

**Directory Structure**:
```
/persist/
├── etc/
│   └── machine-id
├── home/
│   └── hbohlen/
│       └── .ssh/
├── var/
│   ├── lib/
│   │   ├── caddy/
│   │   └── containers/
│   └── log/
```

**Rationale**: Explicit persistence prevents accidental loss of critical data while maintaining impermanence benefits.

#### Scenario: Critical File Persistence
**Given**: System files that must persist across reboots  
**When**: Impermanence rotation occurs  
**Then**:
- Files in /persist directories remain intact
- Critical configuration persists
- System identity preserved (machine-id, SSH keys)
- Application data maintained

#### Scenario: New Persistence Requirement
**Given**: Application needs to persist data  
**When**: Application installed and configured  
**Then**:
- Admin adds directory to persistence config
- Directory created in /persist subvolume
- Data survives future reboots
- Clear mechanism for persistence additions

### Impermanence File Copy Mechanism

**Requirement**: Implement file and directory copying from old roots to new root before deletion.

**Copy Script**:
```nix
{
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    # After creating new root, copy persisted files from old root
    timestamp=$(date +%Y%m%d_%H%M%S)
    old_root="/mnt/old_roots/old_root_$timestamp"
    
    # Copy persistence directories from old root if they exist
    for dir in /persist/*; do
      if [ -d "$old_root$dir" ]; then
        cp -a "$old_root$dir" "/mnt/$dir" 2>/dev/null || true
      fi
    done
  '';
}
```

**Behavior**: Before wiping root, copy any persisted files to new root if they exist in old root.

#### Scenario: Persistence Migration
**Given**: Files in persistence directories modified  
**When**: System boots with impermanence  
**Then**:
- Modified files copied from old root to new root
- Persistence directories recreated as needed
- User modifications preserved
- System configuration maintained

#### Scenario: First Boot Persistence Setup
**Given**: Persistence directories need to be created  
**When**: First boot with impermanence  
**Then**:
- Persistence directories created as needed
- Default configuration files created
- System operates normally
- Future modifications preserved

## MODIFIED Requirements

### Initrd Integration

**Requirement**: Integrate impermanence script into NixOS initrd postDeviceCommands.

**Location**: `boot.initrd.postDeviceCommands` (executed during early boot)

**Timing**: After device detection but before root filesystem mount

**Integration**: Must work within initrd environment with limited tools

**Rationale**: Impermanence must execute early enough to affect root mount but late enough to access disk devices.

#### Scenario: Initrd Environment
**Given**: NixOS initrd boot process  
**When**: Post device detection phase  
**Then**:
- btrfs tools available in initrd
- /dev/sda device accessible
- Mount points accessible
- Commands execute successfully

#### Scenario: Boot Timing Requirements
**Given**: Impermanence needs to run early in boot  
**When**: Boot process initiates  
**Then**:
- Script runs before root filesystem finalization
- Sufficient time for subvolume operations
- No race conditions with other initrd operations
- Clean handoff to system boot

### Systemd Service Integration

**Requirement**: Ensure impermanence integration doesn't conflict with systemd mount operations.

**Strategy**: Use `lib.mkAfter` to ensure script runs after automatic device mounting but before final root setup.

**Conflict Prevention**:
- Use temporary mount point /mnt
- Minimal operations in initrd
- Cleanup all temporary mounts
- Don't interfere with automatic mounts

#### Scenario: Systemd Mount Conflict
**Given**: Automatic systemd mount operations running  
**When**: Impermanence script executes  
**Then**:
- Script uses temporary mount points
- No interference with systemd mounts
- Proper cleanup after operations
- Successful handoff to systemd

#### Scenario: Mount Point Management
**Given**: Multiple mount operations during boot  
**When**: Impermanence uses /mnt mount point  
**Then**:
- /mnt used for temporary mount
- Proper unmounting after operations
- No leftover mount points
- Clean boot process

## REMOVED Requirements

### Manual Root Management
**Removed**: Manual root subvolume management commands

**Rationale**: Automation through initrd ensures consistent, reliable root management.

#### Scenario: Automated Management
**Given**: System configured with impermanence  
**When**: Boot occurs  
**Then**:
- All root management automated
- No manual intervention required
- Consistent behavior every boot
- Reliable operation

### Manual Old Root Cleanup
**Removed**: Manual cleanup scheduling for old roots

**Rationale**: Integrated cleanup during boot ensures consistent maintenance.

#### Scenario: Automatic Maintenance
**Given**: Multiple old roots accumulating  
**When**: System boots  
**Then**:
- Cleanup happens automatically
- No manual cleanup scheduling needed
- Consistent retention policy
- No storage waste from old snapshots

## Implementation Details

### Initrd Environment Constraints
- Limited shell utilities available
- Must be compatible with NixOS initrd
- No network access required
- Minimal filesystem operations
- Fast execution (< 10 seconds)

### Timestamp Format
- **Format**: `YYYYMMDD_HHMMSS`
- **Example**: `20251119_143022`
- **Purpose**: Unique identification, chronological sorting
- **Timezone**: UTC for consistency

### Btrfs Command Usage
```bash
# Archive current root
btrfs subvolume snapshot /mnt/root "/mnt/old_roots/old_root_$timestamp"

# Delete old root
btrfs subvolume delete /mnt/root

# Create fresh root
btrfs subvolume create /mnt/root

# List subvolumes
btrfs subvolume list /mnt

# Cleanup old roots
find /mnt/old_roots -name 'old_root_*' -type d -mtime +30 -exec btrfs subvolume delete {} \;
```

### Error Handling
- Graceful handling of missing subvolumes
- Continue operation even if cleanup fails
- Log operations for debugging
- No boot failure from script errors

### Persistence Path Mapping
```
Source (old root) → Destination (new root)
/persist/etc/machine-id → /etc/machine-id
/persist/home/user/.ssh → /home/user/.ssh
/persist/var/lib/caddy → /var/lib/caddy
/persist/var/lib/containers → /var/lib/containers
```

---

**Integration**: This specification enables clean system state management while preserving critical persistence requirements.
