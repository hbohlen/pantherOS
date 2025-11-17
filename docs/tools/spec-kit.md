# GitHub Spec Kit Integration Guide

This guide explains how to use [GitHub Spec Kit](https://github.com/github/spec-kit) for Spec-Driven Development in the pantherOS repository.

## Table of Contents

- [What is Spec Kit?](#what-is-spec-kit)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Available Commands](#available-commands)
- [Agent Usage Guide](#agent-usage-guide)
- [NixOS-Specific Considerations](#nixos-specific-considerations)
- [Troubleshooting](#troubleshooting)
- [Practical Examples](spec-kit-examples.md) ⭐ Real-world workflows and examples

## What is Spec Kit?

Spec Kit enables Spec-Driven Development (SDD) - a methodology that inverts traditional software development by making specifications executable. Instead of code-first development, you define clear specifications that directly generate working implementations.

**Key Benefits:**
- **Specifications become executable** - they directly generate working implementations
- **Intent drives development** - define the "what" and "why" before the "how"
- **Multi-step refinement** - structured process from requirements to implementation
- **AI-assisted workflow** - leverage AI capabilities for specification interpretation

## Installation

### Prerequisites

- **Python 3.11 or later** - Required for specify-cli
- **uv** - Fast Python package installer and tool runner
- **Git** - Version control (already installed in most environments)

### Installing uv

`uv` is a fast Python package installer and tool runner. Choose one of the following methods:

#### Option 1: Using the official installer (Recommended)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

#### Option 2: Using pip
```bash
pip install uv
```

#### Option 3: Using homebrew (macOS/Linux)
```bash
brew install uv
```

### Installing specify-cli

Once `uv` is installed, install the Spec Kit CLI:

```bash
# Install from the GitHub Spec Kit repository
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

**Note:** This installs `specify-cli` in an isolated environment managed by `uv`. The `specify` command will be available in your PATH after installation.

### Initializing in pantherOS (Already Done)

⚠️ **This repository is already initialized with Spec Kit.** You don't need to run this command unless you're setting up a new repository.

For reference, the initialization command used was:
```bash
# DO NOT RUN - Already configured
# specify init . --ai copilot --here --force
```

The `.specify/` directory contains:
- `memory/constitution.md` - Project principles and guidelines
- `templates/` - Specification, plan, and task templates
- `scripts/` - Helper scripts for feature management
- `specs/` - Feature specifications (created as needed)

### Verifying Installation

Check that everything is installed correctly:

```bash
# Verify uv is installed
uv --version

# Verify specify-cli is installed
specify --version

# Run Spec Kit validation
specify check
```

## Quick Start

### The Spec-Driven Development Workflow

1. **Define Project Principles** (one-time setup, already done)
   ```bash
   # View the constitution
   cat .specify/memory/constitution.md
   ```

2. **Specify a New Feature**
   - Use `/speckit.specify` in GitHub Copilot Chat
   - Or create manually: `mkdir -p .specify/specs/NNN-feature-name`

3. **Create Technical Plan**
   - Use `/speckit.plan` to generate implementation plan
   - Defines modules, dependencies, and architecture

4. **Generate Task Breakdown**
   - Use `/speckit.tasks` to create actionable tasks
   - Tasks include dependencies and can be parallelized

5. **Implement the Feature**
   - Use `/speckit.implement` to execute all tasks
   - Follows the plan systematically

### Running Spec Kit Checks

Validate your specifications at any time:

```bash
# Check all specifications for consistency
specify check

# Check a specific feature
specify check .specify/specs/001-feature-name/
```

## Available Commands

### Core Workflow Commands

#### `/speckit.constitution`
**Purpose:** Create or update project governing principles

**When to use:**
- Setting up a new project
- Updating development guidelines
- Defining technology constraints
- Establishing quality standards

**Example:**
```
/speckit.constitution Update to add:
- Security scanning requirements
- Performance benchmarking standards
- Documentation quality gates
```

**Output:** Updates `.specify/memory/constitution.md`

---

#### `/speckit.specify`
**Purpose:** Define what you want to build (requirements and user stories)

**When to use:**
- Starting a new feature
- Defining system requirements
- Documenting user stories
- Clarifying acceptance criteria

**Example:**
```
/speckit.specify Add support for GNOME desktop environment with:
- Full Wayland support
- Display manager configuration (GDM)
- User session management
- Essential GNOME applications
- Declarative GNOME settings via dconf
- Integration with existing NixOS profiles
```

**Output:** Creates `.specify/specs/NNN-feature-name/spec.md`

---

#### `/speckit.plan`
**Purpose:** Create technical implementation plan with your chosen tech stack

**When to use:**
- After specification is complete
- Before starting implementation
- When architecture decisions are needed
- To identify dependencies and integration points

**Example:**
```
/speckit.plan For GNOME desktop:
- Use NixOS modules for system-wide configuration
- Integrate with home-manager for user-specific settings
- Use nixos-hardware for GPU optimizations
- Structure as Layer 2 profile (desktop/gnome/)
- Ensure compatibility with existing server profiles
```

**Output:** Creates `.specify/specs/NNN-feature-name/plan.md`

---

#### `/speckit.tasks`
**Purpose:** Generate actionable task breakdown for implementation

**When to use:**
- After plan is approved
- Before starting implementation
- To understand work scope and dependencies
- For project management and tracking

**Example:**
```
/speckit.tasks
```

**Output:** Creates `.specify/specs/NNN-feature-name/tasks.md` with:
- Ordered task list
- Dependencies between tasks
- Parallelization opportunities
- Testing requirements

---

#### `/speckit.implement`
**Purpose:** Execute all tasks to build the feature according to the plan

**When to use:**
- After tasks are reviewed and approved
- When ready to start implementation
- For systematic feature development

**Example:**
```
/speckit.implement
```

**Action:** AI agent executes each task in dependency order, creating code, tests, and documentation.

---

### Quality & Analysis Commands

#### `/speckit.clarify`
**Purpose:** Identify underspecified areas by asking targeted questions

**When to use:**
- After initial specification
- Before creating implementation plan
- When requirements seem ambiguous
- To reduce implementation risk

**Example:**
```
/speckit.clarify
```

**Output:** Generates clarifying questions and updates spec based on answers.

**Recommendation:** Always run this before `/speckit.plan` for complex features.

---

#### `/speckit.analyze`
**Purpose:** Cross-artifact consistency and coverage analysis

**When to use:**
- After specification, plan, and tasks are created
- Before implementation begins
- During specification review
- To identify gaps or inconsistencies

**Example:**
```
/speckit.analyze
```

**Output:** Analysis report highlighting:
- Inconsistencies between spec, plan, and tasks
- Missing requirements coverage
- Ambiguous or underspecified areas
- Potential implementation risks

---

#### `/speckit.checklist`
**Purpose:** Generate custom quality checklist for requirements validation

**When to use:**
- After specification is complete
- Before implementation review
- For QA validation scenarios
- To ensure feature completeness

**Example:**
```
/speckit.checklist Focus on:
- NixOS configuration correctness
- Reproducibility across systems
- Security best practices
- Documentation completeness
```

**Output:** Creates `.specify/specs/NNN-feature-name/checklist.md`

---

#### `/speckit.taskstoissues`
**Purpose:** Convert task breakdown into GitHub issues

**When to use:**
- After tasks are finalized
- For project management tracking
- When coordinating with team members
- To enable parallel development

**Example:**
```
/speckit.taskstoissues
```

**Action:** Creates GitHub issues from tasks with:
- Proper labels and milestones
- Dependency relationships
- Clear acceptance criteria
- Links to specification

---

## Agent Usage Guide

### For GitHub Copilot Users

GitHub Copilot can use Spec Kit commands to help you develop features systematically. Here's how to work effectively with the agent:

#### Example 1: New Feature Development

**User Request:**
```
I want to add support for automatic system backups using Restic,
backing up to Backblaze B2, with encryption and scheduled runs.
Use Spec Kit to help me develop this feature properly.
```

**Agent Response Pattern:**
1. Agent runs `/speckit.constitution` to review project principles
2. Agent runs `/speckit.specify` to create detailed specification
3. Agent runs `/speckit.clarify` to ask questions about unclear requirements
4. User answers clarification questions
5. Agent updates specification
6. Agent runs `/speckit.plan` to create technical implementation plan
7. Agent runs `/speckit.analyze` to check for gaps
8. Agent runs `/speckit.tasks` to generate task breakdown
9. Agent runs `/speckit.checklist` to create quality checklist
10. User reviews and approves
11. Agent runs `/speckit.implement` to execute implementation

#### Example 2: Strict Phase-by-Phase Development

**User Request:**
```
Help me add Tailscale VPN integration. Use Spec Kit phases strictly:
1. First create specification
2. Then plan
3. Then tasks
4. Stop before implementation so I can review
```

**Agent Response Pattern:**
1. Agent runs `/speckit.specify` with Tailscale requirements
2. Agent presents specification for review
3. User approves or requests changes
4. Agent runs `/speckit.plan` for technical approach
5. Agent presents plan for review
6. User approves or requests changes
7. Agent runs `/speckit.tasks` for task breakdown
8. Agent presents tasks and stops
9. User reviews tasks independently
10. User explicitly requests `/speckit.implement` when ready

#### Example 3: Quick Specification Without Implementation

**User Request:**
```
Create a specification for adding PostgreSQL database support,
but don't implement it yet. I want to discuss the approach first.
```

**Agent Response Pattern:**
1. Agent runs `/speckit.specify` to create specification
2. Agent runs `/speckit.clarify` if needed
3. Agent presents specification for discussion
4. Agent does NOT run `/speckit.plan` or `/speckit.implement`

### Best Practices for Working with Agents

1. **Be Explicit About Phases**
   - Clearly state which Spec Kit phase you want
   - Specify if you want to stop for review
   - Request clarification when needed

2. **Provide Context**
   ```
   When specifying Datadog monitoring integration, remember:
   - We use Nix flakes for dependency management
   - System config goes in hosts/servers/<hostname>/configuration.nix
   - We prefer minimal dependencies (see constitution)
   - Secrets must use OpNix (not implemented yet)
   ```

3. **Review and Iterate**
   - Review specifications before moving to planning
   - Review plans before generating tasks
   - Review tasks before implementation
   - Request `/speckit.analyze` to catch issues early

4. **Use Clarify Proactively**
   ```
   I want to add Docker support. First run /speckit.clarify
   to identify what decisions need to be made, then create
   the specification based on my answers.
   ```

5. **Leverage Quality Commands**
   ```
   After creating the Wireguard VPN specification and plan,
   run /speckit.analyze to check for issues, and
   /speckit.checklist to ensure we cover all security requirements.
   ```

### Example Chat Interactions

#### Complete Feature Development
```
User: I need to add ZFS filesystem support with automatic snapshots.
      Use Spec Kit to develop this feature completely.

Agent: I'll help you develop ZFS support using Spec Kit phases.
       First, let me review the project constitution...
       [runs /speckit.constitution]
       
       Based on the principles, I'll create a specification...
       [runs /speckit.specify]
       
       The specification is complete. Here's what will be implemented:
       - ZFS module configuration
       - Automatic snapshot scheduling
       - Snapshot retention policies
       - Boot environment integration
       
       Let me clarify a few points...
       [runs /speckit.clarify]
       
       1. What snapshot retention policy do you prefer?
       2. Should snapshots be sent to remote storage?
       ...
       
User: [Answers questions]

Agent: Thank you. I'll update the spec and create the plan...
       [runs /speckit.plan]
       
       Here's the implementation plan using NixOS modules...
       [shows plan]
       
       Generating tasks...
       [runs /speckit.tasks]
       
       All artifacts created. Running analysis...
       [runs /speckit.analyze]
       
       Analysis looks good. Shall I proceed with implementation?

User: Yes, go ahead.

Agent: Implementing ZFS support...
       [runs /speckit.implement]
```

#### Specification-Only Request
```
User: Create a spec for adding Prometheus monitoring, but stop
      there. I want to discuss it with my team first.

Agent: I'll create the Prometheus monitoring specification.
       [runs /speckit.specify]
       
       Here's the specification:
       [shows spec.md content]
       
       I've stopped at the specification phase as requested.
       When you're ready to proceed, let me know and I can:
       - Run /speckit.clarify for any underspecified areas
       - Create the technical plan with /speckit.plan
       - Generate tasks with /speckit.tasks
```

#### Iterative Refinement
```
User: Let's work on adding GPU acceleration for machine learning.
      Start with specification, and let me review each phase.

Agent: I'll create the GPU ML acceleration specification.
       [runs /speckit.specify]
       
       Here's the initial specification. Please review and let
       me know if any changes are needed.

User: Add CUDA Toolkit requirements and ROCm for AMD GPUs.

Agent: I'll update the specification with those requirements.
       [updates spec]
       
       Updated specification complete. Ready for planning phase?

User: Yes, create the plan.

Agent: Creating technical implementation plan...
       [runs /speckit.plan]
       
       Plan complete. It includes:
       - nixos-hardware integration
       - CUDA and ROCm setup
       - ML framework configurations
       
       Shall I generate tasks?

User: Yes, but also run analyze first.

Agent: Running consistency analysis...
       [runs /speckit.analyze]
       
       Analysis complete. Found one gap:
       - Spec mentions PyTorch but plan doesn't include it
       
       I'll update the plan to include PyTorch...
       
       Now generating tasks...
       [runs /speckit.tasks]
```

## NixOS-Specific Considerations

### Working with Nix Development Shells

pantherOS provides multiple development shells. To use Spec Kit in a Nix environment:

#### Option 1: Using the Default Shell
```bash
# Enter default development shell
nix develop

# Install uv and specify-cli (they're not in the Nix shell by default)
curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

#### Option 2: Using the MCP Development Shell
The MCP shell includes Python and development tools:
```bash
# Enter MCP development shell
nix develop .#mcp

# Install uv and specify-cli
curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

#### Option 3: Adding to Nix Shell (TODO)
Future enhancement: Add `uv` and `specify-cli` directly to the Nix development shells.

**Proposed approach:**
```nix
# In flake.nix devShells
mcp = pkgs.mkShell {
  packages = with pkgs; [
    # ... existing packages ...
    python311
    uv
    # specify-cli would need to be packaged for nixpkgs
  ];
};
```

**Blockers:**
- `specify-cli` is not yet packaged in nixpkgs
- Would need to create a Nix derivation for specify-cli
- Alternatively, could use `uv` from nixpkgs and install specify-cli in postShell hook

**Workaround:**
Until native Nix integration is available, use the manual installation method shown in Option 1 and 2 above.

### Spec Kit for NixOS Configurations

When using Spec Kit for NixOS configuration development:

1. **Specifications should describe system state**
   - Not application code, but system configuration
   - Focus on "what services/features" not "how to code them"
   - Example: "Nginx web server with Let's Encrypt" not "write nginx.conf"

2. **Plans should use NixOS patterns**
   - Reference NixOS modules and options
   - Use home-manager for user configuration
   - Consider closure size implications
   - Identify nixpkgs packages needed

3. **Tasks should align with NixOS workflow**
   - Include build validation: `nix build .#nixosConfigurations.<host>`
   - Include test scenarios when possible
   - Test in VM: `nixos-rebuild build-vm --flake .#<host>`
   - Consider rollback procedures

4. **Implementation must follow pantherOS constitution**
   - Declarative configuration only
   - Modular architecture
   - Reproducible builds
   - Security by default
   - Documentation required

### Example NixOS Feature Specification

```
Feature: PostgreSQL Database Server
User Stories:
- As a developer, I want PostgreSQL 15 installed
- As a sysadmin, I want automatic backups configured
- As a security engineer, I want SSL connections enforced

Technical Constraints:
- Use services.postgresql NixOS module
- Configuration must be declarative
- Secrets via OpNix (when available)
- Must work with existing server profiles
```

### Example NixOS Implementation Plan

```
Architecture:
- Create modules/services/postgresql.nix
- Import in server profile
- Configure via nixosModules

Integration Points:
- Existing server profile
- Backup system (if exists)
- Monitoring system (if exists)

Packages Required:
- postgresql_15 (from nixpkgs)
- pgbackrest (for backups)

Testing:
- Build: nix build .#nixosConfigurations.ovh-cloud
- Test: Create test database and connection
- Verify: Check systemd service status
```

## Troubleshooting

### specify command not found

**Problem:** After installing with `uv tool install`, the `specify` command is not available.

**Solution:**
1. Ensure uv's tool bin directory is in your PATH:
   ```bash
   # Add to your shell configuration (.bashrc, .zshrc, config.fish, etc.)
   export PATH="$HOME/.local/bin:$PATH"
   ```

2. Or use uv to run specify:
   ```bash
   uv tool run specify check
   ```

### uv installation fails

**Problem:** The uv installer script fails or is blocked.

**Solution:**
1. Try alternative installation methods (pip or homebrew)
2. Check internet connectivity and firewall settings
3. Install manually from GitHub releases:
   ```bash
   # Download from https://github.com/astral-sh/uv/releases
   # Extract and place in PATH
   ```

### specify check fails with "not a spec kit repository"

**Problem:** Running `specify check` returns an error.

**Solution:**
1. Ensure you're in the pantherOS repository root directory
2. Verify `.specify/` directory exists:
   ```bash
   ls -la .specify/
   ```
3. If `.specify/` is missing, the repository needs initialization (shouldn't happen with pantherOS)

### Python version too old

**Problem:** specify-cli requires Python 3.11+, but system has older version.

**Solution:**
1. Use the NixOS development shell which has Python 3.11:
   ```bash
   nix develop .#mcp
   python3 --version
   ```

2. Or install Python 3.11+ via package manager:
   ```bash
   # Nix
   nix-env -iA nixpkgs.python311
   
   # Homebrew
   brew install python@3.11
   ```

### Devcontainer doesn't have specify-cli

**Problem:** After rebuilding devcontainer, specify-cli is not available.

**Solution:**
1. Check if postCreateCommand ran successfully:
   ```bash
   # In devcontainer terminal
   specify --version
   ```

2. If not installed, run manually:
   ```bash
   uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
   ```

3. Check devcontainer logs for installation errors:
   - VS Code: View → Output → Dev Containers

### Nix shell doesn't persist uv/specify-cli

**Problem:** Every time you enter `nix develop`, uv and specify-cli are not available.

**Solution:**
This is expected behavior with the current setup. The Nix development shells are pure and don't include uv/specify-cli by default.

**Options:**
1. Install uv/specify-cli each time (quick with uv's caching)
2. Use the devcontainer which has persistent installation
3. Wait for native Nix packaging (future enhancement)
4. Install uv/specify-cli outside the Nix shell in your regular environment

## Additional Resources

### Spec Kit Documentation
- [GitHub Spec Kit Repository](https://github.com/github/spec-kit)
- [Spec-Driven Development Guide](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [Video Overview](https://www.youtube.com/watch?v=a9eR1xsfvHg)
- [Supported AI Agents](https://github.com/github/spec-kit#-supported-ai-agents)

### pantherOS Documentation
- **[Practical Examples](spec-kit-examples.md)** - Real-world Spec Kit workflows
- [pantherOS Constitution](../../.specify/memory/constitution.md) - Project principles
- [pantherOS Copilot Instructions](../../.github/copilot-instructions.md) - Copilot integration
- [pantherOS Master Topic Map](../../00_MASTER_TOPIC_MAP.md) - Documentation index
- [Devcontainer Guide](../../.github/devcontainer-readme.md) - Container setup

## Contributing to This Guide

If you find issues or have suggestions for this guide:

1. Check if it's a Spec Kit issue: [spec-kit/issues](https://github.com/github/spec-kit/issues)
2. For pantherOS-specific documentation issues:
   - Create an issue in the pantherOS repository
   - Submit a pull request with improvements
   - Discuss in GitHub Discussions

---

**Last Updated:** 2025-11-17  
**Version:** 1.0.0
