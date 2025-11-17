# pantherOS - NixOS Configuration Repository

**AI Agent Context**: This is a minimal NixOS configuration repository for a single OVH Cloud VPS server.

**Last Updated:** 2025-11-16  
**Status:** Minimal working configuration

## Overview

This repository contains a simple, declarative NixOS configuration for an OVH Cloud VPS using Nix flakes. The configuration is intentionally minimal and focused on maintainability.

## What This Repository Contains

**AI Agent Context**: Actual files in this repository.

### NixOS Configuration
- `flake.nix` - Main flake definition
- `hosts/servers/ovh-cloud/` - Single server configuration
  - `configuration.nix` - System configuration
  - `disko.nix` - Disk partitioning
  - `home.nix` - Home Manager configuration

### Documentation
- `README.md` - This file
- `OVH Cloud VPS - System Profile.md` - Actual NixOS server profile
- `PERFORMANCE-OPTIMIZATIONS.md` - Potential optimizations
- `system_config/03_PANTHEROS_NIXOS_BRIEF.md` - Configuration overview
- `DEPLOYMENT.md` - Deployment instructions
- `OVH-DEPLOYMENT-GUIDE.md` - Detailed deployment guide

### Planning Documents (Future Work)
- `ai_infrastructure/` - Project planning (not implemented)
- `desktop_environment/` - Desktop docs (not implemented)
- `architecture/` - Architecture docs (aspirational)
- `code_snippets/` - Code examples (some relevant)

## Current Configuration Features

**AI Agent Context**: What IS actually implemented.

### ✅ Implemented
- Single NixOS server configuration (OVH Cloud VPS)
- Declarative disk partitioning via disko
- Btrfs filesystem with subvolumes
- SSH-only access with key authentication
- Basic system packages (htop, gcc, make, etc.)
- Home Manager for user environment
- Fish shell with starship prompt
- Modern CLI tools (eza, ripgrep, zoxide, etc.)

### ❌ NOT Implemented
- Desktop environment (Niri, DankMaterialShell)
- Multiple host configurations
- Modular architecture (modules/, profiles/)
- OpNix secrets management (imported but not configured)
- Tailscale VPN
- Datadog monitoring
- Container services
- Security hardening modules
- Hardware-specific optimizations

## Quick Start

### Deploy to OVH VPS

```bash
# 1. Clone repository
git clone https://github.com/hbohlen/pantherOS.git
cd pantherOS

# 2. Review configuration
cat hosts/servers/ovh-cloud/configuration.nix

# 3. Deploy (requires root SSH access to server)
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@YOUR_SERVER_IP
```

### Update Configuration

```bash
# 1. Edit configuration
vim hosts/servers/ovh-cloud/configuration.nix

# 2. Test build locally
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# 3. Deploy to server
sudo nixos-rebuild switch --flake .#ovh-cloud
```

### Add Packages

```bash
# System-level: Edit configuration.nix
environment.systemPackages = with pkgs; [
  htop
  neovim  # Add package
];

# User-level: Edit home.nix
home.packages = with pkgs; [
  starship
  bat  # Add package
];
```

## Documentation

**AI Agent Context**: Key documentation files.

### Configuration
- [NixOS Configuration Brief](system_config/03_PANTHEROS_NIXOS_BRIEF.md) - Overview of actual configuration
- [System Profile](OVH%20Cloud%20VPS%20-%20System%20Profile.md) - Server specifications
- [Performance Optimizations](PERFORMANCE-OPTIMIZATIONS.md) - Potential optimizations

### Deployment
- [Deployment Guide](DEPLOYMENT.md) - Basic deployment instructions
- [OVH Deployment Guide](OVH-DEPLOYMENT-GUIDE.md) - Detailed OVH-specific guide

### Development & AI Integration
- [MCP Setup Guide](.github/MCP-SETUP.md) - Model Context Protocol server configuration
- [MCP Verification Report](.github/MCP-VERIFICATION-REPORT.md) - Comprehensive analysis and validation
- [Copilot Instructions](.github/copilot-instructions.md) - GitHub Copilot integration guide
- [Secrets Quick Reference](.github/SECRETS-QUICK-REFERENCE.md) - Environment variables setup

### Planning (Future Work)
- `ai_infrastructure/` - AI development plans (not implemented)
- `desktop_environment/` - Desktop environment docs (not implemented)
- `architecture/` - Architecture documentation (aspirational)

## Development

### MCP Server Configuration ✅

This repository includes comprehensive MCP (Model Context Protocol) server configuration for AI-assisted development:

- **Configuration**: `.github/mcp-servers.json` (11 servers configured)
- **Setup Guide**: `.github/MCP-SETUP.md`
- **Verification Report**: `.github/MCP-VERIFICATION-REPORT.md`
- **Validation Script**: `.github/verify-mcp-config.sh`
- **CI/CD Workflow**: `.github/workflows/mcp-verification.yml` (with firewall handling)

**Quick Verification:**
```bash
# Run automated verification
./.github/verify-mcp-config.sh

# Enter MCP development environment
nix develop .#mcp

# Test GitHub MCP server
npx -y @modelcontextprotocol/server-github
```

**Available MCP Servers:**
- Essential: github, filesystem, git, brave-search
- NixOS-specific: nix-search, fetch
- AI Infrastructure: postgres, memory, sequential-thinking
- Testing: puppeteer, docker

**Status:** ✅ Production-ready, verified 2025-11-16

### Testing Changes

```bash
# Check flake syntax
nix flake check

# Build without activating
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# Test in VM (if supported)
nixos-rebuild build-vm --flake .#ovh-cloud
```

### Update Dependencies

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Review changes
git diff flake.lock
```

## Contributing

This is a personal NixOS configuration repository. If you find it useful:
1. Fork it
2. Adapt it to your needs
3. Learn from the structure

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Disko Documentation](https://github.com/nix-community/disko)
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)

## License

MIT License - See LICENSE file for details

---

**For AI Agents**: This repository contains a minimal, working NixOS configuration. Many planning documents describe future features that are NOT implemented. Always verify what exists in the actual configuration files before making assumptions about capabilities.