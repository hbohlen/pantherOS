# pantherOS Project Knowledge Base

## Overview
**pantherOS** is a declarative, reproducible NixOS configuration repository managing multiple hosts, including personal laptops and cloud servers. It utilizes **Nix Flakes** for dependency management and **Home Manager** for user environments.

## Architecture

### Core Technologies
- **NixOS**: The underlying operating system.
- **Nix Flakes**: Used for reproducible builds and dependency pinning (`flake.nix`).
- **Home Manager**: Manages user-specific configurations (dotfiles, packages).
- **Disko**: Declarative disk partitioning and formatting.
- **OpNix**: Secret management (likely 1Password integration or similar).
- **OpenSpec**: A workflow for proposing and implementing changes (located in `openspec/`).

### Hosts
The repository defines configurations for the following hosts:

1.  **`zephyrus`** (ASUS ROG Zephyrus G15)
    -   **Type**: Personal Laptop / Workstation.
    -   **Key Features**:
        -   Hybrid Graphics (Intel + NVIDIA).
        -   **Desktop Environment**: Custom stack with **Niri** (Wayland compositor) and **DankMaterialShell** (Qt/QML shell).
        -   **Hardware Detection**: Custom Fish scripts (`hardware-inventory.fish`, etc.) to detect and configure hardware.
        -   **Optimization**: Power profiles, NVMe tuning, specific kernel modules for Alder Lake.
    -   **State**: Currently being optimized for development and battery life.

2.  **`hetzner-vps`**
    -   **Type**: Cloud VPS (Hetzner).
    -   **Usage**: Server hosting.

3.  **`yoga`**
    -   **Type**: Laptop (Lenovo Yoga).
    -   **Features**: Uses `nixos-facter-modules` for hardware detection.

4.  **`ovh-vps`**
    -   **Type**: Cloud VPS (OVH).

### Directory Structure
-   `flake.nix`: Entry point, defines inputs and system configurations.
-   `hosts/`: Host-specific configurations (e.g., `hosts/zephyrus/default.nix`).
-   `modules/`: Reusable NixOS modules.
    -   `desktop-shells/dankmaterial`: Custom shell configuration.
    -   `window-managers/niri`: Niri compositor configuration.
    -   `development/mutagen`: Mutagen sync configuration.
-   `home/`: Home Manager configurations.
-   `openspec/`: Specifications and proposals for project changes.
-   `.agent/`: Agent-specific configurations and knowledge.

## Key Configurations & Decisions

### Zephyrus Optimization
-   **Hardware Detection**: Implemented via custom Fish scripts to inventory hardware and assert correctness.
-   **Niri & DankMaterialShell**: The primary desktop stack. Upstream `niri` module is disabled in favor of a local module to avoid conflicts.
-   **Power Management**: Uses `power-profiles-daemon`.
-   **Unfree Packages**: Allowed system-wide (`nixpkgs.config.allowUnfree = true`).

### Development Environment
-   **Shell**: Fish is the default shell.
-   **Terminal**: Ghostty.
-   **Tools**: Podman (rootless), Git, 1Password (CLI + GUI).

## Workflows
-   **OpenSpec**: Used for structured change management.
    -   `openspec-proposal`: Scaffold a new change.
    -   `openspec-apply`: Implement approved changes.
