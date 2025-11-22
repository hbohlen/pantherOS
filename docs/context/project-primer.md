# PantherOS Project Primer

This document provides a comprehensive overview of the PantherOS project for AI agents working with the codebase.

## Project Overview

PantherOS is a NixOS-based operating system designed with a focus on security, reproducibility, and modularity. The system implements cutting-edge configurations for both workstation and server environments with features such as Btrfs-based impermanence, comprehensive security hardening, and container-first development environments.

### Mission
To create a secure, reproducible, and maintainable NixOS-based operating system that implements modern infrastructure practices while maintaining ease of use for developers and system administrators.

### Vision
A completely declarative, secure, and reproducible operating system configuration that can be deployed across various hardware platforms with minimal configuration drift and maximum security posture.

## Technical Architecture

### Core Components
1. **Module System**: Located in `modules/nixos/`, organized into distinct categories:
   - `core/`: Fundamental system configuration modules
   - `services/`: Network services and daemon modules
   - `security/`: Security hardening modules
   - `filesystems/`: Storage and impermanence modules
   - `hardware/`: Hardware-specific configuration modules

2. **Host Configurations**: Located in `hosts/`, each representing a specific system configuration that combines modules

3. **OpenSpec Framework**: Change management system in `openspec/changes/` that structures development with proposals, requirements, and implementation tasks

### Key Technologies
- NixOS: Base operating system
- Nix: Package manager and configuration language
- Btrfs: Filesystem with snapshot capabilities for impermanence
- Tailscale: VPN for secure networking
- Podman: Container runtime
- systemd: Init system with hardening

## Codebase Structure

### Directory Organization
```
pantherOS/
├── config/              # System configuration files
├── docs/                # Project documentation (newly consolidated)
├── hardware-discovery/ # Hardware discovery outputs
├── home/                # Home manager configurations
├── hosts/              # Host-specific configurations
├── modules/            # Reusable NixOS modules
│   └── nixos/          # NixOS-specific modules
│       ├── core/       # Core system modules
│       ├── services/   # Service modules
│       ├── security/   # Security modules
│       ├── filesystems/ # Filesystem modules
│       └── hardware/   # Hardware-specific modules
├── openspec/           # OpenSpec change proposals
│   └── changes/        # Individual change proposals
├── flake.nix          # Nix flake entry point
├── flake.lock         # Locked flake dependencies
└── ...
```

### Module Patterns
All PantherOS modules follow standard NixOS patterns:
- Option definitions using `mkOption` with proper types
- Enable/disable pattern using `mkEnableOption`
- Conditional configuration using `mkIf`
- Descriptive option documentation

## Development Workflow

### OpenSpec Change Management
PantherOS uses the OpenSpec methodology for managing changes:
1. **Proposal Phase**: Define "Why", "What Changes", and "Impact"
2. **Requirements Phase**: Define specific requirements with scenarios
3. **Tasks Phase**: Break implementation into specific, trackable tasks
4. **Implementation Phase**: Execute tasks following module patterns
5. **Validation Phase**: Verify requirements are met

### Git Workflow
- Feature branches from main
- Descriptive commit messages
- Pull requests for review
- Follows conventional commits where possible

### Nix Development
- Follow Nixpkgs coding conventions
- Use proper option types
- Include helpful descriptions
- Test in VMs before applying to real systems

## Current State and Focus Areas

### Active Development Areas
- Btrfs impermanence implementation
- Security hardening improvements
- AI tools integration
- Server deployment configurations

### Recent Major Changes
- Core NixOS module foundation (completed)
- Documentation consolidation (currently being implemented)
- Hetzner VPS core configuration
- Server Btrfs impermanence

### Planned Future Work
- Enhanced security auditing
- Additional hardware support
- Container orchestration features

## Important Files and Configurations

### Critical Files
- `flake.nix`: Defines dependencies and package entry points
- `hosts/*/configuration.nix`: Host-specific configurations
- `modules/nixos/*/*/default.nix`: Module aggregation files
- `openspec/changes/*/proposal.md`: Change proposals and requirements

### Configuration Patterns
- Host configurations import modules from the module system
- Security settings are centralized in security modules
- Hardware-specific configurations are separated by vendor/model
- Impermanence is implemented via Btrfs modules

## Conventions and Best Practices

### Nix Code Conventions
- Use descriptive option names with `pantherOS.` prefix
- Always specify option types
- Use `mkIf` for conditional configuration
- Follow consistent option organization

### Documentation Conventions
- Markdown format for all documentation
- Clear, descriptive headings
- Code examples with syntax highlighting
- Cross-references to related topics

### Security Best Practices
- Security by default in all modules
- Principle of least privilege
- Defense in depth approach
- Regular security audits

## Working with This Codebase

### For AI Agents
When working with this codebase, please:
1. Follow established module patterns when modifying or adding modules
2. Update documentation when making changes that affect users
3. Consider security implications of any changes
4. Test changes in isolated environments when possible
5. Update OpenSpec documentation when making significant changes

### Common Tasks
1. **Adding a new feature**: Create a new OpenSpec proposal, implement modules, test thoroughly
2. **Fixing a bug**: Locate relevant module, implement fix, update tests or docs as needed
3. **Modifying existing functionality**: Check dependencies, update implementation, verify behavior
4. **Adding hardware support**: Create hardware-specific module, add to appropriate host configuration

This primer should provide the foundational knowledge needed to work effectively with the PantherOS codebase.