# GitHub Spec Kit - Quick Reference

**Quick command reference for GitHub Spec Kit in pantherOS.**

## Installation

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install specify-cli
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Verify
specify --version
specify check
```

## Slash Commands (GitHub Copilot)

### Core Workflow
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/speckit.constitution` | Review/update project principles | Start of project or major features |
| `/speckit.specify` | Create feature specification | Define what to build |
| `/speckit.plan` | Generate implementation plan | After spec, before coding |
| `/speckit.tasks` | Break down into tasks | After plan approval |
| `/speckit.implement` | Execute implementation | When ready to build |

### Quality & Analysis
| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/speckit.clarify` | Ask clarifying questions | After initial spec, before planning |
| `/speckit.analyze` | Check consistency | After spec/plan/tasks created |
| `/speckit.checklist` | Generate QA checklist | Before implementation |
| `/speckit.taskstoissues` | Create GitHub issues | For team coordination |

## Common Workflows

### Quick Implementation
```
1. /speckit.specify [feature description]
2. /speckit.implement
```

### Full Workflow
```
1. /speckit.constitution
2. /speckit.specify [feature description]
3. /speckit.clarify
4. [Answer questions]
5. /speckit.plan
6. /speckit.analyze
7. /speckit.tasks
8. /speckit.implement
```

### Review-Heavy Workflow
```
1. /speckit.specify [feature description]
2. /speckit.clarify
3. [Answer questions]
4. /speckit.plan
5. [Review plan - make changes if needed]
6. /speckit.tasks
7. [Review tasks]
8. /speckit.checklist
9. [Review checklist]
10. /speckit.implement
```

## CLI Commands

```bash
# Validate all specs
specify check

# Validate specific spec
specify check .specify/specs/001-feature-name/

# Initialize new repository (already done for pantherOS)
# specify init . --ai copilot --here --force
```

## Directory Structure

```
.specify/
├── memory/
│   └── constitution.md          # Project principles
├── templates/
│   ├── spec-template.md         # Specification template
│   ├── plan-template.md         # Implementation plan template
│   └── tasks-template.md        # Task breakdown template
└── specs/
    └── NNN-feature-name/        # Each feature
        ├── spec.md              # Requirements
        ├── plan.md              # Technical plan
        └── tasks.md             # Task breakdown
```

## pantherOS-Specific Tips

### For NixOS Configurations
- Specifications should describe **system state**, not code
- Plans should reference **NixOS modules** and options
- Tasks should include `nix build` validation steps
- Follow the pantherOS constitution principles

### Example NixOS Feature Request
```
/speckit.specify Add Nginx web server with:
- Declarative virtual host configuration
- Let's Encrypt SSL certificates
- Automatic renewal
- Integration with existing firewall rules
- Monitoring endpoint for health checks
```

### Testing
```bash
# Build configuration
nix build .#nixosConfigurations.ovh-cloud

# Test in VM
nixos-rebuild build-vm --flake .#ovh-cloud

# Check flake
nix flake check
```

## Troubleshooting

### specify not found
```bash
# Add to PATH
export PATH="$HOME/.local/bin:$PATH"

# Or use uv directly
uv tool run specify check
```

### Python version error
```bash
# Use NixOS development shell
nix develop .#mcp
python3 --version  # Should be 3.11+
```

### Devcontainer missing tools
```bash
# In container terminal
uv --version
specify --version

# If missing, run manually:
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

## Documentation Links

- **[Complete Guide](spec-kit.md)** - Full integration documentation
- **[Practical Examples](spec-kit-examples.md)** - Real-world workflows
- **[Devcontainer Guide](../../.github/devcontainer-readme.md)** - Container setup
- **[pantherOS Constitution](../../.specify/memory/constitution.md)** - Project principles

## Environment Setup

### In Devcontainer (Automatic)
Everything is pre-installed. Just open in VS Code container.

### Local Machine
```bash
# 1. Install prerequisites
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Install Spec Kit
export PATH="$HOME/.local/bin:$PATH"
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 3. Verify
specify check
```

### NixOS Development Shell
```bash
# Enter shell
nix develop .#mcp

# Install tools (not in Nix by default)
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
```

## Key Principles

1. **Specification First** - Define what before how
2. **Clarify Early** - Use `/speckit.clarify` for complex features
3. **Review Plans** - Check implementation approach before coding
4. **Test Incrementally** - Build and test after each task
5. **Document Always** - Include docs in implementation phase

## Example Copilot Session

```
User: I want to add PostgreSQL database support. Use Spec Kit.

Copilot: I'll help you develop this feature using Spec Kit...
         [runs /speckit.constitution]
         [runs /speckit.specify]
         [runs /speckit.clarify]
         
         Please answer these clarification questions:
         1. What PostgreSQL version?
         2. Backup strategy?
         [etc...]

User: [provides answers]

Copilot: [updates spec]
         [runs /speckit.plan]
         [runs /speckit.tasks]
         
         Ready to implement. Shall I proceed?

User: Yes

Copilot: [runs /speckit.implement]
         Implementation complete!
```

---

**Last Updated:** 2025-11-17  
**Version:** 1.0.0  
**See Also:** [Full Documentation](spec-kit.md) | [Examples](spec-kit-examples.md)
