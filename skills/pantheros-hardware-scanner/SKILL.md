---
name: pantheros-hardware-scanner
description: Automates Phase 1 hardware discovery for pantherOS development. Scans system hardware (CPU, memory, storage, network), generates comprehensive documentation, and creates disko.nix templates. Essential for setting up new hosts, documenting existing systems, and preparing disk layouts. Use when: (1) Setting up a new pantherOS host (workstation or server), (2) Documenting hardware specifications, (3) Creating initial disko.nix configuration files, (4) Auditing hardware across multiple hosts.
---

# PantherOS Hardware Scanner

## Overview

This skill automates the Phase 1 hardware discovery process for pantherOS, eliminating the need to manually collect and format hardware information. It scans system components, generates comprehensive documentation, and creates disko.nix templates ready for customization.

**What it does:**
- Scans CPU, memory, storage, and network interfaces
- Generates formatted hardware documentation (Markdown)
- Creates raw system info file for reference
- Produces disko.nix template based on detected hardware
- Suggests optimal filesystem and partition layouts

## Quick Start

### Running the Scanner

```bash
# Navigate to your pantherOS project
cd /home/hbohlen/dev/pantherOS

# Run scanner with hostname
./scripts/scan-hardware.sh <hostname> [output-dir]
```

**Examples:**

```bash
# Scan Yoga workstation, save to hardware docs directory
./scripts/scan-hardware.sh yoga ./docs/hardware/

# Scan Zephyrus laptop, save current directory
./scripts/scan-hardware.sh zephyrus .

# Scan server with full path
./scripts/scan-hardware.sh hetzner-vps /home/hbohlen/dev/pantherOS/docs/hardware/
```

### Understanding Output

The scanner generates three files per host:

1. **`{hostname}-hardware.md`** - Human-readable documentation
   ```markdown
   # Hardware Documentation for yoga

   ## CPU
   - Model: AMD Ryzen 9 7950X
   - Cores: 16, Threads: 32
   - Base: 4.5 GHz, Boost: 5.7 GHz

   ## Memory
   - Total: 64 GB (2x32 GB)
   - Type: DDR5-5600
   ```

2. **`{hostname}-system-info.txt`** - Raw command output
   ```
   === System Information for yoga ===
   --- CPU ---
   Architecture: x86_64
   CPU(s): 32
   Model name: AMD Ryzen 9 7950X 16-Core Processor
   ```

3. **`{hostname}-disko.nix.template`** - Nix disk layout template
   ```nix
   {
     disko.devices = {
       disk = {
         main = {
           type = "disk";
           device = "/dev/nvme0n1";  # ← Verify this!
           content = {
             type = "gpt";
             partitions = {
               # ... btrfs subvolumes ...
   ```

## The Complete Workflow

### Step 1: Scan Hardware

Run the scanner on the target system:

```bash
./scripts/scan-hardware.sh <hostname> ./docs/hardware/
```

**Prerequisites:**
- Run directly on the target system (not over SSH)
- Have `hwinfo`, `util-linux` installed
- Bash 4.0+ available

### Step 2: Review Documentation

Open the generated markdown file:

```bash
cat docs/hardware/<hostname>-hardware.md
```

**Check:**
- CPU model and cores ✓
- Memory capacity and type ✓
- All disks detected ✓
- Network interfaces ✓
- GPU detected (for workstations) ✓

### Step 3: Customize disko.nix

Review and edit the template:

```bash
cat <hostname>-disko.nix.template
```

**Critical edits:**
1. **Device path** - Must match actual disk
   - Desktop: `/dev/nvme0n1`, `/dev/sda`
   - Server: `/dev/vda`, `/dev/sda`

2. **Partition sizes** - Adjust if needed
   ```nix
   boot = {
     size = "1G";  # Increase if using multiple kernels
   };
   ```

3. **Subvolumes** - Customize for your needs
   ```nix
   subvolumes = {
     "/root" = { mountpoint = "/"; };
     "/home" = { mountpoint = "/home"; };
     "/nix" = { mountpoint = "/nix"; };
     "/persist" = { mountpoint = "/persist"; };
     # Add: /var/log, /tmp, etc.
   };
   ```

4. **Filesystem** - btrfs recommended
   ```nix
   content = {
     type = "btrfs";
     subvolumes = { ... };
   };
   ```

### Step 4: Validate Template

Test the template syntax:

```bash
nix-instantiate --eval ./<hostname>-disko.nix.template
```

Should output the evaluated configuration without errors.

### Step 5: Integrate with Host Config

Copy the template to your host directory:

```bash
cp <hostname>-disko.nix.template hosts/<hostname>/disko.nix
```

## Hardware Patterns

### Desktop/Workstation Configuration

**Typical setup:**
- 1x NVMe SSD (500GB - 2TB)
- 16-128 GB RAM
- Discrete GPU (NVIDIA/AMD)
- WiFi + Ethernet

**Template characteristics:**
```nix
device = "/dev/nvme0n1";  # NVMe drive
boot = "512M";            # Standard EFI partition
main = "100%";            # Rest of disk for btrfs
filesystem = "btrfs";     # With multiple subvolumes
```

### Server Configuration (VPS)

**Typical setup:**
- Virtual block device
- 4-32 GB RAM
- No GPU
- Single network interface

**Template characteristics:**
```nix
device = "/dev/vda";      # Virtual disk
boot = "512M";            # Smaller boot partition
main = "100%";            # Everything else
filesystem = "btrfs";     # Single or minimal subvolumes
```

### High-Performance Workstation

**Special considerations:**
- Multiple NVMe drives (consider RAID)
- High-core-count CPU (32+ cores)
- 128+ GB RAM
- Multiple GPUs

**Template characteristics:**
```nix
# May need custom partitioning for multiple disks
# Separate subvolumes for /tmp, /var/lib/docker, etc.
# Consider separate /home on different disk
```

## Common Tasks

### Documenting Existing Hardware

```bash
# Run on each existing host
./scripts/scan-hardware.sh $(hostname) ./docs/hardware/

# Commit documentation
git add docs/hardware/
git commit -m "docs: document $(hostname) hardware"
```

### Setting Up New Host

```bash
# 1. Scan on the new host
./scripts/scan-hardware.sh new-hostname ./docs/hardware/

# 2. Customize template
vim new-hostname-disko.nix.template

# 3. Test build
nixos-rebuild build .#new-hostname

# 4. Deploy (when ready)
nixos-rebuild switch --flake .#new-hostname
```

### Comparing Hardware Across Hosts

```bash
# Generate docs for all hosts
./scripts/scan-hardware.sh yoga ./docs/hardware/
./scripts/scan-hardware.sh zephyrus ./docs/hardware/
./scripts/scan-hardware.sh hetzner-vps ./docs/hardware/
./scripts/scan-hardware.sh ovh-vps ./docs/hardware/

# View differences
diff docs/hardware/yoga-hardware.md docs/hardware/zephyrus-hardware.md
```

### Auditing Hardware Configuration

```bash
# List all documented hosts
ls -1 docs/hardware/*-hardware.md

# Check for documentation completeness
grep -L "Memory" docs/hardware/*-hardware.md  # Find missing memory info

# Verify all hosts have disko.nix
find hosts -name "disko.nix" | sort
```

## Troubleshooting

### Scanner script not found

```bash
# Check if script exists
ls -la /home/hbohlen/dev/pantherOS/skills/pantheros-hardware-scanner/scripts/scan-hardware.sh

# Make executable
chmod +x scripts/scan-hardware.sh

# Run from skill directory
cd /home/hbohlen/dev/pantherOS/skills/pantheros-hardware-scanner
./scripts/scan-hardware.sh <hostname>
```

### hwinfo not available

```bash
# Install hwinfo
nix-env -iA nixos.hwinfo

# Or add to your configuration
# In configuration.nix: environment.systemPackages = [ pkgs.hwinfo ];
```

### Device names don't match reality

```bash
# Manually check block devices
lsblk

# Verify disk is detected
fdisk -l /dev/sda  # or /dev/nvme0n1

# Update template manually
vim <hostname>-disko.nix.template
```

### disko.nix template syntax error

```bash
# Check template syntax
nix-instantiate --eval <hostname>-disko.nix.template

# Common issues:
# - Missing quotes around device path
# - Incorrect subvolume syntax
# - Wrong partition type code
```

### Need different partition layout

```bash
# Edit template to match needs
# Example: Separate /home

boot = {
  size = "512M";
  type = "EF00";
  # ...
};

home = {
  size = "100G";  # Separate home partition
  type = "8300";
  content = {
    type = "btrfs";
    subvolumes = {
      "/home" = { mountpoint = "/home"; };
    };
  };
};
```

## Advanced Usage

### Custom Hardware Report

Generate focused reports:

```bash
# CPU-intensive tasks only
grep -A 20 "## CPU" docs/hardware/yoga-hardware.md

# Storage configuration
grep -A 30 "## Storage" docs/hardware/yoga-hardware.md

# Network interfaces
grep -A 15 "## Network" docs/hardware/yoga-hardware.md
```

### Script Output to Other Formats

```bash
# Convert to PDF (requires pandoc)
pandoc docs/hardware/yoga-hardware.md -o docs/hardware/yoga-hardware.pdf

# Convert to JSON for automation
grep "CPU" docs/hardware/yoga-hardware.md | jq -R -s .
```

### Integration with CI/CD

Add to deployment pipeline:

```yaml
# .github/workflows/deploy.yml
- name: Scan hardware
  run: |
    ./scripts/scan-hardware.sh ${{ matrix.host }} ./docs/hardware/
    nix-instantiate --eval hosts/${{ matrix.host }}/disko.nix
```

## Integration with Other Skills

- **Module Generator** - Use hardware specs to determine required modules (GPU drivers for workstations, server modules for VPS)
- **Host Manager** - Compare configurations across similar hardware
- **Nix Analyzer** - Validate hardware-specific settings in configuration.nix
- **Deployment Orchestrator** - Use hardware info to optimize deployment strategy

## References

For detailed workflow information, see:
- `references/hardware-workflow.md` - Complete Phase 1 process guide
- `references/hardware-patterns.md` - Common hardware configurations
- `references/troubleshooting.md` - Advanced troubleshooting

## Resources

This skill provides:
- **Scripts**: `scan-hardware.sh` - Main hardware scanning script
- **References**: Workflow guides and best practices documentation
- **Templates**: Auto-generated disko.nix configurations
