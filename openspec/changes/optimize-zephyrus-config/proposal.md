# Optimization Proposal: ROG Zephyrus Configuration

## Summary
Optimize the NixOS configuration for the ASUS ROG Zephyrus laptop, focusing on power management, storage performance, shell environment, security, and a polished desktop experience using DankMaterialShell and Niri.

## Motivation
The current configuration is a baseline. To fully utilize the Zephyrus hardware and provide a productive development environment, we need to implement specific optimizations for battery life, NVMe storage, and a cohesive desktop workflow.

## Proposed Changes
1.  **Power Management**: Implement `power-profiles-daemon` with intelligent switching based on power source and battery levels.
2.  **Storage Optimization**: Enable TRIM and tune kernel parameters for NVMe SSDs. Configure BTRFS subvolumes.
3.  **Shell Environment**: Standardize on Fish shell with Ghostty terminal.
4.  **Authentication & Security**: Integrate 1Password (CLI + GUI) and SSH agent.
5.  **Desktop Environment**: Finalize DankMaterialShell + Niri configuration with theming.
6.  **Development Environment**: Setup Podman (rootless) and essential dev tools.

## Alternatives Considered
- **TLP**: Considered for power management but `power-profiles-daemon` offers better integration with modern GNOME/KDE stacks and is simpler for this use case.
- **ZSH**: Rejected in favor of Fish for out-of-the-box usability.
