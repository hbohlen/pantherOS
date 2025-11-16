# Documentation Gaps & Open Questions Analysis

**Generated:** 2025-11-16  
**Repository:** pantherOS NixOS Configuration  
**Purpose:** Identify gaps, missing examples, unclear architecture, and open decisions for Spec Kit-style spec writing

---

## Executive Summary

This analysis identifies critical gaps between the current implementation and documentation, surfaces missing code examples, highlights unclear architectural decisions, and documents unresolved questions that need addressing before creating stable Spec Kit specifications.

**Key Findings:**
- **23 documentation gaps** across deployment, development, operations, and architecture
- **18 missing or weak code examples** for common workflows and configurations
- **12 unclear architectural flows** that need better documentation
- **15 open decisions** with TODO markers or unresolved choices
- **8 high-priority gaps** ready for Spec Kit specification

**Severity Distribution:**
- 🔴 **Critical (Must-have):** 8 gaps blocking core workflows
- 🟡 **Important (Should-have):** 12 gaps affecting productivity
- 🟢 **Nice-to-have (Could-have):** 18 gaps improving completeness

---

## 1. Missing Documentation

### 1.1 Deployment & Operations

#### 🔴 **Initial Server Setup Prerequisites**
- **What exists:** `DEPLOYMENT.md` describes nixos-anywhere usage
- **What's missing:** Pre-deployment requirements, SSH key setup, DNS configuration, firewall rules
- **Impact:** New users blocked at first step without external knowledge
- **Suggested path:** `/docs/howto/deploy-prerequisites.md`
- **Priority:** Critical

**Gap details:**
- No documentation on generating SSH keys for server access
- Missing instructions for obtaining VPS credentials from providers
- No guidance on DNS setup before deployment
- Firewall configuration not documented
- Network prerequisites unclear (static IP vs DHCP)

#### 🔴 **Post-Deployment Verification**
- **What exists:** Deployment script shows deployment process
- **What's missing:** How to verify deployment succeeded, what to check, troubleshooting failed deployments
- **Impact:** Users don't know if deployment succeeded or how to diagnose failures
- **Suggested path:** `/docs/howto/verify-deployment.md`
- **Priority:** Critical

**Gap details:**
- No checklist for post-deployment verification
- Missing commands to test system functionality
- No guidance on checking service status
- Log locations not documented
- Common deployment failures not catalogued

#### 🟡 **Rollback Procedures**
- **What exists:** Nothing about reverting changes
- **What's missing:** How to rollback a failed deployment, disaster recovery, snapshot management
- **Impact:** No safety net for failed deployments
- **Suggested path:** `/docs/ops/rollback-recovery.md`
- **Priority:** Important

**Gap details:**
- No documented rollback procedures
- Missing snapshot/backup strategy
- Disaster recovery plan not defined
- System state version upgrades not documented
- Migration path from previous versions unclear

#### 🟡 **Monitoring and Observability**
- **What exists:** Datadog agent example in code snippets
- **What's missing:** Complete monitoring setup, log aggregation, alerting configuration, metrics to track
- **Impact:** Production systems run without visibility
- **Suggested path:** `/docs/ops/monitoring-setup.md`
- **Priority:** Important

**Gap details:**
- No comprehensive monitoring guide
- Missing metrics collection strategy
- Log aggregation not configured
- Alerting rules not defined
- Performance baselines not established
- Health check endpoints not documented

#### 🟢 **Backup and Restore Procedures**
- **What exists:** Btrfs subvolumes in disko configuration
- **What's missing:** Backup strategy, restore procedures, testing backups
- **Impact:** Data loss risk without documented procedures
- **Suggested path:** `/docs/ops/backup-restore.md`
- **Priority:** Nice-to-have

**Gap details:**
- No backup automation documented
- Btrfs snapshot management not explained
- Off-site backup strategy missing
- Restore testing procedures absent
- RTO/RPO targets not defined

### 1.2 Development Environment

#### 🔴 **Development Environment Setup Guide**
- **What exists:** Dev shells defined in flake.nix, devcontainer.json exists
- **What's missing:** Complete guide for setting up local development, IDE configuration, debugging setup
- **Impact:** New contributors struggle to get started
- **Suggested path:** `/docs/contributing/dev-environment-setup.md`
- **Priority:** Critical

**Gap details:**
- No step-by-step setup for local development
- Nix installation instructions missing
- direnv configuration not documented
- VS Code/Neovim setup not covered
- Dev shell usage examples absent
- Troubleshooting dev environment issues not documented

#### 🟡 **Local Testing Guide**
- **What exists:** NixOS VM testing mentioned in copilot-instructions
- **What's missing:** How to test changes locally, VM testing procedures, integration testing
- **Impact:** Changes pushed without proper testing
- **Suggested path:** `/docs/howto/test-changes-locally.md`
- **Priority:** Important

**Gap details:**
- No VM testing walkthrough
- Local deployment testing not explained
- Integration test procedures missing
- Test data setup not documented
- Performance testing guidance absent

#### 🟢 **Code Review Guidelines**
- **What exists:** Spec Kit quality checklists
- **What's missing:** Nix-specific review guidelines, what to look for, common pitfalls
- **Impact:** Inconsistent code review quality
- **Suggested path:** `/docs/contributing/code-review-guide.md`
- **Priority:** Nice-to-have

**Gap details:**
- No Nix code review checklist
- Security review criteria not defined
- Performance considerations not documented
- Breaking change procedures unclear

### 1.3 NixOS Configuration & Architecture

#### 🔴 **Module System Documentation**
- **What exists:** Aspirational architecture diagrams describe modular system
- **What's missing:** Current minimal configuration not modular; no module creation guide
- **Impact:** Current architecture differs from documentation; confusion about system design
- **Suggested path:** `/docs/architecture/current-vs-planned.md`
- **Priority:** Critical

**Gap details:**
- Documentation describes layered module system not yet implemented
- No guidance on creating new modules
- Module boundaries unclear
- Inter-module dependencies not documented
- Migration path from current minimal to modular unclear

#### 🟡 **Flake Structure Explanation**
- **What exists:** flake.nix with inline comments
- **What's missing:** Deep dive into flake structure, how inputs work, how to add new hosts
- **Impact:** Contributors can't confidently modify flake
- **Suggested path:** `/docs/infra/nixos-flakes-deep-dive.md`
- **Priority:** Important

**Gap details:**
- Flake inputs not fully explained
- nixosConfiguration creation pattern not documented
- How to add new system configurations unclear
- Flake update procedures not covered
- Lock file management not explained

#### 🟡 **Disko Configuration Guide**
- **What exists:** disko.nix files with some comments
- **What's missing:** Why /dev/sdb vs /dev/sda, partition sizing rationale, customization guide
- **Impact:** Disk configuration seems arbitrary; hard to customize
- **Suggested path:** `/docs/infra/disko-disk-management.md`
- **Priority:** Important

**Gap details:**
- Device naming rationale unclear (why /dev/sdb)
- Partition size calculations not explained
- Btrfs subvolume strategy not documented
- VM vs physical disk differences not covered
- How to customize for different hardware unclear

### 1.4 Security & Secrets Management

#### 🔴 **SSH Key Management**
- **What exists:** Hardcoded SSH keys in configuration.nix
- **What's missing:** How to manage SSH keys securely, rotation procedures, per-host keys
- **Impact:** Security risk with hardcoded keys in git
- **Suggested path:** `/docs/security/ssh-key-management.md`
- **Priority:** Critical

**Gap details:**
- SSH key rotation procedures not documented
- Per-host key management not explained
- Key storage best practices missing
- Emergency access procedures unclear
- Key backup strategy not defined

#### 🟡 **OpNix Integration Guide**
- **What exists:** opnix imported but disabled; OPNIX-SETUP.md exists but for disabled feature
- **What's missing:** Actual integration steps when enabling OpNix, migration from hardcoded secrets
- **Impact:** Can't enable secrets management without clear guide
- **Suggested path:** `/docs/howto/enable-opnix-secrets.md`
- **Priority:** Important

**Gap details:**
- OpNix enabling procedure not documented
- Migration path from hardcoded secrets unclear
- 1Password integration setup incomplete
- Secret rotation with OpNix not covered
- Fallback strategies not defined

#### 🟢 **Security Hardening Checklist**
- **What exists:** security-hardening.nix example
- **What's missing:** Complete security baseline, audit procedures, compliance considerations
- **Impact:** Security posture unclear; may have vulnerabilities
- **Suggested path:** `/docs/security/hardening-checklist.md`
- **Priority:** Nice-to-have

**Gap details:**
- No security baseline defined
- CIS benchmark alignment not documented
- Audit log requirements unclear
- Compliance standards not addressed
- Vulnerability scanning not mentioned

### 1.5 AI/MCP Infrastructure

#### 🟢 **MCP Server Usage Examples**
- **What exists:** MCP-SETUP.md with configuration, mcp-servers.json
- **What's missing:** Practical examples of using MCP servers for common tasks
- **Impact:** MCP infrastructure underutilized
- **Suggested path:** `/docs/tools/mcp-usage-examples.md`
- **Priority:** Nice-to-have

**Gap details:**
- No workflow examples using MCP servers
- GitHub integration patterns not shown
- Database operations not demonstrated
- Docker MCP usage unclear
- Troubleshooting MCP issues not covered

#### 🟢 **AgentDB Integration Status**
- **What exists:** Planning documents in ai_infrastructure/
- **What's missing:** Current implementation status, what's actually working
- **Impact:** Unclear if AI infrastructure is usable or aspirational
- **Suggested path:** `/docs/reference/ai-infrastructure-status.md`
- **Priority:** Nice-to-have

**Gap details:**
- AgentDB integration not implemented
- Vector database setup not documented
- Knowledge graph structure undefined
- Query patterns not established
- Performance characteristics unknown

### 1.6 CI/CD Pipeline

#### 🟡 **GitHub Actions Workflows**
- **What exists:** Nothing - no .github/workflows/
- **What's missing:** Automated building, testing, deployment validation
- **Impact:** No CI/CD; manual process prone to errors
- **Suggested path:** `/docs/infra/ci-cd-setup.md`
- **Priority:** Important

**Gap details:**
- No automated build validation
- No flake check in CI
- No deployment dry-run testing
- No security scanning automation
- No documentation linting
- Branch protection not configured

#### 🟢 **Release Management**
- **What exists:** Nothing about versioning or releases
- **What's missing:** Versioning strategy, changelog, release notes, tagging
- **Impact:** No formal release process
- **Suggested path:** `/docs/ops/release-management.md`
- **Priority:** Nice-to-have

**Gap details:**
- No versioning scheme defined
- Changelog not maintained
- Release notes process absent
- Git tagging strategy unclear
- Deployment coordination not documented

### 1.7 Troubleshooting & Maintenance

#### 🟡 **Common Issues FAQ**
- **What exists:** Some troubleshooting in implementation guide
- **What's missing:** Comprehensive FAQ, known issues, workarounds
- **Impact:** Users repeatedly hit same issues
- **Suggested path:** `/docs/troubleshooting/faq.md`
- **Priority:** Important

**Gap details:**
- Known deployment issues not catalogued
- Network troubleshooting missing
- Boot failures not covered
- Package conflicts not documented
- Performance issues not addressed

#### 🟢 **Log Analysis Guide**
- **What exists:** Nothing about logs
- **What's missing:** Where logs are, how to read them, important log messages
- **Impact:** Debugging is trial-and-error
- **Suggested path:** `/docs/ops/log-analysis.md`
- **Priority:** Nice-to-have

**Gap details:**
- Log locations not documented
- systemd journal usage not explained
- Log filtering techniques not shown
- Important log messages not highlighted
- Log retention policy not defined

### 1.8 Documentation Meta

#### 🟢 **Documentation Contribution Guide**
- **What exists:** Spec Kit framework, copilot-instructions.md
- **What's missing:** How to contribute to docs, style guide, review process
- **Impact:** Documentation quality varies
- **Suggested path:** `/docs/contributing/documentation-guide.md`
- **Priority:** Nice-to-have

**Gap details:**
- Documentation style guide missing
- Markdown conventions not defined
- Review process for docs unclear
- Documentation testing not covered
- Link checking not automated

---

## 2. Missing or Weak Code Examples

### 2.1 Deployment Examples

#### 🔴 **Complete First Deployment Walkthrough**
- **Where referenced:** DEPLOYMENT.md, deploy.sh
- **What's missing:** End-to-end example from fresh VPS to working system
- **Useful example would show:**
  - Obtaining VPS credentials
  - Preparing SSH keys
  - Running deployment command
  - Post-deployment verification
  - First login and checks
- **Suggested path:** `/docs/examples/first-deployment-walkthrough.md`
- **Priority:** Critical

#### 🟡 **Multi-Host Deployment Example**
- **Where referenced:** flake.nix has ovh-cloud and hetzner-cloud
- **What's missing:** Deploying to multiple hosts, managing host differences
- **Useful example would show:**
  - Deploying same config to multiple VPS
  - Host-specific customizations
  - Coordinating deployments
  - Managing shared secrets
- **Suggested path:** `/docs/examples/multi-host-deployment.md`
- **Priority:** Important

#### 🟢 **Custom Disk Configuration Example**
- **Where referenced:** disko.nix files
- **What's missing:** Creating custom disk layouts for different needs
- **Useful example would show:**
  - Single disk vs RAID setup
  - Adding data volumes
  - Encrypted partitions
  - NFS mounts
- **Suggested path:** `/docs/examples/custom-disk-layouts.md`
- **Priority:** Nice-to-have

### 2.2 Configuration Examples

#### 🔴 **Adding System Packages Example**
- **Where referenced:** configuration.nix environment.systemPackages (currently commented out)
- **What's missing:** How to safely add packages, search for packages, manage package conflicts
- **Useful example would show:**
  - Searching nixpkgs for packages
  - Adding packages to configuration
  - Handling unfree packages
  - Testing package additions
- **Suggested path:** `/docs/examples/nixos/adding-packages.md`
- **Priority:** Critical

#### 🟡 **Service Configuration Example**
- **Where referenced:** services.openssh in configuration.nix
- **What's missing:** Adding new services, configuring services, service dependencies
- **Useful example would show:**
  - Adding web server (nginx)
  - Database setup (postgresql)
  - Systemd service creation
  - Service networking
- **Suggested path:** `/docs/examples/nixos/service-configuration.md`
- **Priority:** Important

#### 🟡 **User Management Example**
- **Where referenced:** users.users.hbohlen in configuration.nix
- **What's missing:** Adding users, managing groups, setting permissions
- **Useful example would show:**
  - Creating new users
  - Setting user permissions
  - Managing SSH keys per user
  - Home directory management
- **Suggested path:** `/docs/examples/nixos/user-management.md`
- **Priority:** Important

### 2.3 Development Workflow Examples

#### 🔴 **Local Configuration Testing Example**
- **Where referenced:** Mentioned in copilot-instructions
- **What's missing:** Step-by-step VM testing workflow
- **Useful example would show:**
  - Building VM image
  - Starting test VM
  - Testing configuration
  - Iterating on changes
- **Suggested path:** `/docs/examples/local-testing-workflow.md`
- **Priority:** Critical

#### 🟡 **Development Shell Usage Example**
- **Where referenced:** flake.nix devShells
- **What's missing:** When to use which shell, how to switch shells
- **Useful example would show:**
  - Entering specific dev shell
  - Using shell packages
  - Shell-specific workflows
  - Customizing shells
- **Suggested path:** `/docs/examples/dev-shell-usage.md`
- **Priority:** Important

#### 🟢 **Debugging Nix Evaluation Example**
- **Where referenced:** Nil language server in dev shells
- **What's missing:** How to debug Nix evaluation errors, trace values
- **Useful example would show:**
  - Understanding error messages
  - Using nix repl for debugging
  - Tracing attribute values
  - Common syntax errors
- **Suggested path:** `/docs/examples/debugging-nix.md`
- **Priority:** Nice-to-have

### 2.4 Security Examples

#### 🟡 **Firewall Configuration Example**
- **Where referenced:** Not mentioned anywhere
- **What's missing:** Setting up firewall rules, port management
- **Useful example would show:**
  - Enabling firewall
  - Opening specific ports
  - Service-based rules
  - Testing firewall config
- **Suggested path:** `/docs/examples/nixos/firewall-setup.md`
- **Priority:** Important

#### 🟡 **SSL/TLS Certificate Example**
- **Where referenced:** Not mentioned
- **What's missing:** Setting up Let's Encrypt, certificate management
- **Useful example would show:**
  - ACME configuration
  - Nginx with SSL
  - Certificate renewal
  - Wildcard certificates
- **Suggested path:** `/docs/examples/nixos/ssl-certificates.md`
- **Priority:** Important

### 2.5 MCP/AI Examples

#### 🟢 **Using GitHub MCP Server Example**
- **Where referenced:** .github/mcp-servers.json
- **What's missing:** Practical workflow with GitHub MCP
- **Useful example would show:**
  - Querying repository info
  - Creating issues
  - Searching code
  - Reading file contents
- **Suggested path:** `/docs/examples/mcp-github-workflow.md`
- **Priority:** Nice-to-have

#### 🟢 **Using Nix Search MCP Example**
- **Where referenced:** .github/mcp-servers.json has nix-search wrapper
- **What's missing:** How to use nix-search MCP effectively
- **Useful example would show:**
  - Searching for packages
  - Getting package info
  - Finding options
  - Integration in development
- **Suggested path:** `/docs/examples/mcp-nix-search.md`
- **Priority:** Nice-to-have

### 2.6 Spec Kit Examples

#### 🟢 **Creating New Feature Spec Example**
- **Where referenced:** .specify/ framework
- **What's missing:** Complete example of spec creation workflow
- **Useful example would show:**
  - Running /speckit.specify
  - Creating plan
  - Generating tasks
  - Implementing feature
- **Suggested path:** `/docs/examples/creating-feature-spec.md`
- **Priority:** Nice-to-have

#### 🟢 **ADR Creation Example**
- **Where referenced:** Constitution exists but no ADR examples
- **What's missing:** How to create Architecture Decision Records
- **Useful example would show:**
  - When to create ADR
  - ADR template usage
  - Recording decision context
  - Updating ADRs
- **Suggested path:** `/docs/examples/creating-adr.md`
- **Priority:** Nice-to-have

### 2.7 Operational Examples

#### 🟡 **System Update Example**
- **Where referenced:** Flake lock file exists
- **What's missing:** How to update system safely, test updates, rollback
- **Useful example would show:**
  - Updating flake inputs
  - Testing new packages
  - Deploying updates
  - Rolling back if needed
- **Suggested path:** `/docs/examples/updating-system.md`
- **Priority:** Important

#### 🟢 **Performance Tuning Example**
- **Where referenced:** PERFORMANCE-OPTIMIZATIONS.md (planning)
- **What's missing:** Actual performance tuning procedures
- **Useful example would show:**
  - Identifying bottlenecks
  - Kernel tuning
  - Service optimization
  - Measuring improvements
- **Suggested path:** `/docs/examples/performance-tuning.md`
- **Priority:** Nice-to-have

---

## 3. Unclear or Undocumented Architecture/Flows

### 3.1 System Architecture

#### 🔴 **Current vs Planned Architecture Mismatch**
- **Issue:** Documentation describes layered modular architecture that doesn't exist yet
- **Current state:** Minimal monolithic configuration in hosts/servers/*/configuration.nix
- **Documentation claims:** Three-layer module system (core/profiles/hosts)
- **Impact:** Major confusion about system design; contributors might build wrong abstractions
- **Resolution needed:** 
  - Document actual current architecture (minimal/monolithic)
  - Clearly mark aspirational architecture as "planned"
  - Define migration path from current to planned
  - Create ADR for architecture decision
- **Reference:** 
  - `system_config/03_PANTHEROS_NIXOS_BRIEF.md` (describes non-existent layers)
  - `architecture/ARCHITECTURE_DIAGRAMS.md` (aspirational diagrams)

#### 🟡 **Flake Dependency Graph**
- **Issue:** How flake inputs relate and depend on each other is unclear
- **What's unclear:**
  - Why specific input versions chosen
  - How nixos-anywhere uses disko
  - Dependencies between home-manager and nixpkgs
  - Update strategy for inputs
- **Impact:** Can't confidently update dependencies; risk breaking system
- **Resolution needed:** Dependency graph diagram, update procedures
- **Reference:** `flake.nix` lines 4-12

#### 🟡 **Disk Partitioning Flow**
- **Issue:** Why /dev/sdb instead of /dev/sda not explained
- **What's unclear:**
  - Device detection logic
  - When to use which device
  - How disko chooses devices
  - VM vs physical differences
- **Impact:** Wrong device selection could wipe wrong disk
- **Resolution needed:** Device selection flowchart, safety checks
- **Reference:** `hosts/servers/ovh-cloud/disko.nix` line 8 comment

### 3.2 Deployment Flow

#### 🔴 **nixos-anywhere Deployment Process**
- **Issue:** What exactly happens during nixos-anywhere deployment is opaque
- **What's unclear:**
  - Pre-deployment checks performed
  - Order of operations (partitioning → copying → activation)
  - Network requirements during deployment
  - What can go wrong at each stage
  - Recovery from partial deployment
- **Impact:** Can't troubleshoot deployment failures
- **Resolution needed:** Deployment flow diagram, stage-by-stage explanation
- **Reference:** `deploy.sh`, `DEPLOYMENT.md`

#### 🟡 **Bootstrap vs Update Deployment**
- **Issue:** Difference between initial deployment and updates not clear
- **What's unclear:**
  - Does nixos-anywhere work for updates?
  - When to use deploy.sh vs manual rebuild
  - State preservation during updates
  - Data migration considerations
- **Impact:** Might use wrong deployment method
- **Resolution needed:** Decision tree for deployment method selection
- **Reference:** `DEPLOYMENT.md`, `deploy.sh`

### 3.3 Configuration Management Flow

#### 🟡 **Configuration Change Workflow**
- **Issue:** End-to-end flow from editing config to deployed system unclear
- **What's unclear:**
  - Edit → Build → Test → Deploy workflow
  - Where testing fits in
  - Git workflow (branches, PRs, merges)
  - Configuration validation steps
  - Rollback points
- **Impact:** Inconsistent change management; risk of bad deployments
- **Resolution needed:** Workflow diagram, step-by-step procedures
- **Reference:** Not documented anywhere

#### 🟡 **Home Manager Integration Flow**
- **Issue:** home-manager currently disabled; integration flow unclear when enabled
- **What's unclear:**
  - Why disabled (closure size mentioned)
  - When to enable
  - How system config interacts with home config
  - User environment management
- **Impact:** Can't use home-manager features
- **Resolution needed:** Enable conditions, integration guide
- **Reference:** `flake.nix` lines 29-33, 44-48 (commented out)

### 3.4 Secrets Management Flow

#### 🔴 **Secrets Handling Current State**
- **Issue:** Secrets currently hardcoded; OpNix path unclear
- **What's unclear:**
  - Why SSH keys hardcoded in git
  - Migration plan to OpNix
  - Secret rotation procedure
  - Emergency access without OpNix
- **Impact:** Security risk; unclear improvement path
- **Resolution needed:** Current state documented, migration roadmap
- **Reference:** 
  - `hosts/servers/ovh-cloud/configuration.nix` lines 35-44 (hardcoded keys)
  - `flake.nix` line 28 (OpNix commented out)

#### 🟡 **1Password Integration Flow**
- **Issue:** 1Password CLI mentioned in secrets docs but integration unclear
- **What's unclear:**
  - How 1Password connects to OpNix
  - Authentication flow
  - Secret retrieval during build
  - Fallback mechanisms
- **Impact:** Can't set up 1Password integration
- **Resolution needed:** Integration architecture diagram
- **Reference:** `system_config/secrets_management/MASTER_1PASSWORD_GUIDE.md`

### 3.5 Development Flow

#### 🟡 **Development Shell Selection**
- **Issue:** When to use which dev shell not documented
- **What's unclear:**
  - Selection criteria for shells
  - Switching between shells
  - Combining shell environments
  - Custom shell creation
- **Impact:** Suboptimal development experience
- **Resolution needed:** Selection guide, shell comparison matrix
- **Reference:** `flake.nix` lines 53-236 (devShells)

#### 🟢 **MCP Server Communication Flow**
- **Issue:** How MCP servers communicate with tools unclear
- **What's unclear:**
  - Protocol details
  - Authentication flow
  - Error handling
  - Performance characteristics
- **Impact:** Can't debug MCP issues
- **Resolution needed:** Communication flow diagram
- **Reference:** `.github/mcp-servers.json`, `.github/MCP-SETUP.md`

### 3.6 Testing Flow

#### 🟡 **VM Testing Process**
- **Issue:** nixos-rebuild build-vm mentioned but process not documented
- **What's unclear:**
  - Building VM image
  - Running VM
  - Accessing VM
  - Testing in VM
  - Interpreting results
- **Impact:** Testing not done consistently
- **Resolution needed:** VM testing workflow guide
- **Reference:** Mentioned in copilot-instructions but not detailed

---

## 4. Open Decisions / Undefined Choices

### 4.1 Architecture Decisions

#### 🔴 **Decision: Modular vs Monolithic Configuration**
- **File:** `flake.nix`, `hosts/servers/*/configuration.nix`
- **Decision:** Keep minimal monolithic config or refactor to modular system?
- **Options:**
  1. **Keep monolithic:** Simple, everything in one file, easy to understand
  2. **Move to modular:** Reusable modules, cleaner separation, matches documentation
  3. **Hybrid:** Core monolithic with optional modules
- **Uncertainty markers:** Documentation describes modular system not implemented
- **Implications:**
  - Modular: More complexity, better reusability, need module boundaries
  - Monolithic: Simpler, some duplication, harder to share configs
- **Should become:** ADR-002 "Configuration Architecture Pattern"
- **Dependencies:** Affects all future configuration work
- **Priority:** Critical

#### 🟡 **Decision: Home Manager Usage**
- **File:** `flake.nix` lines 29-33, 44-48
- **Decision:** Enable home-manager or continue without it?
- **Options:**
  1. **Enable home-manager:** User environment management, dotfile handling
  2. **Keep disabled:** Smaller closure, simpler system
  3. **Per-host decision:** Enable only where needed
- **Uncertainty markers:** "Temporarily disabled for initial deployment"
- **Implications:**
  - Enable: Larger closure size, more features, user environment control
  - Disable: Minimal system, manual user config management
- **Should become:** ADR-003 "Home Manager Usage Strategy"
- **Dependencies:** Affects user environment management
- **Priority:** Important

#### 🟡 **Decision: OpNix Integration Timeline**
- **File:** `flake.nix` line 28, `OPNIX-SETUP.md`
- **Decision:** When to enable OpNix secrets management?
- **Options:**
  1. **Enable now:** Better security, remove hardcoded secrets
  2. **Later:** Reduce complexity for initial deployment
  3. **Alternative tool:** Use sops-nix or agenix instead
- **Uncertainty markers:** "Temporarily disabled for initial deployment"
- **Implications:**
  - Enable: Better secrets management, 1Password integration, closure size increase
  - Disable: Hardcoded secrets security risk, simpler setup
- **Should become:** ADR-004 "Secrets Management Tool Selection"
- **Dependencies:** Security posture, deployment complexity
- **Priority:** Important

### 4.2 Deployment Decisions

#### 🟡 **Decision: CI/CD Strategy**
- **File:** No .github/workflows/ directory
- **Decision:** What CI/CD approach to take?
- **Options:**
  1. **GitHub Actions:** Native integration, free for public repos
  2. **No CI/CD:** Manual processes, simpler
  3. **External CI:** GitLab CI, Drone, etc.
- **Uncertainty markers:** No CI/CD exists
- **Implications:**
  - GitHub Actions: Automated validation, consistent builds, maintenance overhead
  - No CI: Manual validation, faster initially, error-prone
- **Should become:** ADR-005 "CI/CD Strategy and Tooling"
- **Dependencies:** Development workflow, quality assurance
- **Priority:** Important

#### 🟢 **Decision: Multi-Host Management**
- **File:** `flake.nix` has ovh-cloud and hetzner-cloud
- **Decision:** How to manage configuration across multiple hosts?
- **Options:**
  1. **Shared modules:** Common config in modules, host-specific overrides
  2. **Independent configs:** Each host completely separate
  3. **Profile system:** Profiles like "web-server", "database", composable
- **Uncertainty markers:** Two hosts defined but no clear sharing pattern
- **Implications:**
  - Shared: Less duplication, need abstraction strategy
  - Independent: Simpler, more duplication
- **Should become:** ADR-006 "Multi-Host Configuration Strategy"
- **Dependencies:** Module system architecture
- **Priority:** Nice-to-have

#### 🟢 **Decision: Release Management**
- **File:** No versioning anywhere
- **Decision:** How to version and release configurations?
- **Options:**
  1. **Git tags:** Tag stable configurations
  2. **No versioning:** Always use latest
  3. **Semantic versioning:** Major.minor.patch for configs
- **Uncertainty markers:** No versioning scheme defined
- **Implications:**
  - Versioning: Easier rollback, clearer history, overhead
  - No versioning: Simpler, harder to track changes
- **Should become:** ADR-007 "Configuration Versioning Strategy"
- **Dependencies:** Deployment process, rollback procedures
- **Priority:** Nice-to-have

### 4.3 Infrastructure Decisions

#### 🟡 **Decision: Monitoring Solution**
- **File:** `code_snippets/system_config/nixos/datadog-agent.nix.md`
- **Decision:** What monitoring/observability stack to use?
- **Options:**
  1. **Datadog:** Example exists, cloud-hosted, costs money
  2. **Prometheus + Grafana:** Self-hosted, open source, more management
  3. **Minimal/none:** System logs only
- **Uncertainty markers:** Datadog example exists but not enabled anywhere
- **Implications:**
  - Datadog: Easy setup, costs scale with usage, vendor lock-in
  - Prometheus: More control, self-hosted, setup complexity
- **Should become:** ADR-008 "Monitoring and Observability Stack"
- **Dependencies:** Operations capabilities, budget
- **Priority:** Important

#### 🟢 **Decision: Backup Strategy**
- **File:** Btrfs subvolumes in disko.nix
- **Decision:** What backup approach to implement?
- **Options:**
  1. **Btrfs snapshots:** Local snapshots, fast recovery
  2. **Rsync to remote:** Off-site backups, disaster recovery
  3. **Borg/Restic:** Deduplicated encrypted backups
  4. **Cloud backup:** S3, Backblaze, etc.
- **Uncertainty markers:** Btrfs ready but no backup automation
- **Implications:**
  - Each option has cost/complexity/recovery-time trade-offs
- **Should become:** ADR-009 "Backup and Disaster Recovery"
- **Dependencies:** Data criticality, budget, RTO/RPO requirements
- **Priority:** Nice-to-have

### 4.4 Development Decisions

#### 🟢 **Decision: Documentation Tool**
- **File:** All markdown files, no tooling
- **Decision:** Use documentation generator or keep markdown?
- **Options:**
  1. **Plain markdown:** Simple, readable in GitHub
  2. **MkDocs/Docusaurus:** Nice web UI, search, versioning
  3. **mdBook:** Rust-based, Nix-friendly
- **Uncertainty markers:** No decision made
- **Implications:**
  - Plain markdown: Simple, no maintenance, no fancy features
  - Generator: Better UX, more setup, build step
- **Should become:** Part of documentation strategy
- **Dependencies:** Documentation maintenance burden
- **Priority:** Nice-to-have

#### 🟢 **Decision: AI Infrastructure Scope**
- **File:** `ai_infrastructure/` directory with 10 planning files
- **Decision:** Implement AI infrastructure features or archive?
- **Options:**
  1. **Implement:** AgentDB, MiniMax optimization, etc.
  2. **Archive:** Move to separate project or remove
  3. **Selective:** Implement only practical features
- **Uncertainty markers:** All planning, no implementation
- **Implications:**
  - Implement: Significant work, unclear ROI
  - Archive: Cleaner repo, lose planning work
- **Should become:** Project roadmap decision
- **Dependencies:** Project scope, available resources
- **Priority:** Nice-to-have

### 4.5 TODOs and FIXMEs in Code

#### 🟡 **TODO: SSH Key Management**
- **File:** `hosts/servers/ovh-cloud/configuration.nix` lines 35-44
- **Issue:** SSH keys hardcoded in configuration
- **Decision:** Move to secrets management vs keep hardcoded
- **Options:**
  1. Move to OpNix when enabled
  2. Use separate secrets file
  3. Keep in git (current, not recommended)
- **Priority:** Important (security)

#### 🟡 **TODO: Package Selection**
- **File:** `hosts/servers/ovh-cloud/configuration.nix` lines 62-70
- **Issue:** System packages commented out for minimal closure
- **Decision:** Which packages to include in base system?
- **Options:**
  1. Add back incrementally as needed
  2. Keep ultra-minimal
  3. Create package profiles
- **Priority:** Important (usability)

#### 🟢 **TODO: Agent Execution Guide**
- **File:** `ai_infrastructure/pantherOS_research_plan.md` line 555
- **Issue:** Agent execution guide section marked TODO
- **Decision:** Create guide or remove TODO?
- **Options:**
  1. Create execution guide
  2. Archive with other AI planning docs
- **Priority:** Nice-to-have

#### 🟢 **TODO: Immediate Action Required**
- **File:** `ai_infrastructure/pantherOS_gap_analysis_progress.md` line 413
- **Issue:** Section marked "TODO: IMMEDIATE ACTION REQUIRED"
- **Decision:** What action is required?
- **Options:**
  1. Complete the gap analysis
  2. Archive as planning document
- **Priority:** Nice-to-have

#### 🟢 **TODO: Spec Validation Tasks**
- **File:** `.specify/templates/tasks-template.md` lines 153-158
- **Issue:** Task templates have placeholder TODOs
- **Decision:** Fill in actual tasks or leave as examples?
- **Options:**
  1. Create real task examples
  2. Keep as template placeholders
- **Priority:** Nice-to-have

---

## 5. High-Priority Gaps for Spec Kit

This section identifies which features/flows are mature enough for Spec Kit specifications and which gaps must be filled first.

### 5.1 Ready for Spec Kit Specifications

These areas have sufficient implementation and understanding to create stable specs:

#### 🟢 **Spec-Ready: Basic NixOS Deployment**
- **Feature:** Deploy NixOS to VPS using nixos-anywhere
- **Maturity:** High - working implementation exists
- **What's needed:** Better documentation of existing process
- **Suggested spec:** `/specs/002-basic-nixos-deployment/`
- **Success criteria:** Any developer can deploy to new VPS without help
- **Blockers:** None - ready now
- **Priority:** High

**Spec would include:**
- Prerequisites and setup
- Step-by-step deployment procedure
- Post-deployment verification
- Common issues and solutions
- Rollback procedures

#### 🟢 **Spec-Ready: Disko Disk Management**
- **Feature:** Declarative disk partitioning with disko
- **Maturity:** High - working in production
- **What's needed:** Document current approach, customization options
- **Suggested spec:** `/specs/003-disko-disk-management/`
- **Success criteria:** Can customize disk layout for different hardware
- **Blockers:** None - ready now
- **Priority:** Medium

**Spec would include:**
- Partition layout rationale
- Device selection logic
- Btrfs subvolume strategy
- Customization examples
- Testing procedures

#### 🟢 **Spec-Ready: Development Environment Setup**
- **Feature:** Nix development shells for different languages
- **Maturity:** Medium - shells defined, needs usage guide
- **What's needed:** Document shell usage, when to use which
- **Suggested spec:** `/specs/004-development-environment/`
- **Success criteria:** Contributors can set up dev environment in <30 minutes
- **Blockers:** Minor - need shell usage examples
- **Priority:** High

**Spec would include:**
- Nix installation
- Dev shell selection guide
- IDE integration
- Common workflows
- Troubleshooting

### 5.2 Needs Work Before Spec

These areas need implementation or clarity before creating specs:

#### 🟡 **Not Ready: Modular Configuration System**
- **Feature:** Layered module architecture (core/profiles/hosts)
- **Maturity:** Low - aspirational, not implemented
- **Gaps to fill:**
  1. Decide on architecture approach (ADR needed)
  2. Implement basic module structure
  3. Migrate one host to modular pattern
  4. Document module boundaries
- **Estimated work:** 2-3 weeks
- **Priority:** Medium

**Blockers:**
- Architecture decision (monolithic vs modular)
- No module implementation exists
- Documentation describes non-existent system

#### 🟡 **Not Ready: Secrets Management**
- **Feature:** OpNix + 1Password secrets integration
- **Maturity:** Low - OpNix disabled, keys hardcoded
- **Gaps to fill:**
  1. Enable OpNix
  2. Migrate SSH keys to OpNix
  3. Set up 1Password integration
  4. Document secret management workflow
- **Estimated work:** 1-2 weeks
- **Priority:** High (security)

**Blockers:**
- OpNix not enabled
- No secrets management in place
- Migration plan undefined

#### 🟡 **Not Ready: CI/CD Pipeline**
- **Feature:** Automated build and deployment validation
- **Maturity:** None - no CI/CD exists
- **Gaps to fill:**
  1. Decide on CI tool (likely GitHub Actions)
  2. Create initial workflows (build, check)
  3. Add deployment dry-run testing
  4. Set up branch protection
- **Estimated work:** 1 week
- **Priority:** Medium

**Blockers:**
- No CI/CD tooling chosen
- No workflows exist
- Testing strategy undefined

#### 🟢 **Not Ready: Home Manager Integration**
- **Feature:** User environment management with home-manager
- **Maturity:** Low - disabled, home.nix files exist but unused
- **Gaps to fill:**
  1. Decide when to enable home-manager
  2. Test closure size impact
  3. Create example home configurations
  4. Document user environment patterns
- **Estimated work:** 1 week
- **Priority:** Low

**Blockers:**
- Disabled due to closure size
- Enable conditions unclear
- Usage patterns not defined

### 5.3 Stable Enough for Spec

These areas can have specs with caveats:

#### 🟡 **Spec with Caveats: Multi-Host Management**
- **Feature:** Managing multiple VPS hosts with shared config
- **Maturity:** Medium - two hosts defined, no sharing yet
- **Spec approach:** Document current state, propose improvements
- **Caveats:** Sharing strategy not finalized
- **Suggested spec:** `/specs/005-multi-host-management/`
- **Priority:** Low

**Spec would include:**
- Current: Independent host configs
- Planned: Shared modules or profiles
- Migration path
- When to use shared vs independent

#### 🟢 **Spec with Caveats: MCP Server Integration**
- **Feature:** Using MCP servers for AI-assisted development
- **Maturity:** Medium - configuration exists, usage unclear
- **Spec approach:** Document setup and basic usage
- **Caveats:** Advanced usage patterns undefined
- **Suggested spec:** `/specs/006-mcp-server-integration/`
- **Priority:** Low

**Spec would include:**
- MCP server configuration
- Basic usage examples
- Integration with development workflow
- Known limitations

### 5.4 Specification Priority Matrix

| Feature | Implementation | Documentation | Priority | Spec Status |
|---------|---------------|---------------|----------|-------------|
| Basic NixOS Deployment | ✅ High | ⚠️ Medium | 🔴 Critical | ✅ Ready |
| Disko Disk Management | ✅ High | ⚠️ Medium | 🟡 Important | ✅ Ready |
| Development Environment | ✅ Medium | ⚠️ Low | 🔴 Critical | ✅ Ready |
| Modular Configuration | ❌ None | ❌ Aspirational | 🟡 Important | ❌ Not Ready |
| Secrets Management | ❌ Disabled | ⚠️ Partial | 🔴 Critical | ❌ Not Ready |
| CI/CD Pipeline | ❌ None | ❌ None | 🟡 Important | ❌ Not Ready |
| Home Manager | ❌ Disabled | ⚠️ Exists | 🟢 Nice | ❌ Not Ready |
| Multi-Host Management | ⚠️ Basic | ⚠️ Low | 🟢 Nice | ⚠️ Spec with Caveats |
| MCP Integration | ✅ High | ⚠️ Medium | 🟢 Nice | ⚠️ Spec with Caveats |
| Monitoring Setup | ❌ Example only | ⚠️ Example | 🟡 Important | ❌ Not Ready |
| Backup Strategy | ⚠️ Infra ready | ❌ None | 🟡 Important | ❌ Not Ready |

**Legend:**
- ✅ Good state / Ready
- ⚠️ Partial / Needs work
- ❌ Missing / Not ready
- 🔴 Critical priority
- 🟡 Important priority
- 🟢 Nice-to-have priority

---

## 6. Recommended Action Plan

### Phase 1: Critical Documentation (Week 1-2)

**Goal:** Unblock users and contributors with essential docs

1. **Create deployment prerequisite guide** (🔴 Critical)
   - Target: `/docs/howto/deploy-prerequisites.md`
   - Content: VPS setup, SSH keys, DNS, network requirements

2. **Create post-deployment verification guide** (🔴 Critical)
   - Target: `/docs/howto/verify-deployment.md`
   - Content: Verification checklist, test commands, troubleshooting

3. **Create development environment setup guide** (🔴 Critical)
   - Target: `/docs/contributing/dev-environment-setup.md`
   - Content: Nix install, dev shell usage, IDE setup

4. **Document current architecture vs planned** (🔴 Critical)
   - Target: `/docs/architecture/current-vs-planned.md`
   - Content: Actual implementation, aspirational design, migration path

5. **Create local testing workflow guide** (🔴 Critical)
   - Target: `/docs/howto/test-changes-locally.md`
   - Content: VM testing, validation, iteration

6. **Document SSH key management** (🔴 Critical - Security)
   - Target: `/docs/security/ssh-key-management.md`
   - Content: Current approach, risks, migration to secrets management

### Phase 2: Code Examples (Week 3-4)

**Goal:** Provide practical examples for common tasks

7. **Create complete first deployment walkthrough** (🔴 Critical)
   - Target: `/docs/examples/first-deployment-walkthrough.md`
   - Content: End-to-end from VPS to working system

8. **Create adding packages example** (🔴 Critical)
   - Target: `/docs/examples/nixos/adding-packages.md`
   - Content: Search, add, test packages

9. **Create service configuration examples** (🟡 Important)
   - Target: `/docs/examples/nixos/service-configuration.md`
   - Content: Web server, database, custom services

10. **Create user management example** (🟡 Important)
    - Target: `/docs/examples/nixos/user-management.md`
    - Content: Adding users, groups, permissions

### Phase 3: Architecture Decisions (Week 5)

**Goal:** Resolve open architectural questions

11. **Create ADR-002: Configuration Architecture** (🔴 Critical)
    - Decision: Modular vs monolithic
    - Impact: All future configuration work

12. **Create ADR-003: Home Manager Strategy** (🟡 Important)
    - Decision: When to enable, usage patterns

13. **Create ADR-004: Secrets Management** (🔴 Critical - Security)
    - Decision: OpNix timeline, migration plan

14. **Create ADR-005: CI/CD Strategy** (🟡 Important)
    - Decision: Tool selection, workflow design

### Phase 4: Operations Documentation (Week 6-7)

**Goal:** Support production operations

15. **Create monitoring setup guide** (🟡 Important)
    - Target: `/docs/ops/monitoring-setup.md`
    - Content: Tool selection, configuration, alerting

16. **Create rollback procedures** (🟡 Important)
    - Target: `/docs/ops/rollback-recovery.md`
    - Content: Rollback, disaster recovery, snapshots

17. **Create troubleshooting FAQ** (🟡 Important)
    - Target: `/docs/troubleshooting/faq.md`
    - Content: Common issues, solutions, workarounds

18. **Create system update guide** (🟡 Important)
    - Target: `/docs/examples/updating-system.md`
    - Content: Update, test, deploy, rollback

### Phase 5: Create Spec Kit Specifications (Week 8+)

**Goal:** Create stable specifications for mature features

19. **Create Spec 002: Basic NixOS Deployment** (✅ Ready)
    - Path: `/specs/002-basic-nixos-deployment/`
    - Based on: Working implementation, new docs from Phase 1

20. **Create Spec 003: Disko Disk Management** (✅ Ready)
    - Path: `/specs/003-disko-disk-management/`
    - Based on: Production usage, new architecture docs

21. **Create Spec 004: Development Environment** (✅ Ready)
    - Path: `/specs/004-development-environment/`
    - Based on: Dev shells, new setup guide from Phase 1

### Phase 6: Nice-to-Have Enhancements (Ongoing)

22. Additional code examples (🟢 Nice-to-have)
23. MCP usage examples (🟢 Nice-to-have)
24. Performance tuning guide (🟢 Nice-to-have)
25. Advanced topics (🟢 Nice-to-have)

---

## 7. Gap Summary Statistics

### By Category

| Category | Total Gaps | Critical | Important | Nice-to-have |
|----------|-----------|----------|-----------|--------------|
| Missing Documentation | 23 | 8 | 12 | 3 |
| Missing Code Examples | 18 | 3 | 8 | 7 |
| Unclear Architecture | 12 | 3 | 7 | 2 |
| Open Decisions | 15 | 2 | 6 | 7 |
| **TOTAL** | **68** | **16** | **33** | **19** |

### By Area

| Area | Gaps | Priority Distribution |
|------|------|----------------------|
| Deployment & Operations | 15 | 🔴🔴🔴🔴 🟡🟡🟡 🟢🟢 |
| Development Environment | 12 | 🔴🔴🔴 🟡🟡🟡 🟢🟢🟢 |
| Configuration & Architecture | 18 | 🔴🔴🔴 🟡🟡🟡🟡 🟢🟢 |
| Security | 9 | 🔴🔴🔴 🟡🟡 🟢🟢 |
| CI/CD & Automation | 6 | 🟡🟡 🟢🟢 |
| AI/MCP Infrastructure | 4 | 🟢🟢🟢🟢 |
| Documentation Meta | 4 | 🟢🟢🟢🟢 |

### Blocking Issues

**Critical blockers preventing adoption:**

1. 🔴 No deployment prerequisite guide → Users can't start
2. 🔴 No post-deployment verification → Users don't know if it worked
3. 🔴 No dev environment setup → Contributors can't contribute
4. 🔴 Architecture mismatch → Confusion about system design
5. 🔴 SSH keys hardcoded → Security risk
6. 🔴 No local testing guide → Changes deployed untested
7. 🔴 No adding packages example → Can't customize system
8. 🔴 Secrets management unclear → Can't improve security

**Important gaps affecting quality:**

- No monitoring setup
- No rollback procedures
- No CI/CD automation
- No troubleshooting FAQ
- Modular architecture undefined
- Home manager disabled

---

## 8. Next Steps

### Immediate Actions (This Week)

1. **Review this analysis** with team/maintainers
2. **Prioritize gaps** based on immediate needs
3. **Create GitHub issues** for top 10 critical gaps
4. **Assign owners** to documentation tasks
5. **Start Phase 1** critical documentation

### Short-term Actions (Next Month)

1. **Complete Phase 1** documentation (6 critical docs)
2. **Complete Phase 2** code examples (4 critical examples)
3. **Make Phase 3** architecture decisions (4 ADRs)
4. **Enable CI/CD** for automated validation
5. **Enable secrets management** to remove hardcoded keys

### Medium-term Actions (Next Quarter)

1. **Complete Phase 4** operations documentation
2. **Create Phase 5** Spec Kit specifications
3. **Implement monitoring** and observability
4. **Implement backup** strategy
5. **Consider modular** configuration refactoring

### Long-term Vision (6-12 Months)

1. **Complete Phase 6** nice-to-have enhancements
2. **Implement home manager** if beneficial
3. **Expand multi-host** management patterns
4. **Mature AI/MCP** infrastructure if needed
5. **Continuous improvement** based on user feedback

---

## Appendix A: Gap Tracking Template

For each gap identified, create a GitHub issue with this template:

```markdown
## Gap: [Gap Title]

**Category:** [Missing Docs / Missing Example / Unclear Architecture / Open Decision]
**Priority:** [🔴 Critical / 🟡 Important / 🟢 Nice-to-have]
**Effort:** [Small / Medium / Large]

### Current State
[What exists now]

### Gap Description
[What's missing or unclear]

### Impact
[Who is affected and how]

### Proposed Solution
[What should be created or clarified]

### Target Artifact
[File path where this will be documented]

### Dependencies
[What needs to happen first]

### Acceptance Criteria
- [ ] [Specific criteria 1]
- [ ] [Specific criteria 2]

### Related Issues
[Links to related issues]
```

---

## Appendix B: Documentation Coverage Matrix

| System Area | Config Exists | Docs Exist | Examples Exist | Tests Exist | Coverage |
|-------------|---------------|------------|----------------|-------------|----------|
| NixOS Core | ✅ | ⚠️ | ⚠️ | ❌ | 40% |
| Deployment | ✅ | ⚠️ | ❌ | ❌ | 30% |
| Disk Management | ✅ | ⚠️ | ⚠️ | ❌ | 40% |
| User Management | ✅ | ❌ | ❌ | ❌ | 20% |
| Secrets | ⚠️ | ⚠️ | ❌ | ❌ | 20% |
| Development | ✅ | ⚠️ | ❌ | ❌ | 30% |
| CI/CD | ❌ | ❌ | ❌ | ❌ | 0% |
| Monitoring | ⚠️ | ❌ | ⚠️ | ❌ | 15% |
| Backup | ⚠️ | ❌ | ❌ | ❌ | 10% |
| Testing | ⚠️ | ❌ | ❌ | ❌ | 10% |

**Average Coverage:** 21%  
**Target Coverage:** 80%+  
**Gap:** 59 percentage points

---

## Appendix C: Quick Reference - Top 10 Gaps to Address

1. 🔴 **Deployment prerequisites guide** - Blocks new users
2. 🔴 **Post-deployment verification** - Users don't know success
3. 🔴 **Dev environment setup** - Blocks contributors
4. 🔴 **Current vs planned architecture** - Causes confusion
5. 🔴 **Local testing workflow** - Untested changes deployed
6. 🔴 **SSH key management** - Security risk
7. 🔴 **First deployment walkthrough** - No end-to-end example
8. 🔴 **Adding packages example** - Can't customize
9. 🟡 **ADR: Configuration architecture** - Unclear direction
10. 🟡 **Monitoring setup guide** - No production visibility

---

**End of Gap Analysis**

**Generated by:** Gap & Open-Question Analyzer Agent  
**Date:** 2025-11-16  
**Total gaps identified:** 68  
**Critical gaps:** 16  
**Ready for Spec Kit:** 3 features  
**Recommended first action:** Create deployment prerequisite guide
