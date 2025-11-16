# Repository Structure Overview

**Generated:** 2025-11-16  
**Repository:** pantherOS NixOS Configuration  
**Purpose:** High-level analysis of repository layout and organization

---

## Executive Summary

pantherOS is a **NixOS configuration repository** using **Nix Flakes** for declarative system configuration. The repository is currently in a **minimal implementation state** with a single OVH Cloud VPS server configured, but contains extensive documentation for **aspirational features** (desktop environment, AI infrastructure, modular architecture) that are not yet implemented.

The repository shows signs of **documentation sprawl** with:
- **83 documentation files** across 18 directories
- **Significant duplication** (27 files are duplicates, primarily Spec Kit tooling)
- **Mixed implemented vs aspirational** content
- **Multiple documentation organization attempts** (root, system_config/, ai_infrastructure/, etc.)

---

## Repository Layout

### Directory Tree

```
pantherOS/
├── .config/                          # Config files (not examined in detail)
├── .git/                             # Git repository data
├── .github/                          # GitHub-specific configuration
│   ├── agents/                       # GitHub Copilot Spec Kit agents (9 files)
│   ├── copilot-instructions.md       # Copilot context
│   ├── devcontainer.json             # Dev container config
│   ├── mcp-servers.json              # MCP server configuration
│   └── SECRETS-*.md                  # Secrets management docs (4 files)
├── .opencode/                        # OpenCode framework files
│   ├── agentdb/                      # AgentDB integration
│   ├── command/                      # Command definitions (9 DUPLICATE files)
│   ├── mcp/                          # MCP server scripts
│   ├── plugin/                       # Plugins
│   └── skills/                       # Skills (systematic-debugging)
├── .specify/                         # GitHub Spec Kit framework
│   ├── memory/                       # Constitution and memory
│   ├── scripts/                      # Bash helper scripts
│   │   └── bash/                     # 5 shell scripts
│   ├── specs/                        # Feature specifications (empty, has .gitkeep)
│   └── templates/                    # Spec Kit templates
│       └── commands/                 # Command templates (9 DUPLICATE files)
├── ai_infrastructure/                # AI project planning docs (10 files, NOT IMPLEMENTED)
├── architecture/                     # Architecture diagrams (2 files, aspirational)
├── code_snippets/                    # Code examples
│   └── system_config/
│       ├── CODE_SNIPPETS_INDEX.md
│       └── nixos/                    # 5 NixOS config examples
├── desktop_environment/              # Desktop docs (3 files, NOT IMPLEMENTED)
├── hosts/                            # Host-specific configurations (IMPLEMENTED)
│   └── servers/
│       ├── hetzner-cloud/            # Hetzner VPS config (3 .nix files)
│       └── ovh-cloud/                # OVH VPS config (3 .nix files)
├── specs/                            # Feature specifications
│   └── 001-nixos-anywhere-deployment-setup/
│       ├── spec.md
│       └── checklists/
│           └── requirements.md
├── system_config/                    # System configuration documentation (7 files)
│   ├── implementation_guides/        # Implementation guides (1 file)
│   ├── project_briefs/               # Project briefs (1 file)
│   └── secrets_management/           # Secrets docs (2 files)
├── flake.nix                         # Main flake configuration (CORE)
├── flake.lock                        # Flake lock file (CORE)
├── deploy.sh                         # Deployment script (CORE)
├── migrate-to-dual-disk.sh           # Disk migration utility
├── result                            # Symlink to latest build
└── *.md                              # 12 root-level markdown docs

18 directories, 83 documentation files, 7 Nix files
```

---

## Layer Analysis

### Layer 1: Core Implementation (✅ Working)

**Purpose**: Actual NixOS configuration that is deployed and working

**Directories**:
- `hosts/servers/ovh-cloud/` - OVH Cloud VPS configuration
- `hosts/servers/hetzner-cloud/` - Hetzner Cloud VPS configuration
- `flake.nix` - Main flake with system definitions
- `flake.lock` - Dependency lock file

**Files** (7 Nix configuration files):
- `flake.nix` - Flake inputs, outputs, nixosConfigurations, development shells
- `hosts/servers/ovh-cloud/configuration.nix` - System configuration
- `hosts/servers/ovh-cloud/disko.nix` - Disk partitioning
- `hosts/servers/ovh-cloud/home.nix` - Home Manager config (temporarily disabled)
- `hosts/servers/hetzner-cloud/configuration.nix` - System configuration
- `hosts/servers/hetzner-cloud/disko.nix` - Disk partitioning
- `hosts/servers/hetzner-cloud/home.nix` - Home Manager config (temporarily disabled)

**Characteristics**:
- Minimal, functional NixOS configuration
- Declarative disk partitioning with disko
- SSH-only access with key authentication
- Basic system packages
- Home Manager temporarily disabled to reduce closure size
- OpNix imported but not configured

**Key Technologies**:
- NixOS (nixos-unstable channel)
- Nix Flakes
- disko (disk partitioning)
- nixos-anywhere (remote deployment)
- home-manager (imported but disabled)
- opnix (imported but disabled)

---

### Layer 2: Core Documentation (✅ Essential)

**Purpose**: Documentation for the working implementation

**Directories**:
- `.github/` - GitHub-specific docs and configuration
- Root directory - Main documentation files
- `system_config/` - System configuration documentation
- `specs/` - Feature specifications

**Key Files** (~20 essential docs):
- `README.md` - Main repository overview
- `00_MASTER_TOPIC_MAP.md` - Master navigation index
- `DEPLOYMENT.md` - Deployment guide
- `CONFIGURATION-SUMMARY.md` - Configuration summary
- `.github/copilot-instructions.md` - Copilot context
- `.github/MCP-SETUP.md` - MCP server setup
- `.github/SECRETS-*.md` (4 files) - Secrets management
- `system_config/03_PANTHEROS_NIXOS_BRIEF.md` - Architecture brief
- `system_config/README.md` - System config overview
- `OVH Cloud VPS - System Profile.md` - Hardware specs
- `Hetzner Cloud VPS - System Profile.md` - Hardware specs
- `Yoga - System Profile.md` - Workstation specs
- `.specify/memory/constitution.md` - Project principles
- `specs/001-nixos-anywhere-deployment-setup/` - Active spec

**Characteristics**:
- Well-maintained and up-to-date
- Clear distinction between implemented and aspirational
- Good operational documentation
- Comprehensive secrets management docs
- Hardware specifications documented

---

### Layer 3: Development Tooling (✅ Active)

**Purpose**: Development tools and AI agent infrastructure

**Directories**:
- `.github/agents/` - GitHub Copilot Spec Kit agents (9 files)
- `.specify/` - GitHub Spec Kit framework
- `.opencode/` - OpenCode framework integration

**Key Components**:
1. **GitHub Spec Kit** - Spec-driven development framework
   - 9 agent definitions (analyze, checklist, clarify, constitution, implement, plan, specify, tasks, taskstoissues)
   - Templates for specs, plans, tasks, checklists
   - Bash helper scripts for automation
   
2. **MCP (Model Context Protocol) Integration**
   - `.github/mcp-servers.json` - MCP server configurations
   - `.opencode/mcp/agentdb-server.js` - AgentDB MCP server
   - Integration with GitHub, filesystem, git, postgres, and other MCP servers

3. **AgentDB Integration**
   - `.opencode/agentdb/` - AgentDB index
   - `.opencode/plugin/agentdb/` - AgentDB plugin
   - Vector database for AI agent memory

4. **Development Environments** (defined in flake.nix)
   - default - General development
   - nix - Nix development
   - rust - Rust development
   - node - Node.js development
   - python - Python development
   - go - Go development
   - mcp - MCP-enabled AI development
   - ai - AI infrastructure development

**Issues**:
- **27 duplicate files** across .github/agents/, .opencode/command/, and .specify/templates/commands/
- Unclear which is the canonical source
- Potential sync issues between duplicates

---

### Layer 4: Reference Materials (⚠️ Useful But Verbose)

**Purpose**: Examples, guides, and reference documentation

**Directories**:
- `code_snippets/` - NixOS configuration examples (6 files)
- `system_config/project_briefs/` - Project documentation
- `system_config/implementation_guides/` - Implementation guides
- `system_config/secrets_management/` - Secrets management guides

**Content**:
- **Code Examples** (5 NixOS configs):
  - Battery management
  - Browser configuration
  - Datadog agent
  - NVIDIA GPU
  - Security hardening
  
- **Implementation Guides**:
  - Comprehensive but verbose
  - Some overlap with other documentation
  - Useful for onboarding and deep dives

- **Secrets Management**:
  - OpNix CLI reference
  - 1Password integration guide
  - Overlaps with .github/SECRETS-*.md files

**Issues**:
- Verbose documentation with overlap
- Could benefit from consolidation
- Some examples are for unimplemented features

---

### Layer 5: Aspirational Content (❌ Not Implemented)

**Purpose**: Documentation for future planned features

**Directories**:
- `ai_infrastructure/` - AI project planning (10 files)
- `desktop_environment/` - Dank Linux desktop docs (3 files)
- `architecture/` - Architecture diagrams (2 files, aspirational)

**Content**:
1. **AI Infrastructure Plans** (10 files, 0% implemented):
   - AgentDB integration plan
   - Documentation analysis plan
   - Documentation scraper plan
   - hbohlenOS design plan
   - MiniMax optimization plan
   - Agentic-flow integration
   - Research plans and gap analysis

2. **Desktop Environment** (3 files, 0% implemented):
   - Dank Linux master guide
   - Installation guide
   - Keybindings reference
   - All for DankMaterialShell desktop that doesn't exist in this repo

3. **Architecture Diagrams** (2 files, aspirational):
   - System architecture Mermaid diagrams
   - System integrations diagrams
   - Describes modular architecture not yet implemented

**Issues**:
- Creates confusion about what is actually implemented
- Takes up significant space (13 files, ~18,000 words)
- May become stale as plans change
- Should be archived or moved to separate planning repository

---

### Layer 6: Obsolete Content (❌ Remove)

**Purpose**: Outdated or superseded documentation

**Files**:
- `OVH-DEPLOYMENT-GUIDE.md` - Superseded by DEPLOYMENT.md
- `DISK-OPTIMIZATION.md` - Describes unimplemented features
- `NIXOS-QUICKSTART.md` - Describes unimplemented features
- `OPNIX-SETUP.md` - OpNix not configured (or mark as future)
- `PERFORMANCE-OPTIMIZATIONS.md` - Planning only, not actionable

**Issues**:
- Can mislead users
- Creates maintenance burden
- Should be removed or clearly marked as obsolete

---

## Configuration Knowledge Locations

### Infrastructure as Code

**Primary Location**: `hosts/servers/`

**What's Here**:
- NixOS system configurations
- Disk partitioning configurations (disko)
- Home Manager user environment configs
- SSH key management
- User account configuration

**Knowledge Encoded**:
- Server deployment patterns
- Disk layout strategies
- Security configurations (SSH key-only auth)
- Boot configuration for VPS environments
- Network configuration patterns

---

### Deployment & Operations

**Primary Locations**: 
- `deploy.sh` (deployment script)
- `DEPLOYMENT.md` (deployment documentation)
- `.github/SECRETS-*.md` (secrets management)

**What's Here**:
- Automated deployment procedures
- nixos-anywhere usage
- SSH configuration
- Environment variable requirements
- 1Password/OpNix integration
- Secret management workflows

**Knowledge Encoded**:
- Remote NixOS installation process
- Disk formatting strategies
- Authentication patterns
- Service account management
- Bootstrap procedures

---

### Development Environment

**Primary Locations**:
- `flake.nix` (devShells outputs)
- `.github/devcontainer.json` (Dev Container config)
- `.github/mcp-servers.json` (MCP configuration)

**What's Here**:
- 8 different development shell configurations
- Language-specific tooling (Rust, Node, Python, Go, Nix)
- AI development tooling (MCP, AgentDB)
- VS Code integration
- Container-based development

**Knowledge Encoded**:
- Development workflow patterns
- Language-specific toolchains
- AI agent integration
- IDE configuration
- Reproducible development environments

---

### CI/CD & Automation

**Primary Locations**:
- `.github/` directory
- `.specify/scripts/bash/` (helper scripts)
- `deploy.sh` (deployment automation)

**What's Here**:
- Spec Kit automation scripts
- Deployment automation
- Pre-requisite checking
- Feature creation workflows

**Knowledge Encoded**:
- Spec-driven development workflows
- Automated feature scaffolding
- Validation patterns
- Git workflow automation

---

### AI Agent Context

**Primary Locations**:
- `.github/copilot-instructions.md` (Copilot context)
- `.github/agents/` (Spec Kit agents)
- `.specify/memory/constitution.md` (project principles)
- `.opencode/` (OpenCode integration)

**What's Here**:
- Repository overview for AI agents
- Technology stack information
- Development workflow guidance
- Spec Kit command definitions
- Project constitution and principles
- MCP server integrations
- AgentDB memory system

**Knowledge Encoded**:
- Repository architecture patterns
- Development best practices
- AI-assisted workflow patterns
- Memory and learning capabilities
- Multi-agent coordination

---

### Secrets Management

**Primary Locations**:
- `.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md`
- `.github/SECRETS-QUICK-REFERENCE.md`
- `.github/SECRETS-INVENTORY.md`
- `system_config/secrets_management/`

**What's Here**:
- Complete secrets inventory
- Environment variable documentation
- 1Password integration guides
- OpNix CLI reference
- Secret rotation procedures

**Knowledge Encoded**:
- Secret management patterns
- 1Password CLI usage
- OpNix integration (planned)
- Service account management
- MCP server authentication

---

## Technology Stack Inventory

### Core Technologies (In Active Use)

**NixOS Stack**:
- NixOS (nixos-unstable)
- Nix Flakes
- home-manager (imported, temporarily disabled)
- nixos-hardware (imported, not used)
- disko (active - disk partitioning)
- nixos-anywhere (active - deployment)

**Development Tools**:
- nil (Nix LSP)
- nixpkgs-fmt (Nix formatter)
- nix-init
- nix-eval-lsp

**Shell & CLI**:
- Fish shell
- Starship prompt
- Modern CLI tools (eza, ripgrep, zoxide, etc.)

**Infrastructure**:
- OVH Cloud VPS (200GB, 8GB RAM)
- Hetzner Cloud VPS (similar specs)
- Btrfs filesystem with subvolumes
- GRUB bootloader

---

### Development Tools (Configured, Not Always Used)

**Language Runtimes** (from devShells):
- Rust (rustup, cargo, rust-analyzer, clippy)
- Node.js (18/20, yarn, pnpm)
- Python 3 (pip, virtualenv, black, pylint)
- Go (gopls, golangci-lint)

**AI/ML Tools**:
- MCP (Model Context Protocol)
- AgentDB (vector database)
- PostgreSQL (for AgentDB)
- Docker (for containerized services)

**Development Infrastructure**:
- GitHub Copilot
- Dev Containers
- VS Code (configured)

---

### Planned Technologies (Imported But Not Configured)

**Secrets Management**:
- OpNix (imported in flake, not configured)
- 1Password (documented, not integrated in configs)

**Home Management**:
- home-manager (imported, commented out to reduce closure size)

**Hardware Support**:
- nixos-hardware (imported, not used)

**Monitoring** (documented in examples, not configured):
- Datadog agent
- Tailscale (mentioned in deploy script)

---

### Aspirational Technologies (Documented, Not Implemented)

**Desktop Environment** (desktop_environment/ docs):
- Niri (Wayland compositor)
- DankMaterialShell (desktop shell)
- Quickshell
- Hyprland
- Various GUI applications

**AI Infrastructure** (ai_infrastructure/ docs):
- AgentDB-OpenCode integration
- Agentic-flow
- MiniMax M2
- Documentation scraping system
- hbohlenOS PKM system

---

## Repository Health Assessment

### Strengths ✅

1. **Clean Core Implementation**
   - Minimal, working NixOS configuration
   - Good use of modern Nix features (flakes, disko)
   - Declarative and reproducible

2. **Excellent Operational Documentation**
   - Comprehensive secrets management docs
   - Clear deployment guides
   - Good hardware documentation

3. **Strong AI Integration**
   - GitHub Copilot instructions
   - MCP server integration
   - Spec Kit framework
   - AgentDB for agent memory

4. **Good Development Experience**
   - Multiple devShells for different languages
   - Dev Container support
   - Nix-based reproducible environments

5. **Modern Deployment**
   - nixos-anywhere for remote installation
   - Automated deployment scripts
   - SSH key-based security

---

### Weaknesses ⚠️

1. **Documentation Sprawl**
   - 83 documentation files across 18 directories
   - 27 files are duplicates
   - Mixed implemented vs aspirational content
   - No clear organization strategy

2. **Duplication Problem**
   - 9 Spec Kit agent files duplicated 3x each (27 total files)
   - Unclear canonical source
   - Potential for sync issues
   - Wastes space and creates confusion

3. **Aspirational Content Confusion**
   - 13 files documenting unimplemented features
   - Can mislead users about what exists
   - May become stale
   - Should be archived separately

4. **Limited Modularity**
   - No modular architecture (documented but not implemented)
   - Two similar host configs without shared modules
   - Code duplication between hosts
   - Difficult to scale to more hosts

5. **Incomplete Secrets Integration**
   - OpNix imported but not configured
   - 1Password documented but not integrated
   - Secrets management is manual

6. **Minimal Inline Documentation**
   - Nix files have very few comments
   - Self-documenting code approach
   - Could benefit from more architectural comments

---

### Opportunities 🎯

1. **Documentation Consolidation**
   - Move all docs to /docs/ directory
   - Remove duplicates
   - Archive aspirational content
   - Create clear hierarchy

2. **Modular Architecture**
   - Extract common configuration
   - Create reusable modules
   - Share configuration between hosts
   - Implement profiles layer

3. **Secrets Management**
   - Complete OpNix integration
   - Automate 1Password integration
   - Use secrets in configurations
   - Document production patterns

4. **Testing & Validation**
   - Add NixOS tests
   - CI/CD for configuration validation
   - Automated deployment testing
   - Documentation linting

5. **Examples & Snippets**
   - Organize code_snippets/ better
   - Create runnable examples
   - Integration with actual configs
   - Community contributions

---

### Threats 🚨

1. **Documentation Rot**
   - Large volume increases maintenance burden
   - Duplicates can get out of sync
   - Aspirational docs may become stale
   - Without CI, links may break

2. **Complexity Creep**
   - Temptation to implement all documented features
   - Risk of over-engineering
   - Maintenance burden increases
   - Deviation from minimal approach

3. **Duplication Management**
   - Three copies of Spec Kit agents
   - Manual sync required
   - Risk of divergence
   - Wastes CI/CD resources

4. **Knowledge Silos**
   - Information spread across many locations
   - Hard to find canonical information
   - Multiple overlapping guides
   - Confusing for new contributors

---

## Configuration Knowledge Patterns

### Pattern 1: Single-Host Configuration

**Current State**: Each host has independent configuration files

**Files**:
- `hosts/servers/ovh-cloud/configuration.nix`
- `hosts/servers/hetzner-cloud/configuration.nix`

**Knowledge**:
- Both hosts have nearly identical configuration
- Differences: hostname, disk device, SSH keys (same)
- Opportunity for shared base configuration
- Could extract common server profile

**Recommendation**: Create `profiles/base-server.nix` module

---

### Pattern 2: Disk Configuration

**Current State**: disko configuration for declarative disk setup

**Files**:
- `hosts/servers/ovh-cloud/disko.nix`
- `hosts/servers/hetzner-cloud/disko.nix`

**Knowledge**:
- Btrfs with subvolumes (root, home, var)
- ESP + boot + main partition layout
- VM optimizations (no autodefrag, ssd instead of ssd_spread)
- Notable: uses /dev/sdb instead of /dev/sda (commented in ovh-cloud/disko.nix)

**Recommendation**: Document why /dev/sdb is used

---

### Pattern 3: Security Configuration

**Current State**: SSH key-only authentication

**Files**:
- `hosts/servers/*/configuration.nix` (SSH config)
- `.github/SECRETS-*.md` (documentation)

**Knowledge**:
- No root login
- No password authentication
- 4 authorized SSH keys (Yoga, Phone, Desktop, Zephyrus)
- Wheel group has passwordless sudo

**Recommendation**: Document SSH key rotation procedures

---

### Pattern 4: Development Shells

**Current State**: 8 devShells defined in flake.nix

**Files**:
- `flake.nix` (devShells outputs)

**Knowledge**:
- default: General development (git, neovim, fish, starship, direnv, nil, nixpkgs-fmt)
- nix: Nix-specific development
- rust, node, python, go: Language-specific shells
- mcp: MCP-enabled AI development (Node.js, PostgreSQL, Docker, Nix tools)
- ai: AI infrastructure development (Python, databases, MCP support)

**Recommendation**: Document when to use each shell

---

### Pattern 5: Deployment Automation

**Current State**: deploy.sh script for nixos-anywhere

**Files**:
- `deploy.sh`
- `DEPLOYMENT.md`

**Knowledge**:
- Uses nixos-anywhere for remote installation
- Supports SSH key or password auth
- Requires OP_SERVICE_ACCOUNT_TOKEN env var
- Validates configuration before deployment
- Provides post-deployment instructions

**Recommendation**: Add rollback procedures

---

## Recommended Reorganization

### Phase 1: Remove Duplicates and Obsolete Content

**Remove** (27 files):
- `.opencode/command/speckit.*.md` (9 files - duplicates of .github/agents/)
- `.specify/templates/commands/*.md` (9 files - duplicates of .github/agents/)
- `ai_infrastructure/*` (10 files - unimplemented planning docs)
- `desktop_environment/*` (3 files - unimplemented desktop docs)
- `OVH-DEPLOYMENT-GUIDE.md` (obsolete)
- `DISK-OPTIMIZATION.md` (unimplemented)
- `NIXOS-QUICKSTART.md` (unimplemented)
- `OPNIX-SETUP.md` (unimplemented, or mark as future)
- `PERFORMANCE-OPTIMIZATIONS.md` (planning only)

**Result**: 83 → 53 files

---

### Phase 2: Create /docs/ Structure

**Move** core documentation to /docs/:
```
/docs/
├── README.md                          # Main docs index
├── getting-started/
│   ├── README.md                      # Quick start
│   └── deployment.md                  # From DEPLOYMENT.md
├── reference/
│   ├── configuration.md               # From CONFIGURATION-SUMMARY.md
│   ├── architecture.md                # From system_config/03_PANTHEROS_NIXOS_BRIEF.md
│   └── hardware-profiles/
│       ├── ovh-cloud-vps.md
│       ├── hetzner-cloud-vps.md
│       └── yoga-workstation.md
├── guides/
│   ├── secrets-management.md          # Consolidated from .github/ and system_config/
│   ├── mcp-setup.md                   # From .github/MCP-SETUP.md
│   └── implementation.md              # From system_config/implementation_guides/
├── examples/
│   └── nixos-configurations/          # From code_snippets/
├── architecture/
│   ├── decisions/
│   │   └── constitution.md            # From .specify/memory/
│   └── diagrams/                      # From architecture/
├── specs/                             # Keep as-is, or move to /docs/specs/
└── contributing/
    ├── README.md
    └── copilot-context.md             # From .github/copilot-instructions.md
```

**Keep in root**:
- README.md (points to /docs/)
- 00_MASTER_TOPIC_MAP.md (updated to reflect new structure)

**Keep in .github/**:
- agents/
- devcontainer.json
- mcp-servers.json

**Keep in .specify/**:
- README.md
- memory/
- scripts/
- templates/ (but remove commands/ subdirectory)

---

### Phase 3: Extract Common Modules

**Create** `modules/` or `profiles/` directory:
```
modules/
├── base/
│   ├── networking.nix
│   ├── users.nix
│   ├── security.nix
│   └── packages.nix
└── profiles/
    ├── server-base.nix
    └── workstation-base.nix
```

**Refactor** host configurations to use modules

---

### Phase 4: Add Missing Documentation

**Create**:
- Troubleshooting guide
- FAQ
- Rollback procedures
- Testing documentation
- Contribution guidelines
- Changelog

---

## Next Steps

See the "Next Suggested Agents" section in `doc_inventory.md` for detailed action items:

1. **Pruning/Noise Analysis Agent** - Remove duplicates and obsolete docs
2. **/docs Target Structure Design Agent** - Design and implement new structure
3. **Gap Analysis Agent** - Identify missing documentation
4. **Documentation Consolidation Agent** - Merge overlapping docs
5. **Documentation Linting Agent** - Ensure consistency and quality

---

**End of Structure Overview**
