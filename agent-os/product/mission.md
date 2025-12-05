# PantherOS Mission

## Pitch

PantherOS is a **multi-host NixOS configuration system** that helps **individual power users managing multiple personal machines and servers** achieve **100% reproducible, declarative infrastructure** by providing **a single flake-based configuration that manages laptops, VPS instances, and development environments with AI-assisted workflows, beginner-friendly Neovim setup, and ADHD-friendly defaults**.

## Users

### Primary Customers

- **Independent Developers**: Managing personal development laptops, personal servers, and cloud infrastructure
- **Power Users with Multiple Devices**: Professionals who own multiple laptops and several VPS instances for different purposes
- **NixOS Enthusiasts**: Users who want to push NixOS beyond single-machine setups to full multi-host orchestration
- **Self-Hosters**: Individuals running personal services across VPS instances with automation-first approach
- **Vim/Neovim Beginners**: Developers wanting to learn modal editing with good habits from the start

### User Personas

**The Multi-Device Developer** (25-45)
- Role: Independent developer or consultant with 3-5 devices
- Context: Owns development laptop (Zephyrus), travel laptop (Yoga), multiple VPS servers (Hetzner, OVH, Contabo)
- Pain Points:
  - Configuration drift between personal devices
  - Time wasted recreating setup on new machines
  - Inconsistent environments leading to "works on my machine" problems
  - Difficulty maintaining server configurations alongside desktop configs
- Goals: Unified configuration across all devices, rapid deployment, reproducible environments, automated backups

**The Self-Hosting Enthusiast** (28-50)
- Role: Privacy-conscious individual running personal services
- Context: Manages 2-4 VPS instances with different roles (production, staging, backups)
- Pain Points:
  - Manual server setup leading to configuration drift
  - Difficulty tracking what services run where
  - Inconsistent security posture across servers
  - Complex backup and monitoring strategies
- Goals: Declarative server management, consistent security, automated monitoring, bulletproof backups

**The Automation-First Professional** (30-55)
- Role: Productivity-focused developer with extensive automation
- Context: Wants everything automated from OS configuration to deployment pipelines
- Pain Points:
  - Repetitive configuration tasks across devices
  - Lack of AI integration in development workflow
  - Context switching between different environments
  - Inefficient manual processes
- Goals: AI-assisted workflows, complete automation, consistent tooling, minimal manual intervention

**The Neovim Learner** (20-40)
- Role: Developer transitioning to modal editing
- Context: Wants to learn Vim/Neovim efficiently without developing bad habits
- Pain Points:
  - Overwhelming plugin ecosystem with no clear guidance
  - Easy to develop anti-patterns when self-teaching
  - Mouse dependency and inefficient navigation habits
  - Steep learning curve without proper scaffolding
- Goals: Build muscle memory for efficient editing, gradual skill progression, keyboard-first workflow

## The Problem

### Configuration Drift Across Multiple Personal Devices

Most power users manage multiple devices (laptops, servers, VPS instances) using manual setup or scattered documentation. This leads to **configuration drift** where machines diverge over time, creating **"works on my machine" problems** and **wasted time** when switching between devices or setting up new ones.

**Our Solution:** PantherOS provides a **single flake-based NixOS configuration** that manages all devices declaratively. Define your entire infrastructure once, deploy everywhere with **100% reproducibility** and **guaranteed consistency**.

### Complex Multi-Machine Orchestration

Managing multiple servers (Hetzner, OVH, Contabo VPS) and personal devices requires **duplicated configuration effort**. Each machine needs individual setup with **no central management** or **consistency guarantees**. Updates are manual, risky, and time-consuming.

**Our Solution:** PantherOS's **flake architecture** with modular configuration allows defining all machines in one codebase. Shared modules and host-specific overrides ensure **configuration reuse** with **host-specific customization**. Update once, deploy everywhere.

### Configuration Quality and Technical Debt

NixOS configurations often grow organically, leading to **duplicated patterns**, **monolithic modules**, and **untested configurations**. Without proper structure, configurations become hard to maintain and prone to subtle bugs.

**Our Solution:** PantherOS enforces **modular architecture** with clear separation between hosts, profiles, and modules. **flake-parts** provides standardized structure, **nix-unit** enables unit testing, and **NixOS VM tests** validate complete host configurations. Quality is a first-class citizen.

### Lack of AI-Integrated Development Workflows

Traditional NixOS setups don't leverage AI assistance effectively. Power users miss opportunities for **automated code review**, **context-aware suggestions**, **intelligent task orchestration**, and **AI-assisted configuration management**.

**Our Solution:** PantherOS integrates **OpenCode/OpenAgent**, **GitHub Copilot with MCP servers**, and **AI-enhanced development environment** as first-class citizens. Built-in AI tools provide **automated workflow execution**, **context-aware assistance**, and **intelligent task management** - turning NixOS management into an AI-enhanced experience.

### Inadequate Storage and Backup Strategies

Most users don't have comprehensive storage, backup, and monitoring strategies. They lack **hardware-aware storage optimization**, **Btrfs best practices**, **automated snapshot policies**, and **disaster recovery planning** tailored to their specific hardware (NVMe SSDs vs VPS storage).

**Our Solution:** PantherOS provides **Btrfs + Disko integration** with hardware-aware layouts, **subvolume optimization** for different workloads (development, containers, databases), **automated snapshot strategies**, and **backup integration** with services like Backblaze B2. **Datadog monitoring** and **Prometheus/Grafana** provide complete observability.

### Poor ADHD-Friendly Development Environment

Neurodivergent developers struggle with overwhelming interfaces, inconsistent workflows, and lack of automation. Traditional setups require **constant context switching**, **manual tool configuration**, and **stressful environment management**.

**Our Solution:** PantherOS includes **DankMaterialShell**, **Niri Wayland compositor**, **Fish shell**, and **Ghostty terminal** with **sane defaults**, **minimal cognitive load**, **powerful automation**, and **consistent UX patterns**. ADHD-friendly design principles reduce cognitive overhead and increase productivity.

### Steep Neovim Learning Curve

Learning Neovim without guidance leads to **bad habits**, **mouse dependency**, and **frustration**. Most configurations are either too minimal (leaving beginners lost) or too complex (overwhelming with features).

**Our Solution:** PantherOS provides a **beginner-friendly nixvim configuration** with plugins like **hardtime.nvim** and **precognition.nvim** that actively teach good habits while preventing bad ones. Gradual skill building with visible keybinding hints creates a supportive learning environment.

## Core Values

### Reliability Through Testing

Every configuration change should be **validated before deployment**. Unit tests catch module-level issues, integration tests verify host profiles work end-to-end, and CI ensures nothing breaks across the multi-host fleet.

### Developer Ergonomics

The development experience matters. From terminal tooling to editor configuration, every tool should **reduce friction** and **increase productivity**. Sensible defaults, clear documentation, and AI assistance work together.

### Modularity and Maintainability

Configuration should be **easy to understand**, **easy to modify**, and **easy to extend**. Clear module boundaries, reusable profiles, and documented patterns prevent technical debt accumulation.

### Testability and Confidence

Changes should be made with **confidence**. Automated tests, staging deployments, and rollback capabilities ensure that mistakes can be caught early and recovered from quickly.

## Differentiators

### Personal Multi-Host Management vs Generic Configuration Management

Unlike general-purpose tools (Ansible, Puppet, Chef) or team-focused solutions, PantherOS is designed specifically for **single-user, multi-device scenarios**. It optimizes for **personal device management** with **host-specific overrides**, **hardware-aware configurations**, and **personal workflow integration** rather than corporate standardization.

**Impact:** **Perfect for independent developers** managing their personal infrastructure without enterprise overhead.

### AI-First NixOS Management

While other NixOS distributions focus on configuration management, PantherOS makes **AI agents native citizens** of the NixOS workflow. Agents like **OpenCode/OpenAgent** and **Copilot with MCP servers** aren't add-ons but **integrated components** providing **automated configuration generation**, **context-aware deployment assistance**, and **intelligent workflow orchestration**.

**Impact:** **+50% productivity improvement** through AI-assisted NixOS management and development workflows.

### Hardware-Aware Storage Design

Unlike generic NixOS setups, PantherOS provides **hardware-specific Btrfs/Disko layouts** optimized for different hardware profiles (NVMe SSDs in Zephyrus, hybrid storage in Yoga, VPS block storage). It includes **workload-specific mount options**, **compression strategies**, and **snapshot policies** tailored to each device's capabilities.

**Impact:** **Optimized performance** for each device type with **automatic hardware detection** and **appropriate configuration selection**.

### ADHD-Friendly Development Environment

PantherOS includes **curated defaults** for desktop environment, terminal, shell, and tools designed specifically for neurodivergent developers. **DankMaterialShell**, **Niri**, **Fish**, and **Ghostty** are configured with **minimal cognitive overhead**, **consistent patterns**, and **powerful automation** rather than overwhelming customization options.

**Impact:** **Reduced cognitive load** and **increased focus** for neurodivergent developers through thoughtful defaults and automation.

### Beginner-Friendly Neovim with Habit Building

Unlike typical Neovim configurations that overwhelm or leave users adrift, PantherOS provides a **pedagogical approach** to modal editing. Plugins actively **teach good habits** (hardtime.nvim, precognition.nvim) while providing **discoverable keybindings** (which-key) and **gradual complexity introduction**.

**Impact:** **Faster mastery** of modal editing with **fewer bad habits** and **sustainable skill building**.

### Single-Source-of-Truth Infrastructure

PantherOS manages the **complete lifecycle** of personal infrastructure:
- **Personal devices** with desktop environment and development tools
- **VPS instances** with server workloads and services
- **CI/CD pipelines** with GitHub Actions and Hercules CI integration
- **Secrets management** via OpNix/1Password integration
- **Monitoring** with Datadog and optional Prometheus/Grafana/Loki
- **Backups** with Btrfs snapshots and Backblaze B2 integration
- **Testing** with nix-unit and NixOS VM integration tests

**Impact:** **Single source of truth** for all personal infrastructure with **zero manual intervention** across all devices.

## Key Features

### Core Infrastructure Features
- **NixOS Flake Architecture**: Declarative multi-host configuration in a single codebase
- **flake-parts Structure**: Standardized flake organization with clear module boundaries
- **Modular Configuration**: Reusable modules with host-specific overrides for laptops and servers
- **Host Profiles**: Reusable patterns (laptop, server, dev-only) for consistent host types
- **Disko Integration**: Declarative disk partitioning and Btrfs subvolume management
- **Home Manager**: User environment management separate from system configuration
- **One-Command Deployment**: Full environment setup with `nixos-rebuild switch` or `home-manager switch`

### Testing & Quality Features
- **Unit Testing**: nix-unit tests for individual modules and functions
- **Integration Testing**: NixOS VM tests for complete host profile validation
- **CI Validation**: Automated testing across all hosts on every change
- **Pre-Commit Hooks**: Format checking, linting, and dead code detection

### Hardware-Aware Storage Features
- **Btrfs Subvolumes**: Workload-optimized subvolume layouts for development, containers, and databases
- **Disko Partitioning**: Hardware-aware partitioning strategies for NVMe SSDs and VPS storage
- **Mount Option Optimization**: Compression, autodefrag, noatime, nodatacow tuned per workload
- **Snapshot Strategies**: Automated Btrfs snapshots with retention policies
- **Backup Integration**: Backblaze B2 integration for offsite backups

### AI-Enhanced Features
- **OpenCode/OpenAgent Integration**: ~16 AI agents for development and system management tasks
- **GitHub Copilot with MCP**: Sequential thinking, Brave Search, Context7, NixOS MCP, DeepWiki servers
- **AI-Assisted Configuration**: Context-aware configuration generation and validation
- **Intelligent Workflow Orchestration**: AI-driven task automation and delegation
- **Shell Integration**: AI tools seamlessly integrated into Fish shell environment

### Desktop Environment Features
- **DankMaterialShell**: Material design shell layer with ADHD-friendly defaults
- **Niri Wayland Compositor**: Scrollable-tiling window manager with modern ergonomics
- **Fish Shell**: Smart defaults with AI-enhanced completions
- **Ghostty Terminal**: High-performance terminal with modern features
- **Zed + Nixvim**: Dual-editor setup optimized for NixOS development

### Developer Experience Features
- **Integrated Terminal Tooling**: Fish + Ghostty + Zellij with consistent configuration
- **Shell Completions**: Comprehensive completions for Nix, Git, and development tools
- **Core CLI Tools**: ripgrep, fd, bat, eza, fzf, jq, and more for productive CLI workflow
- **Git Workflow Tools**: delta, lazygit, gh CLI for streamlined version control
- **AI-Assisted Development**: Claude, Copilot integration in terminal and editors

### Neovim Environment Features
- **nixvim Configuration**: Declarative, reproducible Neovim setup
- **Habit-Building Plugins**: hardtime.nvim prevents bad habits, precognition.nvim shows efficient motions
- **Discoverable Keybindings**: which-key integration for visible, learnable shortcuts
- **Modern LSP Support**: Language servers for Nix, Lua, Python, TypeScript, and more
- **Treesitter Integration**: Syntax highlighting and code understanding
- **Git Integration**: gitsigns, fugitive/neogit for in-editor version control
- **File Navigation**: Telescope/fzf-lua for fuzzy finding, neo-tree/oil for file management

### Infrastructure & DevOps Features
- **CI/CD Integration**: GitHub Actions for automated testing and deployment
- **Hercules CI**: Nix-native CI with binary caching via Attic/Cachix
- **Multi-Host CI**: Build and test all hosts with per-branch workflows
- **Staging/Production Deploys**: Safe deployment flows with validation and rollback
- **Secrets Management**: OpNix/1Password integration for all credentials
- **Tailscale Mesh VPN**: Secure networking between all personal devices
- **SSH Hardening**: Declarative SSH security configuration
- **Podman Containers**: Docker-free container runtime with Btrfs optimization

### Monitoring & Observability Features
- **Datadog Integration**: Primary monitoring solution with comprehensive metrics
- **Prometheus/Grafana Stack**: Optional self-hosted monitoring with custom dashboards
- **Loki Log Aggregation**: Centralized log management across all hosts
- **Alert Management**: Configurable alerts for CPU, disk, services, and backup health
- **Performance Dashboards**: Hardware-specific monitoring for laptops and servers

### Automation & Productivity Features
- **GitHub Actions Workflows**: Automated builds, tests, and deployments
- **Binary Caching**: Attic/Cachix integration for faster builds
- **Automated Backups**: Scheduled snapshots and offsite replication
- **One-Click Recovery**: Disaster recovery procedures built into configuration
- **Hardware Detection**: Automatic configuration based on detected hardware (Zephyrus, Yoga, VPS)
