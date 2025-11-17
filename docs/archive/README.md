# Documentation Archive

**Purpose:** This directory contains archived documentation that describes aspirational features, planning documents, and content that is not currently implemented in pantherOS.

**Last Updated:** 2025-11-17

---

## Why Archive Instead of Delete?

These documents contain valuable planning and design work that may be useful for future implementation. However, they were creating confusion by mixing aspirational content with documentation of actual implementation. Archiving preserves the work while clearly separating it from current documentation.

---

## Archive Structure

```
docs/archive/
├── README.md (this file)
├── future-features/            # Features planned but not yet configured (1 file)
└── planning/
    ├── ai-infrastructure/      # AI infrastructure enhancement plans (10 files)
    ├── desktop-environment/    # Dank Linux desktop environment docs (3 files)
    └── performance-ideas.md    # Performance optimization ideas (1 file)
```

---

## Archived Content

### AI Infrastructure Planning (10 files)

**Archived:** 2025-11-17  
**Reason:** No implementation of planned AI infrastructure features  
**Location:** `docs/archive/planning/ai-infrastructure/`

These documents describe ambitious plans for AI ecosystem enhancements including:
- AgentDB vector database integration
- Documentation analysis and scraping systems
- MiniMax M2 optimization strategies
- Agentic-flow integration
- pantherOS research roadmap with gap analysis
- hbohlenOS PKM system design

**Status:** Future aspirational features - may be implemented later

**Files:**
1. `00_MASTER_PROJECT_PLANS.md` - Master AI ecosystem enhancement plan
2. `01_agentdb_integration_plan.md` - AgentDB integration planning
3. `02_documentation_analysis_plan.md` - Documentation analysis planning
4. `03_documentation_scraper_plan.md` - Documentation scraper planning
5. `04_hbohlenOS_design_plan.md` - hbohlenOS PKM system design
6. `05_minimax_optimization_plan.md` - MiniMax M2 optimization planning
7. `06_agentic_flow_integration.md` - Agentic-flow integration planning
8. `pantherOS_research_plan.md` - PantherOS research roadmap
9. `pantherOS_gap_analysis_progress.md` - Gap analysis progress tracking
10. `pantherOS_executable_research_plan.md` - Executable research plan

---

### Desktop Environment Documentation (3 files)

**Archived:** 2025-11-17  
**Reason:** Desktop environment not implemented; pantherOS is currently server-focused  
**Location:** `docs/archive/planning/desktop-environment/`

These documents describe "Dank Linux" - a comprehensive desktop environment setup with:
- Niri window manager
- DankMaterialShell customizations
- Custom keybindings and workflows
- Installation and configuration guides

**Status:** Future desktop environment plans - separate from current server deployments

**Files:**
1. `00_dank_linux_master_guide.md` - Comprehensive Dank Linux guide (2561 words)
2. `02_installation_guide.md` - Dank Linux installation guide (797 words)
3. `04_keybindings_reference.md` - Keybindings reference (1541 words)

---

### Performance Optimization Ideas (1 file)

**Archived:** 2025-11-17 (Batch 3)  
**Reason:** Planning document without implementation path  
**Location:** `docs/archive/planning/performance-ideas.md`

This document lists potential performance optimizations to consider for future implementation. These are valuable ideas but belong in issue tracker rather than active documentation until implementation begins.

**Status:** Planning ideas - may convert to GitHub issues

---

### OpNix Setup Guide (1 file)

**Archived:** 2025-11-17 (Batch 3)  
**Reason:** OpNix imported but not currently configured  
**Location:** `docs/archive/future-features/OPNIX-SETUP.md`

Setup guide for OpNix secrets management. OpNix is imported in flake.nix but explicitly disabled to reduce closure size during initial deployment. This guide will be useful when OpNix integration is enabled.

**Status:** Future feature - archived for reference when feature is implemented

---

### Obsolete Files Removed (Batch 3)

**Removed:** 2025-11-17  
**Reason:** Superseded or describing non-existent features

The following files were completely removed as they were superseded by other documentation or described features that won't be implemented:

1. `OVH-DEPLOYMENT-GUIDE.md` - Superseded by comprehensive DEPLOYMENT.md
2. `DISK-OPTIMIZATION.md` - Unimplemented disk optimizations (current disko configs are canonical)
3. `NIXOS-QUICKSTART.md` - Unimplemented quickstart (README.md + DEPLOYMENT.md provide quickstart)

---

## Current pantherOS Status

**Important:** As of 2025-11-17, pantherOS is a **fresh, undeployed project** with:

✅ **Implemented:**
- NixOS configuration framework (flake.nix)
- Server configurations for OVH Cloud and Hetzner Cloud
- Disko disk partitioning setup
- Basic SSH and networking
- Development shell environments
- MCP server configurations
- Comprehensive secrets management documentation

❌ **Not Implemented:**
- No deployed hosts
- No AI infrastructure
- No desktop environment
- No monitoring (Datadog, Tailscale)
- OpNix imported but not configured
- Home Manager disabled for initial deployment

---

## Using Archived Content

If you want to implement features described in archived documents:

1. **Review the archived document** to understand the original design
2. **Update for current context** - technology and requirements may have changed
3. **Create a proper spec** using `/speckit.specify` command
4. **Move from planning to implementation** following spec-driven development workflow
5. **Update main documentation** as features are implemented

---

## Restoring Content

If you need to restore archived content to active documentation:

```bash
# Move file back from archive
git mv docs/archive/planning/ai-infrastructure/FILE.md ai_infrastructure/

# Update references in documentation
# Update master topic map
```

---

## Archive Policy

### When to Archive:
- Planning documents for unimplemented features
- Aspirational documentation creating confusion about current state
- Outdated designs that may have future value
- Comprehensive documentation for non-existent features

### When to Delete (Not Archive):
- Truly obsolete content with no future value
- Superseded documentation with unique content merged elsewhere
- Duplicates with no unique information
- Generated files that can be recreated

---

## Related Documentation

- [Pruning Plan](_analysis/pruning_plan.md) - Complete documentation cleanup strategy
- [Configuration Summary](../CONFIGURATION-SUMMARY.md) - Actual implementation status
- [System Inventory](../SYSTEM-INVENTORY-AND-OPNIX-STRUCTURE.md) - Complete system inventory
- [Master Topic Map](../00_MASTER_TOPIC_MAP.md) - Repository navigation

---

**Questions?** See the pruning plan in `_analysis/pruning_plan.md` for detailed rationale behind archiving decisions.
