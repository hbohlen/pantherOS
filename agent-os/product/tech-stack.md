# PantherOS Tech Stack

## Core Operating System

### NixOS
- **Version**: nixos-unstable channel with flake-based configuration
- **Purpose**: Declarative, reproducible operating system configuration for multi-host management
- **Rationale**:
  - **Reproducibility**: Entire system state defined as code with perfect reproducibility
  - **Atomic Updates**: All-or-nothing configuration changes with instant rollback
  - **Multi-Host Management**: Single codebase manages all personal devices and VPS instances
  - **Version Control**: All changes tracked in git with complete audit trail
  - **Dependency Management**: Automatic dependency resolution and conflict detection
  - **No Configuration Drift**: Guaranteed consistency across all hosts

### Nix Language
- **Purpose**: Functional, lazy evaluation language for system configuration
- **Rationale**:
  - **Pure Functions**: No side effects, easier to reason about configurations
  - **Lazy Evaluation**: Compute only what's needed, faster builds and evaluations
  - **Composability**: Reusable modules and configuration patterns across hosts
  - **Type Safety**: Catch errors at configuration time, not runtime

## Flake Infrastructure

### Nix Flakes
- **Purpose**: Versioned, reproducible Nix package and configuration management
- **Implementation**:
  - Single flake.nix orchestrates all hosts and modules
  - Per-host directories: `hosts/servers/hetzner-vps/`, `hosts/desktops/zephyrus/`, etc.
  - Hardware, configuration, and disko separated per host
- **Rationale**: **Reproducible builds** with **locked dependencies** and **easy rollbacks**

### flake-parts
- **Source**: github:hercules-ci/flake-parts
- **Purpose**: Modular flake structure with standardized organization
- **Implementation**:
  - Replaces direct nixosConfigurations with structured modules
  - Per-system outputs for packages, devShells, checks
  - Clean separation of concerns across flake outputs
  - Enables module composition and reuse
- **Rationale**:
  - **Standardization**: Consistent flake structure across projects
  - **Modularity**: Each output type in its own module
  - **Per-System**: Automatic handling of multi-architecture builds
  - **Extensibility**: Easy to add new output types

### Home Manager
- **Version**: release-25.05
- **Purpose**: User environment management separate from system configuration
- **Rationale**:
  - **Separation of Concerns**: System vs user configuration
  - **Multi-Host User Configs**: Same user environment across different NixOS machines
  - **Independent Rollback**: Undo user environment changes without touching system
  - **Dotfiles Management**: All user configurations as code

### Disko
- **Source**: github:nix-community/disko
- **Purpose**: Declarative disk partitioning and filesystem management
- **Implementation**:
  - Hardware-aware partitioning strategies
  - Btrfs subvolume layout definition
  - Mount option configuration
- **Rationale**: **Disk layouts in version control**, **automated installation**, **perfect reproducibility**

## Custom Extensions (lib/)

### lib/ Directory Structure
- **Purpose**: Centralized helper functions and custom overlays
- **Implementation**:
  ```
  lib/
  ├── default.nix          # Main entry point, imports all helpers
  ├── hardware-detection.nix   # Hardware profiling helpers
  ├── module-helpers.nix   # Module composition utilities
  └── overlays/
      ├── default.nix      # Overlay aggregation
      └── custom-packages.nix  # Custom package definitions
  ```
- **Rationale**:
  - **Centralization**: All helpers in one discoverable location
  - **Reusability**: Functions available across all modules
  - **Testing**: Easier to unit test isolated functions
  - **Documentation**: Clear API for custom functionality

### Custom Overlays
- **Purpose**: Extend nixpkgs with custom packages and modifications
- **Implementation**:
  - Overlays defined in `lib/overlays/`
  - Applied via flake-parts overlay system
  - Custom packages as first-class citizens
- **Rationale**:
  - **Customization**: Patch or override upstream packages
  - **Local Packages**: Add packages not in nixpkgs
  - **Consistency**: Same modifications across all hosts

## Host Profiles

### profiles/ Directory
- **Purpose**: Reusable host configuration patterns
- **Implementation**:
  ```
  profiles/
  ├── laptop.nix       # Common laptop configuration
  ├── server.nix       # Common server configuration
  ├── dev-only.nix     # Development-only features
  └── minimal.nix      # Minimal base configuration
  ```
- **Features**:
  - **laptop.nix**: Power management, display, input devices, desktop environment
  - **server.nix**: SSH hardening, monitoring, firewall, headless operation
  - **dev-only.nix**: Development tools, AI integration, editors (not for production)
- **Rationale**:
  - **DRY**: Don't repeat common patterns in each host
  - **Consistency**: Same base configuration for similar hosts
  - **Composability**: Hosts import multiple profiles as needed

## Filesystem & Storage

### Btrfs
- **Purpose**: Copy-on-write filesystem with advanced features
- **Implementation**:
  - Subvolumes for different workloads (/, /home, /var/lib/containers, /nix)
  - Compression (zstd) for space savings
  - Snapshot support for rollback and backups
- **Rationale**:
  - **Copy-on-Write**: Efficient storage and snapshots
  - **Subvolumes**: Isolated filesystem trees for different purposes
  - **Compression**: Automatic space savings without performance loss
  - **Snapshots**: Instant rollback capability

### Storage Layouts by Hardware

**Zephyrus Laptop (2x NVMe SSD)**
- Dual SSD configuration (Crucial P3 2TB + Micron 2450 1TB)
- Btrfs RAID1 for redundancy on critical data
- Development-optimized mount options (nodatacow for build caches)
- Container-optimized subvolumes for Podman

**Yoga Laptop**
- Single drive configuration
- Mobile-optimized mount options (battery-conscious)
- Travel-friendly snapshot strategy
- Portable development environment

**VPS Instances (Hetzner, OVH, Contabo)**
- Single virtual disk optimization
- Database-optimized mount options (nodatacow for databases)
- Container storage optimization
- Backup-friendly snapshot layout

## Testing & Quality Assurance

### nix-unit
- **Source**: github:nix-community/nix-unit
- **Purpose**: Unit testing framework for Nix expressions
- **Implementation**:
  - Test lib/ helper functions
  - Validate module option logic
  - Test derivation attributes
- **Usage**:
  ```nix
  # tests/lib-tests.nix
  {
    "hardware detection returns correct profile" = {
      expr = lib.detectHardware { ... };
      expected = "laptop";
    };
  }
  ```
- **Rationale**:
  - **Fast Feedback**: Catch errors before building
  - **Regression Prevention**: Tests document expected behavior
  - **Confidence**: Safe refactoring with test coverage

### NixOS VM Tests (nixosTest)
- **Purpose**: Integration testing for complete system configurations
- **Implementation**:
  - Test VMs for each host profile
  - Validate services start correctly
  - Test networking and security configurations
- **Usage**:
  ```nix
  nixosTest {
    name = "server-profile-test";
    nodes.server = { imports = [ ../profiles/server.nix ]; };
    testScript = ''
      server.wait_for_unit("sshd.service")
      server.succeed("systemctl is-active firewall")
    '';
  }
  ```
- **Rationale**:
  - **End-to-End Validation**: Test complete system behavior
  - **Service Testing**: Verify services work together
  - **Security Validation**: Test firewall and SSH hardening

### Pre-Commit Validation
1. **Nix Format Check**: Ensure consistent code formatting (alejandra)
2. **Nix Linting (statix)**: Check for Nix best practices
3. **Dead Code Detection (deadnix)**: Remove unused code
4. **Shell Script Validation (shellcheck)**: Validate shell scripts
5. **Unit Tests**: Run nix-unit tests
- **Rationale**: **Quality gates** prevent problematic code from entering codebase

### Build Validation
1. **nix flake check**: Validate flake syntax and structure
2. **nix build**: Build all configurations
3. **VM Tests**: Run integration tests
4. **Deployment Testing**: Test deployments in staging environment
- **Rationale**: **End-to-end validation** before production deployment

## Secrets Management

### 1Password
- **Purpose**: Centralized secrets storage and management
- **Rationale**:
  - **Single Source of Truth**: All credentials in one secure location
  - **Audit Trail**: Complete access logging and history
  - **Team Sharing**: Easy sharing within family/team context
  - **Security**: Enterprise-grade encryption and security

### OpNix
- **Source**: github:brizzbuzz/opnix
- **Purpose**: 1Password integration for NixOS configuration
- **Implementation**:
  - Pulls secrets from 1Password at deploy time
  - No secrets in configuration files
  - CI/CD token management
  - Service credential injection
- **Rationale**:
  - **Security**: Secrets never stored in git
  - **Automation**: Seamless integration with NixOS deployment
  - **Consistency**: Same secrets across all hosts
  - **Rotation**: Easy secrets rotation with 1Password

## Networking & Security

### Tailscale
- **Purpose**: Mesh VPN for secure host connectivity
- **Implementation**:
  - All hosts join same Tailscale network
  - Automatic direct connections between devices
  - SSH access via Tailscale IPs
- **Rationale**:
  - **Zero-Config VPN**: Automatic secure networking
  - **Mesh Topology**: Direct connections, no central bottleneck
  - **End-to-End Encryption**: All traffic encrypted by default
  - **NAT Traversal**: Works behind NAT and firewalls

### SSH Hardening
- **Implementation**: NixOS module enforcing security standards
- **Features**:
  - Key-only authentication
  - Strong cipher algorithms
  - Fail2ban integration
  - Port knocking optional
- **Rationale**:
  - **Security First**: Hardened defaults across all hosts
  - **Declarative Security**: Security policies as code
  - **Consistency**: Same security posture everywhere

### Firewall Configuration
- **Implementation**: NixOS firewall with host-specific rules
- **Features**:
  - Default deny policy
  - Explicit allow rules
  - Tailscale traffic always allowed
  - Port-specific restrictions per host type
- **Rationale**:
  - **Defense in Depth**: Multiple security layers
  - **Host-Specific Policies**: Different rules for laptops vs servers
  - **Automated**: No manual firewall management

## Cloud Infrastructure

### Hetzner VPS
- **Purpose**: Primary production server (~458GB disk)
- **Workloads**: Databases, containers, web services, backups
- **Rationale**: **High storage**, **competitive pricing**, **European data centers**

### Contabo VPS
- **Purpose**: Staging environment and deployment testing
- **Rationale**: **Budget-friendly** staging target for testing changes

### OVH VPS
- **Purpose**: Additional server capacity and workload distribution
- **Rationale**: **Redundancy** and **geographic distribution**

### Cloudflare
- **Purpose**: DNS and CDN for hosted services
- **Rationale**:
  - **Fast DNS**: Global anycast DNS
  - **CDN**: Global content delivery
  - **Security**: DDoS protection and WAF
  - **SSL**: Automatic SSL certificate management

### Backblaze B2
- **Purpose**: Object storage for backups and caching
- **Rationale**:
  - **Low Cost**: Very competitive pricing
  - **Simple API**: Easy integration
  - **Reliable**: 99.9% uptime SLA
  - **No Egress Fees**: Free data transfer

## CI/CD & Automation

### GitHub Actions
- **Purpose**: Primary CI/CD platform
- **Implementation**:
  - Matrix builds for all host configurations
  - Per-branch workflows (feature branches build affected hosts)
  - Staging deployment to Contabo (automatic on main)
  - Production deployment to Hetzner (manual approval)
  - Test execution (nix-unit + NixOS VM tests)
- **Rationale**:
  - **Integration**: Native GitHub integration
  - **Multi-Host**: Build and test entire fleet
  - **Secrets**: Secure secret management with GitHub Secrets
  - **Flexibility**: Custom workflows for different deployment needs

### Hercules CI
- **Source**: github:hercules-ci/hercules-ci-agent
- **Purpose**: Nix-native continuous integration
- **Implementation**:
  - Dedicated module for Hercules CI
  - OpNix integration for CI secrets
  - Automated binary cache management
- **Rationale**:
  - **Nix-First**: Designed specifically for Nix workflows
  - **Caching**: Intelligent caching for faster builds
  - **Binary Caches**: Native support for Cachix/Attic

### Binary Caching

#### Attic
- **Source**: github:zhaofengli/attic
- **Purpose**: Self-hosted Nix binary cache server
- **Implementation**:
  - Self-hosted cache server on Hetzner VPS
  - CI populates cache on successful builds
  - All hosts configured as cache clients
  - Garbage collection and retention policies
- **Rationale**:
  - **Control**: Full control over cache infrastructure
  - **Cost**: No per-GB costs after initial setup
  - **Privacy**: Builds stay on owned infrastructure

#### Cachix (Alternative)
- **Purpose**: Managed Nix binary cache service
- **Rationale**:
  - **Managed**: No infrastructure to maintain
  - **Reliable**: Professional uptime SLA
  - **Easy Setup**: Minimal configuration required

### Deployment Strategy
- **Staging**: Contabo VPS receives automatic deployments on main branch
- **Production**: Hetzner VPS requires manual approval
- **Validation**: Pre-deployment checks and health verification
- **Rollback**: Automatic rollback on health check failures
- **Audit**: Deployment logging and audit trail

## Containers & Runtime

### Podman
- **Purpose**: Docker-free container runtime
- **Rationale**:
  - **Rootless**: Run containers without root privileges
  - **Systemd Integration**: Native systemd service support
  - **No Daemon**: Daemonless architecture
  - **Security**: Better security posture than Docker

### Container Storage Optimization
- **Implementation**:
  - Btrfs-optimized storage for `/var/lib/containers`
  - Separate subvolumes for image storage
  - Volume management with proper mount options
- **Rationale**:
  - **Performance**: Optimized for container I/O patterns
  - **Space Efficiency**: Btrfs compression and deduplication
  - **Snapshots**: Easy container state rollback

## Desktop Environment

### DankMaterialShell
- **Purpose**: Material Design shell layer
- **Features**:
  - ADHD-friendly design defaults
  - Consistent theming across applications
  - Minimal cognitive overhead
  - Automation-friendly interface
- **Rationale**: **Sane defaults** for neurodivergent developers, **reduced cognitive load**

### Niri
- **Purpose**: Scrollable-tiling Wayland compositor
- **Features**:
  - Modern Wayland architecture
  - Efficient window management
  - Configurable keybindings
  - IPC for external control
- **Rationale**:
  - **Modern**: Wayland instead of X11
  - **Efficient**: Tiling window manager for productivity
  - **Customizable**: Extensive configuration options

## Terminal & Shell Environment

### Fish Shell
- **Purpose**: Modern interactive shell
- **Features**:
  - Smart defaults out of the box
  - Advanced autocompletion
  - AI-enhanced completions
  - Simple configuration syntax
  - Custom functions and abbreviations
- **Rationale**:
  - **User-Friendly**: Easier to learn than bash/zsh
  - **Productivity**: Powerful features by default
  - **Scripting**: Clean, readable syntax

### Ghostty
- **Purpose**: High-performance terminal emulator
- **Features**:
  - Modern terminal features
  - Excellent performance
  - Configurable appearance
  - Wayland native
- **Rationale**:
  - **Performance**: Fast rendering and low latency
  - **Features**: Modern terminal capabilities
  - **Customization**: Extensive configuration options

### Zellij
- **Purpose**: Terminal multiplexer
- **Features**:
  - Modern tmux alternative
  - Easy pane and tab management
  - Plugin support
  - User-friendly interface
  - Session persistence
- **Rationale**:
  - **Productivity**: Better than tmux for many use cases
  - **Easy**: Simpler configuration and usage
  - **Modern**: Built for modern workflows

### Shell Prompt
- **Options**: Starship or custom Fish prompt
- **Features**:
  - Git status integration
  - Nix shell/flake indicators
  - Command duration
  - Exit status
- **Rationale**: Quick visual feedback on context

## Core CLI Tools

### File Operations
- **ripgrep (rg)**: Fast grep replacement
- **fd**: Fast find replacement
- **bat**: cat with syntax highlighting
- **eza**: Modern ls replacement
- **fzf**: Fuzzy finder
- **zoxide**: Smart cd with frecency

### Data Processing
- **jq**: JSON processor
- **yq**: YAML processor
- **miller**: CSV/JSON/etc. processor

### Process & System
- **htop/btop**: Interactive process viewer
- **procs**: Modern ps replacement

### Network
- **curl**: HTTP client
- **httpie**: User-friendly HTTP client
- **dog**: DNS client

### Git Workflow
- **delta**: Improved git diff
- **lazygit**: TUI for git
- **gh**: GitHub CLI
- **git-absorb**: Automatic fixup commits
- **git-branchless**: Advanced git workflows

### Nix-Specific
- **nix-tree**: Visualize Nix derivation trees
- **nix-diff**: Compare Nix derivations
- **nvd**: Nix version diff (show what changed)

## Editors & Development Tools

### Nixvim (Neovim)
- **Source**: github:nix-community/nixvim
- **Purpose**: Neovim configuration via Nix
- **Philosophy**: Beginner-friendly, habit-building, keyboard-focused
- **Features**:
  - Declarative Neovim configuration
  - Language server protocol (LSP) support
  - Plugin management via Nix
  - Consistent across all hosts
- **Module Structure**:
  ```
  home/editors/nixvim/
  ├── default.nix      # Main entry, imports sub-modules
  ├── core.nix         # Base settings, options, colorscheme
  ├── keymaps.nix      # All keybindings
  ├── lsp.nix          # Language servers and completion
  ├── plugins/
  │   ├── navigation.nix   # Telescope, neo-tree, harpoon
  │   ├── git.nix          # gitsigns, neogit, diffview
  │   ├── ui.nix           # lualine, which-key, notifications
  │   └── habits.nix       # hardtime, precognition
  └── treesitter.nix   # Syntax and text objects
  ```
- **Rationale**:
  - **As Code**: Editor configuration in version control
  - **Reproducible**: Same editor setup everywhere
  - **Modular**: Easy to understand and modify
  - **Pedagogical**: Teaches good habits from day one

### Neovim Plugin Philosophy

#### Required Habit-Building Plugins
- **hardtime.nvim**: Prevents bad habits
  - Blocks repeated hjkl presses (forces efficient motions)
  - Disables arrow keys in normal mode
  - Configurable strictness (start lenient, increase over time)
- **precognition.nvim**: Shows available motions
  - Displays hints for efficient cursor movement
  - Shows w/e/b word motions, f/t character motions
  - Visual guide before pressing keys

#### Navigation & Discovery
- **Telescope** or **fzf-lua**: Fuzzy finding (files, buffers, grep, symbols)
- **neo-tree** or **oil.nvim**: File tree/file manager
- **harpoon**: Quick file switching (mark important files)
- **which-key.nvim**: Keybinding discovery and hints

#### LSP & Completion
- **nvim-lspconfig**: LSP configuration
- **nvim-cmp**: Completion engine with sources (lsp, buffer, path, snippets)
- **LuaSnip** + **friendly-snippets**: Snippet support

#### Syntax & Understanding
- **nvim-treesitter**: Syntax highlighting, text objects, incremental selection
- **nvim-treesitter-textobjects**: Function/class/parameter text objects

#### Git Integration
- **gitsigns.nvim**: Git hunks, blame, staging in gutter
- **neogit** or **fugitive.vim**: Git operations
- **diffview.nvim**: Side-by-side diff viewing

#### UI & Quality of Life
- **lualine.nvim**: Statusline
- **indent-blankline.nvim**: Indentation guides
- **nvim-autopairs**: Auto-close brackets
- **Comment.nvim**: Easy commenting

### Zed
- **Purpose**: High-performance code editor
- **Features**:
  - Excellent performance
  - Collaborative editing
  - Modern UI
  - Good NixOS integration
- **Rationale**:
  - **Performance**: Very fast for large projects
  - **Modern**: Contemporary editor design
  - **Alternative**: Secondary editor when GUI preferred

### Language Servers
- **nil**: Nix language server
- **nixd**: Nix language server daemon (alternative to nil)
- **lua-language-server**: For Neovim configuration
- **pyright/pylsp**: Python
- **typescript-language-server**: TypeScript/JavaScript
- **rust-analyzer**: Rust
- **Purpose**: IDE integration for better development experience
- **Rationale**:
  - **Autocomplete**: Better coding experience
  - **Diagnostics**: Real-time error detection
  - **Refactoring**: Code navigation and refactoring

### Development Tools
- **Formatters**:
  - alejandra: Nix code formatter (opinionated, fast)
  - nixpkgs-fmt: Nixpkgs standard formatter
  - nixfmt-rfc-style: RFC-compliant formatter
  - stylua: Lua formatter
  - black/ruff: Python formatters
  - prettier: JS/TS/JSON/YAML formatter
- **Quality Tools**:
  - statix: Nix linter for best practices
  - deadnix: Dead code detection
  - shellcheck: Shell script validation
- **Purpose**: Maintain high code quality standards
- **Rationale**: **Automated quality enforcement**, **consistent code style**

## AI & Automation Tools

### OpenCode/OpenAgent
- **Implementation**:
  - ~16 AI agents (universal, codebase, system-builder, utilities)
  - ~14 commands for project context and system building
  - Shell integration with environment variables
- **Purpose**: AI-assisted development and system management
- **Rationale**:
  - **Automation**: Reduce repetitive tasks
  - **Intelligence**: AI-driven workflow optimization
  - **Context-Aware**: Agents understand domain context

### GitHub Copilot with MCP Servers
- **MCP Servers**:
  - Sequential thinking: Multi-step reasoning assistance
  - Brave Search: Web search integration
  - Context7: Context management
  - NixOS MCP: NixOS-specific assistance
  - DeepWiki: Documentation analysis
- **Purpose**: Enhanced coding assistance with context
- **Rationale**:
  - **AI-First**: Deep AI integration in development workflow
  - **Context-Rich**: AI understands project context
  - **Productivity**: Faster development with AI assistance

### Claude CLI
- **Purpose**: Terminal-based AI assistance
- **Features**:
  - Shell integration
  - Code explanation and generation
  - System administration help
- **Rationale**: AI assistance without leaving terminal

### Shell Integration
- **Implementation**:
  - Fish shell completions for AI tools
  - Environment variables for AI tool configuration
  - Aliases and functions for common AI tasks
- **Purpose**: Seamless AI tool integration in shell
- **Rationale**:
  - **Workflow**: AI tools integrated into daily workflow
  - **Efficiency**: Quick access to AI capabilities
  - **Context**: Shell has access to project context

## Monitoring & Observability

### Datadog (Primary)
- **Purpose**: Primary monitoring and alerting platform
- **Implementation**:
  - Datadog agent on all hosts
  - Custom dashboards for different host types
  - Alerting for CPU, disk, services
- **Subscription**: Pro subscription available
- **Rationale**:
  - **Comprehensive**: Full-stack monitoring
  - **Hosted**: No self-hosting required
  - **Alerts**: Professional alerting platform
  - **Dashboards**: Rich visualization

### Prometheus (Optional)
- **Purpose**: Metrics collection and storage
- **Implementation**:
  - Prometheus server on designated host
  - node_exporter for system metrics
  - Service-specific exporters
- **Rationale**:
  - **Self-Hosted**: Control over metrics data
  - **Flexible**: Highly customizable
  - **Open Source**: No vendor lock-in

### Grafana (Optional)
- **Purpose**: Metrics visualization and dashboards
- **Implementation**:
  - Grafana server connected to Prometheus
  - Custom dashboards for different use cases
  - Alert management via Alertmanager
- **Rationale**:
  - **Visualization**: Rich dashboard creation
  - **Multiple Sources**: Support various data sources
  - **Open Source**: Community-driven

### Loki (Optional)
- **Purpose**: Log aggregation system
- **Implementation**:
  - Loki server for log storage
  - Promtail for log collection
  - Grafana for log visualization
- **Rationale**:
  - **Log Centralization**: All logs in one place
  - **Efficient**: Cost-effective log storage
  - **Integrated**: Works with Grafana/Prometheus stack

### Alertmanager
- **Purpose**: Alert management and routing
- **Implementation**:
  - Configured with Prometheus
  - Alert routing to various channels
  - Alert deduplication and grouping
- **Rationale**:
  - **Alert Management**: Professional alerting workflows
  - **Integration**: Works with monitoring stack
  - **Flexibility**: Configurable alert routing

## Hardware Detection

### nixos-facter-modules
- **Source**: github:nix-community/nixos-facter-modules
- **Purpose**: Automatic hardware detection and reporting
- **Implementation**:
  - Detect hardware on each host
  - Generate hardware profiles
  - Apply hardware-specific configuration
- **Rationale**:
  - **Automation**: No manual hardware specification
  - **Accuracy**: Automatic detection is more accurate
  - **Maintenance**: Easier to maintain hardware-specific configs

## Directory Structure

### Hosts Directory
```
hosts/
├── servers/
│   ├── hetzner-vps/
│   │   ├── hardware-configuration.nix
│   │   ├── configuration.nix
│   │   └── disko-config.nix
│   ├── contabo-vps/
│   └── ovh-vps/
└── desktops/
    ├── zephyrus/
    └── yoga/
```
**Purpose**: Machine-specific configurations
**Rationale**: Clear separation of host-specific configs

### Profiles Directory
```
profiles/
├── laptop.nix         # Laptop common config
├── server.nix         # Server common config
├── dev-only.nix       # Development features
└── minimal.nix        # Minimal base
```
**Purpose**: Reusable host patterns
**Rationale**: DRY principle for host configuration

### Home Directory
```
home/
└── hbohlen/
    ├── shell/
    ├── editors/
    │   └── nixvim/
    ├── terminal/
    └── ai-tools/
```
**Purpose**: User environment configurations
**Rationale**: Reusable user environment configuration

### Modules Directory
```
modules/
├── monitoring/
├── ci/
├── desktop/
├── networking/
└── secrets/
```
**Purpose**: Shared configuration modules
**Rationale**: Code reuse and consistency across configs

### lib/ Directory
```
lib/
├── default.nix
├── hardware-detection.nix
├── module-helpers.nix
└── overlays/
    ├── default.nix
    └── custom-packages.nix
```
**Purpose**: Helper functions and overlays
**Rationale**: Centralized, testable utilities

### Agent-OS Directory
```
agent-os/
├── config.yml
├── profiles/
├── product/
│   ├── mission.md
│   ├── roadmap.md
│   └── tech-stack.md
└── standards/
```
**Purpose**: Project-specific configuration and standards
**Rationale**: Project-specific customization and standards enforcement

## Development Workflow

### Configuration Changes
1. **Edit Configuration**: Modify relevant configuration files
2. **Format Code**: Run alejandra for consistent formatting
3. **Run Unit Tests**: Execute nix-unit tests
4. **Validate Syntax**: Run `nix flake check`
5. **Test Build**: Run `nix build` to verify configuration builds
6. **Run Integration Tests**: Execute NixOS VM tests for affected profiles
7. **Deploy to Staging**: Use GitHub Actions or manual deploy to Contabo
8. **Verify Staging**: Test changes in staging environment
9. **Deploy to Production**: Deploy to Hetzner after validation
10. **Monitor**: Watch monitoring for any issues

### Git Workflow
1. **Create Feature Branch**: Work on feature in dedicated branch
2. **Commit Changes**: Use conventional commits for clarity
3. **Push and CI**: GitHub Actions automatically builds and tests
4. **Merge to Staging**: Deploy to Contabo for testing
5. **Production Deploy**: Manual approval for production deployment
6. **Monitor**: Watch metrics after deployment

### Rollback Procedure
1. **Identify Issue**: Notice problem via monitoring or user report
2. **Switch to Previous**: Use `nixos-rebuild switch --rollback`
3. **Verify**: Confirm system is in previous good state
4. **Debug**: Investigate issue in staging environment
5. **Fix and Test**: Make fix and test thoroughly (including unit/integration tests)
6. **Redeploy**: Deploy fixed version with full validation

## Backup Strategy

### Btrfs Snapshots
- **Automatic Snapshots**: Daily snapshots with retention policy
- **Manual Snapshots**: Before major changes
- **Retention**: 7 daily, 4 weekly, 12 monthly snapshots
- **Purpose**: Point-in-time recovery capability

### Offsite Backups
- **Backblaze B2**: Object storage for important data
- **Snapshot Replication**: Replicate snapshots to Backblaze B2
- **Backup Verification**: Periodic restore testing
- **Disaster Recovery**: Documented recovery procedures

## Security Model

### Defense in Depth
1. **SSH Hardening**: Key-only auth, strong ciphers
2. **Firewall**: Default deny with explicit allow
3. **Tailscale**: Encrypted mesh network
4. **Secrets**: No secrets in configuration
5. **Updates**: Regular security updates
6. **Monitoring**: Monitor for security events

### Access Control
- **SSH Keys**: Only key-based authentication
- **Tailscale ACL**: Restrict access via Tailscale
- **Secrets Management**: 1Password for all credentials
- **Audit Trail**: Log all access and changes

### Vulnerability Management
- **Nixpkgs Updates**: Monthly updates with security patches
- **Vulnerability Scanning**: Automated scanning for known issues
- **Dependency Pinning**: Lock dependencies for reproducibility
- **Security Auditing**: Regular security reviews

## Recommended Base Development Toolset

A complete development environment includes:

### Terminal Stack
- Fish shell with custom functions
- Ghostty terminal emulator
- Zellij multiplexer
- Starship prompt (or custom Fish prompt)

### CLI Essentials
- ripgrep, fd, bat, eza, fzf, zoxide (file operations)
- jq, yq (data processing)
- htop, btop (system monitoring)
- delta, lazygit, gh (Git workflow)

### Editors
- Neovim via nixvim (primary, keyboard-focused)
- Zed (secondary, GUI when needed)

### Language Tooling
- nil/nixd (Nix)
- lua-language-server (Lua/Neovim)
- pyright (Python)
- typescript-language-server (TypeScript)
- rust-analyzer (Rust)

### AI Tools
- Claude CLI
- GitHub Copilot CLI
- OpenCode/OpenAgent

### Nix Development
- alejandra (formatting)
- statix (linting)
- deadnix (dead code)
- nix-tree, nix-diff, nvd (inspection)

This tech stack prioritizes **reproducibility**, **maintainability**, **testability**, **security**, **performance**, and **developer experience** through a combination of proven technologies (NixOS, Btrfs, Podman) and modern innovations (AI integration, beginner-friendly Neovim, ADHD-friendly defaults, comprehensive testing).
