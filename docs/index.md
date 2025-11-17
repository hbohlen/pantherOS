# pantherOS Documentation Index

Welcome to the pantherOS documentation hub. This page provides an organized overview of all documentation resources in the repository.

## Quick Links

- [Main README](../README.md) - Repository overview and quick start
- [Master Topic Map](../00_MASTER_TOPIC_MAP.md) - Complete documentation index
- [Deployment Guide](../DEPLOYMENT.md) - How to deploy pantherOS configurations

## Documentation by Category

### Development Tools & Workflows

#### Spec-Driven Development
- **[GitHub Spec Kit Integration Guide](tools/spec-kit.md)** ⭐ New!
  - Complete guide for using Spec Kit with pantherOS
  - Installation instructions for uv and specify-cli
  - Detailed command reference with examples
  - Agent usage guide for GitHub Copilot
  - NixOS-specific considerations
  - Troubleshooting common issues
- **[Spec Kit Quick Reference](tools/spec-kit-quick-reference.md)** ⭐ New!
  - Fast command reference and cheat sheet
  - Common workflows at a glance
  - Installation quick start
  - Troubleshooting shortcuts
- **[Spec Kit Practical Examples](tools/spec-kit-examples.md)** ⭐ New!
  - Real-world feature development workflows
  - Complete PostgreSQL implementation example
  - Quick specification examples
  - Iterative development patterns
  - Common workflow templates

#### AI Development & MCP Servers
- [MCP Setup Guide](../.github/MCP-SETUP.md) - Model Context Protocol server configuration
- [MCP Verification Report](../.github/MCP-VERIFICATION-REPORT.md) - Comprehensive MCP validation
- [GitHub Copilot Instructions](../.github/copilot-instructions.md) - Copilot integration guide
- [Secrets & Environment Variables](../.github/SECRETS-QUICK-REFERENCE.md) - Environment setup

### System Configuration

#### NixOS Configuration
- [Configuration Brief](../system_config/03_PANTHEROS_NIXOS_BRIEF.md) - Complete architecture overview
- [Configuration Summary](../CONFIGURATION-SUMMARY.md) - Current system state
- [System Specifications](../SYSTEM-SPECS.md) - Hardware and software specs

#### Host Profiles
- [OVH Cloud VPS Profile](../OVH%20Cloud%20VPS%20-%20System%20Profile.md) - OVH server configuration
- [Hetzner Cloud VPS Profile](../Hetzner%20Cloud%20VPS%20-System%20Profile.md) - Hetzner server configuration
- [Yoga Profile](../Yoga%20-%20System%20Profile.md) - Laptop configuration

### Deployment & Operations

#### Deployment Guides
- [Deployment Guide](../DEPLOYMENT.md) - General deployment instructions
- [OVH Deployment Guide](../OVH-DEPLOYMENT-GUIDE.md) - OVH-specific deployment
- [Disk Optimization](../DISK-OPTIMIZATION.md) - Disk configuration and optimization
- [NixOS Quickstart](../NIXOS-QUICKSTART.md) - Quick reference for NixOS commands

#### Performance & Optimization
- [Performance Optimizations](../PERFORMANCE-OPTIMIZATIONS.md) - System optimization techniques

### Security & Secrets

- [OpNix Setup](../OPNIX-SETUP.md) - 1Password secrets management
- [Secrets Inventory](../.github/SECRETS-INVENTORY.md) - Complete secrets catalog
- [Secrets Documentation](../.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md) - Full secrets guide

### AI Infrastructure (Planning)

These documents contain planning and design work for future features:

- [Master Project Plans](../ai_infrastructure/00_MASTER_PROJECT_PLANS.md)
- [AgentDB Integration Plan](../ai_infrastructure/01_agentdb_integration_plan.md)
- [Documentation Analysis Plan](../ai_infrastructure/02_documentation_analysis_plan.md)
- [Documentation Scraper Plan](../ai_infrastructure/03_documentation_scraper_plan.md)
- [hbohlenOS Design Plan](../ai_infrastructure/04_hbohlenOS_design_plan.md)
- [MiniMax Optimization Plan](../ai_infrastructure/05_minimax_optimization_plan.md)
- [Agentic Flow Integration](../ai_infrastructure/06_agentic_flow_integration.md)
- [pantherOS Research Plan](../ai_infrastructure/pantherOS_research_plan.md)
- [Gap Analysis Progress](../ai_infrastructure/pantherOS_gap_analysis_progress.md)

### Desktop Environment (Planning)

These documents describe the planned "Dank Linux" desktop environment (not yet implemented):

- [Dank Linux Master Guide](../desktop_environment/00_dank_linux_master_guide.md)
- [Installation Guide](../desktop_environment/02_installation_guide.md)
- [Keybindings Reference](../desktop_environment/04_keybindings_reference.md)

### Code Examples

- [Code Snippets Index](../code_snippets/system_config/CODE_SNIPPETS_INDEX.md)
- NixOS Examples:
  - [Battery Management](../code_snippets/system_config/nixos/battery-management.nix.md)
  - [Security Hardening](../code_snippets/system_config/nixos/security-hardening.nix.md)
  - [Browser Configuration](../code_snippets/system_config/nixos/browser.nix.md)
  - [NVIDIA GPU](../code_snippets/system_config/nixos/nvidia-gpu.nix.md)
  - [Datadog Agent](../code_snippets/system_config/nixos/datadog-agent.nix.md)

### Specifications & Planning

- [Spec Kit README](../.specify/README.md) - Spec Kit configuration overview
- [pantherOS Constitution](../.specify/memory/constitution.md) - Project principles
- [Feature Specifications](../.specify/specs/) - Individual feature specs

## Documentation Status Legend

- ✅ **Active** - Current and actively maintained
- ⚠️ **Planning** - Future work, not yet implemented
- 📦 **Archived** - Historical reference, may be outdated

## Getting Started

### For New Contributors

1. Start with the [Main README](../README.md)
2. Review the [pantherOS Constitution](../.specify/memory/constitution.md)
3. Set up your development environment:
   - Follow [MCP Setup Guide](../.github/MCP-SETUP.md)
   - Read [Spec Kit Integration Guide](tools/spec-kit.md)
4. Explore example configurations in `hosts/`

### For AI Agents (GitHub Copilot, etc.)

1. Review [GitHub Copilot Instructions](../.github/copilot-instructions.md)
2. Understand [Spec-Driven Development workflow](tools/spec-kit.md#agent-usage-guide)
3. Check [pantherOS Constitution](../.specify/memory/constitution.md) for project principles
4. Use [Master Topic Map](../00_MASTER_TOPIC_MAP.md) to navigate documentation

### For System Administrators

1. Review [Deployment Guide](../DEPLOYMENT.md)
2. Check relevant host profile (OVH, Hetzner, or Yoga)
3. Understand [NixOS Configuration Brief](../system_config/03_PANTHEROS_NIXOS_BRIEF.md)
4. Set up secrets following [OpNix Setup](../OPNIX-SETUP.md)

## Contributing to Documentation

Documentation contributions are welcome! Please follow these guidelines:

### Documentation Standards

1. **Use Markdown** - All documentation in `.md` format
2. **Update Index** - Add new docs to this index and [Master Topic Map](../00_MASTER_TOPIC_MAP.md)
3. **Include Metadata** - Add "Last Updated" date and version to new docs
4. **Cross-Reference** - Link related documentation
5. **Use Examples** - Include code examples and command snippets
6. **Status Indicators** - Mark planning vs. implemented features

### File Organization

- `/docs/` - General documentation (this directory)
- `/docs/tools/` - Tool-specific guides
- `/docs/tutorials/` - Step-by-step tutorials (create as needed)
- `/docs/reference/` - Reference documentation (create as needed)
- `/.github/` - GitHub-specific docs (MCP, secrets, CI/CD)
- `/.specify/` - Spec Kit configuration and specifications
- `/system_config/` - System configuration documentation
- Root directory - High-level guides and profiles

### Documentation Workflow

1. Create or update documentation
2. Update this index (`docs/index.md`)
3. Update [Master Topic Map](../00_MASTER_TOPIC_MAP.md)
4. Submit PR with clear description
5. Request review from maintainers

## Search Tips

- **By Topic**: Use the category sections above
- **By File Type**: Check relevant directories (`/docs/`, `/.github/`, etc.)
- **By Status**: Look for ✅ Active, ⚠️ Planning, or 📦 Archived indicators
- **Full Text**: Use GitHub's repository search or `ripgrep`/`grep` locally

## Maintenance

This documentation index is maintained as part of the pantherOS project. If you find:

- **Broken Links**: Submit an issue or PR to fix
- **Missing Documentation**: Request new docs via issue
- **Outdated Information**: Submit PR with updates
- **Unclear Content**: Request clarification via issue or discussion

## External Resources

### NixOS
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOS Wiki](https://nixos.wiki/)

### Home Manager
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)

### Tools & Dependencies
- [GitHub Spec Kit](https://github.com/github/spec-kit)
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
- [disko](https://github.com/nix-community/disko)
- [OpNix](https://github.com/brizzbuzz/opnix)

---

**Last Updated:** 2025-11-17  
**Maintainer:** pantherOS Project  
**Version:** 1.0.0
