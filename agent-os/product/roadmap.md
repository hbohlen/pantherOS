# PantherOS Product Roadmap

## Phase 1: Foundation (COMPLETE)

### Completed Core Infrastructure
1. [x] **NixOS Flake Structure** — Multi-host configuration with modular architecture `[COMPLETE]`
   - Single flake managing all hosts (Zephyrus, Yoga, Hetzner, OVH, Contabo)
   - Shared modules with host-specific overrides
   - Modular configuration structure for reuse

2. [x] **Core CI/CD Pipeline** — GitHub Actions integration `[COMPLETE]`
   - Automated builds for all hosts
   - Branch-based workflows with validation
   - Two-stage architecture (build -> validate -> deploy)

3. [x] **Basic Host Configurations** — End-to-end host management `[COMPLETE]`
   - Host-specific directories with hardware/config/disko separation
   - Working configurations for all planned hosts
   - Basic service and application deployment

## Phase 2: Configuration Cleanup & Modularization (NEW - HIGH PRIORITY)

### Architecture Improvements
4. [ ] **flake-parts Migration** — Adopt flake-parts as primary flake structuring tool `[L]`
   - Convert flake.nix from direct nixosConfigurations to flake-parts structure
   - Organize modules, packages, and devShells under flake-parts
   - Enable per-system outputs and cleaner module composition
   - Document migration path and new structure

5. [ ] **Host Profiles System** — Create reusable host pattern library `[M]`
   - Create `profiles/` directory with laptop, server, dev-only profiles
   - Extract common patterns from existing hosts (SSH, networking, nix settings)
   - Profile composition: hosts import profiles + host-specific overrides
   - Document profile usage and extension patterns

6. [ ] **Module Refactoring** — Split large modules and eliminate duplication `[M]`
   - Split nixvim module into logical sub-modules (core, lsp, plugins, keymaps)
   - Extract duplicated host patterns into shared modules
   - Identify and consolidate SSH, networking, nix settings patterns
   - Create clear module dependency documentation

7. [ ] **lib/ Directory Setup** — Establish custom helpers and overlays `[S]`
   - Move hardware-detection.nix helpers to lib/
   - Create lib/default.nix with all helper functions
   - Add custom overlay patterns in lib/overlays/
   - Document lib usage and extension patterns

## Phase 3: Testing & Validation Framework (NEW - HIGH PRIORITY)

### Testing Infrastructure
8. [ ] **nix-unit Integration** — Unit testing for Nix modules `[M]`
   - Set up nix-unit in flake devShell
   - Create test harness for lib/ helper functions
   - Add unit tests for critical module logic
   - Document test patterns and how to add new tests

9. [ ] **NixOS VM Integration Tests** — System-level validation `[L]`
   - Create NixOS test VMs for each host profile (laptop, server)
   - Test critical services start correctly (SSH, networking, monitoring)
   - Validate profile composition works end-to-end
   - Add tests for security configurations (firewall, SSH hardening)

10. [ ] **CI Test Integration** — Automated testing in CI pipeline `[M]`
    - Run nix-unit tests on every PR
    - Run NixOS VM tests for affected profiles
    - Add test result reporting to GitHub Actions
    - Block merges on test failures

## Phase 4: Personal Devices Enhancement (IN PROGRESS)

### High Priority
11. [ ] **Zephyrus Laptop Configuration** — Complete development laptop setup `[L]`
    - Hardware-specific Btrfs/Disko layout for 2x NVMe SSDs (Crucial P3 2TB + Micron 2450 1TB)
    - Development workload optimization (IDE, build caches, Git checkouts)
    - Gaming laptop power management and optimization
    - Container workload tuning for Podman

12. [ ] **Yoga Laptop Configuration** — Mobile development setup `[M]`
    - Different hardware profile detection and optimization
    - Mobile-focused configuration (battery, display, input)
    - Hardware detection documentation
    - Travel-friendly development environment

13. [ ] **Desktop Environment Completion** — DankMaterialShell + Niri `[M]`
    - DankMaterialShell configuration and theming
    - Niri Wayland compositor with keybindings and IPC
    - Polkit integration and authentication
    - ADHD-friendly UX defaults and automation

## Phase 5: Developer Experience & Terminal Tooling (NEW)

### Terminal Environment
14. [ ] **Terminal Stack Configuration** — Fish + Ghostty + Zellij integration `[M]`
    - Fish shell with custom functions and abbreviations
    - Ghostty terminal with optimized configuration
    - Zellij multiplexer with layouts and keybindings
    - Shell prompt with git status, nix-shell indicators
    - Consistent theming across terminal stack

15. [ ] **Core CLI Toolset** — Essential development tools `[S]`
    - File operations: ripgrep, fd, bat, eza, fzf, zoxide
    - Data tools: jq, yq, miller
    - Process tools: htop, btop, procs
    - Network tools: curl, httpie, dog
    - Nix-specific: nix-tree, nix-diff, nvd

16. [ ] **Git Workflow Tools** — Version control productivity `[S]`
    - delta for improved diffs
    - lazygit for TUI git operations
    - gh CLI for GitHub integration
    - git-absorb, git-branchless for advanced workflows
    - Pre-configured git aliases and completions

17. [ ] **AI-Assisted CLI** — Terminal AI integration `[M]`
    - Claude CLI configuration and shell integration
    - Copilot CLI for command suggestions
    - AI-powered shell completions
    - MCP server access from terminal

## Phase 6: Neovim Environment with nixvim (NEW)

### Beginner-Friendly Editor
18. [ ] **nixvim Core Setup** — Foundation for Neovim configuration `[M]`
    - Clean nixvim module structure (split from monolithic config)
    - Base settings: relative line numbers, clipboard, undo persistence
    - Colorscheme with clear visual hierarchy
    - Statusline (lualine) with useful information

19. [ ] **Habit-Building Plugins** — Enforce good Neovim practices `[S]`
    - hardtime.nvim: Prevent bad habits (hjkl spam, arrow keys)
    - precognition.nvim: Show available motions before pressing keys
    - Configure progressive difficulty (start lenient, increase strictness)
    - Document recommended learning progression

20. [ ] **Keybinding Discovery** — Make shortcuts learnable `[S]`
    - which-key.nvim: Show available keybindings on leader press
    - Organize keybindings by category (file, buffer, search, lsp)
    - Custom keybinding documentation accessible in-editor
    - Consistent mnemonic patterns (leader-f for find, leader-b for buffer)

21. [ ] **Navigation & File Management** — Move around efficiently `[M]`
    - Telescope or fzf-lua for fuzzy finding (files, buffers, grep)
    - neo-tree or oil.nvim for file tree/management
    - harpoon for quick file switching
    - Better marks and jumps configuration

22. [ ] **LSP & Completion** — Language intelligence `[M]`
    - LSP configuration for primary languages (Nix, Lua, Python, TypeScript, Rust)
    - nil and nixd for Nix language support
    - nvim-cmp with LSP, buffer, path sources
    - Snippet support with friendly-snippets
    - Diagnostic display and navigation

23. [ ] **Treesitter & Syntax** — Code understanding `[S]`
    - Treesitter parsers for all relevant languages
    - Syntax highlighting with semantic tokens
    - Treesitter text objects (function, class, parameter)
    - Incremental selection

24. [ ] **Git Integration** — Version control in editor `[S]`
    - gitsigns.nvim for hunks, blame, staging
    - neogit or fugitive for git operations
    - diffview.nvim for diff viewing
    - Integration with lazygit

## Phase 7: CI/CD & Infrastructure Enhancements

### High Priority
25. [ ] **Multi-Host CI Pipeline** — Build and test all hosts `[M]`
    - Matrix builds for all host configurations
    - Per-branch workflows (feature branches build affected hosts)
    - Parallel builds where dependencies allow
    - Build time optimization and caching

26. [ ] **Binary Caching Strategy** — Attic/Cachix implementation `[M]`
    - Attic binary cache server setup (or Cachix managed)
    - CI populates cache on successful builds
    - All hosts configured as cache clients
    - Cache garbage collection and retention policies

27. [ ] **Hercules CI Integration** — Nix-native CI enhancement `[M]`
    - Complete Hercules CI module integration
    - OpNix secrets integration for CI tokens
    - Automated binary cache management
    - CI/CD workflow optimization

28. [ ] **Deployment Workflows** — Staging and production deploys `[L]`
    - Staging deployment to Contabo VPS (automatic on main)
    - Production deployment to Hetzner VPS (manual approval)
    - Pre-deployment validation checks
    - Automatic rollback on health check failures
    - Deployment audit logging

### Medium Priority
29. [ ] **Secrets Management Enhancement** — 1Password + OpNix `[M]`
    - Complete OpNix integration for all secrets
    - CI tokens and service credentials
    - Secrets rotation automation
    - Audit trail and access management

30. [ ] **Tailscale Mesh VPN** — Host networking `[S]`
    - Tailscale configuration for all hosts
    - Mesh networking between devices
    - SSH access via Tailscale IPs
    - Firewall and security policies

## Phase 8: Servers & Advanced Services (FUTURE)

### High Priority
31. [ ] **Production Monitoring** — Datadog integration `[L]`
    - Datadog agent deployment across all hosts
    - Service monitoring and alerting
    - Custom dashboards for different host types
    - Performance metrics collection

32. [ ] **Optional Monitoring Stack** — Prometheus/Grafana/Loki `[L]`
    - Prometheus metrics collection
    - Grafana dashboard configuration
    - Loki log aggregation
    - Alertmanager setup
    - node_exporter and service exporters

33. [ ] **Backup & Disaster Recovery** — Comprehensive backup strategy `[L]`
    - Btrfs snapshot automation with retention policies
    - Backblaze B2 integration for offsite backups
    - Database-aware storage layouts
    - Disaster recovery procedures

### Medium Priority
34. [ ] **Containerized Services** — Podman workloads `[M]`
    - Podman configuration with Btrfs optimization
    - Container image storage optimization
    - Volume management for containers
    - Container orchestration for personal services

35. [ ] **Database Storage Optimization** — Workload-specific tuning `[M]`
    - Database-centric Btrfs mount options
    - Performance optimization for different database engines
    - Backup integration for databases
    - Storage layout for mixed workloads

36. [ ] **Security Hardening** — SSH and network security `[S]`
    - SSH hardening module completion
    - Firewall configuration for VPS hosts
    - Security scanning and validation
    - Compliance with best practices

## Phase 9: Hardware-Aware Optimization (FUTURE)

### High Priority
37. [ ] **Hardware Detection System** — Automatic hardware profiling `[M]`
    - nixos-facter-modules integration
    - Automatic hardware detection for all hosts
    - Dynamic configuration based on hardware
    - Hardware-specific documentation

38. [ ] **Btrfs Optimization Suite** — Workload-specific tuning `[L]`
    - Development workload optimization (Zephyrus)
    - Container workload tuning (all hosts)
    - Database workload optimization (servers)
    - Mount option matrices (compression, autodefrag, noatime, nodatacow, discard)

39. [ ] **Disko Layout Generator** — Automated partitioning `[M]`
    - Cluster-wide Disko generation
    - Per-host partitioning strategies
    - Subvolume tree generation
    - Configuration validation

### Medium Priority
40. [ ] **Snapshot & Backup Automation** — Comprehensive backup system `[M]`
    - Automated snapshot creation
    - Backup send/receive automation
    - Retention policy management
    - Backup health monitoring

41. [ ] **Performance Monitoring** — Hardware-specific metrics `[S]`
    - NVMe SSD monitoring for Zephyrus
    - VPS storage monitoring
    - Performance baseline establishment
    - Optimization recommendations

## Phase 10: Documentation & Examples (ONGOING)

### Medium Priority
42. [ ] **Implementation Guides** — Step-by-step documentation `[S]`
    - Hardware setup guides
    - Configuration customization guides
    - Module development guides
    - Troubleshooting documentation

43. [ ] **Deployment Guides** — Production deployment procedures `[M]`
    - Staging deployment procedures
    - Production deployment workflows
    - Disaster recovery documentation
    - Security checklist

44. [ ] **Desktop Environment Docs** — User guides `[S]`
    - DankMaterialShell customization
    - Niri configuration reference
    - Productivity tips and workflows
    - ADHD-friendly usage patterns

45. [ ] **Neovim Learning Guide** — Progressive skill building `[S]`
    - Week-by-week learning plan
    - Essential motions and commands
    - Plugin usage tutorials
    - Habit-building recommendations

46. [ ] **AI Integration Guide** — AI workflow documentation `[S]`
    - OpenCode/OpenAgent usage guide
    - MCP server configuration
    - AI-assisted development workflows
    - Best practices for AI integration

### Lower Priority
47. [ ] **Architecture Documentation** — System design `[S]`
    - System architecture overview
    - Module dependency diagrams
    - Data flow documentation
    - Design decisions and rationale

48. [ ] **Hardware Reports** — Device-specific documentation `[S]`
    - Zephyrus laptop configuration report
    - Yoga laptop optimization guide
    - VPS configuration profiles
    - Performance benchmarks

## Technical Debt and Maintenance

### Ongoing
49. [ ] **Nixpkgs Updates** — Regular updates and security patches `[CONTINUOUS]`
    - Monthly nixpkgs updates
    - Security vulnerability scanning
    - Dependency update testing
    - Channel management

50. [ ] **Module Maintenance** — Keep modules current `[CONTINUOUS]`
    - Regular module updates
    - Compatibility testing
    - Performance optimization
    - Bug fixes and improvements

51. [ ] **Test Maintenance** — Keep tests healthy `[CONTINUOUS]`
    - Update tests when modules change
    - Fix flaky tests promptly
    - Expand test coverage over time
    - Monitor test execution time

52. [ ] **Documentation Maintenance** — Keep docs aligned `[CONTINUOUS]`
    - Update documentation with changes
    - Review and refine guides
    - Maintain code examples
    - User feedback integration

## Notes

### Effort Scale
- **XS**: 1 day (small features, documentation updates)
- **S**: 2-3 days (simple implementations, basic configuration)
- **M**: 1 week (moderate complexity features, integration work)
- **L**: 2 weeks (complex multi-component features, major integrations)
- **XL**: 3+ weeks (major architectural changes, extensive testing)

### Current Status
**Phase 1 (Foundation)** - COMPLETE
- Core infrastructure and CI/CD pipeline operational
- Basic host configurations working end-to-end

**Phase 2 (Configuration Cleanup)** - NEW, HIGH PRIORITY
- flake-parts migration needed
- Host profiles system to be created
- Module refactoring required

**Phase 3 (Testing Framework)** - NEW, HIGH PRIORITY
- nix-unit integration planned
- NixOS VM tests to be implemented
- CI test integration needed

**Phase 4 (Personal Devices)** - IN PROGRESS
- Zephyrus and Yoga configurations being enhanced
- Desktop environment in active development

**Phase 5 (Developer Experience)** - NEW
- Terminal tooling stack to be configured
- Core CLI tools to be documented and packaged

**Phase 6 (Neovim/nixvim)** - NEW
- Beginner-friendly config to be built
- Habit-building plugins to be integrated

**Phase 7 (CI/CD & Infrastructure)** - PLANNED
- Deeper CI/CD integration planned next
- Binary caching and deploy workflows on roadmap

### Success Metrics
- **Setup Time**: < 30 minutes for new host (from hours/days)
- **Reproducibility**: 100% configuration consistency across all hosts
- **Test Coverage**: >80% of critical modules covered by unit tests
- **CI Pipeline**: All hosts build and test in < 15 minutes
- **Developer Productivity**: +50% improvement through AI-assisted workflows
- **Backup Success Rate**: 99.9% automated backup success
- **Monitoring Coverage**: 100% of hosts monitored with alerts
- **Security Compliance**: 100% SSH hardening across all hosts
- **Neovim Adoption**: Measurable reduction in mouse usage over 30 days

### Dependencies
- Phase 2 (Cleanup) should precede Phase 3 (Testing) for cleaner test targets
- Phase 3 (Testing) enables confident changes in all subsequent phases
- Phase 4 builds on Phase 1 infrastructure
- Phase 5/6 (Dev Experience/Neovim) can proceed in parallel
- Phase 7 requires completed personal device configurations
- Phase 8 depends on Phase 7 CI/CD and infrastructure
- Phase 9 hardware-aware features build on all previous phases
- Documentation (Phase 10) is ongoing throughout all phases

### Hardware-Specific Considerations
- **Zephyrus laptop**: Dual NVMe SSD configuration, development workload optimization, power management
- **Yoga laptop**: Different hardware profile, mobile optimization, travel-friendly setup
- **Hetzner VPS**: Production workloads, database storage, container services
- **Contabo VPS**: Staging environment, deployment testing
- **OVH VPS**: Additional server capacity, workload distribution

### Recommended Development Tool Baseline
The following tools form the recommended base development environment:
- **Shell**: Fish with starship prompt
- **Terminal**: Ghostty + Zellij
- **File ops**: ripgrep, fd, bat, eza, fzf, zoxide
- **Git**: delta, lazygit, gh
- **Data**: jq, yq
- **Editors**: Neovim (nixvim), Zed
- **AI**: Claude CLI, Copilot CLI
- **Nix**: nil, nixd, alejandra, statix, deadnix, nix-tree
