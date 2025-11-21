<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines
- Current project state and context

Keep this managed block so 'openspec update' can refresh the instructions.

## Current Project Context

For the latest project state, priorities, and progress, see: `@/CONTEXT.md`

## Quick Reference

### Most Important Files
- `flake.nix` - Entry point for all configurations
- `hosts/<hostname>/default.nix` - Main host configuration  
- `modules/` - Reusable configuration modules
- `docs/architecture/overview.md` - System design documentation

### Current Work Focus
- **Active Phase:** Module development and security integration
- **Focus Areas:** Security hardening, Btrfs impermanence, AI tools integration
- **Next Major Milestone:** Complete Phase 2, begin Phase 3 (host configuration)

### Decision History
- **2025-11-21:** Completed research phase, created 3 OpenSpec proposals
- **2025-11-20:** Finished Phase 1 (hardware discovery)
- **Ongoing:** Module development with 2025 best practices integration

### OpenSpec Proposals (Active)
1. **security-hardening-improvements** - High priority
2. **btrfs-impermanence-snapshots** - High priority  
3. **ai-tools-integration** - Medium priority

<!-- OPENSPEC:END -->