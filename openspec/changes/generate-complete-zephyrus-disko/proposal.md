# Complete Zephyrus Disko.nix Generation - Proposal

## Summary

Generate a complete disko.nix configuration for the ASUS ROG Zephyrus laptop that utilizes both NVMe SSDs with optimized btrfs subvolume layout for heavy development workloads including Zed IDE, Podman containers, and various development tools.

## Problem Statement

The current disko.nix configuration only utilizes the primary 2TB Crucial SSD and lacks:

- Configuration for the secondary 1TB Micron SSD
- Optimized btrfs subvolume layout for development workloads
- Proper mount options for performance and reliability
- Integration with snapshot/backup strategies

## Objective

Create a comprehensive disko.nix that:

1. **Device Verification**: Map facter.json devices to actual hardware (Crucial P3 2TB and Micron 2450 1TB)
2. **Dual-Disk Strategy**: Utilize both NVMe SSDs with appropriate partitioning
3. **Optimized Btrfs Layout**: Design subvolumes for development workloads (~/dev, containers, projects)
4. **Performance Tuning**: Apply mount options optimized for NVMe and development tools
5. **Integration**: Include complementary NixOS configuration for fstrim, Podman, and snapshot tooling

## Hardware Context

**Primary Disk**: `/dev/nvme0n1` - Crucial P3 2TB (CT2000P310SSD8)
**Secondary Disk**: `/dev/nvme1n1` - Micron 2450 1TB (Micron_2450_MTFDKBA1T0TFK)

## Workload Requirements

- **Development Tools**: Zed IDE, Vivaldi, Ghostty, Fish shell, Niri window manager
- **Container Workloads**: Podman containers (rootless)
- **Project Storage**: ~/dev directory with multiple projects
- **Development AI**: opencode.ai and other development tools

## Solution Design

### Disk Strategy

- **Primary Disk (nvme0n1)**: System root, user home, and active projects
- **Secondary Disk (nvme1n1)**: Container storage, cache, and backup data

### Btrfs Subvolume Layout

```
Primary Disk:
- @ (root filesystem)
- @home (user data)
- @nix (Nix store)
- @var (system variables)
- @dev-projects (~/dev - active development)

Secondary Disk:
- @containers (Podman container storage)
- @cache (application caches)
- @snapshots (system snapshots/backup data)
- @tmp (temporary data)
```

## Implementation Tasks

1. **Device Mapping**: Verify hardware from facter.json and map to devices
2. **Disko Configuration**: Generate complete dual-disk disko.nix with btrfs subvolumes
3. **NixOS Integration**: Create complementary configuration snippets
4. **Documentation**: Provide deployment steps and verification procedures
5. **Validation**: Test configuration in --mode test before deployment

## Expected Deliverables

1. Complete `disko.nix` file with both disk configurations
2. NixOS configuration snippets for:
   - fstrim.timer for SSD maintenance
   - Podman basic configuration
   - snapper/snapshot tooling integration
3. Deployment and verification steps
4. Performance and reliability considerations documentation

## Risk Assessment

- **Low Risk**: Configuration based on standard btrfs and disko patterns
- **Mitigation**: Test in --mode disko test before actual deployment
- **Rollback**: Existing single-disk configuration can be restored if needed
