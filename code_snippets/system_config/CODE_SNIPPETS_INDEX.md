# Code Snippets Index & Enrichment Data

**Purpose**: Cataloged code snippets with AI agent retrieval metadata  
**Version**: 1.0  
**Last Updated**: 2025-11-15

---

## Usage for AI Agents

Each code snippet in this directory includes:
1. **Enrichment metadata** (purpose, dependencies, config points)
2. **Integration patterns** (how to use in context)
3. **Validation steps** (testing checklist)
4. **Related modules** (cross-references)

---

## Directory Structure

```
code_snippets/
├── nixos/
│   ├── browser.nix.md          # Browser toggle module
│   ├── fish.nix.md             # Fish shell configuration
│   ├── nix-base.nix.md         # Base Nix settings
│   ├── podman.nix.md           # Podman container runtime
│   ├── disko-example.nix.md    # Declarative disk layouts
│   ├── mkSystem-helper.nix.md  # System builder function
│   ├── nvidia-gpu.nix.md       # NVIDIA GPU configuration for Wayland
│   ├── battery-management.nix.md # Laptop battery optimization
│   └── security-hardening.nix.md # Comprehensive system security
├── opnix/
│   ├── nixos-secrets.nix.md    # OpNix NixOS module config
│   ├── hm-secrets.nix.md       # OpNix Home Manager config
│   └── secret-patterns.md      # Common secret integration patterns
└── services/
    ├── datadog-agent.nix.md    # Datadog monitoring agent
    ├── tailscale.nix.md        # Tailscale VPN service
    └── attic.nix.md            # Attic binary cache

```

---

## Quick Reference by Task

### Setting up NixOS base system
1. [`nixos/nix-base.nix.md`](./nixos/nix-base.nix.md) - Flakes, unfree packages
2. [`nixos/fish.nix.md`](./nixos/fish.nix.md) - Default shell
3. [`nixos/mkSystem-helper.nix.md`](./nixos/mkSystem-helper.nix.md) - System builder

### Desktop environment
1. [`nixos/browser.nix.md`](./nixos/browser.nix.md) - Browser selection
2. [`nixos/nvidia-gpu.nix.md`](./nixos/nvidia-gpu.nix.md) - NVIDIA GPU with Wayland support
3. Niri configuration - see `DESKTOP_ENVIRONMENT_GUIDE.md`
4. DankMaterialShell - see `DESKTOP_ENVIRONMENT_GUIDE.md`

### Hardware optimization
1. [`nixos/battery-management.nix.md`](./nixos/battery-management.nix.md) - Laptop battery optimization
2. [`nixos/nvidia-gpu.nix.md`](./nixos/nvidia-gpu.nix.md) - NVIDIA GPU configuration
3. Hardware modules - see pantherOS implementation guide

### Containers & virtualization
1. [`nixos/podman.nix.md`](./nixos/podman.nix.md) - Rootless containers

### Secrets management
1. [`opnix/nixos-secrets.nix.md`](./opnix/nixos-secrets.nix.md) - System secrets
2. [`opnix/hm-secrets.nix.md`](./opnix/hm-secrets.nix.md) - User secrets
3. [`opnix/secret-patterns.md`](./opnix/secret-patterns.md) - Integration examples

### Services
1. [`services/datadog-agent.nix.md`](./services/datadog-agent.nix.md) - Monitoring
2. [`services/tailscale.nix.md`](./services/tailscale.nix.md) - VPN networking
3. [`services/attic.nix.md`](./services/attic.nix.md) - Binary cache

### Disk management
1. [`nixos/disko-example.nix.md`](./nixos/disko-example.nix.md) - Declarative partitioning

---

## Metadata Format

Each code snippet file includes:

```markdown
# Module Name

## Enrichment Metadata
- **Purpose**: What this module does
- **Layer**: modules/profiles/hosts
- **Dependencies**: Required inputs/modules
- **Conflicts**: Incompatible modules
- **Platforms**: x86_64-linux, aarch64-linux, etc.

## Configuration Points
- Option 1: Description
- Option 2: Description

## Code

\`\`\`nix
# Actual implementation
\`\`\`

## Integration Pattern
How to use this in your config

## Validation Steps
1. Build check
2. Runtime verification
3. Expected behavior

## Related Modules
- Link to related code
- Link to documentation
```

---

## Code Snippet Categories

### Critical Path (required for base system)
- `nix-base.nix.md`
- `mkSystem-helper.nix.md`
- `fish.nix.md`

### Security (secrets handling)
- `nixos-secrets.nix.md`
- `hm-secrets.nix.md`
- `secret-patterns.md`
- [`nixos/security-hardening.nix.md`](./nixos/security-hardening.nix.md) - System security hardening

### Services (optional but recommended)
- `tailscale.nix.md`
- `datadog-agent.nix.md`
- `attic.nix.md`

### Desktop (workstations only)
- `browser.nix.md`
- `podman.nix.md`
- Niri/DMS (see guides)

### Infrastructure (servers/deployment)
- `disko-example.nix.md`
- Service modules

---

## Version Control

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-15 | Initial code extraction and enrichment |
