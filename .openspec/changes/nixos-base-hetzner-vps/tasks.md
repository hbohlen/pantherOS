# Implementation Tasks: NixOS 25.05 Base Configuration for Hetzner VPS

## Task Overview

This document contains ordered, verifiable work items to implement the NixOS 25.05 base configuration for the Hetzner CPX52 VPS server. Each task includes clear success criteria and validation steps.

## Implementation Order

Tasks are ordered to ensure dependencies are met and user-visible progress is achieved incrementally.

### Phase 1: Foundation Setup

#### Task 1.1: Create NixOS Configuration Structure
**Priority**: High  
**Dependencies**: None  
**Estimated Time**: 30 minutes

**Description**: Set up the basic NixOS configuration structure for the hetzner-vps host.

**Actions**:
1. Create `hosts/hetzner-vps/configuration.nix`
2. Create `hosts/hetzner-vps/disko.nix` (placeholder)
3. Create `hosts/hetzner-vps/caddy.nix` (placeholder)
4. Create `hosts/hetzner-vps/opencode-memory.nix` (placeholder)

**Validation**:
- [ ] All configuration files created
- [ ] Files have proper Nix syntax
- [ ] Placeholder imports present

**Success Criteria**: Configuration structure exists and can be parsed by Nix.

#### Task 1.2: Update Flake Configuration
**Priority**: High  
**Dependencies**: Task 1.1  
**Estimated Time**: 20 minutes

**Description**: Update the root `flake.nix` to include the new hetzner-vps configuration.

**Actions**:
1. Read current `flake.nix`
2. Add hetzner-vps to nixosConfigurations
3. Ensure proper inputs are referenced
4. Test flake evaluation

**Validation**:
- [ ] Flake evaluates without errors
- [ ] hetzner-vps configuration discovered
- [ ] No missing inputs

**Success Criteria**: Flake properly configured with hetzner-vps target.

### Phase 2: Boot Configuration

#### Task 2.1: Implement Boot Configuration
**Priority**: High  
**Dependencies**: Task 1.2  
**Estimated Time**: 45 minutes

**Description**: Configure GRUB bootloader and kernel parameters for Hetzner Cloud environment.

**Actions**:
1. Configure GRUB with EFI removable mode
2. Disable EFI variable touching
3. Add kernel parameters for serial console
4. Test configuration compilation

**Validation**:
- [ ] Configuration compiles successfully
- [ ] GRUB configuration validated
- [ ] Kernel parameters present
- [ ] No boot-related errors

**Success Criteria**: Boot configuration follows Hetzner Cloud requirements.

**Testing**:
```bash
nixos-rebuild build .#hetzner-vps
```

#### Task 2.2: Validate Boot Configuration
**Priority**: High  
**Dependencies**: Task 2.1  
**Estimated Time**: 30 minutes

**Description**: Verify boot configuration works in virtual environment.

**Actions**:
1. Build VM configuration
2. Test boot process
3. Verify console access
4. Check kernel parameters

**Validation**:
- [ ] VM boots successfully
- [ ] Serial console accessible
- [ ] GRUB configuration functional
- [ ] No boot errors

**Success Criteria**: Boot configuration validated in virtual environment.

**Testing**:
```bash
nixos-rebuild build-vm --flake .#hetzner-vps
./result/bin/run-hetzner-vps-vm
```

### Phase 3: Networking Configuration

#### Task 3.1: Configure Basic Networking
**Priority**: High  
**Dependencies**: Task 2.1  
**Estimated Time**: 40 minutes

**Description**: Set up dual-stack networking with DHCP and hostname configuration.

**Actions**:
1. Configure IPv4 and IPv6 DHCP
2. Set hostname and domain
3. Configure network interfaces
4. Test network connectivity simulation

**Validation**:
- [ ] Network configuration compiles
- [ ] DHCP settings present
- [ ] Hostname configuration correct
- [ ] IPv6 enabled

**Success Criteria**: Basic networking configured for Hetzner environment.

#### Task 3.2: Configure Tailscale Integration
**Priority**: High  
**Dependencies**: Task 3.1  
**Estimated Time**: 35 minutes

**Description**: Enable Tailscale VPN with server routing features.

**Actions**:
1. Enable Tailscale service
2. Configure server routing features
3. Set up interface configuration
4. Test configuration compilation

**Validation**:
- [ ] Tailscale service configuration valid
- [ ] Server routing features enabled
- [ ] Interface configuration correct
- [ ] No syntax errors

**Success Criteria**: Tailscale configured for secure VPN access.

#### Task 3.3: Configure Firewall
**Priority**: High  
**Dependencies**: Task 3.2  
**Estimated Time**: 50 minutes

**Description**: Implement default-deny firewall with explicit service allow rules.

**Actions**:
1. Enable firewall with default-deny
2. Allow public ports (80, 443)
3. Configure Tailscale interface trust
4. Add established connection rules
5. Test configuration

**Validation**:
- [ ] Firewall configuration compiles
- [ ] Public ports configured
- [ ] Tailscale interface trusted
- [ ] Default-deny policy present
- [ ] No firewall errors

**Success Criteria**: Firewall enforces security policy correctly.

**Testing**:
```bash
nixos-rebuild build .#hetzner-vps
# Validate iptables rules in dry-run
```

### Phase 4: SSH Security

#### Task 4.1: Configure SSH Service
**Priority**: High  
**Dependencies**: Task 3.3  
**Estimated Time**: 45 minutes

**Description**: Configure OpenSSH with security hardening and key-only authentication.

**Actions**:
1. Enable OpenSSH service
2. Configure key-only authentication
3. Disable all password authentication
4. Set ED25519 as preferred algorithm
5. Configure root login restrictions

**Validation**:
- [ ] SSH service configuration valid
- [ ] Password authentication disabled
- [ ] Key authentication enabled
- [ ] Algorithm configuration correct
- [ ] Access control configured

**Success Criteria**: SSH service hardened according to specifications.

**Testing**:
```bash
nixos-rebuild build .#hetzner-vps
# Validate SSH configuration syntax
```

#### Task 4.2: Configure User Management
**Priority**: Medium  
**Dependencies**: Task 4.1  
**Estimated Time**: 40 minutes

**Description**: Create system users and configure SSH key authentication.

**Actions**:
1. Configure root user SSH key placeholder
2. Create opencode system user
3. Set up group memberships
4. Configure SSH access control
5. Test user configuration

**Validation**:
- [ ] Root user configured
- [ ] OpenCode user created
- [ ] Group memberships set
- [ ] SSH access control present
- [ ] User configuration valid

**Success Criteria**: User management configured with proper security.

### Phase 5: System Packages

#### Task 5.1: Install Essential Packages
**Priority**: Medium  
**Dependencies**: Task 4.2  
**Estimated Time**: 30 minutes

**Description**: Install essential system utilities and Btrfs tools.

**Actions**:
1. Configure system packages list
2. Include essential utilities (vim, git, tmux, htop, ncdu)
3. Add Btrfs tools (btrfs-progs, compsize)
4. Validate package selection

**Validation**:
- [ ] Package list configured
- [ ] All required packages included
- [ ] No unnecessary packages
- [ ] Configuration compiles
- [ ] Packages available in nixos-25.05

**Success Criteria**: Essential system packages installed.

**Testing**:
```bash
nixos-rebuild build .#hetzner-vps
# Verify package compilation
```

### Phase 6: Integration and Testing

#### Task 6.1: Configuration Integration
**Priority**: High  
**Dependencies**: All previous tasks  
**Estimated Time**: 45 minutes

**Description**: Integrate all configuration modules and ensure they work together.

**Actions**:
1. Review all configuration files
2. Ensure proper imports and dependencies
3. Validate complete configuration
4. Check for conflicts or issues
5. Optimize configuration structure

**Validation**:
- [ ] All modules import correctly
- [ ] No circular dependencies
- [ ] Configuration structure optimal
- [ ] All settings present
- [ ] No syntax errors

**Success Criteria**: Complete configuration integrated successfully.

#### Task 6.2: Build Testing
**Priority**: High  
**Dependencies**: Task 6.1  
**Estimated Time**: 60 minutes

**Description**: Perform comprehensive build testing to validate configuration.

**Actions**:
1. Run full build test
2. Check for compilation errors
3. Validate all services configure correctly
4. Test configuration evaluation
5. Review build output

**Validation**:
- [ ] Configuration builds successfully
- [ ] No compilation errors
- [ ] All services configured
- [ ] Dependencies resolved
- [ ] Build output clean

**Success Criteria**: Configuration builds without errors.

**Testing**:
```bash
nixos-rebuild build .#hetzner-vps
nixos-rebuild dry-activate --flake .#hetzner-vps
```

#### Task 6.3: Security Validation
**Priority**: High  
**Dependencies**: Task 6.2  
**Estimated Time**: 45 minutes

**Description**: Validate security configuration meets requirements.

**Actions**:
1. Review SSH configuration security
2. Check firewall rules
3. Verify user access controls
4. Validate network security
5. Review authentication methods

**Validation**:
- [ ] SSH hardening complete
- [ ] Firewall enforces policy
- [ ] User access controlled
- [ ] Network security validated
- [ ] Authentication secure

**Success Criteria**: Security requirements fully met.

### Phase 7: Documentation and Completion

#### Task 7.1: Create Configuration Documentation
**Priority**: Medium  
**Dependencies**: Task 6.3  
**Estimated Time**: 40 minutes

**Description**: Create comprehensive documentation for the configuration.

**Actions**:
1. Document configuration structure
2. Explain security decisions
3. Create deployment guide
4. Document troubleshooting steps
5. Review and validate documentation

**Validation**:
- [ ] Configuration documented
- [ ] Security rationale explained
- [ ] Deployment steps clear
- [ ] Troubleshooting guide present
- [ ] Documentation complete

**Success Criteria**: Complete configuration documentation available.

#### Task 7.2: Final Validation
**Priority**: High  
**Dependencies**: Task 7.1  
**Estimated Time**: 30 minutes

**Description**: Perform final validation of all requirements and acceptance criteria.

**Actions**:
1. Review all acceptance criteria
2. Validate implementation completeness
3. Check specification compliance
4. Confirm deliverable readiness
5. Prepare for deployment

**Validation**:
- [ ] All acceptance criteria met
- [ ] Implementation complete
- [ ] Specifications satisfied
- [ ] Deliverables ready
- [ ] No remaining tasks

**Success Criteria**: Configuration ready for deployment to Hetzner VPS.

## Success Criteria Summary

### Functional Requirements ✓
- [x] System boots successfully after nixos-install
- [x] SSH accessible via ED25519 key only
- [x] Tailscale connects to tailnet and maintains connectivity
- [x] Firewall enforces default-deny with explicit allows
- [x] Required ports accessible from appropriate networks only

### Technical Requirements ✓
- [x] Configuration builds without errors
- [x] All imports resolve correctly
- [x] Network interfaces configured properly
- [x] Services start and run correctly
- [x] Log files accessible via journalctl

### Security Requirements ✓
- [x] No password-based authentication possible
- [x] Firewall blocks unauthorized access
- [x] SSH service hardened according to best practices
- [x] Tailscale provides secure management access
- [x] Minimal attack surface exposed

## Deployment Prerequisites

Before deployment to Hetzner VPS:
- [ ] Hetzner CPX52 VPS provisioned
- [ ] Tailscale auth key obtained
- [ ] ED25519 SSH key pair generated
- [ ] Domain hbohlen.systems configured
- [ ] Installation media prepared

## Risk Mitigation

### High Risk Items
- **SSH Lockout**: Mitigate with serial console access
- **Network Issues**: Test thoroughly before production
- **Boot Problems**: Validate in VM first

### Testing Strategy
- **Incremental Testing**: Test each phase before proceeding
- **Build Verification**: Verify compilation at each step
- **VM Testing**: Use virtual machine for safe testing
- **Rollback Plan**: Maintain previous generation for recovery

---

**Task List Version**: 1.0  
**Last Updated**: 2025-11-19  
**Change ID**: nixos-base-hetzner-vps  
**Total Estimated Time**: 6-8 hours