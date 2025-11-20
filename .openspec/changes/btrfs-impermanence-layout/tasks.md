# Tasks: Btrfs Partition Layout with Impermanence

## Implementation Roadmap

This document outlines the ordered tasks required to implement the Btrfs partition layout with impermanence support for the Hetzner CPX52 VPS.

### Phase 1: Configuration Development (Tasks 1-3)
**Objective**: Create the core disko.nix configuration with partition layout and subvolume structure.

#### Task 1: Partition Layout Implementation
**Priority**: High  
**Dependencies**: None  
**Estimated Time**: 1-2 hours  
**Status**: Pending

**Description**: Implement GPT partition table with BIOS boot, ESP, swap, and root partitions.

**Deliverables**:
- [ ] `hosts/servers/hetzner-cloud/disko.nix` with partition layout
- [ ] BIOS boot partition (1MB, type EF02)
- [ ] EFI System Partition (1GB, type EF00 with vfat)
- [ ] Swap partition (32GB with randomEncryption)
- [ ] Root Btrfs partition (~447GB)

**Validation Steps**:
1. Verify syntax with `nix-instantiate hosts/servers/hetzner-cloud/disko.nix`
2. Check partition sizing calculations
3. Validate filesystem types and options

**Technical Details**:
```nix
{
  # GPT partition table
  # BIOS boot: 1MB, EF02
  # ESP: 1GB, EF00/vfat with security options
  # Swap: 32GB, randomEncryption=true
  # Root: remainder, Btrfs
}
```

#### Task 2: Btrfs Subvolume Structure
**Priority**: High  
**Dependencies**: Task 1  
**Estimated Time**: 1 hour  
**Status**: Pending

**Description**: Define all Btrfs subvolumes with proper naming and creation order.

**Deliverables**:
- [ ] 8 subvolumes defined: root, nix, persist, log, containers, caddy, snapshots, old_roots
- [ ] Subvolume creation in correct dependency order
- [ ] Flat layout implementation (@subvolume naming)

**Validation Steps**:
1. Verify subvolume creation order
2. Check naming consistency
3. Validate mount point declarations

**Technical Details**:
```nix
{
  # Create subvolumes in dependency order
  # @root -> /
  # @nix -> /nix
  # @persist -> /persist
  # etc.
}
```

#### Task 3: Mount Configuration and Options
**Priority**: High  
**Dependencies**: Task 2  
**Estimated Time**: 1 hour  
**Status**: Pending

**Description**: Configure mount options, compression levels, and special flags per subvolume.

**Deliverables**:
- [ ] Compression levels per subvolume (zstd:1, zstd:3, nodatacow)
- [ ] Universal mount options (noatime, ssd, space_cache=v2, discard=async)
- [ ] neededForBoot flags for critical subvolumes
- [ ] Management mount at /btrfs_tmp

**Validation Steps**:
1. Verify all mount options present
2. Check compression level assignments
3. Validate neededForBoot requirements

**Technical Details**:
```nix
{
  # Subvolume-specific options:
  # - @nix: compress=zstd:1, neededForBoot=true
  # - @containers: nodatacow, compress=zstd:1
  # - All: noatime, ssd, space_cache=v2, discard=async
}
```

### Phase 2: Impermanence Integration (Tasks 4-5)
**Objective**: Implement impermanence script for root subvolume rotation and cleanup.

#### Task 4: Impermanence Configuration
**Priority**: High  
**Dependencies**: Tasks 1-3  
**Estimated Time**: 2 hours  
**Status**: Pending

**Description**: Create impermanence integration with boot.initrd.postDeviceCommands.

**Deliverables**:
- [ ] Root subvolume wipe script
- [ ] Old root movement to @old_roots with timestamps
- [ ] Automatic 30-day cleanup of old roots
- [ ] Integration with NixOS configuration

**Validation Steps**:
1. Verify script syntax and logic
2. Check timestamp format consistency
3. Test cleanup command logic

**Technical Details**:
```nix
{
  # boot.initrd.postDeviceCommands for root rotation
  # - List current @root snapshot
  # - Move to @old_roots with timestamp
  # - Create fresh @root
  # - Cleanup roots older than 30 days
}
```

#### Task 5: Persistence Declaration Structure
**Priority**: Medium  
**Dependencies**: Task 4  
**Estimated Time**: 1 hour  
**Status**: Pending

**Description**: Create example persistence declarations and documentation.

**Deliverables**:
- [ ] Example /persist directory structure
- [ ] Documentation for adding persistence
- [ ] Common persistence patterns

**Validation Steps**:
1. Check documentation completeness
2. Verify example configurations
3. Test persistence pattern examples

**Technical Details**:
```nix
{
  # Examples:
  # /persist/etc/machine-id
  # /persist/home/hbohlen/.ssh/authorized_keys
  # etc.
}
```

### Phase 3: Testing and Validation (Tasks 6-8)
**Objective**: Thoroughly test configuration in VM environment before production deployment.

#### Task 6: VM Testing Infrastructure
**Priority**: High  
**Dependencies**: Tasks 1-5  
**Estimated Time**: 1-2 hours  
**Status**: Pending

**Description**: Set up VM testing environment with NixOS virtual machine.

**Deliverables**:
- [ ] VM configuration for testing disko.nix
- [ ] Test scripts for partition and subvolume validation
- [ ] Automated verification commands

**Validation Steps**:
1. VM boots successfully with new disk layout
2. All partitions created correctly
3. All subvolumes mount as expected
4. Impermanence rotation works in VM

**Technical Details**:
```bash
# Test commands:
nixos-rebuild build-vm --flake .#hetzner-vps
mount | grep btrfs
btrfs subvolume list /
compsize -x /
```

#### Task 7: Performance Validation
**Priority**: Medium  
**Dependencies**: Task 6  
**Estimated Time**: 1 hour  
**Status**: Pending

**Description**: Verify compression ratios, mount performance, and SSD optimization.

**Deliverables**:
- [ ] Compression ratio measurements
- [ ] Mount option validation
- [ ] TRIM operation verification

**Validation Steps**:
1. Measure compression ratios with compsize
2. Verify no I/O stalls with async discard
3. Check mount performance
4. Validate SSD-specific optimizations

**Technical Details**:
```bash
# Performance tests:
compsize -x /                  # compression ratios
mount | grep btrfs            # mount options
btrfs filesystem usage /      # space usage
```

#### Task 8: Integration Testing
**Priority**: High  
**Dependencies**: Task 6  
**Estimated Time**: 1 hour  
**Status**: Pending

**Description**: Test integration with nixos-base-hetzner-vps change.

**Deliverables**:
- [ ] Combined configuration builds successfully
- [ ] Integration points validated
- [ ] Boot process complete

**Validation Steps**:
1. Build combined configuration
2. Test in VM with both changes
3. Verify boot completion
4. Check all services start properly

**Technical Details**:
```bash
# Integration tests:
nixos-rebuild build --flake .#hetzner-vps
nixos-rebuild build-vm --flake .#hetzner-vps
```

### Phase 4: Documentation and Deployment (Tasks 9-10)
**Objective**: Complete documentation and prepare for production deployment.

#### Task 9: Documentation Completion
**Priority**: Medium  
**Dependencies**: Tasks 6-8  
**Estimated Time**: 1 hour  
**Status**: Pending

**Description**: Complete all documentation including installation and maintenance guides.

**Deliverables**:
- [ ] Installation instructions for disko.nix
- [ ] Subvolume usage guide
- [ ] Snapshot and restore procedures
- [ ] Troubleshooting guide

**Validation Steps**:
1. Review documentation completeness
2. Verify all procedures tested
3. Check for documentation consistency

**Technical Details**:
```markdown
# Documentation sections:
- Installation guide
- Usage guide
- Maintenance procedures
- Troubleshooting
```

#### Task 10: Production Readiness
**Priority**: High  
**Dependencies**: Tasks 6-9  
**Estimated Time**: 30 minutes  
**Status**: Pending

**Description**: Final validation and preparation for Hetzner deployment.

**Deliverables**:
- [ ] All tasks completed and validated
- [ ] Final build test successful
- [ ] Deployment checklist created
- [ ] Rollback plan documented

**Validation Steps**:
1. Final build verification
2. Check all acceptance criteria met
3. Verify rollback procedures
4. Confirm Hetzner deployment readiness

**Technical Details**:
```bash
# Final checks:
nix flake check
nixos-rebuild build --flake .#hetzner-vps
# All acceptance criteria from proposal.md
```

## Task Dependencies

```
Task 1 ──┬─ Task 2 ──┬─ Task 4 ──┬─ Task 9 ──┬─ Task 10
         │           │           │           │
         ├─ Task 3 ──┼─ Task 5   │           │
         │           │           │           │
         └─ Task 6 ──┼─ Task 7   │           │
                     │           │           │
                     └─ Task 8 ──┘           │
                                             │
                     All tasks ──────────────┘
```

## Acceptance Criteria Validation

### Technical Acceptance
- [ ] All partitions created correctly via disko
- [ ] All subvolumes mount at correct paths
- [ ] Mount options applied correctly
- [ ] Compression working with measurable ratios
- [ ] Swap enabled with encryption
- [ ] Management mount functional

### Functional Acceptance
- [ ] Root subvolume wipes cleanly on boot
- [ ] Old roots moved with timestamps
- [ ] Automatic cleanup of old roots
- [ ] Impermanence rotation working

### Integration Acceptance
- [ ] Configuration builds without errors
- [ ] Integration with nixos-base-hetzner-vps
- [ ] VM testing successful
- [ ] Documentation complete

### Performance Acceptance
- [ ] Compression ratios > 30%
- [ ] No I/O stalls from discard
- [ ] SSD optimizations working
- [ ] Mount performance acceptable

## Risk Mitigation Status

### High Risk Items
- [x] **Data Loss Prevention**: Persistence explicitly documented
- [x] **Boot Failure**: VM testing required before production
- [ ] **Impermanence Script**: Manual testing needed

### Medium Risk Items
- [ ] **VM Environment**: May not perfectly match Hetzner environment
- [ ] **Performance**: Actual performance may vary from VM
- [ ] **Space Management**: Need to monitor usage patterns

### Low Risk Items
- [ ] **Documentation**: Review and validation process in place
- [ ] **Maintenance**: Automated cleanup reduces manual intervention

## Quality Gates

### Gate 1: Configuration Complete
- [ ] Tasks 1-3 completed
- [ ] Basic disko.nix builds successfully
- [ ] Partition and subvolume structure validated

### Gate 2: Impermanence Working
- [ ] Tasks 4-5 completed
- [ ] Root rotation script functional
- [ ] Persistence patterns documented

### Gate 3: Testing Passed
- [ ] Tasks 6-8 completed
- [ ] VM testing successful
- [ ] Performance metrics acceptable
- [ ] Integration tests passed

### Gate 4: Production Ready
- [ ] Tasks 9-10 completed
- [ ] All acceptance criteria met
- [ ] Documentation reviewed
- [ ] Deployment ready

## Resource Requirements

### Time Allocation
- **Total Estimated Time**: 8-12 hours
- **Peak Load**: Days 1-2 (configuration development)
- **Testing Phase**: Day 3 (VM testing and validation)
- **Documentation**: Day 4 (finalization and review)

### System Requirements
- **Development Environment**: Linux system with NixOS
- **VM Resources**: 4GB RAM, 20GB disk minimum
- **NixOS Channel**: nixos-25.05 or newer
- **Flake Inputs**: disko, nixpkgs

### External Dependencies
- **Hetzner VPS**: For final deployment testing
- **1Password**: For any secrets needed in testing
- **Tailscale**: For remote VM access if needed

## Success Metrics

### Technical Metrics
- [ ] Configuration builds: 100% success rate
- [ ] Partition creation: 100% accuracy
- [ ] Subvolume mounting: All 8 subvolumes functional
- [ ] Compression ratios: >30% average
- [ ] Impermanence rotation: <10 seconds per boot

### Operational Metrics
- [ ] VM testing: All scenarios pass
- [ ] Documentation: Complete and accurate
- [ ] Integration: Seamless with existing changes
- [ ] Deployment: Ready for Hetzner VPS

### Quality Metrics
- [ ] Code Quality: Follows NixOS conventions
- [ ] Documentation Quality: Clear and actionable
- [ ] Test Coverage: All critical paths tested
- [ ] Error Handling: Graceful failure modes

---

**Task Tracking**: This document should be updated as tasks progress, with completion markers and any issues encountered.
