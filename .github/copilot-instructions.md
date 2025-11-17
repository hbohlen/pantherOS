# pantherOS Repository - Copilot Instructions

## Repository Overview

pantherOS is a comprehensive NixOS configuration system designed for reproducible, secure, and extensible workstation and server deployments. This repository contains declarative system configurations using Nix Flakes, implementing a modular architecture with layered configuration management.

## Technology Stack

### Core Technologies
- **NixOS**: Declarative Linux distribution with reproducible builds
- **Nix Flakes**: Modern Nix package and configuration management
- **home-manager**: Declarative user environment management
- **nixos-hardware**: Hardware-specific NixOS configurations
- **disko**: Declarative disk partitioning for NixOS
- **nixos-anywhere**: Remote NixOS installation system
- **opnix**: Secrets management with 1Password integration

### Development Tools
- **Nix**: Package manager and configuration language
- **nil**: Nix language server
- **nixpkgs-fmt**: Code formatter for Nix files

## Repository Structure

```
pantherOS/
├── flake.nix                    # Main flake configuration with NixOS systems
├── flake.lock                   # Lock file for flake inputs
├── hosts/                       # Host-specific configurations
│   └── servers/                 # Server configurations
│       ├── ovh-cloud/           # OVH Cloud VPS configuration
│       └── hetzner-cloud/       # Hetzner Cloud VPS configuration
├── system_config/               # System configuration documentation
│   ├── 03_PANTHEROS_NIXOS_BRIEF.md  # Complete architecture overview
│   ├── project_briefs/          # Project documentation
│   ├── implementation_guides/   # Step-by-step guides
│   └── secrets_management/      # OpNix and 1Password docs
├── ai_infrastructure/           # AI development planning docs
├── desktop_environment/         # Dank Linux desktop documentation
├── architecture/                # System architecture diagrams
├── code_snippets/               # Code examples and templates
├── specs/                       # System specifications
├── deploy.sh                    # Deployment script
└── migrate-to-dual-disk.sh      # Disk migration utility
```

## Development Workflow

### Setting Up Development Environment

The repository provides multiple development shells via Nix flakes:

- **default**: General development (git, neovim, fish, starship, direnv)
- **nix**: Nix development (nil, nixpkgs-fmt, nix-eval-lsp)
- **rust**: Rust development (rustup, cargo, rust-analyzer, clippy)
- **node**: Node.js development (node 18/20, yarn, pnpm, npm)
- **python**: Python development (python3, pip, virtualenv, black, pylint)
- **go**: Go development (go, gopls, golangci-lint)
- **mcp**: MCP-enabled AI development (Node.js, PostgreSQL, Docker, Nix tools)
- **ai**: AI infrastructure development (Python, databases, MCP support)

To enter a development shell:
```bash
nix develop
# or for specific environments:
nix develop .#nix
nix develop .#mcp  # For AI-assisted development with MCP servers
nix develop .#ai   # For AI infrastructure work
```

### MCP Server Integration

The repository includes comprehensive MCP (Model Context Protocol) server configurations:

- **Configuration**: See `.github/mcp-servers.json` for all available MCP servers
- **Setup Guide**: Detailed instructions in `.github/MCP-SETUP.md`
- **Servers Available**: GitHub, filesystem, git, brave-search, postgres, memory, sequential-thinking, puppeteer, docker, and custom nix-search wrapper

**Essential MCP servers for this project:**
- `github`: Repository operations and code search
- `filesystem`: Local file access
- `git`: Git operations
- `nix-search`: NixOS package search
- `postgres`: AgentDB integration (see `ai_infrastructure/`)
- `memory`: Knowledge graph for configuration patterns

### Building System Configurations

Build a specific host configuration:
```bash
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
nix build .#nixosConfigurations.hetzner-cloud.config.system.build.toplevel
```

### Deployment

Use the provided deployment script:
```bash
./deploy.sh
```

## Architecture Patterns

### Layered Module System

pantherOS implements a three-layer architecture:

1. **Layer 1: Core Modules** - Base functionality (base/, apps/, services/, hardware/, security/, networking/)
2. **Layer 2: Profiles** - Reusable configurations (workstation/, server/, common/)
3. **Layer 3: Host Configurations** - Specific machine configurations

### Configuration Philosophy

- **Declarative**: All system state declared in configuration files
- **Modular**: Reusable modules with clear boundaries
- **Composable**: Mix and match modules for different host configurations
- **Reproducible**: Flake lock ensures deterministic builds

### Secrets Management

The repository integrates with OpNix for secrets management:
- Secrets stored securely in 1Password
- OpNix modules provide declarative secrets configuration
- Currently temporarily disabled in some hosts to reduce closure size during initial deployment

## Code Style and Conventions

### Nix Code Style

- Use `nixpkgs-fmt` for formatting Nix files
- Follow the Nix manual style guide
- Prefer explicit attribute sets over `with` statements
- Use meaningful variable names
- Add comments for complex logic

### File Organization

- Place host-specific configs in `hosts/`
- Document system architecture in `system_config/`
- Keep deployment scripts in the root directory
- Store reusable code examples in `code_snippets/`

### Documentation Standards

- Maintain comprehensive documentation in markdown
- Include architecture diagrams using Mermaid
- Document breaking changes and migration paths
- Keep master topic maps up to date

## Common Tasks

### Adding a New Host Configuration

1. Create a new directory under `hosts/servers/` or `hosts/workstations/`
2. Add `configuration.nix` with system configuration
3. Optionally add `home.nix` for home-manager configuration
4. Update `flake.nix` to include the new nixosConfiguration
5. Document the host in system_config/

### Updating Dependencies

```bash
nix flake update              # Update all inputs
nix flake lock --update-input nixpkgs  # Update specific input
```

### Testing Changes

```bash
# Build without switching
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel

# Test in VM
nixos-rebuild build-vm --flake .#<hostname>
```

## Key Documentation

- **[README.md](../README.md)**: Main repository documentation
- **[00_MASTER_TOPIC_MAP.md](../00_MASTER_TOPIC_MAP.md)**: Complete documentation index
- **[system_config/03_PANTHEROS_NIXOS_BRIEF.md](../system_config/03_PANTHEROS_NIXOS_BRIEF.md)**: Comprehensive architecture overview
- **[DEPLOYMENT.md](../DEPLOYMENT.md)**: Deployment procedures
- **[DISK-OPTIMIZATION.md](../DISK-OPTIMIZATION.md)**: Disk optimization guide

## Important Notes

- **Closure Size**: Some modules (opnix, home-manager) are temporarily disabled in hosts to reduce initial deployment closure size
- **Remote Deployment**: Use nixos-anywhere for remote system installation
- **Disk Configuration**: disko module handles declarative disk partitioning
- **Hardware Support**: nixos-hardware provides optimized configurations for specific hardware

## AI Development Context

This repository includes extensive AI development planning documentation in `ai_infrastructure/`:
- Integration with AgentDB for vector database capabilities
- Documentation analysis and scraping systems
- MiniMax M2 optimization strategies
- Agentic-flow integration plans
- pantherOS research roadmap with gap analysis

## Development Tools & Configuration

### Dev Container Support

The repository includes Dev Container configuration (`.github/devcontainer.json`) for:
- NixOS-based containerized development
- Pre-configured VS Code extensions (nix-ide, Copilot, GitLens)
- Automatic Nix cache setup
- Volume mounts for /nix directory persistence

### Environment Variables

For MCP server integration, configure:
- `GITHUB_TOKEN`: GitHub API access (required for github MCP server)
- `BRAVE_API_KEY`: Web search capability (optional)
- `POSTGRES_CONNECTION_STRING`: AgentDB database connection (for AI infrastructure work)
- `MCP_CONFIG_PATH`: Path to MCP servers configuration (auto-set in mcp dev shell)

**Complete secrets and environment variables documentation:**
- Quick Reference: [.github/SECRETS-QUICK-REFERENCE.md](SECRETS-QUICK-REFERENCE.md)
- Full Guide: [.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md](SECRETS-AND-ENVIRONMENT-VARIABLES.md)

## Spec-Driven Development with GitHub Spec Kit

This repository is configured with [GitHub Spec Kit](https://github.com/github/spec-kit), a toolkit for implementing Spec-Driven Development (SDD). This methodology emphasizes creating clear specifications before implementation.

### 🔴 GLOBAL RULES - MUST FOLLOW

These rules apply to **ALL** development work. No exceptions without explicit justification.

#### 1. Prefer Spec-First Workflows

**ALWAYS follow this sequence for new features or major changes:**

1. **Check for existing specs** under `/docs/specs/` FIRST
2. **If missing or incomplete**, help create or refine specs **BEFORE** editing code
3. **No code changes** without corresponding spec (except trivial bug fixes)

**What requires a spec:**
- ✅ New features (any size)
- ✅ Major refactoring or architectural changes
- ✅ Breaking changes
- ✅ Security improvements
- ✅ Infrastructure changes

**What doesn't require a spec:**
- ⚪ Trivial bug fixes (< 10 lines, obvious fix)
- ⚪ Routine dependency updates
- ⚪ Minor documentation typo fixes

#### 2. Use Spec Kit Commands Appropriately

**Always use the correct command for each phase:**

| When to use | Command | Purpose |
|-------------|---------|---------|
| Starting new feature | `/speckit.specify` | Define what and why |
| Requirements unclear | `/speckit.clarify` | Fill specification gaps |
| Ready to design | `/speckit.plan` | Create technical implementation plan |
| Ready to break down work | `/speckit.tasks` | Generate actionable task breakdown |
| Ready to implement | `/speckit.implement` | Execute the implementation plan |
| Validating quality | `/speckit.analyze` | Check consistency and coverage |
| Creating validation criteria | `/speckit.checklist` | Generate acceptance checklist |
| Converting to issues | `/speckit.taskstoissues` | Create GitHub issues from tasks |

#### 3. Documentation Expectations

**Treat `/docs` as the single source of truth:**

- **Update docs in the same PR** as code changes
- **Keep docs sharded**: One major concept per file, with clear cross-links
- **When adding/modifying significant behavior**: Update or create docs under `/docs`
- **Documentation structure**:
  - `/docs/specs/` - Feature specifications (created via Spec Kit)
  - `/docs/architecture/` - System architecture and ADRs
  - `/docs/howto/` - Task-oriented guides
  - `/docs/reference/` - Configuration and API reference
  - `/docs/contributing/` - Development workflow guides
  - `/docs/examples/` - Code examples and templates

#### 4. TODO Lists and Guidance

**When generating TODO lists, for each task indicate:**

1. **Which `/speckit.*` commands should be used** (if any)
2. **Which file(s) in `/docs` or `/docs/specs` should be updated**
3. **Dependencies** between tasks

**Example format:**
```markdown
- [ ] Create PostgreSQL spec
  - Commands: `/speckit.specify`, `/speckit.clarify`
  - Update: `/docs/specs/010-postgresql/spec.md` (new)
  - Update: `/docs/index.md` (link new spec)

- [ ] Implement basic PostgreSQL service
  - Depends on: PostgreSQL spec completed
  - Commands: None (implementation task)
  - Update: `/docs/examples/nixos/postgresql-basic.md` (new)
  - Update: `/docs/reference/configuration-options.md`
```

### BEHAVIOR GUIDELINES

#### Always Propose Tests and Documentation

When modifying code, **ALWAYS propose:**

1. **Tests** - What tests should be added/updated?
2. **Documentation** - What docs in `/docs` need updating?
3. **Examples** - Should we add code examples?

#### Explain Which Spec You're Implementing

When implementing features, **ALWAYS explain:**

1. **Which spec** (e.g., "Implementing spec 009-gnome-desktop")
2. **Which part of the spec** (e.g., "Section 3.2: Display Manager Configuration")
3. **How implementation aligns** with spec requirements

#### Handle Ambiguity Proactively

**When there is ambiguity:**

1. **Ask clarifying questions** OR
2. **Suggest updating the relevant spec** using `/speckit.clarify`

**Never:**
- ❌ Make assumptions without documenting them
- ❌ Proceed with unclear requirements
- ❌ Implement features that contradict the spec

#### Prefer Small, Reviewable Changes

**Avoid large, monolithic changes:**

- Align changes with specific tasks from `/speckit.tasks`
- One task ≈ one PR (generally)
- Reference spec and task in PR title: `feat: Add GDM config (spec-009, task 3.2)`

### Available Spec Kit Commands

The following slash commands are available for structured feature development:

#### Core Development Workflow

- `/speckit.constitution` - Create or update project governing principles and development guidelines
- `/speckit.specify` - Define what you want to build (requirements and user stories)
- `/speckit.plan` - Create technical implementation plans with your chosen tech stack
- `/speckit.tasks` - Generate actionable task lists for implementation
- `/speckit.implement` - Execute all tasks to build the feature according to the plan

#### Quality & Analysis Commands

- `/speckit.clarify` - Clarify underspecified areas (recommended before `/speckit.plan`)
- `/speckit.analyze` - Cross-artifact consistency & coverage analysis
- `/speckit.checklist` - Generate custom quality checklists for requirements validation
- `/speckit.taskstoissues` - Convert task breakdown into GitHub issues

### Spec Kit Directory Structure

**Spec Kit configuration** (templates and commands):
```
.specify/
├── memory/
│   └── constitution.md          # Project principles and guidelines
├── scripts/
│   └── bash/                    # Helper scripts for feature management
└── templates/
    ├── spec-template.md         # Feature specification template
    ├── plan-template.md         # Implementation plan template
    ├── tasks-template.md        # Task breakdown template
    └── checklist-template.md   # Quality checklist template

.github/agents/
└── speckit.*.md                 # Agent command definitions
```

**Feature specifications** (created as needed):
```
docs/specs/
├── README.md                    # Specs directory guide
└── NNN-feature-name/            # Each feature gets its own directory
    ├── spec.md                  # Feature specification (required)
    ├── plan.md                  # Implementation plan (optional)
    ├── tasks.md                 # Task breakdown (optional)
    └── implementation-details/  # Additional artifacts (optional)
```

### Using Spec Kit for New Features

**Standard workflow (follow this sequence):**

1. **Check Existing Specs**: Search `/docs/specs/` first
2. **Create Specification**: Use `/speckit.specify` to describe what you want to build
3. **Clarify Requirements**: Use `/speckit.clarify` to fill gaps (recommended)
4. **Create Technical Plan**: Use `/speckit.plan` to define implementation approach
5. **Break Down Tasks**: Use `/speckit.tasks` to create actionable task list
6. **Implement**: Use `/speckit.implement` to execute the plan (or work manually)
7. **Validate**: Use `/speckit.analyze` and `/speckit.checklist` for quality assurance

**Complete workflow documentation:**
- [Spec-Driven Workflow Guide](../docs/contributing/spec-driven-workflow.md) - Comprehensive guide with examples
- [Specs Directory README](../docs/specs/README.md) - Spec structure and organization
- [Spec Kit Examples](../docs/tools/spec-kit-examples.md) - Real-world examples
- [GitHub Spec Kit Documentation](https://github.com/github/spec-kit) - Upstream project
- [Spec-Driven Development Guide](https://github.com/github/spec-kit/blob/main/spec-driven.md) - SDD methodology

## Getting Help

- Check the master topic map for navigation: [00_MASTER_TOPIC_MAP.md](../00_MASTER_TOPIC_MAP.md)
- Review implementation guides in `system_config/implementation_guides/`
- See code examples in `code_snippets/`
- Consult the comprehensive architecture brief: `system_config/03_PANTHEROS_NIXOS_BRIEF.md`
- MCP server setup and troubleshooting: [.github/MCP-SETUP.md](MCP-SETUP.md)
