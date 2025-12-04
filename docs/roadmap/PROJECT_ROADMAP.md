# PantherOS Project Roadmap

> **Last Updated:** 2025-12-04  
> **Status:** Active Development  
> **Project Type:** NixOS Configuration Management

## Executive Summary

PantherOS is a comprehensive NixOS-based system configuration project managing multiple hosts (servers and personal devices) with a focus on declarative configuration, automation, and developer experience. This roadmap outlines the strategic direction, current progress, and planned work across all system components.

## Project Goals

### Core Goals
- **Declarative Infrastructure**: Manage all system configurations through Nix flakes
- **Multi-Host Support**: Support servers (Hetzner, OVH, Contabo) and personal devices (Zephyrus, Yoga)
- **Developer Experience**: Provide excellent tooling and automation for development workflows
- **Security**: Implement secure secrets management and hardened configurations
- **Automation**: CI/CD pipelines for testing and deployment

### Non-Goals
- Gaming optimization (explicitly excluded)
- Multi-cloud orchestration (deferred to later phases)
- Desktop application management beyond development tools

## Architecture Overview

```mermaid
graph TB
    subgraph "Configuration Layer"
        Flake[flake.nix<br/>Central Configuration]
        Modules[Modules<br/>Reusable Components]
        Specs[OpenSpec<br/>Requirements & Design]
    end
    
    subgraph "Host Types"
        Servers[Servers<br/>Hetzner, OVH, Contabo]
        Personal[Personal Devices<br/>Zephyrus, Yoga]
    end
    
    subgraph "Infrastructure Services"
        Secrets[1Password + OpNix<br/>Secrets Management]
        CI[GitHub Actions<br/>CI/CD Pipeline]
        Cache[Binary Cache<br/>Build Optimization]
    end
    
    subgraph "Development Tools"
        Shell[Fish Shell<br/>Terminal Environment]
        Editor[Neovim + Zed<br/>Code Editors]
        AI[OpenCode AI<br/>AI Assistance]
    end
    
    Flake --> Modules
    Modules --> Servers
    Modules --> Personal
    Specs --> Flake
    
    Servers --> Secrets
    Personal --> Secrets
    
    CI --> Servers
    CI --> Cache
    Cache --> Servers
    
    Personal --> Shell
    Personal --> Editor
    Personal --> AI
```

## System Components

```mermaid
graph LR
    subgraph "Server Infrastructure"
        Hetzner[Hetzner VPS<br/>Production]
        OVH[OVH VPS<br/>Staging]
        Contabo[Contabo VPS<br/>Staging]
    end
    
    subgraph "Personal Devices"
        Zephyrus[ASUS Zephyrus<br/>Development Laptop]
        Yoga[Lenovo Yoga<br/>Development Laptop]
    end
    
    subgraph "Shared Services"
        Tailscale[Tailscale<br/>Mesh Network]
        OnePass[1Password<br/>Secrets]
        DNS[Cloudflare DNS]
    end
    
    Hetzner -.-> Tailscale
    OVH -.-> Tailscale
    Contabo -.-> Tailscale
    Zephyrus -.-> Tailscale
    Yoga -.-> Tailscale
    
    Hetzner --> OnePass
    OVH --> OnePass
    Contabo --> OnePass
    Zephyrus --> OnePass
    Yoga --> OnePass
    
    DNS --> Hetzner
```

## Phases and Milestones

### Phase 1: Foundation ✅ COMPLETE

**Goal**: Establish core configuration structure and basic tooling

**Completed Milestones**:
- ✅ Modular configuration structure
- ✅ Home Manager integration
- ✅ Basic terminal tools (fish, fzf, eza)
- ✅ Neovim/nixvim setup
- ✅ OpenCode AI integration
- ✅ Hardware detection workflow

**OpenSpec Changes**: 
- `create-modular-config` ✅
- `add-home-manager-setup` ✅
- `add-terminal-tools` ✅
- `add-nixvim-setup` ✅
- `add-opencode-ai` ✅

### Phase 2: Personal Device Support 🔄 IN PROGRESS

**Goal**: Full support for personal development laptops

**Status**: Partially complete (Yoga configured, Zephyrus pending hardware scan)

**Milestones**:
- ✅ Hardware detection and facter integration
- ✅ Yoga laptop configuration
- ⏳ Zephyrus laptop configuration (blocked on hardware access)
- ⏳ DankMaterialShell desktop environment
- ⏳ Niri window manager integration
- ⏳ Ghostty terminal emulator
- ⏳ Zed IDE installation

**OpenSpec Changes**:
- `add-personal-device-hosts` 🔄 (50% - Yoga done)
- `add-dank-material-shell` 📋 (0/39 tasks)
- `add-niri-window-manager` 📋 (0/15 tasks)
- `set-ghostty-as-default-terminal` 📋 (0/7 tasks)
- `add-zed-ide` 📋 (0 tasks defined)

### Phase 3: CI/CD Infrastructure 🔄 IN PROGRESS

**Goal**: Automated testing and deployment pipeline

**Status**: GitLab CI planned but not started

**Milestones**:
- ⏳ GitLab CI pipeline configuration
- ⏳ Attic binary cache setup
- ⏳ Automated deployment to servers
- ⏳ Build artifact caching
- ⏳ Integration testing framework

**OpenSpec Changes**:
- `add-gitlab-ci-infrastructure` 🔄 (4/138 tasks)

### Phase 4: Enhanced Server Infrastructure 📋 PLANNED

**Goal**: Expand server fleet and capabilities

**Status**: Not started

**Milestones**:
- 📋 Contabo VPS configuration
- 📋 Multi-server deployment orchestration
- 📋 Container runtime optimization
- 📋 Database optimization (PostgreSQL + BTRFS)
- 📋 System monitoring integration

**OpenSpec Changes**:
- `add-contabo-vps-server` 📋 (0/25 tasks)
- `optimize-btrfs-postgresql` 📋 (0/24 tasks)
- `refactor-enhance-infrastructure` 📋 (45/100 tasks)

### Phase 5: Desktop Experience 📋 PLANNED

**Goal**: Rich desktop environment for personal devices

**Status**: Design phase

**Milestones**:
- 📋 DankMaterialShell compositor configuration
- 📋 IPC documentation and tooling
- 📋 Matugen theming system
- 📋 Complete desktop customization

**OpenSpec Changes**:
- `add-dms-compositor-config` 📋 (0/100 tasks)
- `add-dms-ipc-documentation` 📋 (0/63 tasks)
- `add-matugen-theming` 📋 (0/61 tasks)

### Phase 6: Advanced Features 🔬 RESEARCH

**Goal**: Performance optimization and advanced capabilities

**Status**: Research and design phase

**Milestones**:
- 🔬 BTRFS optimization strategies
- 🔬 Container runtime performance tuning
- 🔬 Snapshot and backup strategy
- 🔬 Hardware-specific optimizations

**OpenSpec Changes**:
- `design-snapshot-backup-strategy` 🔬
- `optimize-btrfs-for-podman` 🔬
- `optimize-btrfs-podman-advanced` 🔬
- `analyze-performance-bottlenecks` 🔬

## Dependency Graph

```mermaid
graph TD
    ModularConfig[Modular Config] --> HomeManager[Home Manager]
    HomeManager --> TerminalTools[Terminal Tools]
    HomeManager --> Nixvim[Nixvim]
    
    TerminalTools --> PersonalDevices[Personal Device Hosts]
    Nixvim --> PersonalDevices
    
    PersonalDevices --> DMS[DankMaterialShell]
    PersonalDevices --> Ghostty[Ghostty Terminal]
    PersonalDevices --> Zed[Zed IDE]
    
    DMS --> Niri[Niri Window Manager]
    DMS --> DMSCompositor[DMS Compositor Config]
    
    Niri --> Matugen[Matugen Theming]
    DMSCompositor --> DMSIPC[DMS IPC Docs]
    
    ModularConfig --> GitLabCI[GitLab CI]
    GitLabCI --> AtticCache[Attic Cache]
    AtticCache --> AutoDeploy[Auto Deployment]
    
    PersonalDevices --> Contabo[Contabo VPS]
    AutoDeploy --> Contabo
    
    Contabo --> BtrfsOpt[BTRFS Optimization]
    BtrfsOpt --> InfraRefactor[Infrastructure Refactor]
    
    style ModularConfig fill:#90EE90
    style HomeManager fill:#90EE90
    style TerminalTools fill:#90EE90
    style Nixvim fill:#90EE90
    style PersonalDevices fill:#FFD700
    style DMS fill:#FFA500
    style Niri fill:#FFA500
    style GitLabCI fill:#FFA500
    style Contabo fill:#87CEEB
    style DMSCompositor fill:#87CEEB
    style Matugen fill:#87CEEB
```

**Legend**:
- 🟢 Green: Completed
- 🟡 Yellow: In Progress
- 🟠 Orange: Planned - Near Term
- 🔵 Blue: Planned - Future

## Roadmap Timeline

```mermaid
gantt
    title PantherOS Development Timeline
    dateFormat YYYY-MM-DD
    section Foundation
    Modular Config           :done, foundation1, 2024-11-01, 2024-11-15
    Home Manager            :done, foundation2, 2024-11-15, 2024-11-20
    Terminal Tools          :done, foundation3, 2024-11-20, 2024-11-25
    Neovim Setup           :done, foundation4, 2024-11-25, 2024-12-01
    
    section Personal Devices
    Hardware Detection      :done, personal1, 2024-12-01, 2024-12-03
    Yoga Configuration     :done, personal2, 2024-12-03, 2024-12-04
    Zephyrus Config        :active, personal3, 2024-12-04, 2024-12-10
    DankMaterialShell      :personal4, 2024-12-10, 2024-12-20
    Niri Window Manager    :personal5, 2024-12-15, 2024-12-25
    
    section CI/CD
    GitLab CI Pipeline     :ci1, 2024-12-05, 2024-12-15
    Attic Cache Setup      :ci2, 2024-12-10, 2024-12-18
    Automated Deploy       :ci3, 2024-12-18, 2024-12-25
    
    section Servers
    Contabo VPS           :server1, 2025-01-05, 2025-01-15
    BTRFS Optimization    :server2, 2025-01-10, 2025-01-25
    Infrastructure Refactor:server3, 2025-01-20, 2025-02-15
    
    section Desktop
    DMS Compositor        :desktop1, 2025-02-01, 2025-02-28
    Theming System        :desktop2, 2025-02-15, 2025-03-10
    IPC Documentation     :desktop3, 2025-02-20, 2025-03-15
```

## Next Actions

### Immediate (This Week)
1. Complete Zephyrus hardware scan and configuration
2. Start GitLab CI pipeline setup
3. Deploy DankMaterialShell to Yoga device
4. Create GitHub Project board with all issues

### Short Term (Next 2 Weeks)
1. Complete all Phase 2 personal device tasks
2. Deploy functional GitLab CI pipeline
3. Configure Attic binary cache
4. Add Contabo VPS configuration

### Medium Term (Next Month)
1. Full CI/CD automation operational
2. All three servers in production
3. Desktop environment fully customized
4. Begin BTRFS optimization work

---

**Maintained by**: GitHub Copilot AI Agent  
**Review Cycle**: Weekly  
**Status Updates**: After each phase milestone
