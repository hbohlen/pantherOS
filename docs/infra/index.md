# Infrastructure Documentation

> **Category:** Infrastructure  
> **Audience:** Contributors, System Administrators  
> **Last Updated:** 2025-11-17

This section contains documentation about the infrastructure, tooling, and technologies used in pantherOS.

## Table of Contents

- [NixOS Concepts](#nixos-concepts)
- [Development Environments](#development-environments)
- [Deployment Tools](#deployment-tools)
- [CI/CD](#cicd)

## NixOS Concepts

**[NixOS Overview](nixos-overview.md)** - Introduction to NixOS

Essential concepts for working with pantherOS:
- What is NixOS and why we use it
- Declarative configuration
- Nix language basics
- Nix store and generations
- Nix Flakes
- Common patterns

**Key takeaways:**
- Declarative > Imperative
- Reproducibility through flakes
- Atomic updates with rollback
- Infrastructure as Code

## Development Environments

**[Development Shells](dev-shells.md)** - Nix development environments

pantherOS provides multiple development shells:

### General Purpose
- **default** - General development
- **nix** - NixOS configuration development
- **mcp** - AI-assisted development

### Language-Specific
- **rust** - Rust development
- **node** - Node.js/JavaScript/TypeScript
- **python** - Python development
- **go** - Go development

### Specialized
- **ai** - AI infrastructure development

**Quick start:**
```bash
# Enter default shell
nix develop

# Enter specific shell
nix develop .#nix
nix develop .#mcp
```

## Deployment Tools

### disko - Declarative Disk Management

**disko** enables declarative disk partitioning in NixOS:

```nix
# Example disko configuration
disko.devices.disk.main = {
  device = "/dev/sda";
  type = "disk";
  content = {
    type = "gpt";
    partitions = {
      boot = {
        size = "1G";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
        };
      };
      root = {
        size = "100%";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/";
        };
      };
    };
  };
};
```

**Benefits:**
- Reproducible disk layouts
- Version-controlled partitioning
- Supports complex layouts (RAID, LVM, ZFS)
- Automated disk setup

**Resources:**
- [disko GitHub Repository](https://github.com/nix-community/disko)
- [Example configurations](../examples/nixos/)

### nixos-anywhere - Remote Installation

**nixos-anywhere** installs NixOS remotely from any Linux system:

```bash
# Deploy to remote server
nix run github:nix-community/nixos-anywhere -- \
  --flake .#hostname \
  --target-host root@server-ip
```

**Features:**
- Install from any Linux system
- Works with disko for disk setup
- Supports SSH and console access
- Integrates with CI/CD

**Resources:**
- [nixos-anywhere GitHub](https://github.com/nix-community/nixos-anywhere)
- [How-To: Deploy New Server](../howto/deploy-new-server.md)

### Home Manager - User Environment

**Home Manager** manages user-level configuration:

```nix
# home.nix
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    eza
    bottom
  ];
  
  programs.fish.enable = true;
  programs.starship.enable = true;
  
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your@email.com";
  };
}
```

**Benefits:**
- Declarative dotfiles
- User-level packages
- Cross-platform support
- Version controlled

**Resources:**
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)

## CI/CD

> **Status:** Planned - CI/CD documentation will be added as automation is implemented

### Planned Integrations

**GitHub Actions:**
- Automated configuration testing
- Deployment validation
- Flake updates
- Documentation builds

**nixos-anywhere Integration:**
- Automated deployments
- Infrastructure as Code workflows
- Multi-host deployment

**Testing:**
- Configuration syntax checking
- Build verification
- Integration tests
- Security scanning

## Key Technologies

### Core Stack

| Technology | Purpose | Documentation |
|------------|---------|---------------|
| **NixOS** | Operating system | [NixOS Overview](nixos-overview.md) |
| **Nix Flakes** | Dependency management | [NixOS Overview](nixos-overview.md#nix-flakes) |
| **Home Manager** | User environment | [Home Manager Manual](https://nix-community.github.io/home-manager/) |

### Deployment Tools

| Technology | Purpose | Documentation |
|------------|---------|---------------|
| **disko** | Disk partitioning | [disko GitHub](https://github.com/nix-community/disko) |
| **nixos-anywhere** | Remote installation | [How-To: Deploy](../howto/deploy-new-server.md) |

### Development Tools

| Technology | Purpose | Documentation |
|------------|---------|---------------|
| **nil** | Nix language server | [Development Shells](dev-shells.md#nix-shell) |
| **nixpkgs-fmt** | Code formatter | [Development Shells](dev-shells.md#nix-shell) |
| **direnv** | Environment management | [How-To: Setup Development](../howto/setup-development.md) |

## Configuration Files

### Flake Configuration

**Location:** `/flake.nix`

The main entry point for all NixOS configurations:
- Defines system inputs (dependencies)
- Exports nixosConfigurations for each host
- Provides development shells
- Manages dependency versions

**Key sections:**
```nix
{
  inputs = { ... };      # Dependencies
  outputs = { ... };     # Configurations and shells
}
```

### Host Configuration

**Location:** `/hosts/servers/<hostname>/`

Each host has:
- `configuration.nix` - System configuration
- `disko.nix` - Disk layout
- `home.nix` - User environment (optional)

### Documentation

**Location:** `/docs/`

Structured documentation:
- `/docs/architecture/` - System design
- `/docs/howto/` - Task-oriented guides
- `/docs/infra/` - Infrastructure docs (this section)
- `/docs/reference/` - Reference documentation

## Common Tasks

### Update Dependencies

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Review changes
git diff flake.lock
```

### Test Configuration

```bash
# Syntax check
nix flake check

# Build test
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# Test in VM
nixos-rebuild build-vm --flake .#hostname
```

### Deploy Changes

```bash
# Local deployment
sudo nixos-rebuild switch --flake .#hostname

# Remote deployment
nixos-rebuild switch --flake .#hostname \
  --target-host user@server-ip \
  --use-remote-sudo
```

## Learning Resources

### Official Documentation

- **[NixOS Manual](https://nixos.org/manual/nixos/stable/)** - Complete reference
- **[Nix Package Search](https://search.nixos.org/)** - Find packages and options
- **[Nix Pills](https://nixos.org/guides/nix-pills/)** - Deep dive into Nix

### Community Resources

- **[NixOS Wiki](https://nixos.wiki/)** - Community documentation
- **[NixOS Discourse](https://discourse.nixos.org/)** - Community forum
- **[Awesome Nix](https://github.com/nix-community/awesome-nix)** - Curated resources

### pantherOS Documentation

- **[Architecture Overview](../architecture/overview.md)** - System design
- **[How-To Guides](../howto/)** - Task-oriented guides
- **[Examples](../examples/)** - Configuration examples

## Getting Help

### Documentation

Start with:
1. **[NixOS Overview](nixos-overview.md)** - Basic concepts
2. **[Development Shells](dev-shells.md)** - Development environment
3. **[How-To Guides](../howto/)** - Specific tasks

### Community Support

- [NixOS Discourse](https://discourse.nixos.org/) - Ask questions
- [NixOS Matrix Chat](https://matrix.to/#/#nixos:nixos.org) - Real-time chat
- [r/NixOS](https://www.reddit.com/r/NixOS/) - Reddit community

### Contributing

Found an issue or want to add documentation?

1. Review [Contributing Guidelines](../contributing/)
2. Follow [Spec-Driven Workflow](../contributing/spec-driven-workflow.md)
3. Submit a pull request

## See Also

- **[Architecture Documentation](../architecture/)** - System architecture and decisions
- **[How-To Guides](../howto/)** - Task-oriented guides
- **[Operations Documentation](../ops/)** - Hardware and operations
- **[Reference Documentation](../reference/)** - Configuration reference
