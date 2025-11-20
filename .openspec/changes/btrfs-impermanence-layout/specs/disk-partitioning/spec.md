# Disk Partitioning Specification

## ADDED Requirements

### GPT Partition Table for 480GB NVMe SSD

**Requirement**: Create a GPT partition table with 4 partitions optimized for Hetzner Cloud CPX52 VPS.

**Configuration**:
```nix
{
  disko.devices = {
    disk = {
      "sda" = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # 1. BIOS boot partition
            bios-boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            
            # 2. EFI System Partition
            esp = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
              priority = 2;
            };
            
            # 3. Swap partition
            swap = {
              size = "32G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
              };
              priority = 3;
            };
            
            # 4. Root Btrfs partition
            root = {
              size = "512M"; # Will be overridden by "max"
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Force format
                btrfsConfig = {
                  label = "nixos";
                  features = [ "block-group-tree" ];
                };
              };
              priority = 4;
            };
          };
        };
      };
    };
  };
}
```

**Partition Sizes**:
- BIOS Boot: 1MB (EF02) - Legacy GRUB compatibility
- ESP: 1GB (EF00/vfat) - Multiple kernel generations
- Swap: 32GB (8200) - 1.33x RAM for suspend support
- Root: Remaining space (~447GB) (8300/Btrfs)

**Rationale**: Hetzner Cloud requires EFI compatibility but also legacy boot support. The 1GB ESP provides space for multiple NixOS kernel generations. 32GB swap supports RAM expansion scenarios.

#### Scenario: Fresh Installation on Hetzner CPX52
**Given**: Hetzner Cloud VPS with 480GB NVMe SSD and NixOS ISO booted  
**When**: disko.nix is applied during installation  
**Then**:
- GPT partition table created successfully
- All 4 partitions created with correct sizes and types
- ESP formatted as vfat with security mount options
- Swap created with encryption enabled
- Root partition formatted as Btrfs with modern features

#### Scenario: Legacy Boot Compatibility
**Given**: Hetzner Cloud environment with BIOS boot requirements  
**When**: System boots and GRUB needs core.img  
**Then**:
- BIOS boot partition provides 1MB space for GRUB core.img
- EFI boot loader remains in ESP for modern boot
- Both boot paths available for maximum compatibility

### ESP Security Configuration

**Requirement**: Configure EFI System Partition with secure mount options.

**Options**:
- `umask=0077`: Default directory permissions (rwx------)
- `fmask=0077`: Default file permissions (rwx------)  
- `dmask=0077`: Default directory mask (rwx------)

**Rationale**: ESP contains boot files and kernel images. Restrictive permissions prevent unauthorized modifications during runtime.

#### Scenario: Multi-Kernel Support
**Given**: Multiple NixOS kernel versions installed  
**When**: ESP approaches capacity  
**Then**:
- 1GB provides space for 5+ kernel versions
- Each kernel includes initrd (~50-100MB total)
- Security permissions prevent runtime modifications
- Kernel updates don't cause ESP space issues

### Swap Partition Configuration

**Requirement**: Create 32GB swap partition with random encryption for suspend support.

**Configuration**:
```nix
{
  type = "8200";  # Linux swap partition type
  content = {
    type = "swap";
    randomEncryption = true;  # Secure encryption
  };
}
```

**Size Calculation**: 32GB = 1.33 × 32GB RAM (32GB RAM on Hetzner CPX52)

**Rationale**: Provides sufficient swap for memory pressure scenarios and hibernation support. Random encryption ensures security of swap data.

#### Scenario: Memory Pressure Recovery
**Given**: System under high memory load  
**When**: RAM exhaustion occurs  
**Then**:
- 32GB swap provides emergency memory
- Swap operations complete successfully
- System remains responsive
- OOM conditions prevented

#### Scenario: Hibernation Support
**Given**: User initiates system suspend  
**When**: System attempts to hibernate  
**Then**:
- 32GB swap accommodates entire RAM contents
- Random encryption protects data at rest
- Hibernation completes successfully
- System resumes from sleep state

### Btrfs Root Partition

**Requirement**: Create remaining disk space as Btrfs partition with modern features.

**Configuration**:
```nix
{
  type = "8300";  # Linux filesystem type
  content = {
    type = "btrfs";
    extraArgs = [ "-f" ];  # Force format
    btrfsConfig = {
      label = "nixos";
      features = [ "block-group-tree" ];
    };
  };
}
```

**Features**:
- `block-group-tree`: Modern Btrfs metadata structure
- `-f` flag: Force format to handle existing data

**Label**: "nixos" for identification and mount references

#### Scenario: Large Disk Allocation
**Given**: 480GB total disk with other partitions allocated  
**When**: Root partition sizing occurs  
**Then**:
- Root receives remaining space (~447GB)
- Btrfs formatted with modern features
- Label "nixos" applied for identification
- Force flag handles any existing data

#### Scenario: Modern Btrfs Features
**Given**: Btrfs filesystem with block-group-tree  
**When**: System operates under various workloads  
**Then**:
- Modern metadata structure improves performance
- Space management optimized for large filesystems
- Future Btrfs features accessible
- Compatibility with latest Btrfs tools

## MODIFIED Requirements

### Partition Priority Ordering

**Requirement**: Define clear priority order for partition creation.

**Priority Values**:
1. BIOS boot (1)
2. ESP (2)  
3. Swap (3)
4. Root (4)

**Rationale**: Lower numbers create first. BIOS boot must be first for compatibility. ESP needs early creation for boot loader installation. Root gets remaining space regardless of specific sizing.

#### Scenario: Automatic Sizing
**Given**: Root partition with priority 4 and "max" size  
**When**: Partition creation occurs  
**Then**:
- Lower priority partitions created first
- Root receives all remaining space automatically
- No manual calculation needed
- Resilient to changes in other partition sizes

### Force Format Protection

**Requirement**: Use force flag for Btrfs partition formatting.

**Reasoning**: During initial installation, partition may have residual data from hosting platform provisioning.

**Safety**: `-f` flag ensures clean format regardless of previous state.

#### Scenario: Clean Installation
**Given**: Hetzner VPS with fresh disk  
**When**: Btrfs partition is formatted  
**Then**:
- Force flag ensures clean format
- Any residual data cleared
- Optimal filesystem structure established
- Ready for subvolume creation

## REMOVED Requirements

### MBR Partition Table
**Removed**: Traditional MBR partition table support

**Rationale**: GPT provides better features for large disks, better metadata protection, and modern boot compatibility.

#### Scenario: Large Disk Support
**Given**: 480GB NVMe SSD  
**When**: Partition table must be chosen  
**Then**:
- GPT chosen over MBR for disk size
- Better support for large partitions
- Improved metadata protection
- Modern operating system compatibility

### Fixed Root Partition Size
**Removed**: Manual root partition sizing

**Rationale**: Allow root to use remaining space automatically. Flexibility for future size changes.

#### Scenario: Storage Flexibility
**Given**: Partition sizing requirements  
**When**: Disk space allocation needed  
**Then**:
- Root gets remaining space automatically
- No manual calculation required
- Resilient to partition changes
- Optimal space utilization

## Implementation Details

### Partition Creation Order
```nix
# 1. BIOS boot (1MB) - priority 1
# 2. ESP (1GB) - priority 2  
# 3. Swap (32GB) - priority 3
# 4. Root (remainder) - priority 4
```

### Device Recognition
- Primary device: `/dev/sda`
- Hetzner Cloud standard naming
- Compatible with cloud initialization scripts

### Format Options
- vfat: Standard FAT32 for ESP compatibility
- swap: Linux swap with encryption
- btrfs: Modern Linux filesystem with compression

### Security Considerations
- ESP mount restrictions prevent runtime modifications
- Swap encryption protects memory dumps
- Btrfs features support advanced security capabilities

---

**Integration**: This specification provides the foundation for Btrfs subvolume creation in the next capability specification.
