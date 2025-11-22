# pantherOS Architecture

> Quick reference for understanding the repository structure and design decisions.
> For detailed documentation, see [docs/guides/architecture.md](docs/guides/architecture.md)

## Repository Structure

```
pantherOS/
├── flake.nix              # Nix flake configuration (entry point)
├── flake.lock             # Locked dependency versions
├── justfile               # Task automation (run: just --list)
├── ARCHITECTURE.md        # This file
├── CONTRIBUTING.md        # How to contribute
├── README.md              # Project overview and quick start
│
├── hosts/                 # Host-specific configurations
│   ├── yoga/              # Lenovo Yoga 7 2-in-1 (mobile workstation)
│   ├── zephyrus/          # ASUS ROG Zephyrus M16 (performance workstation)
│   └── servers/
│       ├── hetzner-vps/   # Primary development server
│       └── ovh-cloud/     # Secondary server
│
├── modules/               # Reusable NixOS modules
│   ├── nixos/             # System-level modules
│   │   ├── core/          # Base system, boot, users, networking
│   │   ├── services/      # Service configurations (SSH, Tailscale, etc.)
│   │   ├── security/      # Security hardening (firewall, SSH, kernel)
│   │   ├── filesystems/   # Btrfs, impermanence, snapshots, encryption
│   │   └── hardware/      # Hardware-specific configurations
│   ├── home-manager/      # User environment modules
│   └── shared/            # Shared between NixOS and home-manager
│
├── home/                  # Home-manager configurations
│   └── hbohlen/           # User-specific configurations
│
├── docs/                  # Documentation
│   ├── guides/            # How-to guides
│   ├── reference/         # Quick references
│   ├── context/           # AI agent context
│   ├── architecture/      # Design documents
│   └── CODE_REVIEW_REPORT.md  # Comprehensive code review
│
├── scripts/               # Utility scripts
│   ├── hardware-discovery.sh  # Gather hardware info
│   └── install.sh         # Installation utilities
│
├── openspec/              # OpenSpec change management
│   ├── changes/           # Change proposals
│   └── specs/             # Specifications
│
└── config/                # Runtime configuration files
```

## Architecture Principles

### 1. Modularity
- Each module focuses on a single concern
- Modules can be enabled/disabled independently
- Clear separation between system, user, and host configuration

### 2. Declarative Configuration
- Everything defined in code (Infrastructure as Code)
- Reproducible across machines
- Version controlled with git

### 3. Host Classification

**Workstations** (yoga, zephyrus)
- User-focused configurations
- Desktop environments
- Development tools
- Battery optimization (yoga) or performance (zephyrus)

**Servers** (hetzner-vps, ovh-cloud)
- Headless operations
- Service-focused
- Security hardened
- Impermanence for clean state

### 4. Security-First Design
- SSH hardened by default (no password auth, key-only)
- Firewall enabled with restrictive defaults
- Tailscale VPN for secure inter-host communication
- Regular security updates via nixos-unstable

### 5. Filesystem Strategy
- **Btrfs** for all hosts (snapshots, compression, subvolumes)
- **Impermanence** on servers (ephemeral root filesystem)
- **Compression** with zstd (varies by workload)
- **Snapshots** for data recovery

## Module Organization

### Core Modules (`modules/nixos/core/`)
Base system functionality that every host needs:
- `base.nix` - Basic system settings
- `boot.nix` - Bootloader configuration
- `networking.nix` - Network configuration
- `users.nix` - User management
- `systemd.nix` - Systemd optimizations

### Service Modules (`modules/nixos/services/`)
Optional services that can be enabled per-host:
- `ssh.nix` - SSH server configuration
- `networking/tailscale-service.nix` - Tailscale VPN
- `networking/tailscale-firewall.nix` - Tailscale firewall integration
- `podman.nix` - Container runtime
- `monitoring.nix` - Prometheus/Grafana stack

### Security Modules (`modules/nixos/security/`)
Security hardening configurations:
- `firewall.nix` - Advanced firewall with kernel hardening
- `ssh.nix` - SSH security hardening
- `kernel.nix` - Kernel security parameters
- `systemd-hardening.nix` - Service hardening
- `audit.nix` - Security auditing tools

### Filesystem Modules (`modules/nixos/filesystems/`)
Storage and filesystem management:
- `btrfs.nix` - Btrfs configuration and optimization
- `impermanence.nix` - Ephemeral root filesystem
- `snapshots.nix` - Automated snapshot management
- `encryption.nix` - Disk encryption
- `optimization.nix` - Performance tuning

### Hardware Modules (`modules/nixos/hardware/`)
Hardware-specific configurations:
- `workstations.nix` - Common workstation settings
- `servers.nix` - Common server settings
- `yoga.nix` - Lenovo Yoga specific
- `zephyrus.nix` - ASUS Zephyrus specific
- `vps.nix` - VPS environment settings

## Configuration Flow

```
flake.nix
  ↓
nixosConfigurations.<hostname>
  ↓
hosts/<hostname>/default.nix
  ↓
├── hosts/<hostname>/hardware.nix (hardware-specific)
├── hosts/<hostname>/disko.nix (disk layout)
├── modules/nixos/hardware/<type>.nix (hardware profile)
└── modules/nixos/{core,services,security,filesystems}/ (feature modules)
  ↓
System configuration
```

## Adding a New Host

1. **Create host directory structure:**
   ```bash
   mkdir -p hosts/<hostname>
   touch hosts/<hostname>/{default.nix,hardware.nix,disko.nix}
   ```

2. **Run hardware discovery:**
   ```bash
   just discover
   # Copy generated hardware-configuration.nix to hosts/<hostname>/hardware.nix
   ```

3. **Configure disk layout:**
   - Edit `hosts/<hostname>/disko.nix`
   - See `docs/architecture/disk-layouts.md` for templates

4. **Set up host configuration:**
   - Edit `hosts/<hostname>/default.nix`
   - Import appropriate hardware module
   - Enable required services
   - Set hostname and stateVersion

5. **Add to flake.nix:**
   ```nix
   nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     modules = [
       ./hosts/<hostname>
       disko.nixosModules.disko
       home-manager.nixosModules.home-manager
       {
         home-manager.useGlobalPkgs = true;
         home-manager.useUserPackages = true;
         home-manager.users.hbohlen = ./home/hbohlen/default.nix;
       }
     ];
   };
   ```

6. **Test the configuration:**
   ```bash
   just build <hostname>
   ```

## Module Development

### Module Template

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.<category>.<module-name>;
in
{
  options.pantherOS.<category>.<module-name> = {
    enable = mkEnableOption "<description>";
    
    # Add your options here
  };

  config = mkIf cfg.enable {
    # Add your configuration here
    
    # Use assertions for validation
    assertions = [
      {
        assertion = /* condition */;
        message = "Helpful error message";
      }
    ];
  };
  
  meta = {
    maintainers = [ "hbohlen" ];
    doc = ./README.md;
  };
}
```

### Best Practices

1. **Use `mkDefault` for defaults** that can be overridden
2. **Use `mkForce` sparingly** only when absolutely necessary
3. **Add assertions** to catch configuration errors early
4. **Document options** with clear descriptions and examples
5. **Keep modules focused** on a single responsibility
6. **Test thoroughly** before committing

## Development Workflow

1. **Make changes** to modules or host configs
2. **Validate** with `just validate`
3. **Build** with `just build <hostname>`
4. **Test** with `just test <hostname>` (if local)
5. **Deploy** with `just deploy <hostname>` or `just deploy-remote <hostname> <ip>`
6. **Commit** and push changes

## Common Tasks

```bash
# Build a host
just build yoga

# Build all hosts
just build-all

# Validate everything
just validate

# Format code
just fmt

# Update dependencies
just update

# Enter dev shell
just dev

# Show all tasks
just --list
```

## Security Considerations

### Secrets Management
- **Never** commit secrets to git
- Use 1Password, sops-nix, or agenix for secrets
- Reference secrets via external mechanisms

### Network Security
- All hosts connected via Tailscale VPN
- SSH restricted to Tailscale network
- Firewall enabled with restrictive defaults
- Regular security updates

### Access Control
- SSH key-only authentication
- No root login via SSH
- Sudo configured for specific users
- Services run with minimal privileges

## Troubleshooting

### Build Failures
```bash
# Check flake syntax
just check

# Validate modules
just check-modules

# See detailed error
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel --show-trace
```

### Deployment Issues
```bash
# Dry run to see what would change
just show-config <hostname>

# Check remote connectivity
ssh root@<ip> "nixos-version"

# Verify deployment prerequisites
just verify-hetzner  # for Hetzner deployments
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Project Documentation](docs/)
- [Code Review Report](docs/CODE_REVIEW_REPORT.md)

## For AI Agents

This repository is designed to be AI-agent-friendly:

- **Clear structure** with logical organization
- **Comprehensive documentation** in `docs/`
- **Task automation** via justfile
- **Context files** in `docs/context/`
- **Code review report** in `docs/CODE_REVIEW_REPORT.md`
- **Module templates** and best practices documented

When working on this codebase:
1. Read this file first for structure
2. Check `docs/CODE_REVIEW_REPORT.md` for known issues
3. Use `just validate` before committing
4. Follow the module template for new modules
5. Test changes with `just build <hostname>`

---

**Last Updated:** 2025-11-22  
**Maintainer:** hbohlen
