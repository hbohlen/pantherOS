# pantherOS Architecture Overview

> **Category:** Architecture  
> **Audience:** Contributors, System Architects  
> **Last Updated:** 2025-11-17

This document provides a high-level overview of the pantherOS system architecture.

## Table of Contents

- [Design Philosophy](#design-philosophy)
- [Current Implementation](#current-implementation)
- [Technology Stack](#technology-stack)
- [Repository Structure](#repository-structure)
- [Core Components](#core-components)

## Design Philosophy

pantherOS is built on four core principles (detailed in the [Constitution](decisions/constitution.md)):

1. **Declarative Configuration** - All system state declared in Nix expressions
2. **Modular Architecture** - Three-layer module system for composability
3. **Reproducibility** - Deterministic builds with flake lock files
4. **Security by Default** - Minimal attack surface with secure defaults

## Current Implementation

**Status**: Minimal working configuration for cloud VPS deployments

pantherOS currently provides:
- Single-host NixOS configurations using Flakes
- Declarative disk management with disko
- SSH-based authentication and user management
- Home Manager for user environment configuration
- Modern shell environment (Fish, Starship, eza, zoxide)

**Not Yet Implemented**:
- Multi-host configurations (planned)
- Desktop environment (Niri, DankMaterialShell) (planned)
- Full modular architecture with profiles (in progress)
- OpNix secrets management (imported but not configured)
- Monitoring and observability stack (planned)

See [Configuration Summary](../reference/configuration-summary.md) for current system state.

## Technology Stack

### Core Technologies

- **[NixOS](https://nixos.org/)** - Declarative Linux distribution
  - Reproducible system configurations
  - Atomic upgrades and rollbacks
  - Declarative package management

- **[Nix Flakes](https://nixos.wiki/wiki/Flakes)** - Modern Nix interface
  - Hermetic, reproducible builds
  - Explicit dependency management
  - Composable configurations

- **[Home Manager](https://github.com/nix-community/home-manager)** - User environment management
  - Declarative dotfile management
  - User-level package management
  - Cross-platform configuration

### Deployment Tools

- **[disko](https://github.com/nix-community/disko)** - Declarative disk partitioning
  - NixOS-native disk configuration
  - Reproducible filesystem layouts
  - Supports RAID, LVM, ZFS, and more

- **[nixos-anywhere](https://github.com/nix-community/nixos-anywhere)** - Remote NixOS installation
  - Install NixOS from any Linux system
  - Supports cloud VPS and bare metal
  - Integrates with disko for disk setup

### Development Tools

- **[nixpkgs-fmt](https://github.com/nix-community/nixpkgs-fmt)** - Code formatter
- **[nil](https://github.com/oxalica/nil)** - Nix language server
- **[Spec Kit](https://github.com/github/spec-kit)** - Spec-driven development framework

## Repository Structure

```
pantherOS/
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Pinned dependency versions
│
├── hosts/                       # Host-specific configurations
│   └── servers/
│       ├── ovh-cloud/           # OVH VPS configuration
│       └── hetzner-cloud/       # Hetzner VPS configuration
│
├── docs/                        # Documentation
│   ├── architecture/            # Architecture docs and ADRs
│   ├── howto/                   # Task-oriented guides
│   ├── ops/                     # Operations documentation
│   ├── reference/               # Reference documentation
│   ├── specs/                   # Feature specifications
│   ├── tools/                   # Tool documentation
│   └── contributing/            # Contribution guides
│
├── .github/                     # GitHub configuration
│   ├── agents/                  # Spec Kit agent definitions
│   ├── MCP-SETUP.md            # MCP server configuration
│   └── copilot-instructions.md # AI agent guidelines
│
└── .specify/                    # Spec Kit configuration
    ├── templates/               # Specification templates
    └── scripts/                 # Helper scripts
```

For detailed structure documentation, see [Configuration Summary](../reference/configuration-summary.md).

## Core Components

### Flake Configuration

The `flake.nix` file serves as the entry point for all NixOS configurations:

- Defines system inputs (nixpkgs, home-manager, disko, etc.)
- Exports nixosConfigurations for each host
- Provides development shells for different use cases
- Manages dependency versions through flake.lock

### Host Configurations

Each host has three main configuration files:

1. **configuration.nix** - System-level NixOS configuration
   - Boot configuration
   - Networking setup
   - System services
   - Package installation

2. **disko.nix** - Disk partitioning and filesystem layout
   - Declarative disk configuration
   - Filesystem types and mount points
   - Partition sizes and layouts

3. **home.nix** - User environment configuration (optional)
   - Dotfiles and user packages
   - Shell configuration
   - User-level services

### Development Shells

Multiple development environments are provided via `nix develop`:

- **default** - General development (git, neovim, fish, starship)
- **nix** - Nix development (nil, nixpkgs-fmt)
- **mcp** - MCP-enabled AI development
- **rust**, **node**, **python**, **go** - Language-specific shells

See [Infrastructure Documentation](../infra/) for details on development shells.

## See Also

- **[pantherOS Constitution](decisions/constitution.md)** - Core principles and governance
- **[Configuration Summary](../reference/configuration-summary.md)** - Current system state
- **[Deployment Guide](../DEPLOYMENT.md)** - How to deploy pantherOS
- **[Infrastructure Documentation](../infra/)** - NixOS tooling and concepts
- **[Spec-Driven Workflow](../contributing/spec-driven-workflow.md)** - Development methodology
