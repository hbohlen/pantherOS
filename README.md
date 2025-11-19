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

## 🏗️ Architecture

### Core Principles
- **Modular Design**: Single-concern modules for maximum reusability
- **Hardware Separation**: Hardware-specific configs isolated in `hardware.nix` files
- **Declarative Disk Management**: All disk layouts defined with [Disko](https://github.com/nix-community/disko)
- **Secrets Management**: 1Password service account with OpNix integration
- **Security First**: All systems behind Tailscale Tailnet with proper firewall configuration

### Directory Structure
```
pantherOS/
├── docs/                  # Documentation
├── flake.nix             # Flake entry point
├── home/                 # Home-manager configurations
│   └── hbohlen/         # User-specific configs
├── hosts/               # Host-specific configurations
│   ├── yoga/           # Lenovo Yoga workstation
│   ├── zephyrus/       # ASUS ROG workstation
│   └── servers/        # Server configurations
│       ├── hetzner-vps/
│       └── ovh-vps/
├── lib/                 # Custom helper functions
├── modules/             # Modular configurations
│   ├── nixos/         # System-level modules
│   ├── home-manager/  # User-level modules
│   └── shared/        # Shared modules
├── overlays/           # Package overlays
├── pkgs/              # Custom packages
├── profiles/          # Reusable configuration profiles
└── scripts/           # Automation scripts
```

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
   touch docs/modules/nixos/services/my-service.md

   # Home-manager module
   touch modules/home-manager/applications/my-app.nix
   touch docs/modules/home-manager/applications/my-app.md
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

## 🎨 Desktop Environment

### Window Manager
- **Niri** - Wayland compositor with layouts and tiling
- **DankMaterialShell** - Enhanced Material Design UI layer
  - DankGreeter - Login screen
  - DankGop - System monitoring
  - DankSearch - Application launcher
  - DankMaterialShell Niri integration

### Terminal & Shell
- **Ghostty** - Fast, feature-rich terminal
- **Fish** - User-friendly shell with full auto-completion

### Applications
- **Zed IDE** - High-performance code editor
- **Zen Browser** - Privacy-focused Firefox fork
- **1Password** - Password manager with biometric unlock

## 🧩 AI Development Tools

Integrated via [nix-ai-tools](https://github.com/numtide/nix-ai-tools):
- Claude Code CLI
- OpenCode
- Qwen Code
- Gemini CLI
- Codex ACP
- Catnip

## 📦 Package Management

### System Packages
- Managed through NixOS modules
- Custom packages in `pkgs/` directory
- Package overlays in `overlays/` directory

### Development Languages
Each language includes:
- Package manager
- LSP (Language Server Protocol)
- Formatter
- Full AI tool integration

Supported languages:
- Node.js / TypeScript
- Python
- Go
- Rust
- Nix

## 🔧 Disk Configuration

All hosts use Btrfs with optimized sub-volume layouts:
- Root on Btrfs with sub-volumes
- Optimized for SSD longevity
- Home directory at `~/dev` for all projects
- Podman containers with dedicated sub-volumes

## 📖 Documentation

- **README.md** - This file (overview and quick start)
- **docs/** - Detailed documentation
  - **architecture/** - System design decisions
  - **guides/** - Step-by-step guides
  - **modules/** - Module-specific documentation
  - **todos/** - Remaining tasks and roadmap

## 🤝 Contributing

When modifying this configuration:

1. **Follow modular structure** - Keep modules single-concern
2. **Document changes** - Update relevant documentation
3. **Test thoroughly** - Build before switching
4. **Review security** - Ensure secrets aren't committed
5. **Update todos** - Mark completed items in `docs/todos/`

## 📝 License

Personal configuration repository. See repository license for details.

## 🆘 Support

For issues or questions:
1. Check documentation in `docs/`
2. Review existing issues
3. Create new issue with:
   - Host affected
   - Error messages
   - Steps to reproduce
   - Expected behavior

---

**Built with ❤️ using NixOS**
