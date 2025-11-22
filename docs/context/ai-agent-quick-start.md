# PantherOS AI Agent Quick Start

**TL;DR**: PantherOS is a NixOS-based system with modular architecture, Btrfs impermanence, and security-first design. Key directories: `modules/nixos/*`, `hosts/*`, `openspec/changes/*`. Use standard NixOS module patterns.

## Core Architecture

- **Base**: NixOS 24.05+
- **Modules**: `modules/nixos/{core,services,security,filesystems,hardware}/`
- **Hosts**: `hosts/{yoga,zephyrus,servers/*}/`
- **Changes**: `openspec/changes/` (OpenSpec methodology)

## Key Concepts

1. **Impermanence**: Root system resets on boot via Btrfs snapshots; use `/persist` for data preservation
2. **Modular Design**: Single-concern modules following NixOS patterns
3. **Security-First**: Hardened by default across all components
4. **OpenSpec**: Structured change management

## Working With the Codebase

### For Modifications
1. Check `openspec/changes/` for existing proposals
2. Follow module patterns in `modules/nixos/*/` directories
3. Use `mkEnableOption` and `mkIf` for conditional configuration
4. Test in VM before applying to systems

### Common Tasks
- **Add feature**: Create module in appropriate category, import in host
- **Fix bug**: Locate relevant module, maintain backward compatibility
- **Update hardware**: Create/update hardware-specific modules in `hardware/`

## Critical Files
- `flake.nix`: Entry point and dependencies
- `modules/nixos/*/default.nix`: Module aggregation
- `hosts/*/configuration.nix`: Host-specific configurations
- `openspec/changes/*/proposal.md`: Change requirements

## Patterns to Follow
- NixOS module system (`options`, `config`, `mkIf`, etc.)
- Descriptive option names with `pantherOS.` prefix
- Proper option typing using `types.*`
- Security-first defaults

This provides minimal context for effective work on PantherOS.