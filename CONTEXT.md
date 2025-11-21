# pantherOS Project Context

**Last Updated:** 2025-11-21  
**Version:** 1.0.0  
**Status:** Active Development - Phase 2 (Module Development)

## Project Overview

pantherOS is a comprehensive, multi-host NixOS configuration for personal developer infrastructure. This repository manages configurations for multiple workstations and servers with a modular, flake-based approach.

### 🎯 Core Goals
- Declarative configuration for all hosts
- Modular design for maintainability  
- Reproducible across different hardware
- Optimized for solo developer workflows
- Zero configuration drift

### 🖥️ Managed Hosts

#### Workstations
- **yoga** - Lenovo Yoga 7 2-in-1 (battery-optimized, lightweight development)
- **zephyrus** - ASUS ROG Zephyrus M16 (performance workstation, heavy development workflows)

#### Servers  
- **hetzner-vps** - Hetzner Cloud VPS (primary development server)
- **ovh-vps** - OVH Cloud VPS (secondary server)

### 🏗️ Architecture Principles

- **Single Concern Modules** - Each module has one well-defined purpose
- **Hardware Separation** - Hardware-specific configs isolated in `hardware.nix` files
- **Declarative Disk Management** - All disk layouts defined with Disko
- **Secrets Management** - 1Password service account with OpNix integration
- **Security First** - All systems behind Tailscale Tailnet with proper firewall configuration

### 📁 Directory Structure

```
pantherOS/
├── docs/                  # Documentation
│   ├── architecture/         # System design decisions
│   ├── guides/            # Step-by-step guides
│   ├── hardware/           # Hardware specifications
│   ├── modules/            # Module-specific docs
│   ├── plans/              # Implementation plans
│   └── todos/              # Task tracking
├── hosts/                  # Host-specific configurations
│   ├── yoga/              # Lenovo Yoga workstation
│   ├── zephyrus/           # ASUS ROG workstation  
│   └── servers/            # Server configurations
│       ├── hetzner-vps/    # Hetzner Cloud VPS
│       └── ovh-vps/         # OVH Cloud VPS
├── modules/                # Modular configurations
│   ├── nixos/             # System-level modules
│   ├── home-manager/        # User-level modules
│   └── shared/              # Shared utilities
├── openspec/               # OpenSpec change proposals
│   ├── changes/             # Active proposals
│   └── project.md           # Project conventions
└── scripts/                # Automation scripts
```

### 📋 Current Phase Status

#### ✅ Phase 1: Hardware Discovery (COMPLETE)
- All 4 hosts documented with hardware specifications
- Hardware discovery scripts created and tested
- System overview files generated for each host

#### 🔄 Phase 2: Module Development (IN PROGRESS)
- Core system modules implemented
- Home-manager modules created
- Shared utilities developed
- **Current Focus:** Security hardening, Btrfs impermanence, AI tools integration

#### ⏳ Phase 3: Host Configuration (PENDING)
- Apply modules to host configurations
- Optimize per-host settings
- Complete deployment testing

### 🛠️ Technology Stack

#### Core Technologies
- **NixOS** - Declarative Linux distribution
- **Flakes** - Reproducible configuration management
- **Disko** - Declarative disk management
- **Home-Manager** - User environment management

#### Filesystem
- **Btrfs** - Primary filesystem with subvolumes
- **LUKS** - Full disk encryption
- **Impermanence** - Clean system state management

#### Networking & Security
- **Tailscale** - Mesh VPN for secure connectivity
- **Firewall** - Network security controls
- **1Password + OpNix** - Secrets management

#### Development Environment
- **Fish Shell** - User-friendly command line
- **Ghostty/Zed** - Modern terminal and editor
- **AI Tools** - nix-ai-tools integration
- **Podman** - Container management

### 📊 Key Metrics

#### Configuration Coverage
- **Hosts:** 4/4 configured (100%)
- **Hardware Docs:** 4/4 complete (100%)
- **Core Modules:** 80% implemented
- **Security Features:** Basic implementation, needs hardening

#### Development Status
- **Total Tasks:** 47 tasks across all phases
- **Completed:** 31 tasks (66%)
- **In Progress:** 8 tasks (17%)
- **Pending:** 8 tasks (17%)

### 🔄 Recent Changes (Last 30 Days)

#### 2025-11-21
- **Security Hardening Research:** Completed comprehensive research via Brave Search and Context7
- **Btrfs Impermanence Research:** Identified modern practices and snapshot automation
- **AI Tools Integration:** Researched nix-ai-tools ecosystem integration
- **OpenSpec Proposals Created:** 3 new proposals for missing capabilities
- **Documentation Audit:** Completed full audit and cleanup plan

#### Active OpenSpec Proposals
1. **security-hardening-improvements** - High priority
2. **btrfs-impermanence-snapshots** - High priority  
3. **ai-tools-integration** - Medium priority

### 🎯 Current Priorities

#### High Priority (This Week)
1. **Security Hardening Implementation** - Modern systemd hardening, network security
2. **Btrfs Impermanence Migration** - Snapshot automation, clean boot state
3. **Documentation Updates** - Apply 2025 best practices to all guides

#### Medium Priority (Next Week)  
1. **AI Tools Integration** - nix-ai-tools ecosystem
2. **Module Testing** - Comprehensive testing of all new modules
3. **Host Configuration Completion** - Apply all modules to hosts

### 📚 Knowledge Base

#### Best Practices Researched
- **NixOS 2025 Standards:** Flakes, modular configuration, security hardening
- **Btrfs Optimization:** SSD longevity, compression, subvolume management
- **Systemd Hardening:** Service isolation, network restrictions, file permissions
- **AI Development:** Sandboxed tools, project context awareness

#### Implementation Patterns
- **Single Concern Principle:** Each module handles one specific capability
- **Declarative Everything:** No imperative configuration after initial setup
- **Version Control:** All changes tracked and reproducible

### 🚨 Current Challenges

#### Technical Debt
- **Security:** Basic hardening only, missing modern practices
- **Filesystem:** No impermanence, manual snapshot management
- **Development:** No AI tools integration, manual environment setup

#### Knowledge Gaps
- **Systemd Service Hardening:** Need to implement configurable profiles
- **Btrfs Snapshot Automation:** Need automated rollback capabilities
- **AI Tool Sandboxing:** Need proper isolation and integration

### 🔗 External Dependencies

#### Critical Flakes
- `nixpkgs:nixos-unstable` - Core packages and modules
- `home-manager` - User environment management
- `nix-community/disko` - Disk management
- `numtide/nix-ai-tools` - AI development tools

#### Community Resources
- NixOS Wiki, NixOS Discourse, r/NixOS
- Architecture blogs and configuration repositories
- Security hardening guides and tools

### 📝 Development Guidelines

#### Module Development
- Use single-concern principle
- Provide clear options and documentation
- Test across all host types
- Follow NixOS module system patterns

#### Configuration Management
- Everything declarative, no imperative changes
- Use relative imports in flake.nix
- Separate hardware from logical configuration

#### Documentation Standards
- Update docs with implementation changes
- Use examples and scenarios
- Cross-reference between guides

### 🎉 Success Metrics

#### Configuration Completeness
- **Target:** All 4 hosts fully configured with modular approach
- **Current:** 75% complete, missing security and AI integration

#### System Readiness
- **Target:** Production-ready NixOS configurations
- **Current:** Development phase, approaching production readiness

#### Documentation Quality
- **Target:** Comprehensive guides for all aspects
- **Current:** Good coverage, needs 2025 updates

---

## 🚀 Quick Reference for Agents

### Most Important Files
- `flake.nix` - Entry point for all configurations
- `hosts/<hostname>/default.nix` - Main host configuration
- `modules/` - Reusable configuration modules
- `docs/architecture/overview.md` - System design documentation

### Current Work Context
- **Active Phase:** Module development and security integration
- **Focus Areas:** Security hardening, Btrfs impermanence, AI tools
- **Next Major Milestone:** Complete Phase 2, begin Phase 3 (host configuration)

### Decision History
- **2025-11-21:** Completed research phase, created 3 OpenSpec proposals
- **2025-11-20:** Finished Phase 1 (hardware discovery)
- **Ongoing:** Module development with 2025 best practices integration

---

*This context file is automatically generated and maintained. Update when major milestones are reached.*