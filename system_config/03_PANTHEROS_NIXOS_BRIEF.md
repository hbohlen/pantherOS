# pantherOS NixOS Configuration - Brief

**AI Agent Context**: This document describes the ACTUAL NixOS configuration for pantherOS, not aspirational features.

**Version**: 2.0  
**Last Updated**: 2025-11-16  
**Status**: Minimal working configuration for OVH Cloud VPS

---

## Executive Summary

pantherOS currently has a minimal NixOS configuration for the OVH Cloud VPS server. This is a simple, declarative configuration using Nix flakes with basic server functionality.

### Current Features
- **Single Host:** OVH Cloud VPS server configuration
- **Declarative Disk Management:** Using disko for partitioning
- **User Environment:** Home Manager for dotfiles and user packages
- **Authentication:** SSH key-based access only
- **Shell:** Fish with modern CLI tools (starship, eza, zoxide)

### NOT Implemented
- Multiple host configurations
- Desktop environment (Niri, DankMaterialShell)
- Modular architecture with profiles
- Hardware-specific modules
- OpNix secrets management (imported but not configured)
- Tailscale, Datadog, or other services
- Security hardening modules
- Container services

---

## Repository Structure

**AI Agent Context**: Actual files and directories in the repository.

```
pantherOS/
├── flake.nix                    # Main flake with single host config
├── flake.lock                   # Pinned dependencies
│
├── hosts/
│   └── servers/
│       └── ovh-cloud/           # Single server configuration
│           ├── configuration.nix # System configuration
│           ├── disko.nix        # Disk partitioning
│           └── home.nix         # Home Manager config
│
├── system_config/               # Documentation
│   ├── 03_PANTHEROS_NIXOS_BRIEF.md
│   └── ...other docs...
│
├── ai_infrastructure/           # Project planning docs
├── architecture/                # Architecture docs
├── code_snippets/              # Code examples
├── desktop_environment/        # Desktop environment docs (not implemented)
└── specs/                      # Specifications
```

---

## Configuration Overview

### flake.nix

**AI Agent Context**: Main entry point for NixOS configuration.

```nix
{
  description = "PantherOS - NixOS Configurations";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko.url = "github:nix-community/disko";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    opnix.url = "github:brizzbuzz/opnix";
  };
  
  outputs = { self, nixpkgs, home-manager, disko, opnix, ... }: {
    nixosConfigurations.ovh-cloud = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/servers/ovh-cloud/configuration.nix
        disko.nixosModules.default
        opnix.nixosModules.default
        home-manager.nixosModules.home-manager {
          home-manager.users.hbohlen = ./hosts/servers/ovh-cloud/home.nix;
        }
      ];
    };
  };
}
```

### configuration.nix

**AI Agent Context**: System-level configuration.

**Key Settings:**
- Boot: GRUB on /dev/sda
- Network: DHCP enabled, hostname "ovh-cloud"
- SSH: Enabled, key-only auth, no root login
- User: hbohlen (wheel, networkmanager, podman groups)
- Timezone: UTC
- Locale: en_US.UTF-8
- Packages: Basic dev tools (htop, gcc, make, etc.)

### disko.nix

**AI Agent Context**: Declarative disk partitioning.

**Partition Scheme:**
1. EFI System Partition (100MB, vfat)
2. Boot Partition (1GB, ext4)
3. Btrfs Root (remaining space)
   - Subvolumes: root (/), home (/home), var (/var)
   - Mount options: noatime, space_cache=v2

### home.nix

**AI Agent Context**: User environment via Home Manager.

**User Packages:**
- starship (prompt)
- eza (modern ls)
- ripgrep (fast grep)
- gh (GitHub CLI)
- bottom (system monitor)
- 1password-cli
- git, neovim, fish
- zoxide (directory jumper)
- direnv, nix-direnv

**Shell:** Fish with starship prompt and completions

---

## Deployment

### Building the Configuration

```bash
# Check flake
nix flake check

# Build configuration (without activating)
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# Deploy to local system
sudo nixos-rebuild switch --flake .#ovh-cloud
```

### Remote Deployment

```bash
# Using nixos-anywhere (not tested)
nixos-anywhere --flake .#ovh-cloud root@server-ip
```

---

## Development Shells

**AI Agent Context**: Available dev shells in flake.nix.

### Default Shell
```bash
nix develop
```

Includes: git, neovim, fish, starship, direnv, nil, nixpkgs-fmt

### Nix Development Shell
```bash
nix develop .#nix
```

For Nix-specific development.

---

## Future Architecture (NOT IMPLEMENTED)

**AI Agent Context**: These are PLANNED but NOT IMPLEMENTED:

### Planned Modular Structure
- modules/ directory (doesn't exist)
  - base/, hardware/, desktop/, apps/, services/, security/
- profiles/ directory (doesn't exist)
  - common/, workstation/, server/
- Multiple host configurations (only ovh-cloud exists)

### Planned Features
- Desktop environment with Niri compositor
- OpNix secrets management integration
- Multiple host configurations (yoga, zephyrus, desktop)
- Tailscale VPN
- Datadog monitoring
- Podman container services
- Security hardening
- Hardware-specific optimizations

---

## Common Operations

### Update Dependencies

```bash
nix flake update
git diff flake.lock
nix flake check
```

### Test Configuration Changes

```bash
# Build without activating
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# Test (activates but doesn't persist)
sudo nixos-rebuild test --flake .#ovh-cloud

# Switch (activates and persists)
sudo nixos-rebuild switch --flake .#ovh-cloud
```

### Rollback

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous
sudo nixos-rebuild switch --rollback
```

---

## Troubleshooting

### Build Failures

```bash
# Check flake syntax
nix flake check

# Show detailed error
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel --show-trace
```

### SSH Access Issues

```bash
# Check SSH service status
systemctl status sshd

# Check SSH config
sudo nixos-rebuild dry-build --flake .#ovh-cloud
```

---

## Adding Features

### Example: Adding a Package

**Edit configuration.nix:**
```nix
environment.systemPackages = with pkgs; [
  htop
  # ... existing packages ...
  neofetch  # Add new package
];
```

### Example: Enabling a Service

**Edit configuration.nix:**
```nix
services.podman = {
  enable = true;
  dockerCompat = true;
};
```

### Example: Adding User Package

**Edit home.nix:**
```nix
home.packages = with pkgs; [
  # ... existing packages ...
  bat  # Add new user package
];
```

---

## Best Practices

**AI Agent Context**: Guidelines for maintaining this configuration.

### Making Changes
1. Always test with `nixos-rebuild test` first
2. Use `nix flake check` before committing
3. Keep changes small and focused
4. Document significant changes in git commits

### Security
1. Never commit secrets to git
2. Use SSH keys only (no password auth)
3. Keep system updated with `nix flake update`
4. Review changes before applying

### Organization
1. Keep configuration.nix focused on system config
2. Use home.nix for user-specific settings
3. Document complex configurations with comments
4. Use meaningful commit messages

---

## System State Version

**Current:** 25.05 (NixOS unstable)

This is the state version at which the system was first installed. It should NOT be changed during updates.

---

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Disko Documentation](https://github.com/nix-community/disko)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)

---

## Summary for AI Agents

This is a **minimal NixOS configuration** with:
- Single server host (ovh-cloud)
- Basic system packages
- SSH-only access
- Home Manager for user environment
- Declarative disk partitioning

It does NOT have:
- Desktop environment
- Multiple hosts
- Modular architecture
- Complex services
- Secrets management configured

When asked about pantherOS features, refer to what IS implemented, not the planned architecture.
