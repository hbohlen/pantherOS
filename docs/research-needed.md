# ASUS ROG Zephyrus – Research Needed Items

## Hardware Integration Research

### 1. NixOS Hardware Module Availability
**Status**: TBD
**Description**: Check if nixos-hardware repository has specific module for ASUS ROG Zephyrus M16 GU603ZW
**Impact**: Could provide pre-configured hardware-specific optimizations
**Research Steps**:
- Search nixos-hardware for "asus", "rog", "zephyrus", "GU603ZW"
- Check if any ASUS ROG laptop modules exist that could be adapted
- Review existing hardware modules for similar ASUS laptops

### 2. ASUS MUX Switch Behavior in NixOS
**Status**: TBD
**Description**: Verify how ASUS MUX switch interacts with NixOS boot process and graphics initialization
**Impact**: Critical for graphics stability and performance
**Research Steps**:
- Test current MUX switch behavior during NixOS boot
- Verify if MUX switch state persists across reboots
- Check if any kernel modules or services interfere with MUX operation
- Document any required boot parameters or configurations

### 3. Fan Curve Optimization
**Status**: TBD
**Description**: Determine optimal fan curves for both performance and quiet operation
**Impact**: Affects thermal performance, noise levels, and component longevity
**Research Steps**:
- Test current fan curves under various loads (gaming, compilation, idle)
- Monitor temperatures and fan speeds during stress testing
- Experiment with custom fan curve configurations
- Document optimal temperature-to-fan-speed mappings

## Storage and Filesystem Research

### 4. Device Path Verification
**Status**: TBD
**Description**: Confirm NVMe device paths for disko configuration
**Impact**: Critical for proper disk partitioning and boot configuration
**Research Steps**:
- Verify `/dev/nvme0n1` and `/dev/nvme1n1` are consistent across reboots
- Check for any device path changes during system updates
- Test with different kernel versions if applicable
- Document stable device identification methods

### 5. ZSTD Compression Performance Testing
**Status**: TBD
**Description**: Determine optimal ZSTD compression level for this hardware
**Impact**: Balances storage efficiency with CPU overhead
**Research Steps**:
- Benchmark ZSTD levels 1-5 on various file types
- Measure CPU usage and compression ratios
- Test impact on system responsiveness
- Document recommended compression levels for different use cases

### 6. Secondary Drive Encryption Strategy
**Status**: TBD
**Description**: Evaluate need for encryption on 2TB data drive
**Impact**: Affects security, performance, and backup strategy
**Research Steps**:
- Assess data sensitivity and security requirements
- Test performance impact of encrypting secondary drive
- Consider backup and recovery implications
- Document recommended encryption approach

## Power Management Research

### 7. Udev Rules Reliability
**Status**: TBD
**Description**: Test automatic AC/battery profile switching reliability
**Impact**: Affects user experience and power management effectiveness
**Research Steps**:
- Test udev rules with various AC connection/disconnection scenarios
- Verify profile switching works correctly during suspend/resume
- Check for conflicts with power-profiles-daemon
- Document any edge cases or failure modes

### 8. GPU Power Limiting Impact
**Status**: TBD
**Description**: Evaluate performance impact of GPU power limiting on battery
**Impact**: Balances battery life with usability
**Research Steps**:
- Test GPU performance at different power limits (15W, 30W, 40W, 55W)
- Measure frame rates and responsiveness in various applications
- Document battery life improvements at each power level
- Determine optimal power limits for different use cases

## Software Integration Research

### 9. Desktop Environment Integration
**Status**: TBD
**Description**: Investigate profile indicators and controls for desktop environments
**Impact**: Improves user experience and visibility of current system state
**Research Steps**:
- Research Wayland-compatible system tray applications
- Test integration with various desktop environments (GNOME, KDE, Sway/Niri)
- Develop or find profile switching GUI tools
- Document recommended desktop integration approaches

### 10. User Configuration Templates
**Status**: TBD
**Description**: Create user-specific configuration templates
**Impact**: Improves setup experience for different user types
**Research Steps**:
- Develop configurations for different user profiles (developer, gamer, general use)
- Create template home directory structures
- Test with various software stacks and workflows
- Document recommended user configurations

## Performance Optimization Research

### 11. Kernel Parameter Optimization
**Status**: TBD
**Description**: Fine-tune kernel parameters for this specific hardware
**Impact**: Can improve system responsiveness and performance
**Research Steps**:
- Research optimal kernel parameters for i9-12900H and RTX 3070 Ti
- Test various scheduler and I/O parameters
- Benchmark system performance with different configurations
- Document recommended kernel parameter sets

### 12. Virtualization Performance
**Status**: TBD
**Description**: Optimize virtualization settings for this hardware
**Impact**: Affects VM/container performance for development workloads
**Research Steps**:
- Test VM performance with different configurations
- Optimize KVM/QEMU settings for this CPU/GPU combination
- Evaluate GPU passthrough capabilities and performance
- Document recommended virtualization settings

## Security and Maintenance Research

### 13. Backup Strategy Development
**Status**: TBD
**Description**: Design comprehensive backup strategy for dual-drive setup
**Impact**: Critical for data protection and system recovery
**Research Steps**:
- Evaluate backup tools compatible with Btrfs snapshots
- Design backup schedules for system and data drives
- Test disaster recovery procedures
- Document complete backup and restore workflow

### 14. System Update Procedures
**Status**: TBD
**Description**: Develop safe update procedures for this configuration
**Impact**: Prevents system breakage during updates
**Research Steps**:
- Test NixOS updates with current hardware configuration
- Identify potential update conflicts or issues
- Develop rollback procedures
- Document safe update workflow

## Testing and Validation

### 15. Comprehensive Stress Testing
**Status**: TBD
**Description**: Validate system stability under various loads
**Impact**: Ensures reliability for production use
**Research Steps**:
- Conduct CPU stress testing (Prime95, compilation workloads)
- Test GPU stability under gaming and compute loads
- Verify thermal management during extended heavy use
- Document system limits and safe operating parameters

### 16. Battery Life Validation
**Status**: TBD
**Description**: Measure actual battery life with different configurations
**Impact**: Validates effectiveness of power saving measures
**Research Steps**:
- Test battery life with different power profiles
- Measure battery drain during various activities
- Validate automatic profile switching effectiveness
- Document expected battery life for different use cases

## Priority Matrix

| Research Item | Priority | Estimated Effort | Dependencies |
|---------------|-----------|-------------------|---------------|
| Device Path Verification | High | Low | None |
| NixOS Hardware Module | High | Low | None |
| Udev Rules Reliability | High | Medium | Power profiles setup |
| Fan Curve Optimization | Medium | High | Thermal testing tools |
| ZSTD Compression Testing | Medium | Medium | Storage setup |
| GPU Power Limiting | Medium | Medium | NVIDIA drivers |
| Backup Strategy | Medium | High | Storage layout |
| Kernel Parameter Optimization | Low | High | Performance testing |
| Desktop Environment Integration | Low | Medium | Desktop choice |
| Virtualization Performance | Low | Medium | VM setup |

## Next Steps

1. **Immediate (High Priority)**:
   - Verify device paths and hardware module availability
   - Test udev rules for automatic profile switching
   - Document current system behavior as baseline

2. **Short-term (Medium Priority)**:
   - Conduct performance and thermal testing
   - Optimize storage configuration
   - Develop backup strategy

3. **Long-term (Low Priority)**:
   - Fine-tune kernel parameters
   - Develop desktop integration
   - Create comprehensive documentation

## Documentation Updates

As research items are completed, update the following files:
- `system-profile.md` - Add verified hardware information
- `nixos-host-design.md` - Update configuration with research findings
- `research-needed.md` - Mark completed items and add new findings