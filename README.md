# PantherOS

This is a NixOS configuration for Hetzner Cloud VPS.

## Prerequisites

1. Install Nix package manager (multi-user installation recommended):
   ```bash
   curl -L https://nixos.org/nix/install | sh
   ```

## Development Environment

To work on this configuration, you have two options:

### Option 1: Using the development shell

```bash
cd pantherOS
nix develop
```

This provides a shell with all necessary development tools.

### Option 2: Installing tools separately

For VS Code with the Nix extension, you need to install these language servers:

1. **nil (Nix Language Server)**: Install `nil` from nixpkgs
2. **nixd (Nix Language Server)**: Install `nixd` from nixpkgs

You can install them globally using:

```bash
nix profile install nixpkgs#nil nixpkgs#nixd
```

Or if using AUR on Arch-based systems:

```bash
yay -S nil-git nixd
```

## Building the System

To build the NixOS configuration:

```bash
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
