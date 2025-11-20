<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Agent Guidance for pantherOS Root

## Purpose
This repository is a comprehensive NixOS configuration. AI agents should follow strict guidelines when working here.

## Before You Begin

1. **Read `brief.md`** - Contains complete project requirements and specifications
2. **Read `docs/README.md`** - Documentation index and navigation hub
3. **Understand the architecture** - See `docs/architecture/overview.md`
4. **Check current tasks** - See `docs/todos/README.md` for task tracking
5. **Review the modular structure** - See `README.md`

## What This Directory Contains

- `flake.nix` - Flake entry point (currently minimal)
- `hosts/` - Host-specific configurations
- `modules/` - Modular Nix configurations
- `home/` - Home-manager configurations
- `profiles/` - Reusable configuration profiles
- `docs/` - Comprehensive documentation
  - Architecture and design decisions
  - Step-by-step guides
  - Hardware specifications
  - Task tracking and TODOs
  - Module documentation

## Documentation Structure

The `docs/` directory is organized into several sections:

- **docs/architecture/** - System design and architectural decisions
- **docs/guides/** - Step-by-step guides for common tasks
- **docs/hardware/** - Hardware specifications for all hosts
- **docs/modules/** - Documentation for each module category
- **docs/todos/** - Current task tracking and roadmap

See `docs/README.md` for complete documentation index and navigation.

## Agent Tasks

Tasks are organized by phase and tracked in `docs/todos/`:

### Phase 1: Foundation
**See:** `docs/todos/phase1-hardware-discovery.md`
- **Hardware Discovery**: Scan all 4 hosts for specifications
- **Documentation**: Create hardware documentation in `docs/hardware/`
- **Disk Planning**: Design Btrfs layouts per host (see `docs/architecture/disk-layouts.md`)

### Phase 2: Module Development
**See:** `docs/todos/phase2-module-development.md`
- **Modularization**: Research and implement module structure
- **Module Development**: Create system and home-manager modules
- **Flake Configuration**: Populate flake.nix with inputs and outputs

### Phase 3: Host Configuration
**See:** `docs/todos/phase3-host-configuration.md`
- **Testing**: Build and test all host configurations
- **Security**: Implement Tailscale and firewall rules
- **Integration**: Connect all components

### Research Tasks
**See:** `docs/todos/research-tasks.md`
- Research items that inform implementation decisions
- Technology evaluation and comparison
- Best practices research

For reading order guidance and current task status, see `docs/todos/README.md`.

## Module Creation Checklist

When creating a new module:
- [ ] Single concern per module
- [ ] Documentation in `docs/modules/`
- [ ] Proper imports (relative paths)
- [ ] Options defined with `mkEnableOption` or similar
- [ ] Build test: `nixos-rebuild build .#<hostname>`
- [ ] No hardcoded secrets

## Directory Structure Reference

```
pantherOS/
├── flake.nix              # ← Flake entry point
├── hosts/                 # ← Host configs (yoga, zephyrus, servers/*)
│   ├── yoga/             #   - disko.nix, hardware.nix, default.nix
│   ├── zephyrus/         #   - disko.nix, hardware.nix, default.nix
│   └── servers/          #   - hetzner-vps, ovh-vps
├── modules/              # ← Modular configs
│   ├── nixos/           #   - System modules
│   ├── home-manager/    #   - User modules
│   └── shared/          #   - Shared modules
├── home/                # ← Home-manager configs
│   └── hbohlen/         #   - User-specific configs
├── profiles/            # ← Reusable profiles
└── docs/                # ← Documentation hub
    ├── README.md        #   - Documentation index
    ├── architecture/    #   - System design docs
    ├── guides/          #   - Step-by-step guides
    ├── hardware/        #   - Hardware specifications
    ├── modules/         #   - Module documentation
    └── todos/           #   - Task tracking
```

## Critical Rules

1. **NEVER commit secrets** - All secrets via 1Password/OpNix
2. **Test before deploy** - Build works before switch
3. **One host at a time** - Complete host before starting next
4. **Hardware first** - Get specs before code
5. **Modular always** - No monolithic configs
6. **Document everything** - Docs alongside code

## Common Commands

```bash
# Build a host (dry run)
nixos-rebuild build --flake .#yoga

# Switch to a host (LIVE - be careful!)
nixos-rebuild switch --flake .#yoga

# Development shell
nix develop

# Check for updates
nix flake update

# Format Nix code
alejandra .
```

## Skills Integration

pantherOS includes specialized skills for automated workflows:

### Available Skills
- **pantheros-deployment-orchestrator** - Automated deployment and rollback
- **pantheros-hardware-scanner** - Hardware discovery and documentation
- **pantheros-module-generator** - Automated module creation
- **pantheros-secrets-manager** - 1Password integration and secrets handling

### When to Use Skills
- **Hardware Discovery**: Use `pantheros-hardware-scanner` before any host configuration
- **Module Creation**: Use `pantheros-module-generator` for consistent module patterns
- **Deployment**: Use `pantheros-deployment-orchestrator` for safe host deployment
- **Secrets Management**: Use `pantheros-secrets-manager` for all 1Password operations

### Skill Integration Pattern
```bash
# Example: Hardware discovery workflow
cd /home/hbohlen/dev/pantherOS
./skills/pantheros-hardware-scanner/scripts/scan-hardware.sh yoga
```

## OpenSpec Integration

OpenSpec provides structured change proposal workflow for significant changes.

### When to Use OpenSpec
Use OpenSpec for:
- **Architecture Changes**: Module system restructuring, host layout changes
- **Breaking Changes**: API modifications, dependency updates
- **Security Model Changes**: Firewall rules, authentication changes
- **Performance Changes**: Major optimization work
- **New Capabilities**: Adding new tooling or workflows

### OpenSpec Workflow
1. **Proposal**: `/spec-gen <name>` - Generate change proposal
2. **Implementation**: `/code-impl <name>` - Implement approved spec
3. **Validation**: `/nixos-check <name>` - Verify implementation
4. **Archive**: `/openspec-archive <name>` - Archive completed change

### Integration with Phases
- **Phase 1**: Hardware discovery specifications
- **Phase 2**: Module interface specifications  
- **Phase 3**: Host configuration specifications

## Agent Integration

OpenCode agents provide specialized assistance for pantherOS development:

### Agent Roles
- **Architect**: System design and module planning
- **Engineer**: Implementation and code development
- **Librarian**: Research and validation
- **Reviewer**: Quality assurance and testing

### Agent Workflow
1. **Architect** analyzes requirements and creates proposals
2. **Librarian** validates feasibility and researches options
3. **Engineer** implements according to specifications
4. **Reviewer** validates and approves changes

### Custom Commands
- `/spec-gen <name>` - Generate OpenSpec proposal
- `/code-impl <name>` - Implement from specification
- `/nixos-check <name>` - Validate NixOS configuration
- `/research <query>` - Research with context7 and nixos

## Working in Subdirectories

Each subdirectory has its own AGENTS.md with specific guidance:

### Root Level
- `AGENTS.md` - This file, project overview and guidelines

### Subdirectory Guidance
- `openspec/AGENTS.md` - OpenSpec change proposal workflow
- `docs/AGENTS.md` - Documentation-specific guidance
- `modules/AGENTS.md` - For module development
- `hosts/AGENTS.md` - For host configuration
- `home/AGENTS.md` - For home-manager configs
- `overlays/AGENTS.md` - For package overlays
- `scripts/AGENTS.md` - For scripts

## Emergency Contacts

If system won't boot:
- Select previous generation at GRUB
- Use Tailscale from another device
- Use VPS web console (Hetzner/OVH)

## Success Criteria

Configuration is complete when:
- All 4 hosts build successfully
- Hardware specs documented
- All TODOs addressed
- Zero configuration drift
- Documentation complete
