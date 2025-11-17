# pantherOS Documentation Index

Welcome to the pantherOS documentation hub. This page provides organized access to all documentation in the repository.

## 🔴 Important: Spec-First Development

**This project uses Spec-Driven Development (SDD).** Before adding features or making major changes:

1. **Check for existing specs** in [/docs/specs/](specs/)
2. **Create a spec first** if one doesn't exist (use `/speckit.specify`)
3. **Then implement** following the spec

👉 See [Spec-Driven Workflow Guide](contributing/spec-driven-workflow.md) for complete instructions.

## Quick Navigation

### 📚 Core Documentation
- **[Architecture](architecture/)** - System design and decisions
- **[How-To Guides](howto/)** - Task-oriented guides
- **[Operations](ops/)** - Deployment and hardware
- **[Infrastructure](infra/)** - NixOS tooling and concepts
- **[Examples](examples/)** - Configuration examples
- **[Reference](reference/)** - Configuration and specifications

### 🎯 For Contributors
- **[Contributing Guide](contributing/)** - How to contribute
- **[Spec-Driven Workflow](contributing/spec-driven-workflow.md)** - Development methodology
- **[Feature Specifications](specs/)** - Formal specs
- **[Tools Documentation](tools/)** - Spec Kit and other tools

## Documentation by Category

### 🏗️ Architecture & Design

**[Architecture Documentation](architecture/)**
- **[Architecture Overview](architecture/overview.md)** - System design and philosophy
- **[Architecture Decisions (ADRs)](architecture/decisions/)** - Design decisions and rationale
- **[Project Constitution](architecture/decisions/constitution.md)** - Core principles and governance

**What you'll find:**
- Design philosophy and core principles
- Technology stack and rationale
- Repository structure and organization
- Component relationships

### 📖 How-To Guides

**[How-To Guides](howto/)**
- **[Deploy a New Server](howto/deploy-new-server.md)** - Step-by-step deployment
- **[Manage Secrets](howto/manage-secrets.md)** - 1Password secrets management
- **[Setup Development](howto/setup-development.md)** - Development environment

**Task-oriented guides for:**
- Deploying pantherOS to servers
- Managing secrets and credentials
- Setting up development environment
- Common operational tasks

### 🛠️ Operations & Infrastructure

**[Operations Documentation](ops/)**
- **[Hardware Profiles](ops/)** - Server and workstation specs
  - [OVH Cloud VPS](ops/hardware-ovh-cloud.md)
  - [Hetzner Cloud VPS](ops/hardware-hetzner-cloud.md)
  - [Lenovo Yoga](ops/hardware-yoga.md)
- **Deployment procedures and maintenance**

**[Infrastructure Documentation](infra/)**
- **[NixOS Overview](infra/nixos-overview.md)** - NixOS concepts and usage
- **[Development Shells](infra/dev-shells.md)** - Development environments
- **Deployment tools (disko, nixos-anywhere)**

### 💡 Examples & Reference

**[Configuration Examples](examples/)**
- **NixOS Configuration Examples:**
  - [Battery Management](examples/nixos/battery-management.md)
  - [Browser Configuration](examples/nixos/browser-config.md)
  - [Datadog Agent](examples/nixos/datadog-agent.md)
  - [NVIDIA GPU](examples/nixos/nvidia-gpu.md)
  - [Security Hardening](examples/nixos/security-hardening.md)

**[Reference Documentation](reference/)**
- **[Configuration Summary](reference/configuration-summary.md)** - Current system state
- **[System Specifications](reference/system-specs.md)** - Hardware and software specs
- **Secrets Management:**
  - [Secrets Inventory](reference/secrets-inventory.md)
  - [Secrets & Environment Variables](reference/secrets-environment-vars.md)
  - [Secrets Quick Reference](reference/secrets-quick-reference.md)

### 🎯 Spec-Driven Development

**[Spec-Driven Workflow](contributing/spec-driven-workflow.md)** 🔴 **READ THIS FIRST**
- Complete SDD workflow with global rules
- When and how to create specs
- Using Spec Kit commands effectively
- Integration with development workflow

**[Feature Specifications](specs/)**
- All feature specs in one place
- Spec structure and organization
- How to create and maintain specs

**[Spec Kit Tools](tools/)**
- **[Spec Kit Integration Guide](tools/spec-kit.md)** - Complete guide
- **[Spec Kit Quick Reference](tools/spec-kit-quick-reference.md)** - Cheat sheet
- **[Spec Kit Examples](tools/spec-kit-examples.md)** - Real-world workflows

### 🤝 Contributing

**[Contributing Guide](contributing/)**
- How to contribute to pantherOS
- Code standards and practices
- Development workflow

**Additional Resources:**
- **[MCP Setup Guide](../.github/MCP-SETUP.md)** - Model Context Protocol configuration
- **[GitHub Copilot Instructions](../.github/copilot-instructions.md)** - AI agent guidelines

### 📦 Archive

**[Archived Documentation](archive/)**
- **[Planning Documents](archive/planning/)** - Future features and research
- **[Future Features](archive/future-features/)** - Unimplemented features

## Documentation Status Legend

- ✅ **Active** - Current and actively maintained
- ⚠️ **Planning** - Future work, not yet implemented
- 📦 **Archived** - Historical reference, may be outdated

## Getting Started

### For New Contributors

**🔴 IMPORTANT: This project uses Spec-Driven Development**

**Quick start path:**
1. Read the [Main README](../README.md)
2. **Read [Spec-Driven Workflow Guide](contributing/spec-driven-workflow.md)** 📋 (required)
3. Review the [Project Constitution](architecture/decisions/constitution.md)
4. Set up development: [Setup Development Guide](howto/setup-development.md)
5. Browse existing [Feature Specifications](specs/)
6. Make your first contribution!

**Key resources:**
- [Architecture Overview](architecture/overview.md) - Understand system design
- [How-To Guides](howto/) - Common tasks
- [Examples](examples/) - Configuration examples

### For System Administrators

**Deployment path:**
1. Review [How-To: Deploy New Server](howto/deploy-new-server.md)
2. Check hardware profile:
   - [OVH Cloud VPS](ops/hardware-ovh-cloud.md)
   - [Hetzner Cloud VPS](ops/hardware-hetzner-cloud.md)
   - [Lenovo Yoga](ops/hardware-yoga.md)
3. Set up secrets: [Manage Secrets Guide](howto/manage-secrets.md)
4. Understand [NixOS Overview](infra/nixos-overview.md)

**Quick reference:**
- [Configuration Summary](reference/configuration-summary.md) - Current configuration
- [Operations Index](ops/) - Hardware and operations
- [Reference Documentation](reference/) - Specifications and secrets

### For AI Agents (GitHub Copilot, etc.)

**⚠️ CRITICAL: Always follow Spec-Driven Development workflow**

**Required reading:**
1. [GitHub Copilot Instructions](../.github/copilot-instructions.md) - Global rules
2. [Spec-Driven Workflow](contributing/spec-driven-workflow.md) - Development methodology
3. [Project Constitution](architecture/decisions/constitution.md) - Core principles
4. [Feature Specifications](specs/) - Check before making changes

**Key rules:**
- ✅ Always check `/docs/specs/` first
- ✅ Create specs before code using `/speckit.specify`
- ✅ Reference specs in all responses
- ✅ Update `/docs` in same PR as code changes
- ✅ Generate TODOs with spec references and Spec Kit commands

**Navigation:**
- Use this index for documentation structure
- Check [Architecture](architecture/) for system design
- Review [How-To Guides](howto/) for implementation patterns

## Documentation Structure

### Directory Organization

```
/docs/
├── architecture/          # System design and decisions
│   ├── overview.md       # Architecture overview
│   └── decisions/        # ADRs and constitution
├── howto/                # Task-oriented guides
│   ├── deploy-new-server.md
│   ├── manage-secrets.md
│   └── setup-development.md
├── ops/                  # Operations and hardware
│   └── hardware-*.md     # Hardware profiles
├── infra/                # Infrastructure and tooling
│   ├── nixos-overview.md
│   └── dev-shells.md
├── examples/             # Configuration examples
│   └── nixos/           # NixOS examples
├── reference/            # Reference documentation
│   ├── configuration-summary.md
│   └── secrets-*.md
├── specs/                # Feature specifications
├── tools/                # Tool documentation
├── contributing/         # Contribution guides
└── archive/              # Historical/planning docs
```

### Documentation Standards

**For contributors creating new documentation:**

1. **Follow Spec-Driven Development** - Create spec first for major docs
2. **Use Standard Template** - Include category, audience, last updated date
3. **Keep Files Focused** - One major concept per file (~150-200 lines)
4. **Add Cross-References** - Link related documentation (max 3-5 links)
5. **Update Indexes** - Add new docs to relevant index.md files
6. **Include Examples** - Code examples and command snippets
7. **Add Troubleshooting** - Common issues and solutions

**File format:**
```markdown
# Document Title

> **Category:** Architecture|How-To|Operations|Reference  
> **Audience:** Target users  
> **Last Updated:** YYYY-MM-DD

[Content]

## See Also
- [Related Doc](../path/doc.md)
```

## Finding Documentation

### By Purpose

- **Understanding the system** → [Architecture](architecture/)
- **Doing a task** → [How-To Guides](howto/)
- **Deploying/operating** → [Operations](ops/)
- **Learning NixOS** → [Infrastructure](infra/)
- **Looking for examples** → [Examples](examples/)
- **Looking up details** → [Reference](reference/)
- **Contributing** → [Contributing](contributing/)

### Search Methods

- **GitHub Search** - Use GitHub's search within the repository
- **Local Search** - `ripgrep` or `grep` in `/docs` directory
- **Index Files** - Check `index.md` in each directory
- **Cross-References** - Follow "See Also" links at bottom of docs

## External Resources

### NixOS Documentation

- **[NixOS Manual](https://nixos.org/manual/nixos/stable/)** - Official documentation
- **[Nix Package Search](https://search.nixos.org/)** - Find packages and options
- **[NixOS Wiki](https://nixos.wiki/)** - Community documentation
- **[Nix Pills](https://nixos.org/guides/nix-pills/)** - Deep dive into Nix

### Tools

- **[GitHub Spec Kit](https://github.com/github/spec-kit)** - Spec-driven development
- **[nixos-anywhere](https://github.com/nix-community/nixos-anywhere)** - Remote installation
- **[disko](https://github.com/nix-community/disko)** - Disk partitioning
- **[Home Manager](https://nix-community.github.io/home-manager/)** - User environment

### Community

- **[NixOS Discourse](https://discourse.nixos.org/)** - Forums and discussions
- **[NixOS Matrix](https://matrix.to/#/#nixos:nixos.org)** - Real-time chat
- **[r/NixOS](https://www.reddit.com/r/NixOS/)** - Reddit community

## Maintenance & Contributions

### Reporting Issues

- **Broken Links** - Submit issue or PR to fix
- **Missing Documentation** - Request via GitHub issue
- **Outdated Information** - Submit PR with updates
- **Unclear Content** - Open discussion or issue

### Contributing

1. Follow [Contributing Guidelines](contributing/)
2. Use [Spec-Driven Workflow](contributing/spec-driven-workflow.md)
3. Create spec for major documentation additions
4. Update relevant index.md files
5. Submit PR with clear description

---

**Last Updated:** 2025-11-17  
**Documentation Version:** 2.0.0  
**Maintainer:** pantherOS Project
