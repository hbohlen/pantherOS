---
name: NixOS Development Env
description: Set up development environments with Mutagen for file syncing, Podman for containerization, and necessary development packages. When configuring development tools, container environments, or project synchronization.
---
# NixOS Development Env

## When to use this skill:

- Setting up Mutagen for real-time file synchronization
- Configuring Podman for containerized development
- Setting up Docker-compatible development environments
- Configuring development packages and build tools
- Setting up network tools and debugging utilities
- Configuring persistent container storage
- Setting up development shells with required tools
- Configuring version control tools and Git settings
- Setting up code editors and IDEs
- Managing development dependencies and environments
- Creating reproducible development setups

## Best Practices
- virtualisation.podman.enable = true; dockerCompat = true; defaultNetwork.dns_enabled = true;
- modules/development/mutagen { projects sync forward };
