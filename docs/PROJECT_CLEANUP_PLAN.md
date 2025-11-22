# pantherOS Project Cleanup & Reorganization Plan

## Overview

This document outlines the comprehensive cleanup and reorganization plan for the pantherOS project directory. The goal is to:
- Remove clutter and duplicate files
- Consolidate redundant documentation
- Move files to appropriate locations
- Maintain all dotfiles in their current locations
- Optimize and refine documentation

## Current Issues Identified

### 1. Root Level File Clutter
**Problem**: 10+ markdown and config files scattered at root level
- `AGENTS.md` - AI agent guidance (duplicate, redundant)
- `brief.md` - Outdated AI agent brief
- `CLAUDE.md` - Project instructions (keep, but should be in .claude/)
- `config.yaml` - CLI proxy config (move to config/)
- `HANDOFF.md` - Session handoff (move to .claude/)
- `opencode.jsonc` - OpenCode config (move to .opencode/)
- `pantherOS.md` - Project overview (duplicate of README.md)
- Multiple `.md` files without clear organization

### 2. Temporary Hardware Discovery Directories
**Problem**: 4 large hardware discovery directories (~100KB each) with .txt files
- `hardware-discovery-ubuntu-24gb-hel1-1-20251120_224444/`
- `hardware-discovery-vps-9e2f46d4-20251120_230950/`
- `hardware-discovery-yogaCachyOS-20251120_143345/`
- `hardware-discovery-zephyrus-20251120_172030/`

**Total Size**: ~400KB of temporary/completed data

### 3. Duplicate AGENTS.md Files
**Problem**: 7 copies of AGENTS.md in different locations
- `/` (root)
- `/hosts/`
- `/modules/`
- `/overlays/`
- `/home/`
- `/scripts/`
- `/docs/`

**Impact**: Confusion about which is authoritative

### 4. Documentation Sprawl
**Problem**: 13,240 lines of documentation across multiple subdirectories
- `docs/architecture/` - 5 files
- `docs/guides/` - 6 files
- `docs/todos/` - 7 files
- `docs/hardware/` - 4 files
- `docs/plans/` - 5 files
- `docs/*.md` - Multiple root level docs

**Issues**: Some files outdated, some redundant, needs consolidation

### 5. Config Files in Wrong Locations
**Problem**: Configuration files in root instead of dedicated directories
- `opencode.jsonc` - Should be in `.opencode/`
- `config.yaml` - Should be in `config/`

## Cleanup Plan

### Phase 1: Remove Temporary & Duplicate Files

#### 1.1 Remove Hardware Discovery Directories
```bash
# Remove all 4 hardware discovery directories
rm -rf /home/hbohlen/dev/pantherOS/hardware-discovery-*/
```

**Rationale**: These are completed, temporary directories. Hardware specs are already documented in:
- `/home/hbohlen/dev/pantherOS/docs/hardware/*.md`
- `/home/hbohlen/dev/pantherOS/.opencode/context/domain/hardware-specifications.md`

**Savings**: ~400KB disk space

#### 1.2 Consolidate AGENTS.md Files
```bash
# Keep only the authoritative version in .openspec/
# Remove all duplicates:
rm /home/hbohlen/dev/pantherOS/AGENTS.md
rm /home/hbohlen/dev/pantherOS/hosts/AGENTS.md
rm /home/hbohlen/dev/pantherOS/modules/AGENTS.md
rm /home/hbohlen/dev/pantherOS/overlays/AGENTS.md
rm /home/hbohlen/dev/pantherOS/home/AGENTS.md
rm /home/hbohlen/dev/pantherOS/scripts/AGENTS.md
rm /home/hbohlen/dev/pantherOS/docs/AGENTS.md
```

**Rationale**: The root AGENTS.md is the authoritative version and already references `.openspec/AGENTS.md`. Duplicate in subdirectories cause confusion.

#### 1.3 Remove Redundant Overview Files
```bash
# Remove duplicate project overview files
rm /home/hbohlen/dev/pantherOS/brief.md
rm /home/hbohlen/dev/pantherOS/pantherOS.md
```

**Rationale**:
- `brief.md` - Outdated AI agent brief, content moved to other docs
- `pantherOS.md` - Redundant with `README.md`

**Keep**:
- `README.md` - Main project documentation (updated, comprehensive)
- `CLAUDE.md` - Project instructions for Claude

### Phase 2: Move Files to Appropriate Locations

#### 2.1 Move Configuration Files
```bash
# Create config directory
mkdir -p /home/hbohlen/dev/pantherOS/config

# Move config files
mv /home/hbohlen/dev/pantherOS/config.yaml /home/hbohlen/dev/pantherOS/config/
mv /home/hbohlen/dev/pantherOS/opencode.jsonc /home/hbohlen/dev/pantherOS/.opencode/
```

**Rationale**: Configuration files belong in dedicated config directories, not root.

#### 2.2 Move Session & Project Files
```bash
# Move project-specific files to appropriate locations
mv /home/hbohlen/dev/pantherOS/HANDOFF.md /home/hbohlen/dev/pantherOS/.claude/
mv /home/hbohlen/dev/pantherOS/CLAUDE.md /home/hbohlen/dev/pantherOS/.claude/project-instructions.md
```

**Rationale**:
- `.claude/` is the proper location for Claude-related files
- Separate from project root to avoid confusion

#### 2.3 Move Scripts
```bash
# Ensure scripts are in scripts/ directory
# install.sh is already in root, move to scripts/
mv /home/hbohlen/dev/pantherOS/install.sh /home/hbohlen/dev/pantherOS/scripts/
```

**Rationale**: All scripts should be in `scripts/` directory for organization.

### Phase 3: Documentation Optimization

#### 3.1 Consolidate Documentation Structure
```
docs/
├── README.md                          # Main docs index (keep, update)
├── PROJECT_CLEANUP_PLAN.md            # This file (remove after completion)
├── INTEGRATED_KB_MODE.md              # Keep (recently created)
├── PHASE1_COMPLETE.md                 # Archive to docs/archive/
├── architecture/                      # Keep structure
│   ├── overview.md
│   ├── disk-layouts.md
│   ├── host-classification.md
│   ├── module-organization.md
│   └── security-model.md
├── guides/                           # Keep structure
│   ├── README.md
│   ├── hardware-discovery.md
│   ├── module-development.md
│   ├── host-configuration.md
│   ├── testing-deployment.md
│   └── troubleshooting.md
├── hardware/                         # Keep, expand as needed
│   ├── yoga.md
│   ├── zephyrus.md
│   ├── hetzner-vps.md
│   └── ovh-vps.md
├── plans/                           # Keep active plans
│   ├── btrfs-subvolume-layouts.md
│   ├── ghostty-research.md
│   └── host-configurations-review.md
└── archive/                         # NEW: Archive old/completed items
    ├── PHASE1_COMPLETE.md
    └── deprecated/
```

#### 3.2 Update Documentation References
Update all documentation to reflect new file locations:
- Remove references to removed files
- Update paths to moved files
- Ensure all links are valid

#### 3.3 Create Consolidated README
Enhance `docs/README.md` to be a comprehensive navigation hub:
- Project overview
- Quick start guide
- Architecture explanation
- Host configurations
- Development workflows
- Navigation to all other docs

#### 3.4 Optimize File Sizes
- Merge similar documents
- Remove outdated sections
- Condense verbose explanations
- Keep only essential information

### Phase 4: Update Root Directory

#### 4.1 Clean Root Directory
After cleanup, root should contain only:
```
pantherOS/
├── README.md                         # Main project README
├── flake.nix                         # Flake configuration
├── .git/                            # Git repository
├── .gitignore                       # Git ignore rules
├── hosts/                           # Host configurations
├── modules/                         # NixOS modules
├── home/                            # Home-manager configs
├── overlays/                        # Package overlays
├── scripts/                         # Automation scripts
├── docs/                            # Documentation
├── .bmad-core/                      # BMad system (keep)
├── .claude/                         # Claude Memory (keep)
├── .opencode/                       # OpenCode system (keep)
├── .spec-workflow/                  # Spec workflow (keep)
├── .openspec/                       # OpenSpec (keep)
└── [other dotfiles]                 # Keep all dotfiles
```

#### 4.2 Update flake.nix
Ensure flake.nix properly references all modules and configurations.

#### 4.3 Update .gitignore
Add patterns for temporary files and build artifacts.

## Implementation Steps

### Step 1: Backup Current State
```bash
# Create backup before cleanup
git add .
git commit -m "Backup before project cleanup"
```

### Step 2: Remove Temporary Files
```bash
# Remove hardware discovery directories
rm -rf hardware-discovery-*/

# Remove duplicate AGENTS.md files
rm AGENTS.md
rm hosts/AGENTS.md
rm modules/AGENTS.md
rm overlays/AGENTS.md
rm home/AGENTS.md
rm scripts/AGENTS.md
rm docs/AGENTS.md

# Remove redundant overview files
rm brief.md
rm pantherOS.md
```

### Step 3: Move Files to Correct Locations
```bash
# Create config directory
mkdir -p config

# Move config files
mv config.yaml config/
mv opencode.jsonc .opencode/

# Move Claude-related files
mkdir -p .claude
mv HANDOFF.md .claude/
mv CLAUDE.md .claude/project-instructions.md

# Move scripts
mv install.sh scripts/
```

### Step 4: Organize Documentation
```bash
# Create archive directory
mkdir -p docs/archive

# Move completed docs to archive
mv docs/PHASE1_COMPLETE.md docs/archive/

# Update docs/README.md to reflect new structure
```

### Step 5: Update References
- Update all documentation to reflect new file paths
- Update import statements in Nix configurations
- Update any references to moved/removed files

### Step 6: Verify Organization
```bash
# Verify no broken references
# Check all Nix configurations build
# Validate documentation links
```

### Step 7: Commit Changes
```bash
git add .
git commit -m "Clean up and reorganize project structure

- Removed 4 hardware discovery directories (~400KB)
- Consolidated AGENTS.md (removed 6 duplicates)
- Moved config files to dedicated directories
- Organized documentation structure
- Moved scripts to scripts/ directory
- Archived completed documentation"
```

## Expected Outcomes

### Space Savings
- **Hardware discovery directories**: ~400KB
- **Duplicate AGENTS.md files**: ~45KB (6 files × ~7.5KB each)
- **Redundant markdown files**: ~25KB
- **Total estimated savings**: ~470KB

### Improved Organization
- Clear separation of config, docs, scripts
- No duplicate files
- Logical directory structure
- Easy to find files

### Better Documentation
- Consolidated, up-to-date docs
- No broken links
- Clear navigation
- Optimized content

### Maintained Functionality
- All dotfiles preserved in original locations
- All configurations still work
- Git history preserved
- No functional changes

## Risks & Mitigation

### Risk: Breaking References
**Mitigation**: Update all documentation and configuration files before cleanup

### Risk: Losing Important Information
**Mitigation**: Review all files before removal, backup before cleanup

### Risk: Build Failures
**Mitigation**: Verify Nix configurations after reorganization

## Post-Cleanup Tasks

1. **Update project documentation** to reflect new structure
2. **Verify all builds work** with new organization
3. **Update onboarding** materials for new team members
4. **Monitor for broken references** over next few days
5. **Archive this cleanup plan** after successful completion

---

**Plan Version**: 1.0
**Created**: 2025-11-21
**Status**: Ready for implementation
