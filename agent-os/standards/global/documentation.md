# Configuration Documentation

Standards for documenting NixOS configurations and modules.

## Module Documentation

```nix
# modules/packages/default.nix
# Aggregator for all package modules
# Contains system-wide packages and development tools

{
  imports = [
    ./core
    ./dev
  ];
}
```

- **Always include header comments**: Document what each module does
- **Use consistent format**: `# modules/<name>/default.nix\n# Description`
- **Explain module purpose**: What does this module configure?
- **Note dependencies**: Document if module depends on others

## Host Configuration Documentation

```nix
# hosts/servers/hetzner-vps/default.nix
# Optimized configuration for development server
# Supports: Programming (Python, Node, Rust, Go), Containers, AI tools

{
  config,
  lib,
  pkgs,
  ...
}: {
  # Hostname
  networking.hostName = "hetzner-vps";

  # Configuration continues...
}
```

- **Document host purpose**: What is this host used for?
- **List supported features**: What capabilities does this host have?
- **Note special hardware**: Document host-specific hardware considerations
- **Update documentation when changing**: Keep docs in sync with config

## Inline Comments

```nix
# Home Manager - User environment management
home-manager = {
  useGlobalPkgs = true;
  useUserPackages = true;
};

# Tailscale VPN
services.tailscale = {
  enable = true;
  useRoutingFeatures = "client";
  authKeyFile = config.services.onepassword-secrets.secretPaths.tailscaleAuthKey;
};

# Firewall - allow SSH and Tailscale
networking.firewall = {
  enable = true;
  allowedTCPPorts = [22 80 443];
  trustedInterfaces = ["tailscale0"];
  allowedUDPPorts = [config.services.tailscale.port];
};
```

- **Group related options**: Use comments to separate sections
- **Document non-obvious choices**: Explain why certain options are set
- **Note security implications**: Document security-related decisions
- **Comment complex logic**: Explain complex configuration decisions

## README Files

```markdown
# Project Name

## Overview
Brief description of the NixOS configuration.

## Hosts
- **hostname1**: Description and purpose
- **hostname2**: Description and purpose

## Structure
- `flake.nix` - Main flake configuration
- `modules/` - Shared NixOS modules
- `hosts/` - Host-specific configurations
- `home/` - Home Manager configurations

## Getting Started
1. Install NixOS
2. Clone this repository
3. Run `nixos-rebuild switch --flake .#hostname`

## Updates
- Update flake: `nix flake update`
- Test configuration: `nixos-rebuild build --flake .#hostname`

## Secrets
Secrets are managed via 1Password + OpNix.
See documentation for setup instructions.
```

- **Include overview**: What is this configuration for?
- **Document structure**: Explain the directory layout
- **Provide setup instructions**: How to use this configuration
- **Document secrets**: How are secrets managed?
- **Include update process**: How to update the configuration

## Architecture Documentation

```markdown
# Architecture

## Module Organization

### System Modules (modules/)
- **packages** - System and development packages
- **development** - Development environment tools
- **security** - Security-related modules
- **services** - System services configuration

### Host-Specific (hosts/)
- **servers/** - Server configurations
- **laptops/** - Laptop configurations

### Shared Patterns
All hosts share:
- Base NixOS modules from `modules/`
- Package management approach
- Secret management via OpNix
```

- **Explain architecture**: How is the configuration organized?
- **Document patterns**: What patterns are used across modules?
- **Note dependencies**: How do modules depend on each other?
- **Diagram relationships**: Visualize module relationships if complex

## Configuration Examples

```nix
# Example: Adding a new service

# 1. Create module file: modules/services/my-service/default.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  services.myService = {
    enable = true;
    port = 8080;
  };
}

# 2. Import in host config: hosts/my-host/default.nix
{
  imports = [
    ../../../modules
    ../../../modules/services/my-service
  ];
}

# 3. Add configuration
# (Host-specific settings)
```

- **Provide working examples**: Show complete, working examples
- **Step-by-step guides**: Break complex processes into steps
- **Include common use cases**: Show typical usage patterns
- **Test examples**: Ensure examples actually work

## Command Documentation

```bash
# Build configuration without switching
nixos-rebuild build --flake .#hostname

# Switch to new configuration
nixos-rebuild switch --flake .#hostname

# Check configuration
nixos-rebuild check --flake .#hostname

# Update flake dependencies
nix flake update

# View flake info
nix flake info

# List available configurations
nix flake show
```

- **Document common commands**: Provide cheat sheet of useful commands
- **Include parameters**: Explain what command-line options do
- **Show examples**: Provide concrete examples
- **Note prerequisites**: What needs to be true before running commands?

## Security Documentation

```markdown
# Security

## Secret Management
- All secrets stored in 1Password vault
- OpNix manages secret distribution
- No secrets in configuration repository

## Access Control
- SSH key-based authentication only
- Password authentication disabled
- Firewall restricts incoming connections

## Audit
- System logs retained for 30 days
- Btrfs snapshots for rollback capability
- Automatic security updates enabled
```

- **Document security model**: How is security handled?
- **Note security decisions**: Why were certain choices made?
- **Include audit procedures**: How to audit the configuration?
- **Document incident response**: How to handle security issues?

## Changelog

```markdown
# Changelog

## 2025-12-04
- Initial pantherOS setup
- Added Hetzner VPS configuration
- Configured Home Manager
- Set up OpNix secret management

## 2025-12-10
- Added OVH VPS configuration
- Added laptop configurations (yoga, zephyrus)
- Updated to NixOS 25.05
```

- **Keep a changelog**: Track significant changes
- **Include dates**: When were changes made?
- **Document major updates**: What changed between versions?
- **Note breaking changes**: What requires manual intervention?
