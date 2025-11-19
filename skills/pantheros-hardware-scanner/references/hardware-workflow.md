# Hardware Discovery Workflow

## Overview

This guide explains the complete Phase 1 hardware discovery process for pantherOS, from scanning hardware to creating the initial disk layout configuration.

## When to Use This Skill

Use this skill when:
- Setting up a new host in pantherOS
- Documenting hardware for existing systems
- Preparing to create disko.nix for a new machine
- Auditing hardware configurations across hosts

## The Hardware Discovery Process

### Step 1: Run Hardware Scanner

```bash
cd /home/hbohlen/dev/pantherOS
./scripts/scan-hardware.sh <hostname> [output-dir]
```

**Example:**
```bash
./scripts/scan-hardware.sh yoga ./docs/hardware/
```

### Step 2: Review Generated Documentation

The scanner creates three files:

1. **`{hostname}-hardware.md`** - Human-readable hardware documentation
2. **`{hostname}-system-info.txt`** - Raw command output for reference
3. **`{hostname}-disko.nix.template`** - Template for disk layout

### Step 3: Customize disko.nix Template

Edit the generated template to match your needs:

```nix
{ config, lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";  # ← Update this!
        # ... rest of configuration
      };
    };
  };
}
```

**Important checks:**
- Verify device name (`/dev/sda`, `/dev/nvme0n1`, etc.)
- Confirm disk size matches
- Adjust partitions if needed (e.g., separate /home, custom mount points)
- Verify filesystem type (btrfs for pantherOS)

### Step 4: Move to Module Development (Phase 2)

After hardware is documented:
1. Create host directory: `mkdir -p hosts/<hostname>`
2. Copy disko.nix: `cp template.nix hosts/<hostname>/disko.nix`
3. Create configuration: `hosts/<hostname>/configuration.nix`
4. Start building modules

## Hardware Detection Reference

The scanner automatically detects:

### CPU
- Model name, architecture, frequency
- Core/thread count, sockets
- Virtualization support

### Memory
- Total RAM, per-module details
- Memory type (DDR4, DDR5, etc.)
- Speed, latency

### Storage
- All block devices (HDDs, SSDs, NVMe)
- Filesystems, mount points
- Disk health (SSD/HDD rotation)

### Graphics
- GPU model, VRAM
- Integrated vs discrete

### Network
- All network interfaces
- MAC addresses, speeds
- WiFi capabilities

## Common Hardware Patterns

### Desktop/Workstation (Yoga, Zephyrus)
```nix
# Desktop patterns
- Single large NVMe SSD
- Separate /home subvolume
- EFI boot (/boot)
- Btrfs with subvolumes
```

### Server (Hetzner, OVH VPS)
```nix
# Server patterns
- Virtual block device
- Single root filesystem
- Minimal partitions
- No desktop GPU
```

## Best Practices

1. **Always verify device names** - `lsblk` to confirm before using in disko.nix
2. **Document unusual hardware** - Custom RAID, multiple GPUs, specialty cards
3. **Plan for future expansion** - Extra disks, memory slots
4. **Note performance characteristics** - NVMe speeds, GPU capabilities
5. **Keep hardware docs updated** - When upgrading components

## Troubleshooting

### Scanner fails to run
- Ensure running on target system (not remotely)
- Check permissions: `chmod +x scan-hardware.sh`
- Install dependencies: `hwinfo`, `util-linux`

### Device not detected
- Run `lsblk` manually to check
- USB devices may not appear - check `lsusb`
- NVMe drives show as `/dev/nvme*`

### disko.nix template doesn't match
- Manual edit required for non-standard setups
- RAID configurations need custom layout
- Multiple disks require different structure

## Next Steps

After hardware discovery:

1. **Verify documentation is complete**
   - CPU specs documented
   - Memory modules listed
   - Storage layout confirmed

2. **Test disko.nix template**
   ```bash
   nix-instantiate --eval ./hosts/<hostname>/disko.nix
   ```

3. **Proceed to Phase 2**
   - Create host configuration
   - Start building modules
   - Test with `nixos-rebuild build`

## Integration with Other Skills

This skill works together with:
- **Module Generator** - Use hardware specs to determine needed modules
- **Host Manager** - Compare hardware across similar hosts
- **Nix Analyzer** - Validate hardware-specific configurations
