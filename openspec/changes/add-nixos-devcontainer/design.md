# Design: NixOS Devcontainer

## Approach
We will use the standard Microsoft devcontainer base image (Ubuntu) and add the Nix feature. This is more reliable than using a pure NixOS container image which might have compatibility issues with VS Code Server.

## Configuration
- **Image**: `mcr.microsoft.com/devcontainers/base:ubuntu-22.04`
- **Features**:
  - `ghcr.io/devcontainers/features/nix:1`: Installs Nix package manager.
- **Customizations**:
  - Enable flakes in `nix.conf`.
  - Install `direnv` (optional but helpful).

## Verification
The success of this design is measured by the ability to run `nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel` successfully within the container.
