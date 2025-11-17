# pantherOS Documentation & Specs Roadmap

**Generated:** 2025-11-17  
**Purpose:** Actionable roadmap for documentation cleanup, consolidation, and Spec-Driven Development integration  
**Status:** Active Development Roadmap

---

## Table of Contents

- [Quickstart Sequence](#quickstart-sequence)
- [Phase 1: Clean Up & Move Docs into /docs](#phase-1-clean-up--move-docs-into-docs)
- [Phase 2: Fill Critical Documentation & Example Gaps](#phase-2-fill-critical-documentation--example-gaps)
- [Phase 3: Spec Kit Alignment & Spec Expansion](#phase-3-spec-kit-alignment--spec-expansion)
- [Phase 4: Ongoing Spec-Driven Workflow](#phase-4-ongoing-spec-driven-workflow)
- [How to Use This with AI Agents](#how-to-use-this-with-ai-agents)
- [Progress Tracking](#progress-tracking)
- [References](#references)

---

## Quickstart Sequence

**Goal:** Get from current state to organized `/docs` with working Spec Kit in under 2 hours.

### Essential Tasks (Do These First)

- [ ] **QS-1: Create /docs directory structure**
  - **Owner:** human or doc-agent
  - **Type:** infra
  - **Granularity:** small
  - **Commands:** None (mkdir commands)
  - **Action:** Create main `/docs` directories and subdirectories as defined in `_analysis/docs_structure_plan.md`

- [ ] **QS-2: Remove duplicate Spec Kit agent files**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None (git rm)
  - **Action:** Remove 18 duplicate files from `.opencode/command/` and `.specify/templates/commands/` keeping only `.github/agents/` copies

- [ ] **QS-3: Archive aspirational AI infrastructure docs**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None (git mv)
  - **Action:** Move `ai_infrastructure/` (10 files) to `/docs/archive/planning/ai-infrastructure/`

- [ ] **QS-4: Move hardware profiles to /docs/ops/**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None (git mv)
  - **Action:** Move 3 system profile files to `/docs/ops/hardware-*.md`

- [ ] **QS-5: Create docs/index.md from existing navigation**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Transform `00_MASTER_TOPIC_MAP.md` and `README.md` into `/docs/index.md`

- [ ] **QS-6: Create first high-quality spec (deployment)**
  - **Owner:** human with /speckit.specify
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`
  - **Action:** Create `/docs/specs/002-basic-nixos-deployment/` based on existing `DEPLOYMENT.md`

- [ ] **QS-7: Verify Spec Kit installation and commands**
  - **Owner:** human
  - **Type:** infra
  - **Granularity:** small
  - **Commands:** Test all `/speckit.*` commands
  - **Action:** Ensure all Spec Kit commands work with GitHub Copilot

- [ ] **QS-8: Create deployment prerequisite guide (critical gap)**
  - **Owner:** doc-agent or human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Write `/docs/howto/deploy-prerequisites.md` covering VPS setup, SSH keys, DNS

**Success Criteria for Quickstart:**
- `/docs` directory exists with organized structure
- At least one high-quality spec created using Spec Kit
- Duplicate files removed (18 files)
- Critical documentation gap filled (deployment prereqs)
- Spec Kit commands verified working

---

## Phase 1: Clean Up & Move Docs into /docs

**Goal:** Consolidate all documentation under `/docs` with clear organization.  
**Duration:** 2-3 weeks  
**Prerequisites:** Quickstart sequence completed

### 1.1 Directory Structure Setup

- [ ] **P1-1: Create complete /docs directory tree**
  - **Owner:** doc-agent
  - **Type:** infra
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Create all directories from `_analysis/docs_structure_plan.md`
  - **Details:**
    - `/docs/architecture/` with `decisions/` subdirectory
    - `/docs/howto/`, `/docs/ops/`, `/docs/infra/`
    - `/docs/specs/`, `/docs/tools/`, `/docs/examples/nixos/`
    - `/docs/reference/`, `/docs/contributing/`
    - `/docs/archive/{planning,obsolete}/`

- [ ] **P1-2: Create .gitkeep files for empty directories**
  - **Owner:** doc-agent
  - **Type:** infra
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Add `.gitkeep` to directories like `/docs/api/` that will be populated later

### 1.2 Remove Duplicates (18 files)

- [ ] **P1-3: Verify canonical Spec Kit agent files exist**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Confirm all 9 `.github/agents/speckit.*.md` files are present and correct

- [ ] **P1-4: Check for script dependencies on duplicate directories**
  - **Owner:** human or doc-agent
  - **Type:** research
  - **Granularity:** small
  - **Commands:** None (grep commands)
  - **Action:** Search `.specify/scripts/` for references to `.opencode/command/` or `.specify/templates/commands/`

- [ ] **P1-5: Remove .opencode/command/ directory**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None (git rm -r)
  - **Action:** Remove 9 duplicate Spec Kit files
  - **Depends on:** P1-4 showing no dependencies

- [ ] **P1-6: Remove .specify/templates/commands/ directory**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None (git rm -r)
  - **Action:** Remove 9 duplicate Spec Kit files
  - **Depends on:** P1-4 showing no dependencies

### 1.3 Archive Aspirational Content (16 files)

- [ ] **P1-7: Archive AI infrastructure planning docs**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Move `ai_infrastructure/*.md` (10 files) to `/docs/archive/planning/ai-infrastructure/`

- [ ] **P1-8: Archive desktop environment docs**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Move `desktop_environment/*.md` (3 files) to `/docs/archive/planning/desktop-environment/`

- [ ] **P1-9: Archive obsolete deployment guides**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Move `OVH-DEPLOYMENT-GUIDE.md` to `/docs/archive/obsolete/` (after reviewing for unique content)

- [ ] **P1-10: Archive unimplemented feature docs**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Move `DISK-OPTIMIZATION.md`, `NIXOS-QUICKSTART.md`, `PERFORMANCE-OPTIMIZATIONS.md` to `/docs/archive/` (after review)

- [ ] **P1-11: Archive OpNix setup guide (future reference)**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Move `OPNIX-SETUP.md` to `/docs/archive/planning/`

### 1.4 Move Core Documentation (Simple Moves)

- [ ] **P1-12: Move hardware profiles to /docs/ops/**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Rename and move:
    - `OVH Cloud VPS - System Profile.md` → `/docs/ops/hardware-ovh-cloud.md`
    - `Hetzner Cloud VPS - System Profile.md` → `/docs/ops/hardware-hetzner-cloud.md`
    - `Yoga - System Profile.md` → `/docs/ops/hardware-yoga.md`

- [ ] **P1-13: Move reference documentation to /docs/reference/**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Move:
    - `CONFIGURATION-SUMMARY.md` → `/docs/reference/configuration-summary.md`
    - `system_config/COMPLETION_SUMMARY.md` → `/docs/reference/completion-status.md`

- [ ] **P1-14: Copy secrets documentation to /docs/reference/**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Copy (keep originals initially):
    - `.github/SECRETS-INVENTORY.md` → `/docs/reference/secrets-inventory.md`
    - `.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md` → `/docs/reference/secrets-environment-vars.md`
    - `.github/SECRETS-QUICK-REFERENCE.md` → `/docs/reference/secrets-quick-reference.md`

- [ ] **P1-15: Move constitution to /docs/architecture/decisions/**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Move `.specify/memory/constitution.md` → `/docs/architecture/decisions/constitution.md`

- [ ] **P1-16: Move existing spec to /docs/specs/**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Move `specs/001-nixos-anywhere-deployment-setup/` → `/docs/specs/001-nixos-anywhere/`

- [ ] **P1-17: Move code examples to /docs/examples/nixos/**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Move all files from `code_snippets/system_config/nixos/*.md` to `/docs/examples/nixos/`

### 1.5 Condense Verbose Documentation

- [ ] **P1-18: Condense MASTER_PROJECT_BRIEF.md**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Reduce `system_config/project_briefs/01_MASTER_PROJECT_BRIEF.md` from 1554 words to ~600 words
  - **Details:** Remove redundant architecture descriptions, keep vision and goals

- [ ] **P1-19: Condense implementation guide to troubleshooting focus**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Transform `system_config/implementation_guides/03_pantherOS_IMPLEMENTATION_GUIDE.md`
  - **Output:** `/docs/howto/troubleshoot-common-issues.md` (~1000 words)
  - **Details:** Keep unique troubleshooting, remove redundant deployment steps

- [ ] **P1-20: Condense 1Password guide**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Condense `system_config/secrets_management/MASTER_1PASSWORD_GUIDE.md`
  - **Output:** `/docs/howto/manage-secrets-1password.md` (~800 words)
  - **Alternative:** Merge into `.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md`

- [ ] **P1-21: Update OpNix CLI reference with future warning**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Add "⚠️ Future Reference" header to `system_config/secrets_management/01_cli_reference.md`
  - **Output:** `/docs/howto/manage-secrets-opnix.md` (~400 words)

- [ ] **P1-22: Standardize code example format**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Apply standard template to all 5 example files
  - **Template:** Overview (3 sentences) → Prerequisites → Configuration → Verification → Customization
  - **Target:** Each file 100-150 lines max

### 1.6 Update Architecture Documentation

- [ ] **P1-23: Add "ASPIRATIONAL" warnings to architecture diagrams**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Update both architecture diagram files
  - **Output:** `/docs/architecture/diagrams-system.md` and `diagrams-integration.md`
  - **Details:** Add clear headers, create "Current Implementation" vs "Planned Architecture" sections

- [ ] **P1-24: Create current vs planned architecture document**
  - **Owner:** doc-agent or human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/architecture/current-vs-planned.md`
  - **Details:** Document actual minimal configuration vs aspirational modular system

### 1.7 Create Index Files

- [ ] **P1-25: Create /docs/index.md (main entry point)**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Transform `00_MASTER_TOPIC_MAP.md` and `README.md` into organized index
  - **Details:** Welcome, overview, quick links, getting started paths

- [ ] **P1-26: Create index files for all major sections**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `index.md` for:
    - `/docs/architecture/`, `/docs/decisions/`, `/docs/howto/`
    - `/docs/ops/`, `/docs/infra/`, `/docs/specs/`
    - `/docs/tools/`, `/docs/examples/`, `/docs/reference/`, `/docs/contributing/`

### 1.8 Clean Up Old Structure

- [ ] **P1-27: Remove old directories after migration**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Remove now-empty directories: `system_config/`, `code_snippets/`, `specs/`, `architecture/`
  - **Depends on:** All moves completed

- [ ] **P1-28: Update root README to reference /docs/**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Update `README.md` with link to `/docs/index.md`

- [ ] **P1-29: Update .github/copilot-instructions.md**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Remove references to deleted/archived content, update file paths

### 1.9 Validation

- [ ] **P1-30: Check for broken internal links**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None (grep commands)
  - **Action:** Search for references to moved/deleted files and update links

- [ ] **P1-31: Verify NixOS configurations still build**
  - **Owner:** human or code-agent
  - **Type:** infra
  - **Granularity:** medium
  - **Commands:** None (nix build commands)
  - **Action:** Run `nix build .#nixosConfigurations.{ovh-cloud,hetzner-cloud}.config.system.build.toplevel`

- [ ] **P1-32: Create pruning changelog**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/archive/PRUNING_CHANGELOG.md` documenting all changes made

**Phase 1 Success Criteria:**
- All documentation under `/docs` with clear structure
- 18 duplicate files removed
- 16 aspirational/obsolete files archived
- All internal links working
- NixOS configurations build successfully

---

## Phase 2: Fill Critical Documentation & Example Gaps

**Goal:** Address the 8 critical documentation gaps blocking user adoption.  
**Duration:** 3-4 weeks  
**Prerequisites:** Phase 1 completed, `/docs` structure in place

### 2.1 Critical Deployment Documentation (Week 1)

- [ ] **P2-1: Create deployment prerequisites guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/howto/deploy-prerequisites.md`
  - **Priority:** 🔴 Critical
  - **Content:**
    - VPS provider setup
    - SSH key generation and configuration
    - DNS configuration requirements
    - Firewall prerequisites
    - Network requirements (static IP vs DHCP)

- [ ] **P2-2: Create post-deployment verification guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/howto/verify-deployment.md`
  - **Priority:** 🔴 Critical
  - **Content:**
    - Post-deployment checklist
    - Verification commands
    - Service status checks
    - Log locations
    - Common deployment failure patterns

- [ ] **P2-3: Create complete first deployment walkthrough**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** large
  - **Commands:** None
  - **Action:** Create `/docs/examples/first-deployment-walkthrough.md`
  - **Priority:** 🔴 Critical
  - **Content:**
    - End-to-end from fresh VPS to working system
    - Screenshots/output examples
    - Troubleshooting common issues
    - First login and verification

- [ ] **P2-4: Create rollback and recovery procedures**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/ops/rollback-recovery.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Rollback procedures
    - Disaster recovery plan
    - Snapshot management
    - State preservation during updates

### 2.2 Critical Development Documentation (Week 2)

- [ ] **P2-5: Create development environment setup guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** large
  - **Commands:** None
  - **Action:** Create `/docs/contributing/dev-environment-setup.md`
  - **Priority:** 🔴 Critical
  - **Content:**
    - Nix installation (multiple platforms)
    - direnv configuration
    - VS Code/Neovim setup
    - Dev shell usage guide
    - Troubleshooting dev environment

- [ ] **P2-6: Create local testing workflow guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/howto/test-changes-locally.md`
  - **Priority:** 🔴 Critical
  - **Content:**
    - VM testing with nixos-rebuild build-vm
    - Local deployment testing
    - Integration test procedures
    - Validation workflows

- [ ] **P2-7: Create Nix development patterns guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/contributing/nix-development-patterns.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Common Nix patterns
    - Best practices
    - Debugging techniques
    - Code review guidelines

### 2.3 Critical Code Examples (Week 3)

- [ ] **P2-8: Create adding packages example**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/examples/nixos/adding-packages.md`
  - **Priority:** 🔴 Critical
  - **Content:**
    - Searching nixpkgs
    - Adding to configuration
    - Handling unfree packages
    - Testing package additions

- [ ] **P2-9: Create service configuration example**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/examples/nixos/service-configuration.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Web server setup (nginx)
    - Database configuration (postgresql)
    - Custom systemd services
    - Service networking

- [ ] **P2-10: Create user management example**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/examples/nixos/user-management.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Creating users
    - Setting permissions
    - SSH key management per user
    - Home directory management

- [ ] **P2-11: Create firewall configuration example**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/examples/nixos/firewall-setup.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Enabling firewall
    - Opening ports
    - Service-based rules
    - Testing configuration

### 2.4 Critical Security Documentation (Week 4)

- [ ] **P2-12: Create SSH key management guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/security/ssh-key-management.md`
  - **Priority:** 🔴 Critical (security)
  - **Content:**
    - Current approach (hardcoded - security risk)
    - Key rotation procedures
    - Per-host key management
    - Migration plan to secrets management
    - Emergency access procedures

- [ ] **P2-13: Create secrets management workflow guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/howto/manage-secrets.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Overview of secrets management
    - Current state and limitations
    - 1Password integration (when enabled)
    - OpNix integration (future)
    - Best practices

- [ ] **P2-14: Create security hardening checklist**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/security/hardening-checklist.md`
  - **Priority:** 🟢 Nice-to-have
  - **Content:**
    - Security baseline
    - CIS benchmark alignment
    - Audit procedures
    - Compliance considerations

### 2.5 Important Infrastructure Documentation

- [ ] **P2-15: Create NixOS flakes deep dive**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** large
  - **Commands:** None
  - **Action:** Create `/docs/infra/nixos-flakes-deep-dive.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Flake structure explanation
    - Input dependencies
    - nixosConfiguration patterns
    - Update procedures
    - Lock file management

- [ ] **P2-16: Create disko disk management guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/infra/disko-disk-management.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Device selection rationale (why /dev/sdb)
    - Partition sizing
    - Btrfs subvolume strategy
    - VM vs physical differences
    - Customization guide

- [ ] **P2-17: Create monitoring setup guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** large
  - **Commands:** None
  - **Action:** Create `/docs/ops/monitoring-setup.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Monitoring tool options (Datadog, Prometheus, etc.)
    - Configuration examples
    - Alerting setup
    - Performance baselines
    - Log aggregation

- [ ] **P2-18: Create system update guide**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/examples/updating-system.md`
  - **Priority:** 🟡 Important
  - **Content:**
    - Updating flake inputs
    - Testing new packages
    - Deploying updates
    - Rollback procedures

**Phase 2 Success Criteria:**
- All 8 critical documentation gaps filled
- 10+ practical code examples available
- Security documentation comprehensive
- Contributors can set up dev environment in <30 minutes
- Users can deploy first server without external help

---

## Phase 3: Spec Kit Alignment & Spec Expansion

**Goal:** Create high-quality specifications for mature features using Spec Kit methodology.  
**Duration:** 4-6 weeks  
**Prerequisites:** Phase 2 completed, documentation gaps filled

### 3.1 Spec Kit Setup & Validation

- [ ] **P3-1: Verify Spec Kit installation**
  - **Owner:** human
  - **Type:** infra
  - **Granularity:** small
  - **Commands:** Test all `/speckit.*` commands
  - **Action:** Ensure all Spec Kit agents work correctly
  - **Details:** Test specify, clarify, plan, tasks, implement, analyze, checklist

- [ ] **P3-2: Review and update constitution**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** `/speckit.constitution`
  - **Action:** Review `/docs/architecture/decisions/constitution.md`
  - **Details:** Ensure principles align with project goals

- [ ] **P3-3: Create Spec Kit usage guide for pantherOS**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/tools/spec-kit-usage-guide.md`
  - **Details:** pantherOS-specific Spec Kit workflows and best practices

### 3.2 Create Core Specifications (Ready Now)

- [ ] **P3-4: Create Spec 002 - Basic NixOS Deployment**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** large
  - **Commands:** `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`, `/speckit.tasks`
  - **Action:** Create `/docs/specs/002-basic-nixos-deployment/`
  - **Priority:** High
  - **Maturity:** ✅ Ready (working implementation exists)
  - **Content:**
    - Prerequisites and setup
    - Step-by-step deployment procedure
    - Post-deployment verification
    - Common issues and solutions
    - Rollback procedures

- [ ] **P3-5: Create Spec 003 - Disko Disk Management**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** large
  - **Commands:** `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`, `/speckit.tasks`
  - **Action:** Create `/docs/specs/003-disko-disk-management/`
  - **Priority:** Medium
  - **Maturity:** ✅ Ready (production usage)
  - **Content:**
    - Partition layout rationale
    - Device selection logic
    - Btrfs subvolume strategy
    - Customization examples
    - Testing procedures

- [ ] **P3-6: Create Spec 004 - Development Environment**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** large
  - **Commands:** `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`, `/speckit.tasks`
  - **Action:** Create `/docs/specs/004-development-environment/`
  - **Priority:** High
  - **Maturity:** ✅ Ready (shells defined, needs usage guide)
  - **Content:**
    - Nix installation
    - Dev shell selection guide
    - IDE integration
    - Common workflows
    - Troubleshooting

### 3.3 Architecture Decision Records (ADRs)

- [ ] **P3-7: Create ADR-001 - Nix Flakes over Channels**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None (ADR format)
  - **Action:** Create `/docs/decisions/adr-001-flakes-over-channels.md`
  - **Details:** Document why flakes chosen, benefits, trade-offs

- [ ] **P3-8: Create ADR-002 - Configuration Architecture Pattern**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None (ADR format)
  - **Action:** Create `/docs/decisions/adr-002-configuration-architecture.md`
  - **Priority:** 🔴 Critical
  - **Decision:** Modular vs monolithic configuration
  - **Details:** Current minimal approach vs planned modular, migration path

- [ ] **P3-9: Create ADR-003 - Home Manager Strategy**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None (ADR format)
  - **Action:** Create `/docs/decisions/adr-003-home-manager-strategy.md`
  - **Decision:** When to enable, usage patterns, closure size trade-offs

- [ ] **P3-10: Create ADR-004 - Secrets Management Tool**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None (ADR format)
  - **Action:** Create `/docs/decisions/adr-004-secrets-management.md`
  - **Priority:** 🔴 Critical (security)
  - **Decision:** OpNix timeline, migration from hardcoded secrets

- [ ] **P3-11: Create ADR-005 - CI/CD Strategy**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None (ADR format)
  - **Action:** Create `/docs/decisions/adr-005-ci-cd-strategy.md`
  - **Decision:** GitHub Actions vs alternatives, workflow design

- [ ] **P3-12: Create ADR-006 - Multi-Host Configuration**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None (ADR format)
  - **Action:** Create `/docs/decisions/adr-006-multi-host-config.md`
  - **Decision:** Shared modules vs independent configs

- [ ] **P3-13: Create ADR-007 - Monitoring Stack**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None (ADR format)
  - **Action:** Create `/docs/decisions/adr-007-monitoring-stack.md`
  - **Decision:** Datadog vs Prometheus+Grafana vs minimal

### 3.4 Specs with Caveats (Implementation Needed)

- [ ] **P3-14: Create Spec 005 - Multi-Host Management (with caveats)**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** large
  - **Commands:** `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`
  - **Action:** Create `/docs/specs/005-multi-host-management/`
  - **Priority:** Low
  - **Maturity:** ⚠️ Partial (two hosts, no sharing)
  - **Caveats:** Sharing strategy not finalized
  - **Content:**
    - Current: Independent host configs
    - Planned: Shared modules or profiles
    - Migration path

- [ ] **P3-15: Create Spec 006 - MCP Server Integration (with caveats)**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** `/speckit.specify`, `/speckit.plan`
  - **Action:** Create `/docs/specs/006-mcp-server-integration/`
  - **Priority:** Low
  - **Maturity:** ⚠️ Partial (config exists, usage unclear)
  - **Caveats:** Advanced usage patterns undefined
  - **Content:**
    - MCP server configuration
    - Basic usage examples
    - Integration with development workflow

### 3.5 Spec Quality & Validation

- [ ] **P3-16: Run spec analysis on all created specs**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** `/speckit.analyze`
  - **Action:** Run analysis on specs 002-006
  - **Details:** Check consistency, coverage, quality

- [ ] **P3-17: Create quality checklists for each spec**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** `/speckit.checklist`
  - **Action:** Generate validation checklists
  - **Details:** Requirements validation, acceptance criteria

- [ ] **P3-18: Create spec index and navigation**
  - **Owner:** doc-agent
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Update `/docs/specs/index.md` with all specs
  - **Details:** Include maturity status, priority, dependencies

**Phase 3 Success Criteria:**
- 5-6 high-quality specifications created
- All specs use Spec Kit methodology
- 7+ Architecture Decision Records documented
- Spec Kit workflow integrated with daily development
- Clear distinction between implemented and planned features

---

## Phase 4: Ongoing Spec-Driven Workflow

**Goal:** Establish sustainable Spec-Driven Development practices.  
**Duration:** Ongoing  
**Prerequisites:** Phase 3 completed, core specs in place

### 4.1 Workflow Integration

- [ ] **P4-1: Document Spec-Driven workflow for new features**
  - **Owner:** human or doc-agent
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Create `/docs/contributing/spec-driven-workflow.md`
  - **Details:** Step-by-step process: specify → clarify → plan → tasks → implement

- [ ] **P4-2: Create feature request template using Spec Kit**
  - **Owner:** human
  - **Type:** infra
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Create `.github/ISSUE_TEMPLATE/feature-request.md`
  - **Details:** Template prompts for spec creation using `/speckit.specify`

- [ ] **P4-3: Create pull request template with spec reference**
  - **Owner:** human
  - **Type:** infra
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Create `.github/PULL_REQUEST_TEMPLATE.md`
  - **Details:** Require spec reference for non-trivial changes

### 4.2 Implement Missing Features (Requires Code Changes)

- [ ] **P4-4: Enable OpNix secrets management**
  - **Owner:** code-agent
  - **Type:** code
  - **Granularity:** large
  - **Commands:** `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`
  - **Action:** Enable OpNix, migrate hardcoded secrets
  - **Spec:** Create spec first using `/speckit.specify`
  - **Priority:** 🔴 Critical (security)

- [ ] **P4-5: Implement CI/CD pipeline**
  - **Owner:** code-agent
  - **Type:** code
  - **Granularity:** large
  - **Commands:** `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`
  - **Action:** Create GitHub Actions workflows
  - **Spec:** Create spec first using `/speckit.specify`
  - **Priority:** 🟡 Important

- [ ] **P4-6: Implement monitoring infrastructure**
  - **Owner:** code-agent
  - **Type:** code
  - **Granularity:** large
  - **Commands:** `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`
  - **Action:** Set up chosen monitoring solution
  - **Spec:** Create spec first using `/speckit.specify`
  - **Depends on:** ADR-007 decision

- [ ] **P4-7: Implement backup automation**
  - **Owner:** code-agent
  - **Type:** code
  - **Granularity:** large
  - **Commands:** `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`
  - **Action:** Automate Btrfs snapshots and off-site backups
  - **Spec:** Create spec first using `/speckit.specify`
  - **Priority:** 🟡 Important

### 4.3 Continuous Improvement

- [ ] **P4-8: Set up documentation CI/CD**
  - **Owner:** code-agent
  - **Type:** infra
  - **Granularity:** medium
  - **Commands:** None
  - **Action:** Add markdown linting, link checking, spell checking
  - **Tools:** markdownlint, markdown-link-check, cspell

- [ ] **P4-9: Implement spec-to-GitHub-issues workflow**
  - **Owner:** human
  - **Type:** infra
  - **Granularity:** medium
  - **Commands:** `/speckit.taskstoissues`
  - **Action:** Test and document converting specs to issues
  - **Details:** Use `/speckit.taskstoissues` for task breakdown

- [ ] **P4-10: Create monthly documentation review process**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** small
  - **Commands:** None
  - **Action:** Schedule regular doc reviews
  - **Details:** Check accuracy, update outdated content, identify gaps

- [ ] **P4-11: Collect user feedback on documentation**
  - **Owner:** human
  - **Type:** research
  - **Granularity:** ongoing
  - **Commands:** None
  - **Action:** Create feedback mechanism (GitHub discussions, surveys)

- [ ] **P4-12: Expand code example library**
  - **Owner:** doc-agent or human
  - **Type:** doc
  - **Granularity:** ongoing
  - **Commands:** None
  - **Action:** Add examples based on user requests and common patterns

### 4.4 Advanced Specifications

- [ ] **P4-13: Create Spec 007 - Modular Configuration System**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** large
  - **Commands:** `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`, `/speckit.tasks`
  - **Action:** Create spec for refactoring to modular architecture
  - **Depends on:** ADR-002 decision
  - **Maturity:** ❌ Not ready (needs architecture decision)

- [ ] **P4-14: Create Spec 008 - Home Manager Integration**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** medium
  - **Commands:** `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`
  - **Action:** Create spec for enabling home-manager
  - **Depends on:** ADR-003 decision
  - **Maturity:** ❌ Not ready (currently disabled)

- [ ] **P4-15: Create specs for new features as needed**
  - **Owner:** human
  - **Type:** doc
  - **Granularity:** ongoing
  - **Commands:** All `/speckit.*` commands
  - **Action:** Use Spec Kit for all new features
  - **Details:** Make specification-first approach standard

**Phase 4 Success Criteria:**
- Spec-Driven Development is default workflow
- All new features start with specification
- Documentation stays current with regular reviews
- CI/CD validates documentation quality
- Community contributes specs and examples

---

## How to Use This with AI Agents

### Overview

This roadmap is designed to be used by both humans and AI agents. Each task has clear ownership, type, and granularity to help AI agents work effectively on documentation and code changes.

### Task Metadata

Each task includes:
- **Owner:** `human`, `doc-agent`, or `code-agent`
- **Type:** `doc`, `code`, `infra`, `research`
- **Granularity:** `small` (<2 hours), `medium` (2-8 hours), `large` (>8 hours)
- **Commands:** Relevant `/speckit.*` commands to use
- **Dependencies:** Prerequisites for the task

### For Doc-Agent Usage

**Doc-agent** specializes in documentation work:

1. **Filter tasks by owner:**
   ```
   Tasks marked "doc-agent" or "human or doc-agent"
   ```

2. **Pick ONE small task at a time:**
   - Start with tasks in current phase
   - Choose tasks with no unmet dependencies
   - Prefer `small` granularity tasks

3. **Example workflow:**
   ```
   1. Find next "doc-agent" task in current phase
   2. Read task description carefully
   3. Complete ONLY that task (don't do related tasks)
   4. Create/update files as specified
   5. Verify changes are minimal and correct
   6. Report progress
   7. Move to next task
   ```

4. **Example tasks for doc-agent:**
   - Moving files (P1-12, P1-13, P1-14, etc.)
   - Creating index files (P1-25, P1-26)
   - Condensing verbose docs (P1-18, P1-19, P1-20)
   - Standardizing formats (P1-22)
   - Creating new documentation (P2-1, P2-2, P2-3, etc.)

### For Code-Agent Usage

**Code-agent** specializes in code changes:

1. **Filter tasks by owner:**
   ```
   Tasks marked "code-agent"
   ```

2. **Note: Most code-agent tasks are in Phase 4**
   - Implement missing features
   - Set up CI/CD
   - Create automation

3. **Example workflow:**
   ```
   1. Find next "code-agent" task
   2. Check if spec exists (if not, create spec first)
   3. Use /speckit.plan to create implementation plan
   4. Use /speckit.tasks to break down work
   5. Implement ONE task at a time
   6. Test changes
   7. Report progress
   ```

4. **Example tasks for code-agent:**
   - Enable OpNix (P4-4)
   - Implement CI/CD (P4-5)
   - Set up monitoring (P4-6)
   - Implement backup automation (P4-7)

### For Human Contributors

**Humans** handle:
- Architecture decisions (ADRs)
- Spec creation and validation
- Complex judgment calls
- Review and approval

**How to assign tasks to AI agents:**

1. **Point agent at this roadmap:**
   ```
   "Please review /docs/roadmap-docs-and-specs.md and pick ONE small task 
   from Phase 1 that is marked 'doc-agent' and has no unmet dependencies."
   ```

2. **Be specific about scope:**
   ```
   "Complete task P1-12 only. Do not do any other tasks or make any 
   other changes."
   ```

3. **Verify before moving on:**
   ```
   After agent completes task:
   - Review changed files
   - Verify scope was correct
   - Check for unintended changes
   - Run tests if applicable
   - Commit changes
   ```

4. **Iterate one task at a time:**
   ```
   Do NOT say: "Complete all tasks in Phase 1"
   DO say: "Complete task P1-12, then wait for my review"
   ```

### Spec Kit Commands for Agent Tasks

When tasks include **Commands:** with `/speckit.*`, the agent should:

1. **For specification tasks:**
   ```
   Use: /speckit.specify "Create basic NixOS deployment specification"
   Then: /speckit.clarify to fill gaps
   Then: /speckit.plan to create implementation plan
   ```

2. **For implementation tasks:**
   ```
   Use: /speckit.plan on existing spec
   Then: /speckit.tasks to create task breakdown
   Then: /speckit.implement to execute tasks
   ```

3. **For quality validation:**
   ```
   Use: /speckit.analyze after creating spec
   Use: /speckit.checklist to generate validation criteria
   ```

### Best Practices for AI Agent Usage

**DO:**
- ✅ Pick ONE task at a time
- ✅ Complete task exactly as specified
- ✅ Check dependencies before starting
- ✅ Verify changes after completion
- ✅ Update task checkbox when done
- ✅ Report any blockers or issues

**DON'T:**
- ❌ Work on multiple tasks simultaneously
- ❌ Make changes outside task scope
- ❌ Skip verification steps
- ❌ Ignore dependencies
- ❌ Modify unrelated files

### Progress Tracking

Track progress in this document:
- Update checkboxes as tasks complete: `- [x]`
- Add notes about blockers: `**Blocked:** reason`
- Update success criteria tracking
- Document any deviations from plan

### Getting Help

If agent encounters issues:
- Mark task as **Blocked** with reason
- Ask human to review and provide guidance
- Don't attempt workarounds without approval
- Document issue for future reference

---

## Progress Tracking

### Overall Progress

**Phase 1: Clean Up & Move Docs into /docs**
- Total tasks: 32
- Completed: 0
- In progress: 0
- Progress: 0%

**Phase 2: Fill Critical Documentation & Example Gaps**
- Total tasks: 18
- Completed: 0
- In progress: 0
- Progress: 0%

**Phase 3: Spec Kit Alignment & Spec Expansion**
- Total tasks: 18
- Completed: 0
- In progress: 0
- Progress: 0%

**Phase 4: Ongoing Spec-Driven Workflow**
- Total tasks: 15
- Completed: 0
- In progress: 0
- Progress: 0%

**Overall Total: 83 tasks (plus 8 quickstart tasks)**

### Success Metrics

**Documentation Quality:**
- [ ] 0% duplicate content (target: 0 duplicate files)
- [ ] Documentation coverage >80% (currently ~21%)
- [ ] All critical gaps filled (0/8 completed)
- [ ] Internal link health 100%

**Spec Kit Integration:**
- [ ] 5+ high-quality specs created (currently 1)
- [ ] All new features use Spec-Driven workflow
- [ ] Spec Kit commands work reliably

**Developer Experience:**
- [ ] New contributors can set up dev environment in <30 min
- [ ] Users can deploy first server without external help
- [ ] Documentation easy to navigate and discover

### Current Status

**Last Updated:** 2025-11-17  
**Current Phase:** Quickstart / Phase 1  
**Next Milestone:** Complete Quickstart sequence  
**Blockers:** None currently

---

## References

### Source Documents

- **Pruning Plan:** `_analysis/pruning_plan.md`
  - 83 documentation files analyzed
  - 20 keep as-is, 15 condense, 5 obsolete
  - 18 duplicates identified, 13 to archive

- **Docs Structure Plan:** `_analysis/docs_structure_plan.md`
  - Proposed `/docs` architecture
  - Sharding rules and file size targets
  - Migration plan and validation checklist

- **Gaps and Questions:** `_analysis/gaps_and_questions.md`
  - 68 total gaps identified (16 critical, 33 important, 19 nice-to-have)
  - Missing documentation and code examples
  - Unclear architecture and open decisions
  - Priority matrix for specifications

### Related Documentation

- **Spec Kit Guide:** `/docs/tools/spec-kit.md`
- **Spec Kit Examples:** `/docs/tools/spec-kit-examples.md`
- **Constitution:** `/docs/architecture/decisions/constitution.md` (will be moved)
- **Existing Spec:** `/docs/specs/001-nixos-anywhere/` (will be moved)

### External Resources

- [GitHub Spec Kit](https://github.com/github/spec-kit)
- [Spec-Driven Development Guide](https://github.com/github/spec-kit/blob/main/spec-driven.md)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)

---

## Appendix: Task Summary by Owner

### Doc-Agent Tasks (Primary Focus)

**Phase 1:** P1-1 through P1-32 (most tasks)  
**Phase 2:** P2-1 through P2-18 (documentation and examples)  
**Phase 3:** P3-3, P3-18 (supporting documentation)  
**Phase 4:** P4-1, P4-10, P4-12 (ongoing doc maintenance)

**Total:** ~60 tasks

### Code-Agent Tasks

**Phase 1:** P1-31 (verification builds)  
**Phase 4:** P4-4 through P4-8 (implementation and infrastructure)

**Total:** ~6 tasks

### Human Tasks (Decision Making)

**Phase 3:** P3-1, P3-2, P3-4 through P3-17 (specs and ADRs)  
**Phase 4:** P4-2, P4-3, P4-9, P4-11, P4-13 through P4-15 (workflow and advanced specs)

**Total:** ~20 tasks

### Shared Tasks (Human or Doc-Agent)

**Phase 1:** P1-24 (architecture clarity)  
**Phase 2:** Multiple (can be done by either)

---

## Change Log

### 2025-11-17
- Initial roadmap created based on analysis files
- 83 tasks across 4 phases defined
- Quickstart sequence added (8 essential tasks)
- AI agent usage guide included
- Task metadata standardized (owner, type, granularity, commands)

---

**End of Roadmap**
