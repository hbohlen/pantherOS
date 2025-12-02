# Add NixOS Devcontainer

## Goal

Enable testing of NixOS configurations, specifically targeting the `hetzner-vps` server, within GitHub Codespaces/Devcontainers.

## Context

The user wants to verify their NixOS configurations before deploying to actual hardware. A devcontainer provides a consistent, isolated environment for running Nix builds and checks.

## Scope

- Create `.devcontainer/devcontainer.json`.
- Configure it to use Nix.
- Ensure `hetzner-vps` configuration can be built inside the container.
