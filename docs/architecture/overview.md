# System Architecture Overview

This document describes the overall architecture of the pantherOS NixOS configuration.

## Project Vision

pantherOS is a comprehensive, multi-host NixOS configuration for personal developer infrastructure. It aims to solve configuration drift between devices by providing a declarative, modular, and reproducible framework.

**Core Goals:**
- Declarative configuration for all hosts
- Modular design for maintainability
- Reproducible across different hardware
- Optimized for solo developer workflows
- Zero configuration drift

## Host Architecture

### Host Classification

The infrastructure consists of 4 hosts, categorized by purpose:

#### Workstations
- **yoga**: Lenovo Yoga 7 2-in-1
  - Purpose: Lightweight programming, research
  - Optimizations: Battery life, portability
  - Primary use: Mobile development, web browsing

- **zephyrus**: ASUS ROG Zephyrus M16
  - Purpose: High-performance development
  - Optimizations: Raw performance, multi-SSD
  - Primary use: Heavy development, Podman containers, AI tools

#### Servers
- **hetzner-vps**: Hetzner Cloud VPS
  - Purpose: Primary codespace server
  - Optimizations: Server workloads, network services
  - Primary use: Remote development, service hosting

- **ovh-vps**: OVH Cloud VPS
  - Purpose: Secondary server (backup/mirror)
  - Optimizations: Same as Hetzner
  - Primary use: Redundancy, additional workloads

### Host Configuration Strategy

Each host has three configuration layers:

1. **Hardware Layer** (`hosts/<hostname>/hardware.nix`)
   - Hardware detection
   - Kernel parameters
   - Firmware
   - Device-specific settings

2. **Disk Layer** (`hosts/<hostname>/disko.nix`)
   - Filesystem layout (Btrfs)
   - Sub-volume structure
   - Mount options
   - SSD optimizations

3. **System Layer** (`hosts/<hostname>/default.nix`)
   - Modules
   - Services
   - Applications
   - User configuration

## Modular Architecture

### Module Organization

Modules are organized by concern and scope:

#### System Modules (modules/nixos/)
```
nixos/
├── core/              # Core system functionality
│   ├── base/         # Fundamental system config
│   ├── boot/         # Bootloader, initrd
│   └── systemd/      # Systemd configuration
├── services/         # Network services and daemons
│   ├── ssh/          # SSH server
│   ├── tailscale/    # Tailscale integration
│   └── ...
├── security/         # Security configurations
│   ├── firewall/     # Firewall rules
│   ├── ssh/          # SSH hardening
│   └── ...
└── hardware/         # Hardware-specific modules
    ├── yoga/         # Yoga-specific config
    ├── zephyrus/     # Zephyrus-specific config
    └── servers/      # Server-specific config
```

#### Home-Manager Modules (modules/home-manager/)
```
home-manager/
├── shell/            # Terminal and shell
│   ├── fish/         # Fish shell
│   ├── ghostty/      # Ghostty terminal
│   └── ...
├── applications/     # User applications
│   ├── 1password/    # 1Password integration
│   ├── zed/          # Zed IDE
│   └── ...
├── development/      # Development tools
│   ├── languages/    # Language environments
│   ├── ai-tools/     # AI coding assistants
│   └── ...
└── desktop/          # Desktop environment
    ├── niri/         # Window manager
    ├── dms/          # DankMaterialShell
    └── ...
```

#### Shared Modules (modules/shared/)
```
shared/
├── base/             # Common configuration
├── options/          # Shared options
└── utils/            # Helper functions
```

### Single Concern Principle

Each module has a single, well-defined purpose:

**Good Examples:**
- `modules/nixos/security/firewall.nix` - Only firewall configuration
- `modules/home-manager/shell/fish.nix` - Only Fish shell configuration
- `modules/nixos/services/tailscale.nix` - Only Tailscale integration

**Avoid:**
- Combining unrelated functionality
- Creating "kitchen sink" modules
- Hard-coding host-specific settings in general modules

### Module Dependencies

Dependencies are managed carefully:

**Implicit Dependencies:**
- Modules in the same category may depend on each other
- Core modules are imported before specialized modules

**Explicit Dependencies:**
- Documented in module comments
- Use `mkIf` to ensure proper ordering
- Avoid circular dependencies

**No Hard Dependencies:**
- Modules should work independently
- Optional features via `mkIf config.module.feature`

## File System Design

### Btrfs Sub-Volume Strategy

All hosts use Btrfs with optimized sub-volume layouts:

```
/
├── @                   # Root sub-volume
├── @home              # Home directory
├── @dev               # Development projects
├── @var               # Variable data
├── @nix               # Nix store (if separate)
└── @snapshots         # Snapshots
```

**Benefits:**
- Atomic snapshots of sub-volumes
- Different mount options per sub-volume
- Compression for space savings
- Easy rollback

**Mount Options:**
- `compress=zstd` - Compression for SSD longevity
- `noatime` - Reduced disk writes
- `ssd` - SSD-specific optimizations

### Home Directory Structure

```
/home/hbohlen/
├── .config/           # Application configs
├── .local/            # Local applications
├── dev/               # Development projects (auto-activate devShell)
├── .nix-profile/      # Nix user profile
└── .cache/            # Cache directories
```

Key aspects:
- All configuration via home-manager
- Development projects in `~/dev` with auto-activation
- Dotfiles managed declaratively

## Security Model

### Tailscale Mesh Network

All devices connected via Tailscale:
- Creates secure mesh network
- Zero-trust access between devices
- No open ports to internet
- Works behind NAT/firewalls

**Components:**
- All workstations connected
- All servers connected
- Containers can access Tailnet
- ACLs for fine-grained control

### Secrets Management

1Password as single source of truth:
- Service account: `pantherOS`
- OpNix integration for NixOS
- 1Password GUI for workstations
- SSH keys managed via 1Password

**Secrets Flow:**
```
1Password → OpNix → NixOS configuration → Services
```

### Firewall Strategy

**Workstations:**
- Default deny incoming
- Allow Tailscale
- Allow essential services

**Servers:**
- Default deny all
- Allow Tailscale SSH only
- Allow specific services via reverse proxy
- No direct internet exposure

## Development Environment

### DevShell

Auto-activated environment for `~/dev`:
- Complete language support (Node, Python, Go, Rust, Nix)
- LSP servers configured
- Formatters installed
- AI coding tools integrated

### Languages and Tooling

**Languages:**
- Node.js/JavaScript/TypeScript
- Python
- Go
- Rust
- Nix

**AI Tools:**
- Claude Code CLI
- opencode.ai
- qwen-code
- And others via nix-ai-tools

**Development Tools:**
- Zed IDE (primary)
- Ghostty (terminal)
- Fish (shell)
- Podman (containers)

### Desktop Environment

**Window Manager:** Niri (Wayland)
**Shell Integration:** DankMaterialShell
**Terminal:** Ghostty
**Shell:** Fish

## Configuration Flow

### Configuration Hierarchy

```
flake.nix
└── nixosConfigurations.<hostname>
    ├── hosts/<hostname>/default.nix
    │   ├── hardware.nix
    │   ├── disko.nix
    │   └── imported modules
    │       ├── modules/nixos/*
    │       ├── modules/shared/*
    │       └── external inputs
    └── home-manager configuration
        └── modules/home-manager/*
```

### Build Process

1. **Flake evaluation** - Resolve all inputs and modules
2. **Hardware detection** - Apply hardware-specific settings
3. **Disk configuration** - Create filesystem layout
4. **System modules** - Configure system services
5. **User modules** - Configure user environment
6. **Activation** - Apply configuration

### Testing Flow

1. **Build test** - Verify compilation
2. **Dry run** - Test activation
3. **Switch** - Apply configuration (carefully for servers)

## Key Design Decisions

### Why NixOS?
- Declarative configuration
- Atomic upgrades and rollbacks
- Reproducible builds
- Excellent package management
- Strong ecosystem

### Why Btrfs?
- Built-in snapshots
- Sub-volumes for flexible layout
- Compression
- Checksums for data integrity
- Good performance

### Why Tailscale?
- Easy zero-config VPN
- No firewall punching
- Works everywhere
- Good security model
- Simple access control

### Why Modular?
- Single concern per module
- Easy to understand
- Simple to test
- Reusable components
- Easy to maintain

### Why Home-Manager?
- Declarative user configuration
- Separates user from system
- Better organization
- Standard patterns

## Configuration Management

### Update Strategy

**Regular Updates:**
```bash
nix flake update  # Update inputs
nixos-rebuild build .#<hostname>  # Test
nixos-rebuild switch .#<hostname>  # Deploy
```

**Rollback:**
```bash
nixos-rebuild switch --generation -1  # Previous
# Or select from GRUB menu
```

### Git Workflow

**Branch Structure:**
- `main` - Stable configuration
- `refactor` - Development work
- Feature branches for major changes

**Commit Strategy:**
- Small, focused commits
- Commit before major changes
- Test after each commit
- Clear commit messages

### CI/CD

**Automated Testing:**
- Build all hosts on changes
- Test in CI before merging
- Verification steps

**Deployment:**
- Manual deployment (for now)
- Potential automation in future
- Always tested first

## Future Enhancements

### Planned Improvements
- Private Nix cache (Backblaze B2 + Attic)
- Automated CI/CD pipeline
- Additional modules as needed
- Enhanced security features
- Better monitoring

### Scalability
- Architecture supports adding more hosts
- Modular design allows expansion
- Pattern-based approach scales well
- Documentation evolves with system

## Success Metrics

**Configuration is complete when:**
- [ ] All 4 hosts build successfully
- [ ] Hardware specs documented
- [ ] All TODOs addressed
- [ ] Zero configuration drift
- [ ] Documentation complete
- [ ] Deployment is reproducible

## Related Documentation

- [Module Organization](./module-organization.md)
- [Disk Layouts](./disk-layouts.md)
- [Security Model](./security-model.md)
- [Hardware Discovery Guide](../guides/hardware-discovery.md)
- [Module Development Guide](../guides/module-development.md)

---

**Maintained by:** hbohlen
**Last Updated:** 2025-11-19
**Version:** 1.0
