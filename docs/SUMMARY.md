# PantherOS Documentation Index

## Getting Started
- [Introduction](./README.md)
- [Getting Started Guide](./guides/getting-started.md)

## Guides
- [Architecture Guide](./guides/architecture.md)
- [Module Development Guide](./guides/module-development.md)
- [Contributing Guide](./guides/contributing.md)

## Tutorials
- [Basic Setup Tutorial](./tutorials/basic-setup.md)

## Reference
- [Quick Reference](./reference/quick-reference.md)
- [Specifications](./specs/specifications.md)
- [Style Guide](./style-guide.md)

## Troubleshooting
- [Common Issues](./troubleshooting/common-issues.md)

## Context
- [Project Primer](./context/project-primer.md)
- [Implementation Guide](./context/implementation-guide.md)
- [Decision History](./context/decision-history.md)

## OpenSpec Changes
- [Core NixOS Module Foundation](../openspec/changes/core-nixos-module-foundation/proposal.md)
- [Documentation Consolidation](../openspec/changes/documentation-consolidation/proposal.md)
- [Hetzner VPS Core Configuration](../openspec/changes/hetzner-vps-core-configuration/proposal.md)
- [Security Hardening Improvements](../openspec/changes/security-hardening-improvements/proposal.md)
- [Btrfs Impermanence with Snapshots](../openspec/changes/btrfs-impermanence-snapshots/proposal.md)
- [AI Tools Integration](../openspec/changes/ai-tools-integration/proposal.md)

## System Modules
### Core Modules
- [Base Configuration](../modules/nixos/core/base.nix)
- [Boot Configuration](../modules/nixos/core/boot.nix)
- [Systemd Configuration](../modules/nixos/core/systemd.nix)
- [Networking Configuration](../modules/nixos/core/networking.nix)
- [User Configuration](../modules/nixos/core/users.nix)

### Service Modules
- [Tailscale VPN](../modules/nixos/services/tailscale.nix)
- [SSH Service](../modules/nixos/services/ssh.nix)
- [Podman Container Service](../modules/nixos/services/podman.nix)
- [Network Services](../modules/nixos/services/networking.nix)
- [Monitoring Services](../modules/nixos/services/monitoring.nix)

### Security Modules
- [Firewall Configuration](../modules/nixos/security/firewall.nix)
- [SSH Security Hardening](../modules/nixos/security/ssh.nix)
- [Systemd Hardening](../modules/nixos/security/systemd-hardening.nix)
- [Kernel Security](../modules/nixos/security/kernel.nix)
- [Security Auditing](../modules/nixos/security/audit.nix)

### Filesystem Modules
- [Btrfs Configuration](../modules/nixos/filesystems/btrfs.nix)
- [Impermanence Implementation](../modules/nixos/filesystems/impermanence.nix)
- [Snapshot Management](../modules/nixos/filesystems/snapshots.nix)
- [Encryption Configuration](../modules/nixos/filesystems/encryption.nix)
- [Optimization Settings](../modules/nixos/filesystems/optimization.nix)

### Hardware Modules
- [Workstations](../modules/nixos/hardware/workstations.nix)
- [Servers](../modules/nixos/hardware/servers.nix)
- [Yoga-specific Configuration](../modules/nixos/hardware/yoga.nix)
- [Zephyrus-specific Configuration](../modules/nixos/hardware/zephyrus.nix)
- [VPS-specific Configuration](../modules/nixos/hardware/vps.nix)