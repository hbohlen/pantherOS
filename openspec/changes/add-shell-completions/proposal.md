# Change: Add Comprehensive Shell Completions

## Why

The system uses Fish shell extensively with many custom aliases and commands (OpenCode, OpenAgent, monitoring, backups, etc.), but lacks:
- Shell completions for custom commands
- Completion generators for frequently used tools
- Integration with tool-specific completion systems
- Dynamic completion for system resources (hosts, services, containers)

Adding comprehensive completions would significantly improve command-line efficiency and discoverability.

## What Changes

- Create Fish completion files for all custom commands and aliases
- Generate completions for Nix commands (nixos-rebuild, nix-build, etc.)
- Add completions for container management (Podman)
- Create completions for custom backup, monitoring, and network scripts
- Integrate tool completions (git, kubectl, docker, etc.)
- Add dynamic completions (list running containers, systemd services, etc.)
- Configure completion caching for performance

## Impact

### Affected Specs
- Modified capability: `shell-configuration` (add completions support)
- New capability: `command-completions` (completion system and generators)

### Affected Code
- New directory: `modules/shell/completions/` for completion files
- Modified: `home/hbohlen/home.nix` to include completions
- New scripts: Completion generators for dynamic content
- Fish configuration: Enable and configure completion system

### Benefits
- Faster command-line workflows with tab completion
- Discovery of available commands and options
- Reduced typos and command errors
- Better UX for custom tooling
- Consistency across shell interactions

### Considerations
- Completion files need maintenance as tools evolve
- Dynamic completions may add latency to shell startup
- Some tools may not support programmatic completion
- Completions need testing across different scenarios
