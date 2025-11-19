# Hardware Discovery Guide

This guide explains how to scan and document hardware specifications for all pantherOS hosts.

## Overview

Hardware discovery is critical for:
- Optimizing configurations for each host
- Planning disk layouts
- Ensuring compatibility
- Informing module design decisions

## Hardware to Collect

For each host, collect:

### Essential Information
- **CPU**: Model, cores, threads, features (VT-x, AVX, etc.)
- **GPU**: Integrated and discrete graphics
- **RAM**: Total capacity, type (DDR4/DDR5), speed
- **Storage**: Disks (SSD/HDD), capacity, interface (NVMe/SATA)
- **Network**: Wired, wireless adapters
- **Other**: Battery (laptops), sensors, special features

### Host-Specific Considerations

**Workstations (yoga, zephyrus):**
- Battery capacity and health
- Display specifications
- Touch/pen support
- Power management features

**Servers (hetzner-vps, ovh-vps):**
- Virtualization features
- Storage options
- Network configuration
- Security features

## Discovery Process

### Step 1: Create Hardware Documentation

Create a new file in `docs/hardware/` for each host:
```bash
touch docs/hardware/<hostname>.md
```

### Step 2: Collect Hardware Information

Use these commands to gather information:

#### System Overview
```bash
# System information
hostnamectl
lscpu
lsmem

# Hardware summary
hwinfo --short
```

#### CPU Details
```bash
# Detailed CPU information
lscpu -e

# CPU features
grep -E 'flags|fgroup' /proc/cpuinfo

# CPU frequency
lscpu | grep "CPU(s):"
```

#### Memory Information
```bash
# Memory details
cat /proc/meminfo

# Memory modules (requires root)
dmidecode -t memory

# Check for ECC
dmesg | grep -i ecc
```

#### Storage Information
```bash
# Disk listing
lsblk

# Disk details
fdisk -l

# NVMe details (if applicable)
nvme list

# Storage health (SSDs)
smartctl -a /dev/nvme0n1  # Replace with actual device
```

#### GPU Information
```bash
# GPU details
lspci | grep -i vga

# NVIDIA GPUs (if applicable)
nvidia-smi

# AMD GPUs (if applicable)
rocm-smi
```

#### Network Adapters
```bash
# Network devices
ip link show

# WiFi adapters
iwconfig

# Detailed network info
lspci | grep -i ethernet
lspci | grep -i network
```

### Step 3: Document in Standard Format

Use this template for each host's hardware documentation:

```markdown
# Hardware: <hostname>

## Overview
<Brief description of the host and its purpose>

## CPU
- **Model**: <CPU model name>
- **Cores/Threads**: <X cores / Y threads>
- **Base Frequency**: <X.X GHz>
- **Max Frequency**: <X.X GHz>
- **Features**: <important features like VT-x, AVX, etc.>

## GPU
- **Integrated**: <iGPU model if applicable>
- **Discrete**: <dGPU model if applicable>
- **VRAM**: <if applicable>

## Memory
- **Total**: <X GB>
- **Type**: <DDR4/DDR5>
- **Speed**: <X MHz>
- **Configuration**: <e.g., 2x8GB>

## Storage
- **Primary**: <device> - <capacity> <type> (<interface>)
- **Secondary**: <device> - <capacity> <type> (<interface>) [if applicable]

## Network
- **Wired**: <adapter model>
- **Wireless**: <adapter model> [if applicable]

## Other
- **Battery**: <capacity and health for laptops>
- **Special Features**: <e.g., fingerprint reader, backlit keyboard>

## Configuration Implications
- <How this hardware affects configuration>
- <Optimization strategies>
- <Potential issues>
```

### Step 4: Create Hardware Scan Script (Optional)

Create a reusable script in `scripts/`:
```bash
#!/usr/bin/env bash
# Generate hardware report

HOSTNAME=$(hostname)
OUTPUT_FILE="docs/hardware/${HOSTNAME}.md"

# Capture hardware info
{
    echo "# Hardware Report: ${HOSTNAME}"
    echo ""
    echo "Generated on: $(date)"
    echo ""
    echo "## System"
    hostnamectl
    echo ""
    echo "## CPU"
    lscpu
    echo ""
    echo "## Memory"
    cat /proc/meminfo
    echo ""
    echo "## Storage"
    lsblk
    echo ""
    echo "## Network"
    ip link show
    echo ""
    echo "## PCI Devices"
    lspci
} > /tmp/hardware-report.txt

# Clean up and format
cat /tmp/hardware-report.txt

echo ""
echo "Report saved to /tmp/hardware-report.txt"
echo "Review and format into docs/hardware/${HOSTNAME}.md"
```

Make it executable:
```bash
chmod +x scripts/scan-hardware.sh
```

## Planning Disk Layouts

Once hardware is documented, use the information to plan disk layouts:

### Considerations
1. **Host Purpose**: Workstation vs server vs development
2. **Storage Capacity**: How much space is needed
3. **Performance**: NVMe vs SATA, single vs multiple drives
4. **Reliability**: RAID, backups, snapshots
5. **Btrfs Features**: Sub-volumes, compression, snapshots

### Disk Layout Template

```markdown
## Planned Disk Layout

### Primary Disk: <device>
- **Purpose**: Root filesystem, home, and development
- **Filesystem**: Btrfs
- **Sub-volumes**:
  - `@` - Root filesystem
  - `@home` - Home directory
  - `@dev` - Development projects
  - `@var` - Variable data
  - `@nix` - Nix store (if separate)
  - `@snapshots` - Snapshots

### Mount Options
- `compress=zstd` - Compression for SSD longevity
- `noatime` - Reduce writes
- `ssd` - SSD optimizations

### Rationale
<Explain the layout choices based on hardware and usage>
```

## Verification

### Check Hardware Documentation

For each host, verify:
- [ ] All essential hardware documented
- [ ] Format matches standard template
- [ ] Configuration implications noted
- [ ] Disk layout planned
- [ ] File saved in `docs/hardware/`

### Review Process
1. Check that documentation is complete
2. Verify hardware specs make sense
3. Ensure disk layout is appropriate
4. Review configuration implications

## Next Steps

After hardware discovery:
1. Update hardware documentation in repository
2. Proceed to [disk layout planning](./disk-layouts.md)
3. Create `disko.nix` files for each host
4. Update task tracking in `docs/todos/phase1-hardware-discovery.md`

## Tips

### Best Practices
- Document hardware as soon as possible after hardware changes
- Take screenshots or photos of hardware labels
- Keep hardware specs updated
- Note any quirks or issues with specific hardware

### Common Issues
- **Missing GPU information**: Try different tools (lshw, hwinfo)
- **Incomplete memory info**: Requires root for dmidecode
- **Network adapter names**: May need additional drivers

### Tools
- `lscpu` - CPU information
- `lsmem` - Memory information
- `lsblk` - Block devices
- `lspci` - PCI devices
- `hwinfo` - Comprehensive hardware info
- `smartctl` - Storage health (SSDs)

---

**See also:**
- [Disk Layout Planning](../architecture/disk-layouts.md)
- [Disko Configuration](https://github.com/nix-community/disko)
- [Phase 1 Tasks](../todos/phase1-hardware-discovery.md)
