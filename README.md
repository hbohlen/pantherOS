# pantherOS - Declarative NixOS Configuration

A personal, multi-host NixOS configuration for solo developer infrastructure. This repository manages configurations for multiple workstations and servers with a modular, flake-based approach.

## 🎯 Overview

This project provides a **declarative, modular, and reproducible** framework for managing personal development infrastructure. It solves the problem of configuration drift between devices and servers by providing a single source of truth for all system configurations.

## 🖥️ Managed Hosts

### Workstations
- **yoga** - Lenovo Yoga 7 2-in-1 (battery-optimized, lightweight development)
- **zephyrus** - ASUS ROG Zephyrus M16 (performance workstation, heavy development workflows)

### Servers
- **hetzner-vps** - Hetzner Cloud VPS (primary development server)
- **ovh-vps** - OVH Cloud VPS (secondary server)

## 📚 Documentation

Complete documentation is available in the [docs/](./docs/) directory:

- [Getting Started Guide](./docs/guides/getting-started.md) - Initial setup and basic usage
- [Architecture Guide](./docs/guides/architecture.md) - System design and structure
- [Module Development Guide](./docs/guides/module-development.md) - Creating and maintaining modules
- [Tutorials](./docs/tutorials/) - Step-by-step guides for specific tasks
- [Reference Materials](./docs/reference/) - Quick reference and specifications
- [Troubleshooting](./docs/troubleshooting/) - Common issues and solutions

For AI agents working with this codebase, see the [Project Primer](./docs/context/project-primer.md).

## 🚀 Quick Start

### Prerequisites
- NixOS installed on target machines
- 1Password account with service account configured
- Access to Tailscale Tailnet

### Deployment

1. **Clone this repository**
   ```bash
   git clone <repository-url>
   cd pantherOS
   ```

2. **Configure 1Password service account**
   - Ensure `opnix` is configured with your `pantherOS` service account
   - Verify vault access: `op nix list-items pantherOS`

3. **Deploy to a host**
   ```bash
   # For yoga workstation
   nixos-rebuild switch --flake .#yoga

   # For zephyrus workstation
   nixos-rebuild switch --flake .#zephyrus

   # For hetzner VPS
   nixos-rebuild switch --flake .#hetzner-vps

   # For ovh VPS
   nixos-rebuild switch --flake .#ovh-vps
   ```

## 🛠️ Development

### Working on Configuration

1. **Create a new module**
   ```bash
   # System module
   touch modules/nixos/services/my-service.nix

   # Check the Module Development Guide for patterns
   # See: docs/guides/module-development.md
   ```

2. **Add module to a host**
   Edit `hosts/<hostname>/default.nix`:
   ```nix
   {
     imports = [
       ./disko.nix
       ./hardware.nix

       # Add your new module
       ../../modules/nixos/services/my-service.nix
     ];
   }
   ```

3. **Test configuration**
   ```bash
   nixos-rebuild build --flake .#<hostname>
   ```

### Development Shell

A fully configured development environment is available:
```bash
nix develop
```

This provides all necessary tools for working on the configuration, including Nix language servers, formatters, and development utilities.

## 🔒 Security

### Secrets Management
- All secrets are managed through 1Password service account
- Reference format: `op:<vault>/<item>/<section>/<field>`
- Never commit secrets to the repository
- Use OpNix for NixOS integration

### Network Security
- All hosts operate within a Tailscale Tailnet
- Firewall rules configured per host type
- SSH access restricted to Tailnet devices
- No public-facing services (except through reverse proxy with Tailnet access)

## 🧩 OpenSpec Change Management

This project uses OpenSpec for structured change management. See the [Specification Documentation](./docs/specs/specifications.md) and individual proposals in `openspec/changes/` for details on planned and implemented changes.

## 📝 License

Personal configuration repository. See repository license for details.

## 🆘 Support

For issues or questions:
1. Check documentation in [docs/](./docs/)
2. Review existing issues
3. Create new issue with:
   - Host affected
   - Error messages
   - Steps to reproduce
   - Expected behavior

---

**Built with ❤️ using NixOS**