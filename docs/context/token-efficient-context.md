# PantherOS Token-Efficient Context Loading System

This document provides essential context about PantherOS in a format optimized for token-efficient loading by AI agents.

## Project Summary
PantherOS is a modular NixOS-based operating system featuring Btrfs impermanence, security-first design, and OpenSpec change management.

## Key Directories
- `modules/nixos/{core,services,security,filesystems,hardware}/` - NixOS modules
- `hosts/` - Host-specific configurations
- `openspec/changes/` - Change proposals and implementation tasks

## Core Architecture
1. **Module System**: Five categories (core, services, security, filesystems, hardware)
2. **Impermanence**: Btrfs snapshots reset root on boot; `/persist` for data preservation
3. **Security**: Hardened by default using dedicated security modules
4. **Change Management**: OpenSpec methodology with proposals, tasks, validation

## Essential Patterns
- NixOS modules: `{ config, lib, ... }` with `options` and `config` attributes
- Use `mkEnableOption` for enabling modules
- Use `mkIf cfg.enable { ... }` for conditional configuration
- Prefix options with `pantherOS.`
- Use proper types: `types.str`, `types.bool`, `types.int`, etc.

## Critical Workflows
- **Adding features**: Create module → Import in host → Test in VM
- **Bug fixes**: Locate module → Verify dependencies → Maintain compatibility
- **System changes**: Follow OpenSpec → Update tasks → Validate requirements

## Reference Points
- Module development: `docs/guides/module-development.md`
- Architecture: `docs/guides/architecture.md`
- Implementation: `docs/context/implementation-guide.md`
- Project overview: `docs/context/project-primer.md`

## Security Considerations
- Default-deny approach in firewall configurations
- SSH key authentication (no passwords)
- Kernel hardening parameters enabled
- Service hardening through systemd options

## Quick Commands
- Build configuration: `nixos-rebuild build --flake .#hostname`
- Switch config: `nixos-rebuild switch --flake .#hostname`
- VM testing: `nixos-rebuild build-vm --flake .#hostname`
- Update inputs: `nix flake update`

This context provides sufficient information for an AI agent to work effectively with the PantherOS codebase.