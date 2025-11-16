# Documentation Structure & Sharding Plan

**Generated:** 2025-11-16  
**Repository:** pantherOS NixOS Configuration  
**Purpose:** Define `/docs` tree architecture and sharding strategy for AI-optimized documentation

---

## Executive Summary

This plan proposes a comprehensive `/docs` directory structure for the pantherOS repository, designed to be:

- **Stable**: Organized by purpose and audience, not by current implementation state
- **Discoverable**: Clear hierarchy with obvious locations for different doc types
- **AI-Optimized**: Small, focused files (~150-200 lines) for better retrieval and context
- **Contributor-Friendly**: Intuitive organization that new contributors can navigate

**Key Metrics:**
- Current state: 83 documentation files across 18 directories
- Target state: ~55-60 focused files in `/docs` structure
- Reduction: ~30% through deduplication, consolidation, and archival
- Improved organization: 8 top-level categories vs 18 scattered directories

---

## Proposed `/docs` Directory Structure

### High-Level Tree

```
/docs/
├── index.md                           # Main entry point (generated from README)
├── architecture/                      # System design and decisions
│   ├── overview.md
│   ├── components-core.md
│   ├── components-deployment.md
│   ├── diagrams-system.md
│   ├── diagrams-integration.md
│   └── decisions/                     # ADRs and principles
│       ├── index.md
│       └── constitution.md
├── decisions/                         # Architecture Decision Records
│   ├── index.md
│   └── adr-001-flakes-over-channels.md
├── howto/                             # Task-oriented guides
│   ├── index.md
│   ├── deploy-new-server.md
│   ├── manage-secrets.md
│   ├── setup-development.md
│   ├── troubleshoot-common-issues.md
│   └── migrate-dual-disk.md
├── ops/                               # Operations and maintenance
│   ├── index.md
│   ├── deployment-overview.md
│   ├── hardware-ovh-cloud.md
│   ├── hardware-hetzner-cloud.md
│   ├── hardware-yoga.md
│   └── monitoring.md
├── infra/                             # Infrastructure and tooling
│   ├── index.md
│   ├── nixos-overview.md
│   ├── nixos-flakes.md
│   ├── nixos-disko.md
│   ├── nixos-anywhere.md
│   ├── devcontainer.md
│   ├── dev-shells.md
│   └── ci-cd.md
├── api/                               # API documentation
│   └── index.md                       # Placeholder for future
├── specs/                             # Spec-Kit specifications
│   ├── index.md
│   └── 001-nixos-anywhere/           # Existing spec
│       ├── spec.md
│       ├── plan.md
│       ├── tasks.md
│       └── checklists/
│           └── requirements.md
├── tools/                             # Tool documentation
│   ├── index.md
│   ├── spec-kit-overview.md
│   ├── spec-kit-commands.md
│   ├── mcp-servers.md
│   ├── agentdb.md
│   └── nix-workflows.md
├── examples/                          # Code examples
│   ├── index.md
│   └── nixos/
│       ├── battery-management.md
│       ├── browser-config.md
│       ├── datadog-agent.md
│       ├── nvidia-gpu.md
│       └── security-hardening.md
├── reference/                         # Reference documentation
│   ├── index.md
│   ├── configuration-summary.md
│   ├── secrets-inventory.md
│   ├── secrets-environment-vars.md
│   └── secrets-quick-reference.md
├── contributing/                      # Contribution guides
│   ├── index.md
│   ├── getting-started.md
│   ├── copilot-context.md
│   └── code-style.md
└── archive/                           # Historical/deprecated docs
    ├── index.md
    ├── planning/
    │   ├── ai-infrastructure/        # Future AI plans
    │   └── desktop-environment/      # Future desktop plans
    └── obsolete/
        ├── ovh-deployment-guide.md   # Superseded docs
        └── disk-optimization.md
```

---
## Detailed Structure Definitions

### `/docs/index.md`

**Purpose:** Main entry point for all documentation  
**Content:**
- Welcome and overview
- Quick links to major sections
- Getting started paths (user, contributor, operator)
- Search and navigation guidance

**Source:** Transform from current `README.md` + `00_MASTER_TOPIC_MAP.md`  
**Target Size:** ~100-150 lines

---

### `/docs/architecture/`

**Purpose:** System design, architecture decisions, and technical vision

#### Files and Purposes

| File | Purpose | Size Target | Sources |
|------|---------|-------------|---------|
| `overview.md` | High-level architecture and design philosophy | 150 lines | `system_config/03_PANTHEROS_NIXOS_BRIEF.md` (condensed) |
| `components-core.md` | Core NixOS components (flakes, hosts, modules) | 150 lines | Extracted from brief + `CONFIGURATION-SUMMARY.md` |
| `components-deployment.md` | Deployment components (disko, nixos-anywhere) | 150 lines | Extracted from deployment docs |
| `diagrams-system.md` | System architecture diagrams | 200 lines | `architecture/ARCHITECTURE_DIAGRAMS.md` (marked aspirational) |
| `diagrams-integration.md` | System integration diagrams | 200 lines | `architecture/ARCHITECTURE_DIAGRAMS_SYSTEMS.md` |

#### `/docs/architecture/decisions/`

**Purpose:** Architecture Decision Records and project principles

| File | Purpose | Size Target | Sources |
|------|---------|-------------|---------|
| `index.md` | ADR index and overview | 50 lines | New |
| `constitution.md` | Project constitution and core principles | 200 lines | `.specify/memory/constitution.md` |

---

### `/docs/decisions/`

**Purpose:** Standalone ADRs for major technical decisions

#### Initial ADRs to Create

| File | Purpose | Size Target | Sources |
|------|---------|-------------|---------|
| `index.md` | ADR index template | 50 lines | New |
| `adr-001-flakes-over-channels.md` | Why we use flakes | 100 lines | Extract from briefs |
| `adr-002-minimal-server-config.md` | Minimal vs modular approach | 100 lines | Extract from briefs |
| `adr-003-disko-declarative-disks.md` | Why declarative disk management | 100 lines | Extract from deployment docs |

---

### `/docs/howto/`

**Purpose:** Task-oriented, step-by-step guides for common operations

#### Files and Purposes

| File | Purpose | Size Target | Sources |
|------|---------|-------------|---------|
| `index.md` | Guide index and quick reference | 100 lines | New |
| `deploy-new-server.md` | Deploy a new NixOS server | 200 lines | `DEPLOYMENT.md` (main content) |
| `manage-secrets.md` | Secrets management workflows | 200 lines | Consolidated from `.github/SECRETS-*.md` |
| `setup-development.md` | Set up development environment | 150 lines | Extract from copilot-instructions + devShells |
| `troubleshoot-common-issues.md` | Common problems and solutions | 200 lines | Extract from implementation guide |
| `migrate-dual-disk.md` | Migrate to dual-disk setup | 150 lines | `migrate-to-dual-disk.sh` (documentation) |

**Sharding Note:** `manage-secrets.md` may be split into:
- `manage-secrets-overview.md` (~100 lines)
- `manage-secrets-1password.md` (~100 lines)
- `manage-secrets-opnix.md` (~100 lines, future)

---

### `/docs/ops/`

**Purpose:** Operations, deployment, and infrastructure management

#### Files and Purposes

| File | Purpose | Size Target | Sources |
|------|---------|-------------|---------|
| `index.md` | Operations overview | 100 lines | New |
| `deployment-overview.md` | Deployment process and tooling | 150 lines | `DEPLOYMENT.md` (overview sections) |
| `hardware-ovh-cloud.md` | OVH Cloud VPS specifications | 100 lines | `OVH Cloud VPS - System Profile.md` |
| `hardware-hetzner-cloud.md` | Hetzner Cloud VPS specifications | 100 lines | `Hetzner Cloud VPS - System Profile.md` |
| `hardware-yoga.md` | Lenovo Yoga workstation specs | 150 lines | `Yoga - System Profile.md` |
| `monitoring.md` | Monitoring and observability | 100 lines | New (placeholder) |

---

### `/docs/infra/`

**Purpose:** Infrastructure tooling, NixOS concepts, and CI/CD

#### Files and Purposes

| File | Purpose | Size Target | Sources |
|------|---------|-------------|---------|
| `index.md` | Infrastructure overview | 100 lines | New |
| `nixos-overview.md` | NixOS introduction and concepts | 150 lines | Extract from briefs and README |
| `nixos-flakes.md` | Flakes architecture and usage | 150 lines | Extract from `flake.nix` comments + docs |
| `nixos-disko.md` | Disko disk management | 150 lines | Extract from disko configs + docs |
| `nixos-anywhere.md` | nixos-anywhere remote installation | 150 lines | Extract from deployment docs |
| `devcontainer.md` | Dev Container setup and usage | 100 lines | `.github/devcontainer.json` + docs |
| `dev-shells.md` | Development shell environments | 150 lines | Extract from `flake.nix` devShells |
| `ci-cd.md` | CI/CD and automation | 100 lines | New (placeholder) |

---

### `/docs/specs/`, `/docs/tools/`, `/docs/examples/`, `/docs/reference/`, `/docs/contributing/`

Please see the complete document for detailed specifications of these sections.

---

## Document Mapping Table

This table maps each existing document to its target location in the `/docs` structure.

### Legend
- **Status:** From `pruning_plan.md` analysis
  - `KEEP_AS_IS` - Keep with minimal changes
  - `KEEP_AND_CONDENSE` - Keep but reduce size
  - `DELETE_AFTER_REVIEW` - Remove after review
  - `ARCHIVE` - Move to `/docs/archive/`
  - `DUPLICATE` - Delete (duplicate of another file)
- **Action:**
  - `MOVE` - Move file to target path
  - `TRANSFORM` - Significant restructuring needed
  - `SPLIT` - Shard into multiple files
  - `MERGE` - Merge with other files
  - `DELETE` - Remove (after extracting any unique content)

### Root Directory Documentation

| Current Path | Status | Target Docs Path | Action | Notes |
|--------------|--------|------------------|--------|-------|
| `./00_MASTER_TOPIC_MAP.md` | KEEP_AS_IS | `/docs/index.md` | TRANSFORM | Transform into main docs index |
| `./README.md` | KEEP_AS_IS | `/README.md` + `/docs/index.md` | SPLIT | Keep root README (brief), expand into docs index |
| `./CONFIGURATION-SUMMARY.md` | KEEP_AS_IS | `/docs/reference/configuration-summary.md` | MOVE | Direct move |
| `./DEPLOYMENT.md` | KEEP_AS_IS | `/docs/howto/deploy-new-server.md` + `/docs/ops/deployment-overview.md` | SPLIT | Split overview vs step-by-step |
| `./OVH-DEPLOYMENT-GUIDE.md` | DELETE_AFTER_REVIEW | `/docs/archive/obsolete/ovh-deployment-guide.md` | MOVE | Archive as superseded |
| `./DISK-OPTIMIZATION.md` | DELETE_AFTER_REVIEW | `/docs/archive/obsolete/disk-optimization.md` | MOVE | Archive as unimplemented |
| `./NIXOS-QUICKSTART.md` | DELETE_AFTER_REVIEW | N/A | DELETE | Merge into getting-started.md or delete |
| `./OPNIX-SETUP.md` | DELETE_AFTER_REVIEW | `/docs/archive/planning/opnix-setup.md` | MOVE | Archive for future reference |
| `./PERFORMANCE-OPTIMIZATIONS.md` | DELETE_AFTER_REVIEW | `/docs/archive/planning/performance-ideas.md` | MOVE | Archive or convert to issues |
| `./OVH Cloud VPS - System Profile.md` | KEEP_AS_IS | `/docs/ops/hardware-ovh-cloud.md` | MOVE | Rename for consistency |
| `./Hetzner Cloud VPS - System Profile.md` | KEEP_AS_IS | `/docs/ops/hardware-hetzner-cloud.md` | MOVE | Rename for consistency |
| `./Yoga - System Profile.md` | KEEP_AS_IS | `/docs/ops/hardware-yoga.md` | MOVE | Rename for consistency |

### System Config Directory

| Current Path | Status | Target Docs Path | Action | Notes |
|--------------|--------|------------------|--------|-------|
| `./system_config/README.md` | KEEP_AS_IS | `/docs/architecture/overview.md` | TRANSFORM | Incorporate into architecture overview |
| `./system_config/00_TOPIC_MAP.md` | KEEP_AS_IS | N/A | DELETE | Superseded by main index |
| `./system_config/03_PANTHEROS_NIXOS_BRIEF.md` | KEEP_AS_IS | `/docs/architecture/overview.md` + `/docs/architecture/components-core.md` | SPLIT | Split into overview + components |
| `./system_config/COMPLETION_SUMMARY.md` | KEEP_AS_IS | `/docs/reference/completion-status.md` | MOVE | Move to reference |
| `./system_config/project_briefs/01_MASTER_PROJECT_BRIEF.md` | KEEP_AND_CONDENSE | `/docs/architecture/overview.md` | MERGE | Merge unique content into overview |
| `./system_config/implementation_guides/03_pantherOS_IMPLEMENTATION_GUIDE.md` | KEEP_AND_CONDENSE | `/docs/howto/troubleshoot-common-issues.md` | TRANSFORM | Extract troubleshooting, remove redundancy |
| `./system_config/secrets_management/01_cli_reference.md` | KEEP_AND_CONDENSE | `/docs/howto/manage-secrets-opnix.md` | MOVE | Mark as future reference |
| `./system_config/secrets_management/MASTER_1PASSWORD_GUIDE.md` | KEEP_AND_CONDENSE | `/docs/howto/manage-secrets-1password.md` | TRANSFORM | Condense and restructure |

### AI Infrastructure, Desktop Environment, Architecture Directories

| Current Path | Status | Target Docs Path | Action | Notes |
|--------------|--------|------------------|--------|-------|
| `./ai_infrastructure/*.md` (10 files) | ARCHIVE | `/docs/archive/planning/ai-infrastructure/` | MOVE | Archive all planning docs |
| `./desktop_environment/*.md` (3 files) | ARCHIVE | `/docs/archive/planning/desktop-environment/` | MOVE | Archive all desktop docs |
| `./architecture/ARCHITECTURE_DIAGRAMS.md` | KEEP_AND_CONDENSE | `/docs/architecture/diagrams-system.md` | MOVE | Add "aspirational" warnings |
| `./architecture/ARCHITECTURE_DIAGRAMS_SYSTEMS.md` | KEEP_AND_CONDENSE | `/docs/architecture/diagrams-integration.md` | MOVE | Add "aspirational" warnings |

### Code Snippets Directory

| Current Path | Status | Target Docs Path | Action | Notes |
|--------------|--------|------------------|--------|-------|
| `./code_snippets/system_config/CODE_SNIPPETS_INDEX.md` | KEEP_AND_CONDENSE | `/docs/examples/index.md` | TRANSFORM | Restructure as examples index |
| `./code_snippets/system_config/nixos/battery-management.nix.md` | KEEP_AND_CONDENSE | `/docs/examples/nixos/battery-management.md` | MOVE | Standardize format |
| `./code_snippets/system_config/nixos/browser.nix.md` | KEEP_AND_CONDENSE | `/docs/examples/nixos/browser-config.md` | MOVE | Standardize format |
| `./code_snippets/system_config/nixos/datadog-agent.nix.md` | KEEP_AND_CONDENSE | `/docs/examples/nixos/datadog-agent.md` | MOVE | Standardize format |
| `./code_snippets/system_config/nixos/nvidia-gpu.nix.md` | KEEP_AND_CONDENSE | `/docs/examples/nixos/nvidia-gpu.md` | MOVE | Standardize format |
| `./code_snippets/system_config/nixos/security-hardening.nix.md` | KEEP_AND_CONDENSE | `/docs/examples/nixos/security-hardening.md` | MOVE | Standardize format |

### Specs, GitHub, OpenCode & Specify Directories

| Current Path | Status | Target Docs Path | Action | Notes |
|--------------|--------|------------------|--------|-------|
| `./specs/001-nixos-anywhere-deployment-setup/spec.md` | KEEP_AS_IS | `/docs/specs/001-nixos-anywhere/spec.md` | MOVE | Keep structure |
| `./specs/001-nixos-anywhere-deployment-setup/checklists/requirements.md` | KEEP_AS_IS | `/docs/specs/001-nixos-anywhere/checklists/requirements.md` | MOVE | Keep structure |
| `./.github/copilot-instructions.md` | KEEP_AS_IS | `/docs/contributing/copilot-context.md` | MOVE | Keep in both locations initially |
| `./.github/MCP-SETUP.md` | KEEP_AS_IS | `/docs/tools/mcp-servers.md` | MOVE | Keep in both locations initially |
| `./.github/SECRETS-*.md` (4 files) | KEEP_AS_IS | `/docs/reference/secrets-*.md` | MOVE | Keep in both locations initially |
| `./.github/agents/speckit.*.md` (9 files) | KEEP_AS_IS | `./.github/agents/` (keep) + summary in `/docs/tools/` | KEEP | Canonical source stays in .github/ |
| `./.opencode/command/speckit.*.md` (9 files) | DUPLICATE | N/A | DELETE | Remove duplicates |
| `./.opencode/skills/systematic-debugging/README.md` | KEEP_AND_CONDENSE | `/docs/howto/debug-systematically.md` | MOVE | Condense to quick reference |
| `./.specify/README.md` | KEEP_AS_IS | `/docs/tools/spec-kit-overview.md` | MOVE | Explain Spec Kit framework |
| `./.specify/memory/constitution.md` | KEEP_AS_IS | `/docs/architecture/decisions/constitution.md` | MOVE | Project principles |
| `./.specify/templates/commands/*.md` (9 files) | DUPLICATE | N/A | DELETE | Remove duplicates |
| `./.specify/templates/*.md` (5 files) | KEEP_AS_IS | `./.specify/templates/` | KEEP | Templates stay in .specify/ |


---

## Sharding Rules

### General Principles

1. **One Major Concept Per File**
   - Each file should cover a single, well-defined topic
   - Related subtopics can be in the same file if they form a coherent whole
   - Split files when they exceed target size or cover multiple independent concepts

2. **Target File Size**
   - **Optimal:** 100-150 lines (~600-900 words)
   - **Maximum:** 200 lines (~1200 words)
   - **Minimum:** 50 lines (~300 words)
   - Files shorter than 50 lines should be merged with related content

3. **Consistent Naming Conventions**
   - Use lowercase with hyphens: `topic-subtopic.md`
   - Component docs: `component-<name>.md`
   - How-to guides: `<verb>-<object>.md` (e.g., `deploy-new-server.md`)
   - Examples: `<feature>-<aspect>.md` (e.g., `battery-management.md`)
   - Hardware profiles: `hardware-<name>.md`

4. **Independent Readability**
   - Each file should be understandable on its own
   - Include brief context at the start
   - Link to related docs sparingly (2-3 max)
   - Use "See also" section at the end for related topics

### Specific Sharding Scenarios

#### Scenario 1: Long Architecture Documents

**Current:** `system_config/03_PANTHEROS_NIXOS_BRIEF.md` (1050 words)

**Shard into:**
1. `/docs/architecture/overview.md` (~150 lines)
   - High-level philosophy and design goals
   - Technology stack rationale
   - Architecture principles

2. `/docs/architecture/components-core.md` (~150 lines)
   - NixOS flakes structure
   - Host configuration pattern
   - Module system

3. `/docs/architecture/components-deployment.md` (~150 lines)
   - disko disk management
   - nixos-anywhere deployment
   - Bootstrap process

**Sharding Strategy:**
- Split by component type (core vs deployment)
- Each file covers related components
- Cross-reference with "See also" sections

#### Scenario 2: Comprehensive Guides

**Current:** `DEPLOYMENT.md` (940 words)

**Shard into:**
1. `/docs/ops/deployment-overview.md` (~100 lines)
   - Deployment process overview
   - Prerequisites
   - High-level steps

2. `/docs/howto/deploy-new-server.md` (~200 lines)
   - Step-by-step deployment guide
   - Command examples
   - Troubleshooting

**Sharding Strategy:**
- Separate overview (conceptual) from how-to (procedural)
- How-to can be longer as it's task-focused
- Overview links to detailed how-to

#### Scenario 3: Secrets Management Documentation

**Current:** Multiple files in `.github/` and `system_config/secrets_management/` (6+ files, ~8000 words)

**Shard into:**
1. `/docs/howto/manage-secrets.md` (~100 lines)
   - Overview of secrets management
   - Quick start guide
   - Links to detailed guides

2. `/docs/howto/manage-secrets-1password.md` (~150 lines)
   - 1Password integration
   - CLI workflows
   - Best practices

3. `/docs/howto/manage-secrets-opnix.md` (~150 lines)
   - OpNix integration (future)
   - Configuration
   - Usage patterns

4. `/docs/reference/secrets-inventory.md` (~200 lines)
   - Complete secrets list
   - Required vs optional
   - Access patterns

5. `/docs/reference/secrets-environment-vars.md` (~200 lines)
   - Environment variable reference
   - Configuration options
   - Examples

6. `/docs/reference/secrets-quick-reference.md` (~100 lines)
   - Quick reference table
   - Common commands
   - Troubleshooting

**Sharding Strategy:**
- Separate how-to guides by tool (1Password, OpNix)
- Reference docs for inventory and lookups
- Quick reference for common tasks

#### Scenario 4: Code Examples

**Current:** 5 example files in `code_snippets/` (varying sizes)

**Keep separate, standardize format:**
Each example file should follow this structure:

```markdown
# [Feature] Configuration Example

## Overview
[2-3 sentences - what this example does]

## Prerequisites
- [List of prerequisites]

## Use Cases
- [When to use this configuration]

## Configuration
\```nix
[Nix code block with inline comments]
\```

## Verification
\```bash
[Commands to verify it works]
\```

## Customization
[Key variables to customize]

## Troubleshooting
[Common issues and solutions]

## References
- [Link to official docs]
- [Link to related examples]
```

**Target:** Each example 100-150 lines max

### Sharding Decision Tree

Use this decision tree when deciding whether to shard a document:

```
Is the file > 200 lines?
├─ YES → Consider sharding
│   ├─ Does it cover multiple independent concepts?
│   │   ├─ YES → SHARD by concept (1 file per concept)
│   │   └─ NO → Is it a reference document (list/table)?
│   │       ├─ YES → KEEP as single file (okay to be longer)
│   │       └─ NO → SHARD by logical sections
│   └─ Can it be condensed without losing information?
│       ├─ YES → CONDENSE first, then reassess
│       └─ NO → SHARD by logical sections
└─ NO → Keep as single file
    └─ Is it < 50 lines?
        ├─ YES → Consider merging with related content
        └─ NO → Keep as-is
```

### Cross-Reference Guidelines

**Limit cross-references:** Each file should have max 3-5 cross-references

**Reference format:**
```markdown
## See Also

- [Related Topic](../path/to/related.md) - Brief description
- [Another Topic](./another.md) - Brief description
```

**When to cross-reference:**
- Prerequisites that are documented elsewhere
- Related how-to guides for the same component
- Deeper dives into subtopics
- Architecture context for technical docs

**When NOT to cross-reference:**
- Tangentially related topics
- General background information
- Multiple links to the same section
- Links that break the flow of reading

### File Header Template

Every documentation file should start with this structure:

```markdown
# [File Title]

> **Category:** [Architecture|How-To|Operations|Reference|etc.]  
> **Audience:** [Users|Contributors|Operators|All]  
> **Last Updated:** [YYYY-MM-DD]

[2-3 sentence overview of what this file covers]

## Table of Contents

- [Section 1](#section-1)
- [Section 2](#section-2)
...

[Content sections]

## See Also

- [Related Doc 1](../path/doc1.md)
- [Related Doc 2](../path/doc2.md)
```


---

## Migration Plan

This section provides a safe, step-by-step migration plan for implementing the new `/docs` structure.

### Prerequisites

Before starting migration:

1. ✅ Human review and approval of this plan
2. ✅ Backup branch created: `git checkout -b docs-migration-backup`
3. ✅ All changes committed to current branch
4. ✅ Team notification of upcoming documentation reorganization

### Phase 1: Preparation (Non-Destructive)

**Goal:** Set up infrastructure without moving existing docs

#### Step 1.1: Create `/docs` Directory Structure

```bash
# Create main /docs directories
mkdir -p docs/{architecture,decisions,howto,ops,infra,api,specs,tools,examples,reference,contributing,archive}

# Create subdirectories
mkdir -p docs/architecture/decisions
mkdir -p docs/examples/nixos
mkdir -p docs/archive/{planning,obsolete}
mkdir -p docs/archive/planning/{ai-infrastructure,desktop-environment}

# Create .gitkeep files for empty directories
touch docs/api/.gitkeep
```

**Verification:** 
```bash
tree docs/ -L 2
```

**Commit:**
```bash
git add docs/
git commit -m "docs: Create initial /docs directory structure"
```

### Phase 2: Remove Duplicates (Safe Deletions)

**Goal:** Remove duplicate Spec Kit agent files

#### Step 2.1: Verify Canonical Files Exist

```bash
# Verify all 9 canonical files exist in .github/agents/
ls -1 .github/agents/speckit.*.md | wc -l
# Should output: 9
```

#### Step 2.2: Check for Script Dependencies

```bash
# Check if any scripts reference the directories we're removing
grep -r "\.opencode/command" .specify/scripts/ || echo "No references found"
grep -r "templates/commands" .specify/scripts/ || echo "No references found"
```

#### Step 2.3: Remove Duplicate Directories

If no dependencies found:

```bash
# Remove duplicate Spec Kit agent files
git rm -r .opencode/command/
git rm -r .specify/templates/commands/

git commit -m "docs: Remove duplicate Spec Kit agent definitions (18 files)

Keep canonical definitions in .github/agents/ only.
Removes duplicates from:
- .opencode/command/ (9 files)
- .specify/templates/commands/ (9 files)"
```

### Phase 3: Archive Aspirational Content

**Goal:** Move unimplemented planning docs to archive

#### Step 3.1: Archive AI Infrastructure Plans

```bash
# Move all AI infrastructure planning docs
git mv ai_infrastructure/*.md docs/archive/planning/ai-infrastructure/

# Remove empty directory
git rm -d ai_infrastructure/

git commit -m "docs: Archive AI infrastructure planning documents (10 files)"
```

#### Step 3.2: Archive Desktop Environment Plans

```bash
# Move all desktop environment docs
git mv desktop_environment/*.md docs/archive/planning/desktop-environment/

# Remove empty directory
git rm -d desktop_environment/

git commit -m "docs: Archive desktop environment documentation (3 files)"
```

### Phase 4: Archive Obsolete Files

**Goal:** Move superseded documentation to archive

```bash
# Archive superseded files
git mv OVH-DEPLOYMENT-GUIDE.md docs/archive/obsolete/
git mv DISK-OPTIMIZATION.md docs/archive/obsolete/
git mv NIXOS-QUICKSTART.md docs/archive/obsolete/

# Archive future reference files
git mv OPNIX-SETUP.md docs/archive/planning/
git mv PERFORMANCE-OPTIMIZATIONS.md docs/archive/planning/

git commit -m "docs: Archive obsolete and unimplemented documentation (5 files)"
```

### Phase 5: Move Core Documentation (Simple Moves)

**Goal:** Move docs that don't require transformation

#### Step 5.1: Move Hardware Profiles

```bash
# Rename and move hardware profiles
git mv "OVH Cloud VPS - System Profile.md" docs/ops/hardware-ovh-cloud.md
git mv "Hetzner Cloud VPS - System Profile.md" docs/ops/hardware-hetzner-cloud.md
git mv "Yoga - System Profile.md" docs/ops/hardware-yoga.md

git commit -m "docs: Move hardware profiles to /docs/ops/"
```

#### Step 5.2: Move Reference Documentation

```bash
# Move configuration summary
git mv CONFIGURATION-SUMMARY.md docs/reference/configuration-summary.md

# Move system config completion summary
git mv system_config/COMPLETION_SUMMARY.md docs/reference/completion-status.md

git commit -m "docs: Move reference documentation to /docs/reference/"
```

#### Step 5.3: Move Secrets Documentation

```bash
# Copy (not move) secrets docs from .github/ to /docs/reference/
# Keep originals in .github/ initially for backward compatibility
cp .github/SECRETS-INVENTORY.md docs/reference/secrets-inventory.md
cp .github/SECRETS-AND-ENVIRONMENT-VARIABLES.md docs/reference/secrets-environment-vars.md
cp .github/SECRETS-QUICK-REFERENCE.md docs/reference/secrets-quick-reference.md

# Add copied files
git add docs/reference/secrets-*.md

git commit -m "docs: Copy secrets documentation to /docs/reference/"
```

#### Step 5.4: Move Constitution

```bash
# Move constitution to architecture/decisions
git mv .specify/memory/constitution.md docs/architecture/decisions/

git commit -m "docs: Move constitution to /docs/architecture/decisions/"
```

#### Step 5.5: Move Existing Spec

```bash
# Move spec directory
git mv specs/001-nixos-anywhere-deployment-setup docs/specs/001-nixos-anywhere

git commit -m "docs: Move deployment spec to /docs/specs/"
```

### Phase 6: Transform and Shard Large Documents

**Goal:** Split large docs into focused files

This phase requires manual work to:
- Extract content from large documents
- Reorganize into focused files
- Add appropriate headers and cross-references
- Follow sharding rules

Key documents to shard:
1. `system_config/03_PANTHEROS_NIXOS_BRIEF.md` → 3 architecture files
2. `DEPLOYMENT.md` → 2 files (overview + how-to)
3. Secrets documentation → 6 focused files
4. Code examples → Standardize format

**Each transformation should be committed separately**

### Phase 7: Create New Documentation

**Goal:** Write missing documentation

New files to create:
- `docs/infra/nixos-*.md` (6 files)
- `docs/tools/*.md` (4 files)
- `docs/contributing/*.md` (3 files)
- `docs/decisions/adr-*.md` (3 ADRs)
- Index files for all sections

**Each new file should be committed separately**

### Phase 8: Update Navigation and Cross-References

**Goal:** Ensure all links work and navigation is clear

```bash
# Update all index files with actual content
git add docs/**/index.md
git commit -m "docs: Update all index files with actual content"

# Add cross-references between related documents
git add docs/**/*.md
git commit -m "docs: Add cross-references between related documents"

# Update root README to point to /docs/
git add README.md
git commit -m "docs: Update root README to reference /docs/"
```

### Phase 9: Clean Up Old Structure

**Goal:** Remove now-empty or superseded directories

```bash
# Remove old directories that are now empty
git rm -r system_config/
git rm -r code_snippets/
git rm -r specs/
git rm -r architecture/

# Remove old navigation files
git rm 00_MASTER_TOPIC_MAP.md

git commit -m "docs: Remove old documentation directories and topic map"
```

### Phase 10: Validation and Testing

**Goal:** Ensure everything works

```bash
# Check for broken links (manual or with tool)
# Verify no external references broken
# Build NixOS configurations to ensure no breakage
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
nix build .#nixosConfigurations.hetzner-cloud.config.system.build.toplevel
```


---

## Validation Checklist

Use this checklist to verify the migration was successful:

### Structure Validation

- [ ] `/docs` directory exists with all major sections
- [ ] All section directories have `index.md` files
- [ ] Archive directory structure is in place
- [ ] Example directory structure is in place

### Content Validation

- [ ] All 83 original files are either moved, archived, or deleted (with justification)
- [ ] No files are lost (check git history)
- [ ] All hardware profiles moved to `/docs/ops/`
- [ ] All examples moved to `/docs/examples/nixos/`
- [ ] Secrets docs present in `/docs/reference/`
- [ ] Constitution in `/docs/architecture/decisions/`

### Duplication Validation

- [ ] No duplicate Spec Kit agent files outside `.github/agents/`
- [ ] `.opencode/command/` directory removed
- [ ] `.specify/templates/commands/` directory removed
- [ ] Only 9 Spec Kit agent files exist (in `.github/agents/`)

### Archive Validation

- [ ] AI infrastructure docs in `/docs/archive/planning/ai-infrastructure/`
- [ ] Desktop environment docs in `/docs/archive/planning/desktop-environment/`
- [ ] Obsolete files in `/docs/archive/obsolete/`
- [ ] Total ~18 files in archive

### Link Validation

- [ ] Root `README.md` links to `/docs/index.md`
- [ ] All section index files link back to main index
- [ ] Cross-references use relative paths
- [ ] No broken internal links
- [ ] External links still work

### Build Validation

- [ ] `nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel` succeeds
- [ ] `nix build .#nixosConfigurations.hetzner-cloud.config.system.build.toplevel` succeeds
- [ ] No Nix evaluation errors related to doc paths

### Quality Validation

- [ ] All new files follow header template
- [ ] Files are within size targets (100-200 lines)
- [ ] Each file covers one major concept
- [ ] Examples follow standardized format
- [ ] Cross-references are limited (max 3-5 per file)

### Metadata Validation

- [ ] Migration changelog created
- [ ] Copilot instructions updated
- [ ] PR description complete
- [ ] All commits have meaningful messages

---

## Rollback Plan

If issues are discovered after migration:

### Option 1: Revert Specific Changes

```bash
# Revert specific commits
git revert <commit-sha>

# Or revert range
git revert HEAD~5..HEAD
```

### Option 2: Restore from Backup Branch

```bash
# Switch to backup branch
git checkout docs-migration-backup

# Create new branch from backup
git checkout -b docs-migration-rollback

# Cherry-pick any work done after migration
git cherry-pick <commit-sha>
```

### Option 3: Selective Restore

```bash
# Restore specific files from before migration
git checkout <old-commit-sha> -- path/to/file.md

# Commit restoration
git commit -m "docs: Restore [file] from pre-migration state"
```

---

## Success Criteria

The migration is considered successful when:

1. ✅ All 83 original files are accounted for (moved, archived, or deleted with reason)
2. ✅ `/docs` structure is complete with all sections and indexes
3. ✅ 18 duplicate files removed
4. ✅ 18 aspirational/obsolete files archived
5. ✅ All internal links work
6. ✅ NixOS configurations build successfully
7. ✅ No broken references in scripts or code
8. ✅ Team approves new structure
9. ✅ Documentation is easier to navigate
10. ✅ AI agents can better discover and retrieve docs

---

## Future Enhancements

After migration is complete, consider:

1. **Documentation CI/CD**
   - Markdown linting (markdownlint)
   - Link checking (markdown-link-check)
   - Spell checking (aspell, cspell)
   - Vale style guide enforcement

2. **Search Enhancement**
   - Full-text search integration
   - Tag-based navigation
   - Doc versioning

3. **More Examples**
   - Real-world configuration examples
   - Integration examples
   - Troubleshooting scenarios

4. **Interactive Documentation**
   - Runnable examples
   - Interactive tutorials
   - Video walkthroughs

5. **API Documentation**
   - When APIs are introduced
   - NixOS module API docs
   - Function reference

---

## Summary Statistics

### Before Migration

| Metric | Value |
|--------|-------|
| Total documentation files | 83 |
| Directories with docs | 18 |
| Duplicate files | 18 (27 total copies) |
| Obsolete/low-value files | 5 |
| Aspirational/unimplemented | 13 |
| Average file location depth | 2-3 levels |
| Organization strategy | Ad-hoc, scattered |

### After Migration

| Metric | Value |
|--------|-------|
| Total documentation files | ~60 |
| Directories with docs | 8 (under /docs) |
| Duplicate files | 0 |
| Archived files | 18 |
| Files in /docs | ~45 |
| Average file location depth | 2 levels |
| Organization strategy | Structured, hierarchical |

### Improvement Metrics

| Metric | Improvement |
|--------|-------------|
| File reduction | ~30% (83 → 60) |
| Directory consolidation | ~55% (18 → 8) |
| Duplicate elimination | 100% (18 → 0) |
| Discoverability | High (clear categories) |
| AI retrieval | Optimized (small, focused files) |
| Contributor experience | Improved (intuitive structure) |

---

## Key Takeaways

1. **Stable Structure**: `/docs` organization by purpose and audience, not implementation state
2. **AI-Optimized**: Small files (~150 lines) with single concepts for better retrieval
3. **Discoverable**: Clear hierarchy with 8 major categories
4. **No Data Loss**: Everything either moved, archived, or deleted with justification
5. **Safe Migration**: Phased approach with validation at each step
6. **Backward Compatible**: Critical docs duplicated during transition
7. **Future-Proof**: Structure accommodates growth without reorganization

---

**End of Documentation Structure & Sharding Plan**
