# Documentation Pruning & Refactoring Plan

**Generated:** 2025-11-16  
**Repository:** pantherOS NixOS Configuration  
**Purpose:** Safe, conservative pruning strategy for documentation cleanup

---

## Executive Summary

This plan identifies documentation to keep, refactor, or remove from the pantherOS repository. Out of **83 documentation files**, this plan recommends:

- **Keep as-is:** 20 files (core reference documents)
- **Keep but refactor/condense:** 15 files (useful but verbose)
- **Probably obsolete or low-value:** 5 files (candidates for deletion)
- **Duplicates/Overlapping:** 27 files (9 files × 3 copies)
- **Archive (aspirational content):** 16 files (unimplemented features)

**Conservative approach:** When in doubt, files are marked "needs review" rather than immediate deletion. All destructive operations require human sign-off before execution.

---

## 1. Definitely Keep - Core Reference Documents

These documents are essential for repository understanding, operations, and AI agent context. Keep as-is without modification.

### Root Directory Core Docs (6 files)

| Path | Reason | Action |
|------|--------|--------|
| `./00_MASTER_TOPIC_MAP.md` | Master navigation index; essential for repo orientation | **KEEP_AS_IS** |
| `./README.md` | Primary repository documentation; entry point for all users | **KEEP_AS_IS** |
| `./CONFIGURATION-SUMMARY.md` | Accurate summary of current implementation; distinguishes reality from plans | **KEEP_AS_IS** |
| `./DEPLOYMENT.md` | Active deployment guide; used regularly | **KEEP_AS_IS** |
| `./OVH Cloud VPS - System Profile.md` | Hardware specifications for deployed server | **KEEP_AS_IS** |
| `./Hetzner Cloud VPS -System Profile.md` | Hardware specifications for deployed server | **KEEP_AS_IS** |
| `./Yoga - System Profile.md` | Hardware specifications for workstation | **KEEP_AS_IS** |

### System Config Directory (4 files)

| Path | Reason | Action |
|------|--------|--------|
| `./system_config/README.md` | Directory overview; well-maintained | **KEEP_AS_IS** |
| `./system_config/00_TOPIC_MAP.md` | Navigation index for system_config directory | **KEEP_AS_IS** |
| `./system_config/03_PANTHEROS_NIXOS_BRIEF.md` | Comprehensive architecture brief; accurate implementation description | **KEEP_AS_IS** |
| `./system_config/COMPLETION_SUMMARY.md` | Status tracking; useful for understanding what's done | **KEEP_AS_IS** |

### GitHub Directory (6 files)

| Path | Reason | Action |
|------|--------|--------|
| `./.github/copilot-instructions.md` | Critical for AI agent context; comprehensive repository knowledge | **KEEP_AS_IS** |
| `./.github/MCP-SETUP.md` | Active MCP server configuration guide; actively used | **KEEP_AS_IS** |
| `./.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md` | Comprehensive secrets documentation; essential for operations | **KEEP_AS_IS** |
| `./.github/SECRETS-QUICK-REFERENCE.md` | Quick reference for secrets; complements comprehensive guide | **KEEP_AS_IS** |
| `./.github/SECRETS-INVENTORY.md` | Complete inventory of secrets; essential for security management | **KEEP_AS_IS** |
| `./.github/devcontainer.json` | Dev container configuration; actively used | **KEEP_AS_IS** |
| `./.github/mcp-servers.json` | MCP server configuration; actively used | **KEEP_AS_IS** |

### Specify Framework (2 files)

| Path | Reason | Action |
|------|--------|--------|
| `./.specify/README.md` | Spec Kit framework documentation | **KEEP_AS_IS** |
| `./.specify/memory/constitution.md` | Project principles and governing philosophy | **KEEP_AS_IS** |

### Active Specs (2 files)

| Path | Reason | Action |
|------|--------|--------|
| `./specs/001-nixos-anywhere-deployment-setup/spec.md` | Active feature specification; implemented | **KEEP_AS_IS** |
| `./specs/001-nixos-anywhere-deployment-setup/checklists/requirements.md` | Requirements checklist for implemented feature | **KEEP_AS_IS** |

**Total to keep as-is: 20 files**

---

## 2. Keep but Refactor/Condense

These documents contain valuable information but are verbose, overlap with other docs, or could be better organized.

### System Config Guides (3 files)

#### `./system_config/project_briefs/01_MASTER_PROJECT_BRIEF.md`

**Current state:** 1554 words, comprehensive project planning document  
**Issue:** Overlaps significantly with `03_PANTHEROS_NIXOS_BRIEF.md` and `CONFIGURATION-SUMMARY.md`  
**Proposed action:** **KEEP_AND_CONDENSE**

**Refactor notes:**
- **Drop:** Redundant architecture descriptions already in `03_PANTHEROS_NIXOS_BRIEF.md`
- **Preserve verbatim:** Project vision and goals (unique content)
- **Preserve verbatim:** Technology stack rationale (why Nix, why flakes)
- **Restructure:** Convert detailed implementation plans to bullet list of completed items
- **Target word count:** ~600 words (reduce by 60%)

**Specific sections to condense:**
- Lines describing NixOS implementation details → reference `03_PANTHEROS_NIXOS_BRIEF.md` instead
- Detailed module descriptions → keep high-level list only
- Future plans → move to separate planning doc or mark clearly as aspirational

---

#### `./system_config/implementation_guides/03_pantherOS_IMPLEMENTATION_GUIDE.md`

**Current state:** 2662 words, step-by-step implementation guide  
**Issue:** Very long, some overlap with DEPLOYMENT.md, contains obsolete steps  
**Proposed action:** **KEEP_AND_CONDENSE**

**Refactor notes:**
- **Drop:** Steps for unimplemented features (home-manager setup, OpNix configuration)
- **Drop:** Redundant deployment steps already covered in `DEPLOYMENT.md`
- **Preserve verbatim:** Unique troubleshooting scenarios and solutions
- **Preserve verbatim:** Nix-specific development patterns not documented elsewhere
- **Restructure:** Convert to troubleshooting guide + reference to `DEPLOYMENT.md` for deployment
- **Target word count:** ~1000 words (reduce by 62%)

**Specific sections to condense:**
- Initial setup → link to `DEPLOYMENT.md`
- Configuration structure → link to `03_PANTHEROS_NIXOS_BRIEF.md`
- Keep: Troubleshooting section (unique value)
- Keep: Advanced Nix patterns and tips

---

#### `./system_config/secrets_management/MASTER_1PASSWORD_GUIDE.md`

**Current state:** 2539 words, comprehensive 1Password integration guide  
**Issue:** Very verbose; significant overlap with `.github/SECRETS-*.md` files  
**Proposed action:** **KEEP_AND_CONDENSE**

**Refactor notes:**
- **Drop:** Basic 1Password CLI usage (document once in `.github/SECRETS-QUICK-REFERENCE.md`)
- **Preserve verbatim:** pantherOS-specific integration patterns
- **Preserve verbatim:** OpNix integration plans (when implemented)
- **Restructure:** Convert to quick reference with links to comprehensive guides
- **Target word count:** ~800 words (reduce by 68%)

**Alternative:** **MERGE_INTO:** `.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md`  
If merged, delete this file and consolidate all secrets documentation in `.github/`

---

### Secrets Management (1 file)

#### `./system_config/secrets_management/01_cli_reference.md`

**Current state:** 1156 words, OpNix CLI reference  
**Issue:** OpNix not currently configured; may become outdated  
**Proposed action:** **KEEP_AND_CONDENSE** (or mark as future reference)

**Refactor notes:**
- **Add prominent header:** "⚠️ OpNix not currently configured - Future reference"
- **Drop:** Redundant examples
- **Preserve verbatim:** Unique OpNix commands and patterns
- **Restructure:** Convert to concise CLI reference table
- **Target word count:** ~400 words (reduce by 65%)

---

### Code Snippets (6 files)

#### Code snippet files in `./code_snippets/system_config/nixos/`

**Current state:** 5 example files (battery-management, browser, datadog-agent, nvidia-gpu, security-hardening) + 1 index  
**Issue:** Useful examples but inconsistent formatting; some for unimplemented features  
**Proposed action:** **KEEP_AND_CONDENSE**

**Refactor notes for each file:**
- **Drop:** Long explanatory prose; let code speak for itself
- **Preserve verbatim:** All code examples and configurations
- **Add:** Brief (2-3 sentence) introduction explaining use case
- **Add:** Prerequisites section (1-2 sentences)
- **Restructure:** Standardize format across all examples:
  ```
  # [Feature Name] Configuration Example
  
  ## Use Case
  [2-3 sentences]
  
  ## Prerequisites
  [1-2 sentences]
  
  ## Configuration
  [code block]
  
  ## Testing
  [verification commands]
  ```
- **Target:** Reduce each file by ~30-40% while keeping all code

**Specific files:**
- `battery-management.nix.md` - Keep but mark "For laptops/workstations only"
- `browser.nix.md` - Keep but condense explanation
- `datadog-agent.nix.md` - Keep but mark "Optional monitoring"
- `nvidia-gpu.nix.md` - Keep but mark "For NVIDIA hardware only"
- `security-hardening.nix.md` - Keep and highlight importance
- `CODE_SNIPPETS_INDEX.md` - Update to reflect standardized format

---

### Architecture Diagrams (2 files)

#### `./architecture/ARCHITECTURE_DIAGRAMS.md` and `./architecture/ARCHITECTURE_DIAGRAMS_SYSTEMS.md`

**Current state:** 1295 and 1490 words; Mermaid diagrams of system architecture  
**Issue:** Describe aspirational modular architecture not yet implemented; could confuse users  
**Proposed action:** **KEEP_AND_CONDENSE**

**Refactor notes:**
- **Add prominent header:** "⚠️ ASPIRATIONAL ARCHITECTURE - Not Currently Implemented"
- **Drop:** Diagrams for unimplemented modules
- **Preserve verbatim:** High-level system architecture diagrams
- **Add:** Clear "Current Implementation" section showing actual structure
- **Restructure:** 
  - Section 1: Current Implementation (simple diagram)
  - Section 2: Planned Architecture (existing diagrams with "future" label)
- **Target:** Reduce combined size by ~40%; add clarity about current vs. future

---

### OpenCode Skills (1 file)

#### `./.opencode/skills/systematic-debugging/README.md`

**Current state:** 739 words, systematic debugging methodology  
**Issue:** Useful reference but verbose for a skill document  
**Proposed action:** **KEEP_AND_CONDENSE**

**Refactor notes:**
- **Drop:** Extended explanations; keep procedure concise
- **Preserve verbatim:** Step-by-step debugging checklist
- **Restructure:** Convert to quick reference flowchart or decision tree
- **Target word count:** ~300 words (reduce by 60%)

---

### Specify Templates (5 files)

#### Templates in `./.specify/templates/`

**Current state:** 5 template files (agent-file-template, checklist-template, plan-template, spec-template, tasks-template)  
**Issue:** Templates are appropriately concise but could be more consistent  
**Proposed action:** **KEEP_AND_CONDENSE** (minor refinement)

**Refactor notes:**
- **Ensure consistency:** All templates use same frontmatter format
- **Add:** Brief usage instructions at top of each template
- **Target:** Minor edits only; templates are already concise

---

**Total to refactor: 15 files**

---

## 3. Probably Obsolete or Low-Value

These files are candidates for deletion or archiving. Each includes a human review question.

### Superseded Documentation

#### `./OVH-DEPLOYMENT-GUIDE.md`

**Issue:** Superseded by `DEPLOYMENT.md` which covers both OVH and Hetzner deployments  
**Word count:** 185 words  
**Last useful content:** Some OVH-specific details not in `DEPLOYMENT.md`  
**Proposed action:** **DELETE_AFTER_REVIEW**

**Justification:** 
- `DEPLOYMENT.md` provides comprehensive deployment guide
- OVH-specific details (if any unique content) should be in `OVH Cloud VPS - System Profile.md`
- Maintaining multiple deployment guides creates confusion and sync issues

**Human review question:**  
> Are there any OVH-specific deployment details in this file that are NOT covered in `DEPLOYMENT.md` or `OVH Cloud VPS - System Profile.md`? If yes, merge unique content before deleting.

**Review checklist:**
- [ ] Compare OVH-DEPLOYMENT-GUIDE.md with DEPLOYMENT.md
- [ ] Identify any unique OVH-specific content
- [ ] Merge unique content into DEPLOYMENT.md or OVH profile
- [ ] Delete OVH-DEPLOYMENT-GUIDE.md

---

### Unimplemented Features

#### `./DISK-OPTIMIZATION.md`

**Issue:** Describes unimplemented disk optimization features  
**Word count:** 120 words  
**Content:** Plans for disk layout optimization not yet implemented  
**Proposed action:** **DELETE_AFTER_REVIEW**

**Justification:**
- Current disko configurations in `hosts/servers/*/disko.nix` are the implemented reality
- This file describes optimization ideas that haven't been implemented
- Planning documents without clear implementation path create maintenance burden
- If these optimizations are still desired, they should be GitHub issues, not docs

**Human review question:**
> Are these disk optimizations still planned for implementation? If yes, convert to GitHub issues. If no, delete.

**Review checklist:**
- [ ] Review disk optimization ideas in file
- [ ] Decide if optimizations are still relevant
- [ ] If relevant: create GitHub issue and link from architecture docs
- [ ] Delete DISK-OPTIMIZATION.md

---

#### `./NIXOS-QUICKSTART.md`

**Issue:** Describes unimplemented quickstart features  
**Word count:** 126 words  
**Content:** Plans for quickstart guide not yet implemented  
**Proposed action:** **DELETE_AFTER_REVIEW**

**Justification:**
- Current quickstart is `README.md` + `DEPLOYMENT.md`
- This file describes a more elaborate quickstart that doesn't exist
- Confuses users about what documentation exists
- If quickstart needs improvement, update README.md instead

**Human review question:**
> Should we create a comprehensive quickstart guide? If yes, update README.md and DEPLOYMENT.md. If no, delete.

**Review checklist:**
- [ ] Review quickstart requirements
- [ ] Decide if current README.md + DEPLOYMENT.md are sufficient
- [ ] If insufficient: enhance existing docs (don't create another doc)
- [ ] Delete NIXOS-QUICKSTART.md

---

### Not Currently Configured

#### `./OPNIX-SETUP.md`

**Issue:** OpNix imported but not currently configured; setup guide not applicable  
**Word count:** 182 words  
**Content:** Setup guide for OpNix secrets management (not configured)  
**Proposed action:** **DELETE_AFTER_REVIEW** or **ARCHIVE_TO:** `/docs/archive/future-features/opnix-setup.md`

**Justification:**
- OpNix is imported in flake.nix but explicitly not configured
- Module is disabled to reduce closure size
- Having a setup guide for unconfigured feature is confusing
- If/when OpNix is configured, setup will be in main deployment docs

**Alternative:** Keep as future reference in archived location

**Human review question:**
> Is OpNix integration planned for near-term implementation? If yes, archive for future reference. If no or distant future, delete.

**Review checklist:**
- [ ] Check OpNix integration timeline/priority
- [ ] If planned: archive to `/docs/archive/future-features/`
- [ ] If not planned: delete
- [ ] Update CONFIGURATION-SUMMARY.md to reflect decision

---

### Planning Only

#### `./PERFORMANCE-OPTIMIZATIONS.md`

**Issue:** Planning document for potential optimizations; not actionable  
**Word count:** 752 words  
**Content:** List of potential performance optimizations to consider  
**Proposed action:** **DELETE_AFTER_REVIEW** or **ARCHIVE_TO:** `/docs/archive/planning/performance-ideas.md`

**Justification:**
- Lists performance optimization ideas without implementation plan
- Not referenced from working configuration
- Good ideas but belongs in issue tracker, not documentation
- Maintaining planning docs in main tree creates clutter

**Alternative:** Convert to GitHub issues for tracking

**Human review question:**
> Should these performance optimizations be tracked as GitHub issues? If yes, create issues and delete doc. If ideas aren't actionable, delete.

**Review checklist:**
- [ ] Review optimization ideas
- [ ] Identify actionable optimizations
- [ ] Create GitHub issues for actionable items
- [ ] Delete or archive PERFORMANCE-OPTIMIZATIONS.md

---

**Total obsolete/low-value: 5 files**

---

## 4. Duplicates / Overlapping

Critical duplication issue: 9 Spec Kit agent files exist in THREE locations, creating 27 files where 9 should exist.

### Primary Duplication: Spec Kit Agent Files

**Issue:** Each of 9 Spec Kit agent definitions exists in 3 locations:
1. `.github/agents/` (canonical location)
2. `.opencode/command/` (duplicate)
3. `.specify/templates/commands/` (duplicate)

**Analysis:**
- `.github/agents/` - GitHub Copilot agent definitions (canonical)
- `.opencode/command/` - OpenCode command definitions (appears to be legacy sync)
- `.specify/templates/commands/` - Spec Kit templates (may be different purpose)

**Recommendation:** Keep `.github/agents/` as canonical source; investigate before removing others

#### Files Affected (9 files × 3 locations = 27 files)

##### speckit.analyze.md (3 copies)

| Location | Size | Status | Action |
|----------|------|--------|--------|
| `.github/agents/speckit.analyze.md` | 956 words | Canonical | **KEEP_AS_IS** |
| `.opencode/command/speckit.analyze.md` | 948 words | Near-duplicate | **DELETE_AFTER_REVIEW** |
| `.specify/templates/commands/analyze.md` | 956 words | Exact duplicate | **DELETE_AFTER_REVIEW** |

**Justification:** `.github/agents/` is the GitHub Copilot integration point; duplicates serve no purpose

**Human review question:**
> Does `.opencode/` or `.specify/templates/commands/` serve a different purpose than `.github/agents/`? If no, remove duplicates.

---

##### speckit.checklist.md (3 copies)

| Location | Size | Status | Action |
|----------|------|--------|--------|
| `.github/agents/speckit.checklist.md` | 2225 words | Canonical | **KEEP_AS_IS** |
| `.opencode/command/speckit.checklist.md` | 2219 words | Near-duplicate | **DELETE_AFTER_REVIEW** |
| `.specify/templates/commands/checklist.md` | 2225 words | Exact duplicate | **DELETE_AFTER_REVIEW** |

---

##### speckit.clarify.md (3 copies)

| Location | Size | Status | Action |
|----------|------|--------|--------|
| `.github/agents/speckit.clarify.md` | 1569 words | Canonical | **KEEP_AS_IS** |
| `.opencode/command/speckit.clarify.md` | 1562 words | Near-duplicate | **DELETE_AFTER_REVIEW** |
| `.specify/templates/commands/clarify.md` | 1569 words | Exact duplicate | **DELETE_AFTER_REVIEW** |

---

##### speckit.constitution.md (3 copies)

| Location | Size | Status | Action |
|----------|------|--------|--------|
| `.github/agents/speckit.constitution.md` | 694 words | Canonical | **KEEP_AS_IS** |
| `.opencode/command/speckit.constitution.md` | 694 words | Exact duplicate | **DELETE_AFTER_REVIEW** |
| `.specify/templates/commands/constitution.md` | 694 words | Exact duplicate | **DELETE_AFTER_REVIEW** |

---

##### speckit.implement.md (3 copies)

| Location | Size | Status | Action |
|----------|------|--------|--------|
| `.github/agents/speckit.implement.md` | 977 words | Canonical | **KEEP_AS_IS** |
| `.opencode/command/speckit.implement.md` | 969 words | Near-duplicate | **DELETE_AFTER_REVIEW** |
| `.specify/templates/commands/implement.md` | 977 words | Exact duplicate | **DELETE_AFTER_REVIEW** |

---

##### speckit.plan.md (3 copies)

| Location | Size | Status | Action |
|----------|------|--------|--------|
| `.github/agents/speckit.plan.md` | 424 words | Canonical | **KEEP_AS_IS** |
| `.opencode/command/speckit.plan.md` | 411 words | Near-duplicate | **DELETE_AFTER_REVIEW** |
| `.specify/templates/commands/plan.md` | 424 words | Exact duplicate | **DELETE_AFTER_REVIEW** |

---

##### speckit.specify.md (3 copies)

| Location | Size | Status | Action |
|----------|------|--------|--------|
| `.github/agents/speckit.specify.md` | 1712 words | Canonical | **KEEP_AS_IS** |
| `.opencode/command/speckit.specify.md` | 1709 words | Near-duplicate | **DELETE_AFTER_REVIEW** |
| `.specify/templates/commands/specify.md` | 1712 words | Exact duplicate | **DELETE_AFTER_REVIEW** |

---

##### speckit.tasks.md (3 copies)

| Location | Size | Status | Action |
|----------|------|--------|--------|
| `.github/agents/speckit.tasks.md` | 930 words | Canonical | **KEEP_AS_IS** |
| `.opencode/command/speckit.tasks.md` | 924 words | Near-duplicate | **DELETE_AFTER_REVIEW** |
| `.specify/templates/commands/tasks.md` | 930 words | Exact duplicate | **DELETE_AFTER_REVIEW** |

---

##### speckit.taskstoissues.md (3 copies)

| Location | Size | Status | Action |
|----------|------|--------|--------|
| `.github/agents/speckit.taskstoissues.md` | 165 words | Canonical | **KEEP_AS_IS** |
| `.opencode/command/speckit.taskstoissues.md` | 157 words | Near-duplicate | **DELETE_AFTER_REVIEW** |
| `.specify/templates/commands/taskstoissues.md` | 165 words | Exact duplicate | **DELETE_AFTER_REVIEW** |

---

### Summary of Duplicates

**Total duplicate files to remove:** 18 files (9 from `.opencode/command/`, 9 from `.specify/templates/commands/`)

**Directories to remove:**
- `.opencode/command/` (entire directory, 9 files)
- `.specify/templates/commands/` (entire directory, 9 files)

**Canonical location to keep:**
- `.github/agents/` (9 files, keep all)

**Space saved:** ~18,000 words of duplicate content

**Human review required:**
> Verify that removing `.opencode/command/` and `.specify/templates/commands/` directories won't break any automation scripts or workflows. Check `.specify/scripts/bash/` for any references to these directories.

---

**Total duplicates: 18 files to remove (keeping 9 canonical versions)**

---

## 5. Archive - Aspirational Content (Not Implemented)

These files document features that are not implemented and may never be. They should be archived separately to avoid confusion about the current state of the repository.

### AI Infrastructure Planning (10 files)

**Directory:** `./ai_infrastructure/`

**Issue:** All 10 files document AI infrastructure plans that are not implemented  
**Total size:** ~18,000 words of planning documentation  
**Proposed action:** **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` or delete

| File | Size | Content | Action |
|------|------|---------|--------|
| `00_MASTER_PROJECT_PLANS.md` | 2040w | Master AI ecosystem enhancement plan | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |
| `01_agentdb_integration_plan.md` | 1537w | AgentDB integration planning | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |
| `02_documentation_analysis_plan.md` | 589w | Documentation analysis planning | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |
| `03_documentation_scraper_plan.md` | 243w | Documentation scraper planning | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |
| `04_hbohlenOS_design_plan.md` | 392w | hbohlenOS PKM system design | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |
| `05_minimax_optimization_plan.md` | 560w | MiniMax M2 optimization planning | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |
| `06_agentic_flow_integration.md` | 782w | Agentic-flow integration planning | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |
| `pantherOS_research_plan.md` | 2288w | PantherOS research roadmap | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |
| `pantherOS_gap_analysis_progress.md` | 1856w | Gap analysis progress tracking | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |
| `pantherOS_executable_research_plan.md` | 1782w | Executable research plan | **ARCHIVE_TO:** `/docs/archive/planning/ai-infrastructure/` |

**Justification:**
- Zero implementation of any planned AI infrastructure features
- Planning documents become stale without implementation
- Creates confusion about repository's actual capabilities
- May contain useful ideas for future but shouldn't be in main docs

**Alternative:** Delete entirely if no future implementation planned

**Human review question:**
> Is AI infrastructure enhancement still a planned goal? If yes, archive for future reference. If no, delete entirely.

**Review checklist:**
- [ ] Determine if AI infrastructure plans are still relevant
- [ ] If relevant: create `/docs/archive/planning/ai-infrastructure/` directory
- [ ] If relevant: move all 10 files with note explaining they're future plans
- [ ] If not relevant: delete entire `ai_infrastructure/` directory
- [ ] Update `00_MASTER_TOPIC_MAP.md` to remove references or note archive location

---

### Desktop Environment Documentation (3 files)

**Directory:** `./desktop_environment/`

**Issue:** All 3 files document "Dank Linux" desktop environment that is not implemented  
**Total size:** ~5,000 words of documentation for non-existent feature  
**Proposed action:** **ARCHIVE_TO:** `/docs/archive/planning/desktop-environment/` or delete

| File | Size | Content | Action |
|------|------|---------|--------|
| `00_dank_linux_master_guide.md` | 2561w | Comprehensive Dank Linux guide | **ARCHIVE_TO:** `/docs/archive/planning/desktop-environment/` |
| `02_installation_guide.md` | 797w | Dank Linux installation guide | **ARCHIVE_TO:** `/docs/archive/planning/desktop-environment/` |
| `04_keybindings_reference.md` | 1541w | Keybindings reference | **ARCHIVE_TO:** `/docs/archive/planning/desktop-environment/` |

**Justification:**
- Repository is currently server-focused; no desktop environment configured
- "Dank Linux" appears to be a separate/related project, not part of pantherOS servers
- Comprehensive documentation for non-existent feature creates major confusion
- Desktop environment configuration should be in separate repository or branch

**Alternative:** Move to separate repository if Dank Linux is independent project

**Human review question:**
> Is Dank Linux desktop environment part of pantherOS or a separate project? If separate, move to its own repository. If part of pantherOS, archive until implementation begins.

**Review checklist:**
- [ ] Determine relationship between pantherOS and Dank Linux
- [ ] If separate project: create new repository and move docs there
- [ ] If same project but future: archive to `/docs/archive/planning/desktop-environment/`
- [ ] If abandoned: delete entire `desktop_environment/` directory
- [ ] Update `00_MASTER_TOPIC_MAP.md` accordingly

---

### Aspirational Architecture Diagrams (partial - see also section 2)

**Note:** Architecture diagrams are addressed in section 2 (Keep but Refactor/Condense) because they have some current value. However, if human review determines they're too aspirational, they could be archived instead.

**Alternative action:** **ARCHIVE_TO:** `/docs/archive/planning/architecture/`

**Only if:** Human review determines diagrams are more confusing than helpful

---

**Total to archive: 13 files (10 AI infrastructure + 3 desktop environment)**

---

## Human Review Summary

Before executing any deletions or archives, the following questions require human review:

### Critical Decisions Required

1. **Spec Kit Duplicates (18 files)**
   - [ ] Verify that `.opencode/command/` can be safely deleted
   - [ ] Verify that `.specify/templates/commands/` can be safely deleted
   - [ ] Check if any scripts reference these directories
   - [ ] Confirm `.github/agents/` is the only location needed

2. **AI Infrastructure (10 files)**
   - [ ] Is AI infrastructure enhancement still a planned goal?
   - [ ] If yes: archive to `/docs/archive/planning/ai-infrastructure/`
   - [ ] If no: delete entire `ai_infrastructure/` directory

3. **Desktop Environment (3 files)**
   - [ ] Is Dank Linux part of pantherOS or a separate project?
   - [ ] If separate: move to its own repository
   - [ ] If part of pantherOS: archive until implementation
   - [ ] If abandoned: delete entire `desktop_environment/` directory

4. **OpNix Setup (1 file)**
   - [ ] Is OpNix integration planned for near-term implementation?
   - [ ] If yes: archive for future reference
   - [ ] If no: delete `OPNIX-SETUP.md`

5. **Obsolete Guides (4 files)**
   - [ ] Review each file for unique content before deletion:
     - [ ] `OVH-DEPLOYMENT-GUIDE.md` - merge unique content?
     - [ ] `DISK-OPTIMIZATION.md` - convert to issues?
     - [ ] `NIXOS-QUICKSTART.md` - enhance README instead?
     - [ ] `PERFORMANCE-OPTIMIZATIONS.md` - convert to issues?

---

## Refactor Execution Checklist

This checklist provides step-by-step actions that a later agent can follow once human sign-off is received.

### Phase 1: Preparation and Backup (Non-Destructive)

- [ ] **1.1** Create backup branch: `git checkout -b docs-pruning-backup`
- [ ] **1.2** Create `/docs/archive/` directory structure:
  ```bash
  mkdir -p /docs/archive/planning/ai-infrastructure
  mkdir -p /docs/archive/planning/desktop-environment
  mkdir -p /docs/archive/future-features
  mkdir -p /docs/archive/obsolete
  ```
- [ ] **1.3** Document all planned changes in `/docs/archive/PRUNING_CHANGELOG.md`
- [ ] **1.4** Verify git status is clean: `git status`

### Phase 2: Remove Duplicate Files (After Human Review)

**Prerequisites:** Human review confirms duplicates can be removed

- [ ] **2.1** Verify canonical files exist in `.github/agents/`:
  ```bash
  ls -la .github/agents/speckit.*.md
  ```
- [ ] **2.2** Check for scripts that reference `.opencode/command/`:
  ```bash
  grep -r "\.opencode/command" .specify/scripts/
  grep -r "\.opencode/command" .github/
  ```
- [ ] **2.3** Check for scripts that reference `.specify/templates/commands/`:
  ```bash
  grep -r "templates/commands" .specify/scripts/
  ```
- [ ] **2.4** If no references found, remove duplicate directories:
  ```bash
  git rm -r .opencode/command/
  git rm -r .specify/templates/commands/
  ```
- [ ] **2.5** Commit: `git commit -m "Remove duplicate Spec Kit agent files (18 files)"`
- [ ] **2.6** Verify repository still works: test Spec Kit commands

### Phase 3: Archive Aspirational Content (After Human Review)

**Prerequisites:** Human review determines archive vs. delete for each category

#### AI Infrastructure (10 files)

- [ ] **3.1** If archiving (not deleting):
  ```bash
  git mv ai_infrastructure/* docs/archive/planning/ai-infrastructure/
  git rm -d ai_infrastructure/
  ```
- [ ] **3.2** If deleting:
  ```bash
  git rm -r ai_infrastructure/
  ```
- [ ] **3.3** Commit: `git commit -m "Archive/remove AI infrastructure planning docs (10 files)"`

#### Desktop Environment (3 files)

- [ ] **3.4** If archiving (not deleting):
  ```bash
  git mv desktop_environment/* docs/archive/planning/desktop-environment/
  git rm -d desktop_environment/
  ```
- [ ] **3.5** If deleting:
  ```bash
  git rm -r desktop_environment/
  ```
- [ ] **3.6** Commit: `git commit -m "Archive/remove desktop environment docs (3 files)"`

### Phase 4: Remove Obsolete Files (After Human Review)

**Prerequisites:** Human review confirms each file can be deleted and unique content is merged

#### OVH Deployment Guide

- [ ] **4.1** Review `OVH-DEPLOYMENT-GUIDE.md` for unique content
- [ ] **4.2** If unique content found, merge into `DEPLOYMENT.md` or `OVH Cloud VPS - System Profile.md`
- [ ] **4.3** Remove file:
  ```bash
  git rm OVH-DEPLOYMENT-GUIDE.md
  ```
- [ ] **4.4** Commit: `git commit -m "Remove obsolete OVH-DEPLOYMENT-GUIDE.md (superseded by DEPLOYMENT.md)"`

#### Unimplemented Feature Docs

- [ ] **4.5** Review `DISK-OPTIMIZATION.md` and create GitHub issue if optimizations still planned
- [ ] **4.6** Remove file:
  ```bash
  git rm DISK-OPTIMIZATION.md
  ```
- [ ] **4.7** Review `NIXOS-QUICKSTART.md` and enhance README.md if needed
- [ ] **4.8** Remove file:
  ```bash
  git rm NIXOS-QUICKSTART.md
  ```
- [ ] **4.9** Review `PERFORMANCE-OPTIMIZATIONS.md` and create GitHub issues for actionable items
- [ ] **4.10** Remove file:
  ```bash
  git rm PERFORMANCE-OPTIMIZATIONS.md
  ```
- [ ] **4.11** Commit: `git commit -m "Remove unimplemented feature docs (3 files)"`

#### OpNix Setup

- [ ] **4.12** Based on human review decision:
  - If archiving: `git mv OPNIX-SETUP.md docs/archive/future-features/`
  - If deleting: `git rm OPNIX-SETUP.md`
- [ ] **4.13** Commit: `git commit -m "Archive/remove OPNIX-SETUP.md"`

### Phase 5: Refactor/Condense Documents

**Prerequisites:** No human review needed; these are improvements, not deletions

#### System Config Guides

- [ ] **5.1** Condense `./system_config/project_briefs/01_MASTER_PROJECT_BRIEF.md`:
  - Remove redundant architecture descriptions
  - Keep project vision and goals
  - Convert detailed plans to bullet lists
  - Target: ~600 words
- [ ] **5.2** Commit: `git commit -m "Condense MASTER_PROJECT_BRIEF.md (reduce by 60%)"`

- [ ] **5.3** Condense `./system_config/implementation_guides/03_pantherOS_IMPLEMENTATION_GUIDE.md`:
  - Remove steps for unimplemented features
  - Remove redundant deployment steps
  - Keep unique troubleshooting content
  - Restructure as troubleshooting guide + references
  - Target: ~1000 words
- [ ] **5.4** Commit: `git commit -m "Condense implementation guide to troubleshooting focus"`

- [ ] **5.5** Condense `./system_config/secrets_management/MASTER_1PASSWORD_GUIDE.md`:
  - Remove basic CLI usage
  - Keep pantherOS-specific patterns
  - Restructure as quick reference
  - Target: ~800 words
  - OR merge into `.github/SECRETS-AND-ENVIRONMENT-VARIABLES.md` and delete
- [ ] **5.6** Commit: `git commit -m "Condense 1Password guide"`

- [ ] **5.7** Update `./system_config/secrets_management/01_cli_reference.md`:
  - Add "Future reference" warning header
  - Convert to concise CLI reference table
  - Target: ~400 words
- [ ] **5.8** Commit: `git commit -m "Mark OpNix CLI reference as future feature"`

#### Code Snippets

- [ ] **5.9** Standardize all code snippet files in `./code_snippets/system_config/nixos/`:
  - Apply standard template to each file
  - Remove prose, keep code
  - Add brief intro, prerequisites, verification
  - Update CODE_SNIPPETS_INDEX.md
- [ ] **5.10** Commit: `git commit -m "Standardize code snippet format (6 files)"`

#### Architecture Diagrams

- [ ] **5.11** Update `./architecture/ARCHITECTURE_DIAGRAMS.md`:
  - Add "ASPIRATIONAL" warning header
  - Add "Current Implementation" section
  - Label existing diagrams as "planned"
  - Reduce by ~40%
- [ ] **5.12** Update `./architecture/ARCHITECTURE_DIAGRAMS_SYSTEMS.md` similarly
- [ ] **5.13** Commit: `git commit -m "Clarify architecture diagrams as aspirational"`

#### Miscellaneous

- [ ] **5.14** Condense `./.opencode/skills/systematic-debugging/README.md`:
  - Keep debugging checklist
  - Remove extended explanations
  - Convert to quick reference
  - Target: ~300 words
- [ ] **5.15** Commit: `git commit -m "Condense systematic debugging skill"`

- [ ] **5.16** Review and standardize `.specify/templates/` files (5 files):
  - Ensure consistent frontmatter
  - Add usage instructions
  - Minor edits only
- [ ] **5.17** Commit: `git commit -m "Standardize Spec Kit templates"`

### Phase 6: Update Navigation and References

- [ ] **6.1** Update `./00_MASTER_TOPIC_MAP.md`:
  - Remove references to deleted files
  - Update references to archived files
  - Mark condensed files with (updated) notation
- [ ] **6.2** Update `./system_config/00_TOPIC_MAP.md` similarly
- [ ] **6.3** Commit: `git commit -m "Update navigation documents after pruning"`

- [ ] **6.4** Update `./.github/copilot-instructions.md`:
  - Remove references to deleted/archived content
  - Update file counts and structure descriptions
- [ ] **6.5** Commit: `git commit -m "Update Copilot instructions after pruning"`

- [ ] **6.6** Search for broken internal links:
  ```bash
  # Check for links to deleted files
  grep -r "ai_infrastructure" --include="*.md" .
  grep -r "desktop_environment" --include="*.md" .
  grep -r "OVH-DEPLOYMENT-GUIDE" --include="*.md" .
  ```
- [ ] **6.7** Fix any broken internal links found
- [ ] **6.8** Commit: `git commit -m "Fix internal links after pruning"`

### Phase 7: Create Summary and Documentation

- [ ] **7.1** Create `/docs/archive/PRUNING_CHANGELOG.md` with:
  - Date of pruning
  - Files removed (with reasons)
  - Files archived (with new locations)
  - Files condensed (with before/after sizes)
  - Decision rationale for each change
- [ ] **7.2** Commit: `git commit -m "Add pruning changelog"`

- [ ] **7.3** Update `README.md` if structure changed significantly
- [ ] **7.4** Commit: `git commit -m "Update README after documentation restructure"`

### Phase 8: Validation and Testing

- [ ] **8.1** Verify all links work:
  ```bash
  # Use markdown link checker or manual review
  find . -name "*.md" -exec grep -l "\[.*\](.*)" {} \;
  ```
- [ ] **8.2** Test Spec Kit commands still work (if duplicates were removed)
- [ ] **8.3** Verify no broken references in code:
  ```bash
  # Check Nix files for doc references
  grep -r "docs/" --include="*.nix" .
  ```
- [ ] **8.4** Build NixOS configurations to ensure no breakage:
  ```bash
  nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
  nix build .#nixosConfigurations.hetzner-cloud.config.system.build.toplevel
  ```
- [ ] **8.5** Run any existing documentation tests (if they exist)

### Phase 9: Final Review and Merge

- [ ] **9.1** Review all commits in pruning branch
- [ ] **9.2** Create summary statistics:
  - Files before pruning: 83
  - Files after pruning: [count]
  - Files removed: [count]
  - Files archived: [count]
  - Files condensed: [count]
  - Estimated space saved: [size]
- [ ] **9.3** Push branch for review:
  ```bash
  git push origin docs-pruning-backup
  ```
- [ ] **9.4** Create pull request with summary
- [ ] **9.5** Address review feedback
- [ ] **9.6** Merge to main branch after approval

### Phase 10: Post-Merge Cleanup

- [ ] **10.1** Verify main branch is clean and builds
- [ ] **10.2** Update any CI/CD that references old file paths
- [ ] **10.3** Notify team of documentation restructure
- [ ] **10.4** Monitor for any issues related to missing documentation
- [ ] **10.5** Create follow-up issues for any remaining documentation work

---

## Expected Outcomes

### Before Pruning
- **Total files:** 83 documentation files
- **Total estimated size:** ~60,000 words
- **Duplicates:** 27 files (18 exact duplicates)
- **Obsolete/low-value:** 5 files
- **Aspirational/unimplemented:** 13 files

### After Pruning (Conservative Estimate)
- **Total files:** ~50 documentation files
- **Total estimated size:** ~35,000 words (42% reduction)
- **Duplicates:** 0 files
- **Obsolete/low-value:** 0 files (archived or removed)
- **Aspirational/unimplemented:** 0 files in main tree (archived)

### Quality Improvements
- **Clarity:** Clear distinction between implemented and aspirational features
- **Maintenance:** Reduced maintenance burden (fewer files to keep updated)
- **Navigation:** Easier to find relevant documentation
- **AI agent context:** More focused documentation for AI agents to learn from
- **Onboarding:** New contributors see only relevant, current documentation

### Risks Mitigated by Conservative Approach
- **No deletion without review:** All deletions require human sign-off
- **Archive option:** Aspirational content preserved for future reference
- **Merge unique content:** Obsolete files reviewed for unique content before deletion
- **Git history:** All changes tracked in git for easy rollback if needed
- **Backup branch:** Pruning work done on separate branch for review

---

## Next Steps

1. **Human Review:** Review this plan and answer all "Human review questions"
2. **Decision Documentation:** Document decisions in `/docs/archive/PRUNING_DECISIONS.md`
3. **Approval:** Obtain approval to proceed with pruning
4. **Execution:** Follow "Refactor Execution Checklist" step-by-step
5. **Validation:** Verify all changes before merging
6. **Follow-up:** Create issues for any remaining documentation work

---

## Appendix: File Classification Summary Table

| Classification | Count | Action | Examples |
|----------------|-------|--------|----------|
| Keep as-is | 20 | No changes | README.md, DEPLOYMENT.md, system profiles |
| Keep but condense | 15 | Reduce verbosity, improve clarity | Implementation guides, 1Password guide, code snippets |
| Obsolete/low-value | 5 | Delete after review | OVH-DEPLOYMENT-GUIDE.md, DISK-OPTIMIZATION.md |
| Duplicates | 18 | Delete (keeping 9 canonical) | Spec Kit agents in .opencode/ and .specify/templates/ |
| Archive (aspirational) | 13 | Move to /docs/archive/ | AI infrastructure plans, desktop environment docs |
| **Total** | **71 actions on 83 files** | | **Reduce from 83 to ~50 files** |

---

**End of Pruning Plan**
