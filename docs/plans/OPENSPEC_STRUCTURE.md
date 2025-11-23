# OpenSpec Structure for pantherOS Implementation

This document outlines the recommended OpenSpec structure for implementing the 8 Agent Task Packs from OVERVIEW.md.

**Generated:** 2025-11-23

---

## Proposed Directory Structure

```
.openspec/
├── specs/
│   └── (existing shared specs)
│       └── hetzner-cloud-deployment/
└── changes/
    ├── 2025-11-23-secrets-management/
    │   ├── proposal.md
    │   ├── tasks.md
    │   └── specs/
    │       ├── opnix-integration/
    │       │   └── spec.md
    │       └── secrets-inventory/
    │           └── spec.md
    │
    ├── 2025-11-23-hardware-metadata/
    │   ├── proposal.md
    │   ├── tasks.md
    │   └── specs/
    │       └── meta-nix-schema/
    │           └── spec.md
    │
    ├── 2025-11-23-disk-standardization/
    │   ├── proposal.md
    │   ├── tasks.md
    │   └── specs/
    │       ├── disko-templates/
    │       │   └── spec.md
    │       └── canonical-layout/
    │           └── spec.md
    │
    ├── 2025-11-23-security-tailscale-firewall/
    │   ├── proposal.md
    │   ├── tasks.md
    │   └── specs/
    │       ├── tailscale-config/
    │       │   └── spec.md
    │       └── firewall-policies/
    │           └── spec.md
    │
    ├── 2025-11-23-devshell-languages/
    │   ├── proposal.md
    │   ├── tasks.md
    │   └── specs/
    │       ├── global-devshell/
    │       │   └── spec.md
    │       ├── language-tooling/
    │       │   └── spec.md
    │       └── direnv-integration/
    │           └── spec.md
    │
    ├── 2025-11-23-ai-tools-stack/
    │   ├── proposal.md
    │   ├── tasks.md
    │   └── specs/
    │       ├── nix-ai-tools-integration/
    │       │   └── spec.md
    │       └── api-key-management/
    │           └── spec.md
    │
    ├── 2025-11-23-desktop-stack/
    │   ├── proposal.md
    │   ├── tasks.md
    │   └── specs/
    │       ├── niri-compositor/
    │       │   └── spec.md
    │       ├── dank-material-shell/
    │       │   └── spec.md
    │       └── ghostty-terminal/
    │           └── spec.md
    │
    └── 2025-11-23-attic-ci/
        ├── proposal.md
        ├── tasks.md
        └── specs/
            ├── attic-server/
            │   └── spec.md
            ├── binary-cache-client/
            │   └── spec.md
            └── github-actions-ci/
                └── spec.md
```

---

## Template: Proposal.md

```markdown
# [Task Pack Name] - Proposal

**Date:** 2025-11-23
**Status:** Draft | In Progress | Completed
**Priority:** P0 (Critical) | P1 (High) | P2 (Medium) | P3 (Low)

## Overview

Brief description of what this task pack implements.

## Goals

- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

## Non-Goals

- What this pack explicitly does NOT address

## Background

Why this is needed, context from OVERVIEW.md.

## Proposed Solution

High-level approach to implementation.

## Specifications

List of detailed specs in the `specs/` directory:

- [OpNix Integration](./specs/opnix-integration/spec.md)
- [Secrets Inventory](./specs/secrets-inventory/spec.md)

## Success Criteria

How we know this task pack is complete:

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Tests pass
- [ ] Documentation complete

## Dependencies

- Depends on: [Other task pack name]
- Blocks: [Future task pack]

## References

- [OVERVIEW.md](../../OVERVIEW.md)
- [Research Plan](../../docs/plans/IMPLEMENTATION_RESEARCH_PLAN.md)
```

---

## Template: Tasks.md

```markdown
# [Task Pack Name] - Tasks

**Status:** Not Started | In Progress | Completed

## Task Breakdown

### Phase 1: Research & Design
- [ ] Task 1.1 - Description
- [ ] Task 1.2 - Description
- [ ] Task 1.3 - Description

### Phase 2: Implementation
- [ ] Task 2.1 - Description
  - Assignee: Agent | Human
  - Estimate: 1h, 4h, 1d
  - Status: Not Started | In Progress | Blocked | Done
- [ ] Task 2.2 - Description

### Phase 3: Testing & Validation
- [ ] Task 3.1 - Description
- [ ] Task 3.2 - Description

### Phase 4: Documentation
- [ ] Task 4.1 - Description
- [ ] Task 4.2 - Description

## Blockers

- [ ] Blocker 1 - Description and resolution plan

## Notes

Additional context, decisions made during implementation.

## Completion Checklist

- [ ] All tasks completed
- [ ] Tests pass on all hosts
- [ ] Documentation updated
- [ ] Changes committed and pushed
- [ ] OpenSpec archived
```

---

## Template: spec.md

```markdown
# [Component Name] Specification

**Version:** 1.0
**Status:** Draft | Review | Approved | Implemented
**Last Updated:** 2025-11-23

## Overview

Brief description of this component.

## Requirements

### Functional Requirements
- FR1: Description
- FR2: Description

### Non-Functional Requirements
- NFR1: Performance requirement
- NFR2: Security requirement

## Design

### Architecture

Describe the high-level architecture.

### Module Structure

```
modules/
  nixos/
    component/
      default.nix
      submodule.nix
```

### Configuration Schema

```nix
{
  options.pantherOS.component = {
    enable = mkEnableOption "Component description";
    setting1 = mkOption { ... };
    setting2 = mkOption { ... };
  };
}
```

### Implementation Details

Detailed implementation notes.

## Integration Points

- Integrates with: Module A, Module B
- Provides: Interface X, Interface Y
- Depends on: Service C, Service D

## Usage Examples

```nix
{
  pantherOS.component = {
    enable = true;
    setting1 = "value";
  };
}
```

## Testing Strategy

- Unit tests: How to test individual functions
- Integration tests: How to test with other modules
- Manual tests: Steps for validation

## Security Considerations

- Authentication requirements
- Authorization requirements
- Secret handling
- Network exposure

## Performance Considerations

- Resource usage
- Optimization opportunities
- Scaling considerations

## Migration Path

How to migrate from current state to this implementation.

## Rollback Plan

How to revert if this implementation causes issues.

## Open Questions

- [ ] Question 1
- [ ] Question 2

## References

- Related docs
- External resources
- Related OpenSpec proposals

---

**Author:** AI Agent | Human
**Reviewers:** TBD
**Approval:** TBD
```

---

## Recommended Implementation Order

Based on priority matrix in IMPLEMENTATION_RESEARCH_PLAN.md:

### Week 1: Foundation (P0 - Critical)
1. **2025-11-23-secrets-management/** (Pack 3)
   - Critical blocker for everything else
   - Highest security priority

2. **2025-11-23-security-tailscale-firewall/** (Pack 4 - partial)
   - Firewall rules to secure VPS hosts

### Week 2: Core Infrastructure (P1 - High)
3. **2025-11-23-hardware-metadata/** (Pack 1)
   - Foundation for optimization

4. **2025-11-23-disk-standardization/** (Pack 2)
   - Standardize layouts across hosts

5. **2025-11-23-security-tailscale-firewall/** (Pack 4 - complete)
   - Full Tailscale configuration with tags

### Week 3: Developer Experience (P1 - High)
6. **2025-11-23-devshell-languages/** (Pack 5)
   - Essential for development workflow

### Week 4+: Enhancements (P2-P3)
7. **2025-11-23-desktop-stack/** (Pack 7)
   - If desktop environment is needed

8. **2025-11-23-ai-tools-stack/** (Pack 6)
   - Nice to have, not critical

9. **2025-11-23-attic-ci/** (Pack 8)
   - Optimization for later

---

## OpenSpec Workflow

### Creating a New Change

```bash
# 1. Create directory structure
mkdir -p .openspec/changes/2025-11-23-task-pack-name/{specs/component-name}

# 2. Copy templates
cp docs/plans/templates/proposal.md .openspec/changes/2025-11-23-task-pack-name/
cp docs/plans/templates/tasks.md .openspec/changes/2025-11-23-task-pack-name/
cp docs/plans/templates/spec.md .openspec/changes/2025-11-23-task-pack-name/specs/component-name/

# 3. Fill in templates

# 4. Begin implementation

# 5. Update tasks.md as you progress

# 6. When complete, archive
./scripts/openspec-archive.sh 2025-11-23-task-pack-name
```

### Using OpenSpec with AI Agents

AI agents can:
1. **Read proposals** to understand goals and context
2. **Update tasks.md** to track progress
3. **Create specs** for new components
4. **Reference specs** when implementing modules
5. **Archive changes** when complete

---

## Next Steps

1. ✅ Create this structure document
2. ❌ Create OpenSpec proposal for Pack 3 (Secrets Management)
3. ❌ Create OpenSpec proposal for Pack 4 (Security/Tailscale/Firewall)
4. ❌ Populate templates directory with examples
5. ❌ Begin implementation following priority order

---

**Maintained by:** Claude Code
**For:** pantherOS Implementation Planning
