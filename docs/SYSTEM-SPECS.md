# pantherOS System Specifications

**Project Name:** pantherOS  
**Short Description:** Declarative NixOS configuration system using Nix Flakes for reproducible, secure VPS deployments  
**Version:** 1.0  
**Last Updated:** 2025-11-17  
**Status:** Minimal working configuration with documented expansion path

---

## Executive Summary

This document provides implementation-oriented specifications for the pantherOS NixOS configuration system. It documents the **current minimal implementation** (not aspirational architecture) and provides clear boundaries, responsibilities, and configuration surfaces for each subsystem.

**Current Implementation Status:**
- ✅ Working: Single-host NixOS flake, disko disk management, SSH-only access, development shells
- ⚠️ Disabled: home-manager (closure size), OpNix secrets (initial deployment)
- ❌ Not Implemented: Modular architecture, desktop environment, monitoring, multiple active hosts

**Document Purpose:**
- Onboarding: Understand system architecture and components
- Maintenance: Know what each unit does and doesn't do
- Extension: Add features with clear boundaries and dependencies

---

## Section 1: Spec Index

| Unit Name | Purpose | Priority | Related Files |
|-----------|---------|----------|---------------|
| **NixOS Flake Layout** | Defines system configurations, inputs, and development shells | Must-have for onboarding | `flake.nix`, `flake.lock` |
| **Host Configuration System** | Individual server system configurations | Must-have for onboarding | `hosts/servers/*/configuration.nix` |
| **Disko Disk Management** | Declarative disk partitioning and filesystem setup | Must-have for onboarding | `hosts/servers/*/disko.nix` |
| **SSH-Only Remote Access** | Secure remote access without passwords | Important for maintenance | `configuration.nix` (services.openssh) |
| **Development Shells** | Language-specific development environments | Important for maintenance | `flake.nix` (devShells) |
| **MCP Server Integration** | AI-assisted development tooling | Important for maintenance | `.github/mcp-servers.json`, `.github/MCP-SETUP.md` |
| **Deployment Workflows** | Remote and local deployment procedures | Must-have for onboarding | `deploy.sh`, `DEPLOYMENT.md` |
| **Secrets Management (Planned)** | Secure secrets handling with OpNix/1Password | Nice-to-have / future | `flake.nix` (opnix input, disabled) |
| **Home Manager (Disabled)** | User environment and dotfile management | Nice-to-have / future | `hosts/servers/*/home.nix` (not loaded) |
| **Configuration Management Strategy** | How to organize, update, and test configurations | Important for maintenance | `README.md`, system_config/ |

---

## Section 2: Detailed Specifications

The following sections provide comprehensive specifications for each subsystem unit in pantherOS.

---

### 2.1 NixOS Flake Layout

**Purpose:**  
Central flake definition that declares all system configurations, external dependencies (inputs), and development environments. Serves as the single entry point for building, deploying, and developing pantherOS.

**Responsibilities:**
- Declare nixpkgs and external flake inputs (home-manager, disko, opnix, nixos-hardware, etc.)
- Define nixosConfigurations for each host (ovh-cloud, hetzner-cloud)
- Provide development shells for multiple language ecosystems (nix, rust, node, python, go, mcp, ai)
- Pin dependency versions via flake.lock for reproducibility
- Enable unfree packages globally

**Non-Responsibilities (What This Unit Does NOT Do):**
- Does NOT contain actual system configuration (that's in host configs)
- Does NOT manage secrets directly (delegates to opnix when enabled)
- Does NOT handle disk partitioning (delegates to disko)
- Does NOT provide runtime services (only build-time configuration)

**Inputs:**
- External flake inputs from GitHub (nixpkgs, home-manager, disko, opnix, nixos-hardware, nix-ai-tools, nixos-anywhere)
- Host-specific configuration modules from `hosts/servers/*/`

**Outputs:**
- `nixosConfigurations.<hostname>`: System configurations ready to build/deploy
- `devShells.<system>.<name>`: Development environments for various languages
- `packages.<system>.default`: Default package (toplevel system build)

**Key Dependencies:**
- **Internal:** Host configuration files, disko configurations
- **External:** nixpkgs, disko, home-manager (disabled), opnix (disabled), nixos-hardware, nixos-anywhere

**Config Surface:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `nixpkgs.url` | String | `github:NixOS/nixpkgs/nixos-unstable` | NixOS package channel |
| `config.allowUnfree` | Boolean | `true` | Allow proprietary packages |
| `system` | String | `x86_64-linux` | Target system architecture |
| `modules` | List | `[configuration.nix, disko.nixosModules.default]` | NixOS modules to load |

**Invariants / Guarantees:**
- Flake.lock ensures deterministic builds across machines
- All system configurations use same nixpkgs revision (prevents version drift)
- Dev shells are pure and reproducible
- Configuration evaluation is hermetic (no impure dependencies)

**Failure Modes & Handling:**
- **Invalid flake syntax:** Nix will fail with parse error during `nix flake check`
- **Missing input:** Build fails if referenced input not in flake.lock
- **Module conflicts:** NixOS module system reports conflicting options
- **Unfree license:** Build fails unless `allowUnfree = true`
- **Recovery:** Use `nix flake check` before building, review error traces

**Open Questions:**
- When to enable home-manager? (Currently disabled due to closure size - ADR needed)
- When to enable opnix? (Currently disabled for initial deployment simplicity)
- Should we pin nixpkgs to stable vs unstable? (Currently unstable for latest packages)

**Related Docs/Files:**
- `flake.nix` (main flake definition)
- `flake.lock` (pinned dependency versions)
- `README.md` (usage instructions)
- `system_config/03_PANTHEROS_NIXOS_BRIEF.md` (architecture overview)

---

### 2.2 Host Configuration System

**Purpose:**  
Define system-level configuration for individual servers including boot, networking, users, services, packages, and security settings.

**Responsibilities:**
- Boot loader configuration (GRUB)
- Network setup (hostname, DHCP)
- User accounts and SSH keys
- System service enablement
- System-wide package installation
- Timezone, locale, console settings
- Security policies

**Non-Responsibilities:**
- Does NOT manage disk partitioning (delegates to disko.nix)
- Does NOT manage user dotfiles (would be home-manager)
- Does NOT handle secrets rotation (would be opnix)
- Does NOT configure desktop environment (not implemented)

**Related Docs/Files:**
- `hosts/servers/ovh-cloud/configuration.nix`
- `hosts/servers/hetzner-cloud/configuration.nix`
- `OVH Cloud VPS - System Profile.md`
- `Hetzner Cloud VPS -System Profile.md`

---

### 2.3 Disko Disk Management

**Purpose:**  
Declaratively define disk partitioning, filesystem layout, and mount points for NixOS installations.

**Responsibilities:**
- Partition disk into EFI, boot, and root partitions
- Create Btrfs filesystem with subvolumes (root, home, var)
- Define mount points and mount options
- Set filesystem labels

**Non-Responsibilities:**
- Does NOT handle disk encryption (not configured)
- Does NOT manage RAID or LVM (single disk setup)
- Does NOT perform backups or snapshots
- Does NOT migrate data between disks

**Related Docs/Files:**
- `hosts/servers/ovh-cloud/disko.nix`
- `hosts/servers/hetzner-cloud/disko.nix`
- `DEPLOYMENT.md`

---

### 2.4 SSH-Only Remote Access

**Purpose:**  
Provide secure, password-less remote access using SSH key authentication.

**Responsibilities:**
- Enable OpenSSH daemon
- Enforce SSH key authentication only
- Disable root login via SSH
- Configure authorized SSH keys per user

**Related Docs/Files:**
- `hosts/servers/*/configuration.nix` (services.openssh)
- `.github/SECRETS-QUICK-REFERENCE.md`

---

### 2.5 Development Shells

**Purpose:**  
Provide isolated, reproducible development environments for different programming languages.

**Available Shells:**
- `default`: General development
- `nix`: Nix development
- `rust`: Rust development
- `node`: Node.js development
- `python`: Python development
- `go`: Go development
- `mcp`: MCP/AI development
- `ai`: AI infrastructure

**Related Docs/Files:**
- `flake.nix` (devShells section)
- `.github/copilot-instructions.md`

---

### 2.6 MCP Server Integration

**Purpose:**  
Integrate Model Context Protocol (MCP) servers for AI-assisted development.

**Configured MCP Servers:**
- github, filesystem, git, brave-search, nix-search, postgres, memory, sequential-thinking, puppeteer, docker, fetch

**Related Docs/Files:**
- `.github/mcp-servers.json`
- `.github/MCP-SETUP.md`
- `.github/MCP-VERIFICATION-REPORT.md`

---

### 2.7 Deployment Workflows

**Purpose:**  
Automate deployment of NixOS configurations to remote servers and local systems.

**Deployment Methods:**
- `nixos-anywhere`: Initial VPS deployment
- `nixos-rebuild`: Local updates
- `deploy.sh`: Automated deployment script

**Related Docs/Files:**
- `deploy.sh`
- `DEPLOYMENT.md`
- `OVH-DEPLOYMENT-GUIDE.md`

---

### 2.8 Secrets Management (Planned)

**Status:** DISABLED (Temporarily disabled for initial deployment)

**Purpose:**  
Securely manage sensitive configuration data using OpNix integration with 1Password.

**Open Questions:**
- **CRITICAL:** When to enable OpNix? (Needs ADR-004 decision)
- Which secrets to migrate first?
- Alternative to OpNix? (sops-nix, agenix)

**Related Docs/Files:**
- `flake.nix` (opnix module, commented out)
- `OPNIX-SETUP.md`
- `system_config/secrets_management/`

---

### 2.9 Home Manager (Disabled)

**Status:** DISABLED (Temporarily disabled to reduce closure size)

**Purpose:**  
Manage user-specific environment, dotfiles, and packages declaratively.

**Open Questions:**
- **CRITICAL:** When to enable home-manager? (Needs ADR-003 decision)
- Is closure size still a concern?

**Related Docs/Files:**
- `flake.nix` (home-manager module, commented out)
- `hosts/servers/*/home.nix` (exist but not loaded)

---

### 2.10 Configuration Management Strategy

**Purpose:**  
Define the approach, patterns, and best practices for managing NixOS configurations.

**Current Architecture:** Minimal Monolithic
- Single configuration file per host
- No module system
- No sharing between hosts

**Planned Architecture:** Layered Modular (Not Implemented)
- Layer 1: Core modules
- Layer 2: Profiles
- Layer 3: Host configs

**Best Practices:**
1. Always run `nix flake check` before deploying
2. Test in VM before production when possible
3. Keep `system.stateVersion` unchanged after initial install
4. Never commit secrets to git
5. Pin dependencies with flake.lock

**Related Docs/Files:**
- `README.md`
- `00_MASTER_TOPIC_MAP.md`
- `system_config/03_PANTHEROS_NIXOS_BRIEF.md`
- `_analysis/gaps_and_questions.md`

---

## Section 3: Priority Summary

### Must-Have for Onboarding
1. **NixOS Flake Layout** - Entry point for entire system
2. **Host Configuration System** - Core system configuration
3. **Disko Disk Management** - Critical for deployment
4. **Deployment Workflows** - How to actually deploy

### Important for Maintenance
5. **SSH-Only Remote Access** - Daily operations and security
6. **Development Shells** - Development and testing
7. **MCP Server Integration** - Enhanced productivity
8. **Configuration Management Strategy** - How to make changes safely

### Nice-to-Have / Future
9. **Secrets Management (Planned)** - Better security (currently disabled)
10. **Home Manager (Disabled)** - Better user environment management

---

## Section 4: Implementation Roadmap

### Current State (v1.0)
- ✅ Basic NixOS flake with 2 host configs
- ✅ Disko disk management working
- ✅ SSH-only access configured
- ✅ Development shells provided
- ✅ MCP integration documented
- ✅ Basic deployment working

### Next Steps (v1.1) - Security & Usability
- [ ] Enable OpNix secrets management
- [ ] Enable home-manager (if closure size acceptable)
- [ ] Add system monitoring
- [ ] Create backup automation
- [ ] Document rollback procedures

### Future Enhancements (v2.0) - Modularity
- [ ] Implement modular architecture (ADR-002)
- [ ] Create reusable profiles
- [ ] Add hardware-specific modules
- [ ] Implement CI/CD pipeline (ADR-005)
- [ ] Multi-host orchestration

---

## Appendix A: Decision Register

Architecture Decision Records (ADRs) needed:

| ID | Decision | Status | Priority |
|----|----------|--------|----------|
| ADR-002 | Configuration Architecture (Modular vs Monolithic) | ❌ Needed | Critical |
| ADR-003 | Home Manager Usage Strategy | ❌ Needed | Important |
| ADR-004 | Secrets Management Tool Selection | ❌ Needed | Critical |
| ADR-005 | CI/CD Strategy and Tooling | ❌ Needed | Important |
| ADR-008 | Monitoring and Observability Stack | ❌ Needed | Important |
| ADR-009 | Backup and Disaster Recovery | ❌ Needed | Nice-to-have |

---

## Appendix B: Terminology

**Glossary:**
- **Flake:** Nix's unit of code distribution with pinned dependencies
- **Disko:** Declarative disk partitioning for NixOS
- **nixos-anywhere:** Tool for remote NixOS installation
- **OpNix:** Secrets management integration with 1Password
- **Home Manager:** User environment management for NixOS
- **MCP:** Model Context Protocol for AI tool integration
- **Generation:** NixOS system snapshot for rollback
- **State Version:** NixOS version at initial install (don't change)

---

## Document History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-11-17 | Initial specification document | AI Agent |

---

**End of System Specifications**

For questions, issues, or contributions, see:
- GitHub Issues: https://github.com/hbohlen/pantherOS/issues
- README: [README.md](README.md)
- Master Topic Map: [00_MASTER_TOPIC_MAP.md](00_MASTER_TOPIC_MAP.md)
