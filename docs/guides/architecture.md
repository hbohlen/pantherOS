# PantherOS Architecture

This document provides an overview of the PantherOS architecture and design principles.

## Overview

PantherOS is a modular NixOS-based operating system built with security, reproducibility, and maintainability as core principles. The architecture is organized around a clear separation of concerns with distinct modules for different system aspects.

## Directory Structure

```
pantherOS/
├── config/              # System configuration files
├── docs/                # Documentation (this directory)
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
└── ...
```

## Module Categories

### Core Modules
Located in `modules/nixos/core/`, these handle fundamental system configuration:
- `base.nix`: Basic system settings
- `boot.nix`: Bootloader and kernel configuration
- `systemd.nix`: Systemd optimization
- `networking.nix`: Network configuration
- `users.nix`: User management

### Service Modules
Located in `modules/nixos/services/`, these handle various services:
- `tailscale.nix`: VPN service configuration
- `ssh.nix`: SSH service management
- `podman.nix`: Container service
- `monitoring.nix`: System monitoring services

### Security Modules
Located in `modules/nixos/security/`, these implement security hardening:
- `firewall.nix`: Firewall configuration
- `ssh.nix`: SSH security hardening
- `systemd-hardening.nix`: Systemd service hardening
- `kernel.nix`: Kernel security parameters
- `audit.nix`: Security auditing tools

### Filesystem Modules
Located in `modules/nixos/filesystems/`, these handle storage:
- `btrfs.nix`: Btrfs filesystem configuration
- `impermanence.nix`: Impermanence implementation
- `snapshots.nix`: Snapshot management
- `encryption.nix`: Storage encryption
- `optimization.nix`: Performance optimization

### Hardware Modules
Located in `modules/nixos/hardware/`, these provide hardware-specific configurations:
- `workstations.nix`: General workstation features
- `servers.nix`: Server-specific settings
- `yoga.nix`: Lenovo Yoga-specific configuration
- `zephyrus.nix`: ASUS Zephyrus-specific configuration
- `vps.nix`: VPS environment settings

## Host Configurations

Host-specific configurations in the `hosts/` directory tie together the reusable modules. Each host configuration:

1. Imports necessary modules
2. Configures hardware-specific settings
3. Applies security hardening
4. Sets up services appropriate for the host's role

## Design Principles

### Modularity
Each module focuses on a single concern and can be enabled/disabled independently.

### Reusability
Modules are designed to be reusable across different hosts and hardware configurations.

### Security-First
Security hardening is built into modules rather than added afterward.

### Impermanence
System states are reset on each boot using Btrfs snapshots for a clean, predictable system state.

### Documentation-Driven
Changes follow the OpenSpec methodology to ensure proper documentation and planning.

## OpenSpec Change Management

PantherOS uses OpenSpec for managing changes, which includes:
1. Proposals with clear requirements and scenarios
2. Tasks with specific implementation steps
3. Implementation with proper testing
4. Validation against requirements

This ensures changes are well-documented and follow a consistent pattern.