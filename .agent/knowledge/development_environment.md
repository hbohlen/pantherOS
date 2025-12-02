# Development Environment

## Overview

The **pantherOS** development environment is designed to be robust, reproducible, and container-centric. It leverages Nix for tool management and Podman for containerization.

## Core Components

### 1. Shell & Terminal

- **Shell**: **Fish** (`programs.fish.enable = true`).
  - Chosen for out-of-the-box features (autosuggestions, syntax highlighting).
  - Configuration managed via Home Manager.
- **Terminal**: **Ghostty**.
  - GPU-accelerated, modern terminal emulator.
  - Configured as the default terminal (`xdg.terminal-exec`).

### 2. Containerization

- **Runtime**: **Podman** (`virtualisation.podman`).
  - **Rootless**: Runs without root privileges for security.
  - **Docker Compatibility**: `dockerCompat = true` creates a `docker` alias for `podman`.
  - **DNS**: `defaultNetwork.settings.dns_enabled = true` for container networking.

### 3. Secret Management

- **Tool**: **1Password**.
  - **System Integration**: `programs._1password` and `programs._1password-gui`.
  - **SSH Agent**: Integrated for secure SSH key management.
  - **Polkit**: Configured to allow user access (`polkitPolicyOwners`).

### 4. Development Tools

- **Editor**: **Neovim** (via `nixvim`) and **Zed**.
- **Version Control**: **Git**.
- **Nix Tools**: `nil` (LSP), `nixd`, `nixpkgs-fmt`.
- **AI Assistance**: **OpenCode** / **OpenAgent** integration for AI-assisted coding.

## Workflows

- **DevContainers**: Support for VS Code / DevContainer workflows using the Podman backend.
- **Nix Shells**: Project-specific dependencies are managed via `flake.nix` `devShells`, ensuring isolation and reproducibility.

## Setup Verification

- **Containers**: `podman run --rm hello-world`
- **Secrets**: `op whoami`
- **SSH**: `ssh -T git@github.com` (should use 1Password agent)
