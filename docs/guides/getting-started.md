# Getting Started with PantherOS

This guide will help you get started with PantherOS, from understanding the basics to setting up your first configuration.

## Prerequisites

Before working with PantherOS, you should have:

1. Basic understanding of Linux/Unix systems
2. Familiarity with the command line
3. Understanding of Git for version control
4. Familiarity with the Nix package manager and NixOS (helpful but not required)

## Understanding PantherOS Architecture

PantherOS is built on NixOS with a modular approach. The key components include:

1. **Module System**: Organized in `modules/nixos/` with distinct categories:
   - Core: Fundamental system configuration
   - Services: Network services and daemons
   - Security: Security hardening modules
   - Filesystems: Storage and impermanence modules
   - Hardware: Hardware-specific configurations

2. **Host Configurations**: Located in `hosts/` directory, each representing a specific system

3. **OpenSpec Framework**: Structured approach to implementing changes, found in `openspec/changes/`

## Setting Up Your Development Environment

1. Clone the PantherOS repository:
   ```bash
   git clone <repository-url>
   cd pantheros
   ```

2. Ensure you have Nix installed with experimental features enabled:
   ```bash
   nix --version
   ```

3. Enter the development environment:
   ```bash
   nix develop
   ```

## Building Your First Configuration

1. Navigate to the hosts directory:
   ```bash
   cd hosts
   ```

2. Examine available configurations:
   ```bash
   ls
   ```

3. Build a configuration (example with yoga):
   ```bash
   cd yoga
   sudo nixos-rebuild build --flake .#yoga
   ```

## Understanding the Module System

PantherOS uses a structured module system organized in the `modules/nixos/` directory. Each module uses the standard NixOS module pattern with options defined using `mkOption` and `mkEnableOption`.

Example module structure:
```nix
{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.moduleName;
in
{
  options.pantherOS.moduleName = {
    enable = mkEnableOption "Module description";
    
    # Additional options...
  };

  config = mkIf cfg.enable {
    # Module implementation...
  };
}
```

## Key Features to Explore

1. **Impermanence**: Btrfs-based system state reset on each boot
2. **Security Hardening**: Pre-configured security measures
3. **Hardware Support**: Optimized configurations for different hardware types
4. **Service Management**: Consistent service configuration patterns

## Next Steps

After completing this guide, continue to:
- Read the [Architecture Guide](./architecture.md)
- Review the [Module Development Guide](./module-development.md)
- Explore OpenSpec change proposals in `openspec/changes/`