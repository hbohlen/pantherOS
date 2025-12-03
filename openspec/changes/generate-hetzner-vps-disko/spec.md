# OpenSpec: Generate Hetzner VPS Production-Ready Disko Configuration

## Summary

Generate a production-ready `disko.nix` configuration for the Hetzner VPS with optimal BTRFS subvolume layout, proper mount options for KVM environment, and integrated snapshot/backup procedures.

## Hardware Context

**Host**: Hetzner VPS (KVM virtualization)
**Disk**: Single 458GB device (`/dev/vda`) with virtio_scsi controller
**Memory**: 3.6GB total
**Role**: Production server

## Current State

- Hetzner VPS exists with hardware scanning data in `hosts/servers/hetzner-vps/facter.json`
- No production-ready disko.nix configuration exists
- Basic infrastructure in place but lacks enterprise storage management

## Proposed Changes

### 1. Device Verification & Analysis

- **Main disk path**: `/dev/vda` (confirmed from facter.json)
- **Effective size**: 458GB (confirmed from hardware scan)
- **Controller**: virtio_scsi (KVM optimized)
- **Virtualization**: KVM environment with appropriate mount options

### 2. Complete Disko Configuration

**Partitions**:

- EFI System Partition (ESP): 512MB (if using UEFI)
- Main BTRFS partition: Remaining space (457.5GB)

**BTRFS Subvolumes** (production-optimized):

- `/@root` → `/` (root filesystem)
- `/@home` → `/home` (user data)
- `/@nix` → `/nix` (Nix store)
- `/@var` → `/var` (variable data)
- `/@cache` → `/var/cache` (application caches)
- `/@log` → `/var/log` (log files)
- `/@tmp` → `/var/tmp` (temporary files)
- `/@persist` → `/persist` (persistent configuration)
- `/@postgresql` → `/var/lib/postgresql` (database data, nodatacow)

### 3. Mount Options (KVM-optimized)

- **Compression**: `zstd` for space efficiency
- **Performance**: `noatime` to reduce disk writes
- **SSD optimization**: `discard=async` for TRIM support
- **Database**: `nodatacow` for PostgreSQL subvolume (critical for performance)

### 4. Supporting Infrastructure

- **fstrim service**: Weekly SSD optimization
- **snapper integration**: Automated snapshots
- **Service hooks**: Monitoring and maintenance tasks

### 5. Snapshot & Backup Strategy

- **Daily snapshots**: Automatic for root and home subvolumes
- **Weekly snapshots**: Extended retention for critical data
- **Backup integration**: Snapshots as backup points
- **Restore procedures**: Documented step-by-step recovery

## Implementation Plan

### Phase 1: Core Disko Configuration

1. Create production-ready `disko.nix` with BTRFS subvolume layout
2. Implement proper mount options for KVM/virtio_scsi environment
3. Add device verification and sizing logic
4. Include comprehensive documentation and comments

### Phase 2: Supporting Services

1. Configure fstrim service for SSD optimization
2. Set up snapper for snapshot management
3. Create service hooks for monitoring
4. Add maintenance and health check procedures

### Phase 3: Backup & Recovery

1. Document snapshot strategy and retention policies
2. Create restore procedures for different failure scenarios
3. Integrate with existing backup infrastructure
4. Test recovery procedures

### Phase 4: Validation & Testing

1. Validate Nix syntax and disko compatibility
2. Test installation on staging environment
3. Verify all mount points and subvolumes work correctly
4. Confirm backup/restore procedures

## Success Criteria

- [ ] Production-ready `disko.nix` generated for Hetzner VPS
- [ ] All BTRFS subvolumes created with appropriate mount options
- [ ] fstrim and snapper services configured and functional
- [ ] Complete snapshot/backup strategy documented
- [ ] Restore procedures tested and verified
- [ ] Nix flake validation passes
- [ ] Installation tested on similar hardware configuration

## Risk Assessment

- **Low**: Configuration based on proven patterns and existing hardware data
- **Medium**: Need to test installation on actual Hetzner VPS hardware
- **Mitigation**: Staged deployment with rollback capability

## Dependencies

- Hetzner VPS hardware configuration (available in facter.json)
- Existing NixOS infrastructure and flake configuration
- OpenSpec change management workflow

## Files to be Created/Modified

- `hosts/servers/hetzner-vps/disko.nix` (new)
- `hosts/servers/hetzner-vps/snapper.nix` (new)
- `hosts/servers/hetzner-vps/fstrim.nix` (new)
- Documentation for snapshot/backup procedures

## Estimated Effort

- **Disko configuration**: 2-3 hours
- **Supporting services**: 1-2 hours
- **Documentation**: 1 hour
- **Testing & validation**: 2-4 hours (staged)
- **Total**: 6-10 hours (including testing)

## Approval Required

This change requires approval before implementation as it affects production server storage configuration.
