# Change Proposal: NixOS 25.05 Base Configuration for Hetzner CPX52 VPS

## Summary

Deploy a hardened NixOS 25.05 base configuration for a Hetzner Cloud CPX52 VPS server with Tailscale networking, SSH hardening, and essential system packages. This configuration serves as the foundation for running OpenCode services with persistent AI memory.

## Why

This change is necessary to establish a secure, production-ready foundation for the pantherOS project. The current configuration lacks a proper base setup for Hetzner VPS infrastructure, which is essential for deploying OpenCode services with persistent AI memory.

**Security**: Current infrastructure lacks proper SSH hardening and network security measures, exposing the system to potential attacks.

**Reliability**: Without proper boot configuration and basic system packages, the VPS cannot serve as a stable foundation for hosting services.

**Scalability**: A modular, NixOS-based configuration enables easy addition of services while maintaining security and reliability.

**Maintainability**: Declarative configuration ensures reproducible deployments and simplifies ongoing maintenance.

## Context

### Infrastructure Details
- **Target**: Hetzner Cloud CPX52 VPS
  - 16 vCPU AMD EPYC processor
  - 32GB RAM
  - 480GB NVMe SSD
- **OS**: NixOS 25.05
- **Hostname**: hetzner-vps
- **Domain**: hbohlen.systems

### Current State
- Empty directory structure with minimal files
- No existing NixOS configurations for Hetzner VPS
- Project uses NixOS flakes with modular architecture
- Need secure, production-ready base configuration

### Problem Statement
Current configuration lacks a proper base setup for Hetzner VPS infrastructure. The system needs:
- Proper boot configuration for Hetzner Cloud environment
- Secure networking with Tailscale VPN
- Hardened SSH access
- Essential system packages
- Firewall protection with appropriate port access

## Solution Overview

### Architectural Approach
1. **Declarative Configuration**: Use NixOS flakes for reproducible builds
2. **Modular Design**: Separate concerns into discrete modules
3. **Security First**: SSH hardening, firewall rules, minimal exposure
4. **Network Isolation**: Tailscale for management access
5. **Production Ready**: Follow security best practices

### Key Components

#### Boot Configuration
- GRUB bootloader with EFI support
- Hetzner Cloud compatible settings (removable EFI)
- Serial console access for remote management
- Kernel parameters optimized for VPS environment

#### Networking
- Primary IPv4/IPv6 via DHCP
- Tailscale VPN with server routing features
- Firewall with default-deny policy
- Explicit port access for required services

#### SSH Security
- Key-only authentication (no passwords)
- ED25519 key format requirement
- Root login restrictions
- Global password authentication disabled

#### System Users
- Root user with SSH key authentication
- OpenCode system user with appropriate group memberships
- Security group integrations

#### System Packages
- Essential utilities (vim, git, tmux)
- Filesystem tools (btrfs-progs, compsize)
- System monitoring (htop, ncdu)

## Success Criteria

### Functional Requirements
- [ ] System boots successfully after nixos-install
- [ ] SSH accessible via ED25519 key only
- [ ] Tailscale connects to tailnet and maintains connectivity
- [ ] Firewall enforces default-deny with explicit allows
- [ ] Required ports accessible from appropriate networks only

### Technical Requirements
- [ ] Configuration builds without errors
- [ ] All imports resolve correctly
- [ ] Network interfaces configured properly
- [ ] Services start and run correctly
- [ ] Log files accessible via journalctl

### Security Requirements
- [ ] No password-based authentication possible
- [ ] Firewall blocks unauthorized access
- [ ] SSH service hardened according to best practices
- [ ] Tailscale provides secure management access
- [ ] Minimal attack surface exposed

## Deliverables

### Configuration Files
1. `hosts/hetzner-vps/configuration.nix` - Main configuration
2. `hosts/hetzner-vps/disko.nix` - Disk layout (placeholder for future)
3. `hosts/hetzner-vps/caddy.nix` - Reverse proxy config (placeholder)
4. `hosts/hetzner-vps/opencode-memory.nix` - OpenCode integration (placeholder)

### Documentation
- Installation instructions
- Configuration explanation
- Security considerations
- Troubleshooting guide

### Validation
- Build verification
- Service validation
- Security audit
- Acceptance criteria testing

## Risks and Mitigations

### High Risk
- **SSH Lockout**: Mitigate with serial console access and Hetzner web console
- **Network Isolation**: Ensure Tailscale configuration before firewall lockdown

### Medium Risk
- **Boot Configuration**: Test in Hetzner console before full deployment
- **Package Compatibility**: Use NixOS 25.05 stable channel

### Low Risk
- **Performance Impact**: Minimal packages and services
- **Maintenance**: Declarative configuration simplifies updates

## Timeline

This is a foundational change that should be completed before any application-layer services are added. Estimated effort: 1-2 days for implementation and testing.

## Dependencies

### External Services
- Hetzner Cloud account with VPS provisioned
- Tailscale account and auth key
- Domain hbohlen.systems configured
- SSH key pair for authentication

### Internal Components
- NixOS flake configuration
- Disko module for disk management
- Firewall module implementation
- SSH hardening module

## Approval Requirements

- [ ] Security review of SSH configuration
- [ ] Network review of firewall rules
- [ ] Build test successful on development system
- [ ] Documentation complete and reviewed
- [ ] Change ID assigned and proposal accepted

## References

- [Hetzner Cloud Console](https://console.hetzner.cloud/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [NixOS Flakes](https://nixos.wiki/wiki/Flakes)

---

**Change ID**: nixos-base-hetzner-vps  
**Status**: Proposal  
**Author**: hbohlen  
**Date**: 2025-11-19