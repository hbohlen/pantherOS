# Change Proposal: Btrfs Partition Layout with Impermanence for Hetzner CPX52

## Summary

Design and implement an optimal Btrfs partition layout with impermanence support for the 480GB NVMe SSD on Hetzner CPX52 VPS. The configuration uses ephemeral root with automatic cleanup, persistent data subvolumes, and optimized compression settings per workload.

## Why

This change is essential for establishing a production-ready, maintainable server infrastructure with several key benefits:

**Clean State Guarantee**: Impermanence ensures the system starts fresh on every boot, eliminating configuration drift and accumulated cruft that degrades systems over time.

**Explicit Persistence**: Forces deliberate decisions about what data persists, improving security by reducing attack surface and simplifying backup strategies.

**Easy Recovery**: Btrfs snapshots enable instant rollback. Old roots are preserved for 30 days, allowing recovery from misconfigurations.

**Performance Optimization**: Subvolume-specific compression and mount options optimize for different workloads (database, containers, logs).

**SSD Longevity**: Compression reduces write amplification, and `discard=async` provides optimal TRIM performance without I/O stalls.

## Context

### Infrastructure Details
- **Target**: Hetzner Cloud CPX52 VPS
  - 16 vCPU AMD EPYC processor
  - 32GB RAM
  - 480GB NVMe SSD (/dev/sda)
- **OS**: NixOS 25.05
- **Filesystem**: Btrfs with flat subvolume layout

### Current State
- Empty `hosts/servers/hetzner-cloud/disko.nix` file
- Existing change `nixos-base-hetzner-vps` provides base configuration
- Need disk layout before system installation

### Problem Statement
The server requires a disk layout that:
- Supports impermanence (ephemeral root wiped on boot)
- Provides persistent storage for specific data (/nix, /persist, logs, containers)
- Optimizes for SSD performance and longevity
- Enables snapshot-based backups
- Supports 32GB RAM with swap for potential suspend operations

## Solution Overview

### Architectural Approach
1. **GPT Partition Table**: Modern partitioning with legacy BIOS boot compatibility
2. **Flat Subvolume Layout**: Simple `@subvolume` naming without nested hierarchy
3. **Workload-Specific Optimization**: Different compression levels per subvolume purpose
4. **Impermanence Integration**: Root wipe via initrd commands with 30-day old root retention

### Partition Layout

| Partition | Size | Type | Purpose |
|-----------|------|------|---------|
| BIOS Boot | 1MB | EF02 | Legacy boot compatibility |
| ESP | 1GB | EF00/vfat | Multiple kernel generations |
| Swap | 32GB | swap | RAM 1.33x for suspend support |
| Root | ~447GB | Btrfs | All subvolumes |

### Subvolume Structure

| Subvolume | Mountpoint | Compression | Special Options |
|-----------|------------|-------------|-----------------|
| root | / | zstd:3 | Ephemeral (wiped on boot) |
| nix | /nix | zstd:1 | neededForBoot |
| persist | /persist | zstd:3 | neededForBoot |
| log | /var/log | zstd:3 | neededForBoot |
| containers | /var/lib/containers | zstd:1 | nodatacow for databases |
| caddy | /var/lib/caddy | zstd:3 | SSL certs persistence |
| snapshots | /.snapshots | zstd:3 | Backup snapshots |
| old_roots | /btrfs_tmp/old_roots | zstd:3 | Impermanence rotation |

### Key Design Decisions

1. **Flat Layout over Nested**: Simpler management, easier snapshot restoration
2. **Separate Log Subvolume**: Isolates high-write logs from other persistent data
3. **nodatacow for Containers**: Better performance for database workloads in Podman
4. **1GB ESP**: Accommodates multiple NixOS generations with kernels
5. **zstd Compression Levels**: :1 for performance-critical, :3 for balanced

## Success Criteria

### Functional Requirements
- [ ] All partitions created correctly via disko
- [ ] All subvolumes mount at correct paths
- [ ] Root subvolume wipes cleanly on every reboot
- [ ] Old roots moved to old_roots with timestamps
- [ ] Automatic cleanup of roots older than 30 days

### Technical Requirements
- [ ] Configuration builds without errors
- [ ] Mount options applied correctly (verify with `mount | grep btrfs`)
- [ ] Compression working (verify with `compsize`)
- [ ] Swap enabled with randomEncryption
- [ ] Management mount at /btrfs_tmp functional

### Performance Requirements
- [ ] Compression ratios measurable via compsize
- [ ] No I/O stalls from TRIM operations (async discard)
- [ ] Database containers perform well with nodatacow

## Deliverables

### Configuration Files
1. `hosts/servers/hetzner-cloud/disko.nix` - Complete disk configuration

### Documentation
- Installation instructions
- Subvolume purpose and usage
- Snapshot and restore procedures
- Impermanence file persistence guide

### Validation
- Build verification
- Partition and subvolume verification
- Mount option validation
- Impermanence rotation testing

## Risks and Mitigations

### High Risk
- **Data Loss on Impermanence**: Mitigate by explicitly configuring /persist binds before enabling
- **Boot Failure**: Test disko config in VM before production deployment

### Medium Risk
- **Swap Insufficient**: 32GB provides 1.33x RAM; monitor for OOM conditions
- **Subvolume Fragmentation**: Schedule periodic balance operations

### Low Risk
- **Compression Overhead**: zstd is CPU-efficient; negligible impact on modern CPUs
- **Snapshot Space**: Monitor with `btrfs filesystem usage`

## Timeline

This is a foundational change that blocks system installation. Must be completed before deploying NixOS to the Hetzner VPS. Estimated effort: 4-6 hours for implementation and VM testing.

## Dependencies

### External Dependencies
- Hetzner Cloud VPS with 480GB NVMe provisioned
- NixOS 25.05 installation ISO
- disko flake input configured

### Internal Dependencies
- None (first disk-level configuration)

### Blocked By This Change
- `nixos-base-hetzner-vps` (needs disk layout for installation)
- All subsequent host configuration

## Approval Requirements

- [ ] Disk layout review for optimal SSD performance
- [ ] Impermanence integration review
- [ ] VM test successful with disko
- [ ] Documentation complete
- [ ] Change ID assigned and proposal accepted

## References

- [Disko Documentation](https://github.com/nix-community/disko)
- [Btrfs Wiki - SSD Optimization](https://btrfs.wiki.kernel.org/index.php/SSD_Performance)
- [NixOS Impermanence](https://github.com/nix-community/impermanence)
- [Erase Your Darlings](https://grahamc.com/blog/erase-your-darlings/)
- [Btrfs Compression](https://btrfs.wiki.kernel.org/index.php/Compression)

---

**Change ID**: btrfs-impermanence-layout  
**Status**: Proposal  
**Author**: hbohlen  
**Date**: 2025-11-19
