# PantherOS

This is a NixOS configuration for Hetzner Cloud VPS.

## Prerequisites

1. Install Nix package manager (multi-user installation recommended):
   ```fish
   curl -L https://nixos.org/nix/install | sh
   ```

## Development Environment

To work on this configuration, you have two options:

### Option 1: Using the development shell

```fish
cd pantherOS
nix develop
```

This provides a shell with all necessary development tools.

### Option 2: Installing tools separately

For VS Code with the Nix extension, you need to install these language servers:

1. **nil (Nix Language Server)**: Install `nil` from nixpkgs
2. **nixd (Nix Language Server)**: Install `nixd` from nixpkgs

You can install them globally using:

```fish
nix profile install nixpkgs#nil nixpkgs#nixd
```

Or if using AUR on Arch-based systems:

```fish
yay -S nil-git nixd
```

## Building the System

To build the NixOS configuration:

```fish
cd /path/to/pantherOS
sudo nixos-rebuild build --flake .#hetzner-vps
```

## Configuration Structure

- `flake.nix`: Main flake configuration
- `hosts/servers/hetzner-vps/`: Hetzner VPS specific configuration
  - `hardware.nix`: Hardware configuration
  - `configuration.nix`: Main system configuration
  - `disko.nix`: Disk partitioning configuration

## Development Tools

This project includes:

- nil: Nix language server
- nixd: Alternative Nix language server
- nixpkgs-fmt: Nix code formatter
- nix-tree: Nix dependency explorer

## Continuous Integration

This repository supports multiple CI/CD platforms:

- **Hercules CI**: Native Nix/NixOS integration for building and deploying configurations
  - See [Hercules CI Setup Guide](docs/HERCULES_CI_SETUP.md) for configuration details
  - Module: `modules/ci/default.nix`
  - Example: `docs/examples/hercules-ci-example.nix`

## GitHub Copilot Integration

This repository is configured with GitHub Copilot Coding Agent enhancements including:

- **5 MCP Servers**: Sequential thinking, Brave Search, Context7, NixOS MCP, and DeepWiki
- **VPS SSH Access**: Remote NixOS configuration building and testing
- **Automated Testing**: Configuration validation tools

### Quick Setup

Run the interactive setup script:

```bash
./.github/copilot/setup-environment.sh
```

For detailed instructions, see:
- [**Quick Start Guide**](.github/copilot/README.md)
- [**Complete Setup Instructions**](.github/copilot/SETUP.md)
- [**Quick Reference Card**](.github/copilot/QUICK_REFERENCE.md)

### Using Copilot

Example prompts:

```
@copilot Search for the latest NixOS packages using brave-search
@copilot Plan this migration using sequential-thinking
@copilot Find NixOS options for configuring SSH using nixos-mcp
@copilot Help me test this configuration on the VPS
```

See [`.github/copilot/README.md`](.github/copilot/README.md) for more details.
