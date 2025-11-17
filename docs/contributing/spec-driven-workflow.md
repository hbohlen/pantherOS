# Spec-Driven Development Workflow

This guide explains how to use Spec-Driven Development (SDD) methodology in the pantherOS project, following the global rules for specification-first development.

## Quick Reference

**New feature?** → Create spec first → Plan → Tasks → Implement  
**Major change?** → Update spec first → Update plan → Implement  
**Bug fix?** → Check spec → Update if needed → Fix

## Global Rules

These rules apply to **all** development work in pantherOS:

### 1. Prefer Spec-First Workflows

**For new features or major changes:**

1. **Check for existing specs** under `/docs/specs/`
2. **If missing or incomplete**, help refine or create specs **BEFORE** editing code
3. **No code changes** without corresponding spec (except trivial fixes)

**What requires a spec?**
- ✅ New features (any size)
- ✅ Major refactoring or architectural changes
- ✅ Breaking changes
- ✅ Security improvements
- ✅ Infrastructure changes

**What doesn't require a spec?**
- ⚪ Trivial bug fixes (typos, simple logic errors)
- ⚪ Routine dependency updates
- ⚪ Minor documentation corrections

### 2. Use Spec Kit Commands

Use the appropriate `/speckit.*` command for each phase:

| Phase | Command | Purpose |
|-------|---------|---------|
| Requirements | `/speckit.specify` | Define what and why |
| Clarification | `/speckit.clarify` | Fill gaps in requirements |
| Planning | `/speckit.plan` | Create technical design |
| Task Breakdown | `/speckit.tasks` | Generate actionable tasks |
| Implementation | `/speckit.implement` | Execute the plan |
| Validation | `/speckit.analyze` | Check consistency |
| Quality | `/speckit.checklist` | Generate validation criteria |
| Issues | `/speckit.taskstoissues` | Convert tasks to GitHub issues |

### 3. Documentation Expectations

**Treat `/docs` as the single source of truth:**

- All feature documentation lives under `/docs`
- When adding or modifying significant behavior, update or create docs under `/docs` as part of the work
- Keep docs sharded: one major concept per file, with clear links
- Update documentation in the **same PR** as code changes

**Documentation structure:**
```
/docs/
├── specs/              # Feature specifications (spec-first)
├── architecture/       # System architecture and decisions
├── howto/              # Task-oriented guides
├── reference/          # API and configuration reference
├── contributing/       # Development guides (you are here)
└── tools/              # Tool usage documentation
```

### 4. TODO Lists and Guidance

When generating TODO lists, for each task indicate:

1. **Which `/speckit.*` commands should be used**, if any
2. **Which file(s) in `/docs` or `/docs/specs` should be updated**
3. **Dependencies** on other tasks or specs

**Example TODO format:**

```markdown
## TODO: Implement GNOME Desktop Environment

### Prerequisites
- [ ] Review existing desktop specs in `/docs/specs/`
- [ ] Check pantherOS constitution principles

### Specification Phase (Use /speckit.specify)
- [ ] Create `/docs/specs/009-gnome-desktop/spec.md`
  - Commands: `/speckit.specify`, `/speckit.clarify`
  - Update: `/docs/index.md` to link new spec

### Planning Phase (Use /speckit.plan)
- [ ] Create `/docs/specs/009-gnome-desktop/plan.md`
  - Commands: `/speckit.plan`
  - Review: NixOS GNOME modules documentation

### Implementation Phase (Use /speckit.tasks, /speckit.implement)
- [ ] Create task breakdown in `/docs/specs/009-gnome-desktop/tasks.md`
  - Commands: `/speckit.tasks`
- [ ] Implement GNOME configuration module
  - Commands: `/speckit.implement`
  - Update: `/docs/examples/nixos/gnome-desktop.md` (create new)
- [ ] Add GNOME profile to profiles/
  - Update: `/docs/architecture/module-system.md`

### Validation Phase (Use /speckit.checklist)
- [ ] Generate validation checklist
  - Commands: `/speckit.checklist`
- [ ] Test GNOME deployment in VM
  - Update: `/docs/howto/test-changes-locally.md` (add GNOME example)
```

## Behavior Guidelines

### Propose Tests and Documentation

**Always propose when modifying code:**

1. **Tests** - What tests should be added/updated?
2. **Documentation** - What docs need updating?
3. **Examples** - Should we add code examples?

**Example:**
```
I'm implementing SSH key rotation (spec 015).

Tests to add:
- Test key rotation function
- Test rollback on failure
- Integration test for SSH access

Documentation to update:
- /docs/security/ssh-key-management.md - Add rotation procedure
- /docs/howto/manage-secrets.md - Reference SSH rotation
- /docs/specs/015-ssh-key-rotation/plan.md - Update with implementation details

Examples to create:
- /docs/examples/nixos/ssh-key-rotation.nix - Configuration example
```

### Explain Spec Implementation

When implementing a feature, **always explain**:

1. **Which spec** you're implementing
2. **Which part of the spec** the current work addresses
3. **How the implementation** aligns with spec requirements

**Example:**
```
Implementing spec 009-gnome-desktop, section 3.2 "Display Manager Configuration".

This change adds GDM (GNOME Display Manager) configuration as specified in:
- Requirement: REQ-009-002 "System shall use GDM as display manager"
- Acceptance Criteria: AC-009-003 "GDM starts automatically on boot"

Implementation aligns with spec by:
- Using NixOS services.xserver.displayManager.gdm options
- Enabling Wayland as specified in REQ-009-004
- Configuring auto-login for demo user per AC-009-007
```

### Handle Ambiguity

**When there is ambiguity:**

1. **Ask clarifying questions** OR
2. **Suggest updating the relevant spec**

**Don't:**
- ❌ Make assumptions without documenting them
- ❌ Proceed with unclear requirements
- ❌ Implement features without spec guidance

**Do:**
- ✅ Identify the ambiguous area
- ✅ Propose clarification approaches
- ✅ Update spec with clarifications
- ✅ Document assumptions if proceeding

**Example:**
```
The spec says "support multiple desktop environments" but doesn't specify:
1. Should they be installable simultaneously or mutually exclusive?
2. How should users switch between them?
3. Should we support per-user desktop selection?

Recommendation:
- Use /speckit.clarify to add these details to the spec
- Update spec section 4.2 with desktop switching mechanism
- Document decision in /docs/architecture/decisions/adr-012-desktop-switching.md
```

### Small, Reviewable Changes

**Avoid large, monolithic changes:**

- Prefer small, reviewable PR-sized changes
- Align changes with specific tasks from `/speckit.tasks`
- One task = one PR (generally)
- Reference spec and task number in PR

**Example PR naming:**
```
feat: Implement GDM configuration (spec-009, task 3.2)
docs: Add GNOME deployment guide (spec-009, task 4.1)
test: Add GNOME integration tests (spec-009, task 5.3)
```

## Complete Workflow Example

### Scenario: Adding PostgreSQL Database Support

#### Step 1: Check Existing Specs

```bash
ls docs/specs/ | grep -i postgres
# No existing spec found
```

#### Step 2: Create Specification

```
/speckit.specify Add PostgreSQL database support with declarative configuration,
automatic backups, and secure secrets management via OpNix.
```

This creates: `/docs/specs/010-postgresql-database/spec.md`

#### Step 3: Clarify Requirements

```
/speckit.clarify
```

Answer clarification questions:
- Database version? → PostgreSQL 15 (stable)
- Backup frequency? → Daily, 7-day retention
- User management? → Declarative via NixOS config
- SSL/TLS? → Yes, required for remote connections

#### Step 4: Create Technical Plan

```
/speckit.plan Use NixOS services.postgresql module with custom configuration.
Integrate with existing security framework and OpNix for credentials.
```

This creates: `/docs/specs/010-postgresql-database/plan.md`

Review the plan:
- Architecture decisions documented
- NixOS modules identified
- Integration points clear
- Phased approach defined

#### Step 5: Generate Task Breakdown

```
/speckit.tasks
```

This creates: `/docs/specs/010-postgresql-database/tasks.md`

Example tasks generated:
```markdown
1. [ ] Set up basic PostgreSQL service
   - Spec Kit: None (implementation)
   - Docs: Create /docs/examples/nixos/postgresql-basic.md
   
2. [ ] Configure SSL/TLS certificates
   - Spec Kit: None (implementation)
   - Docs: Update /docs/security/ssl-certificates.md
   
3. [ ] Integrate OpNix for credential management
   - Spec Kit: None (implementation)
   - Docs: Update /docs/howto/manage-secrets-opnix.md
   
4. [ ] Implement backup automation
   - Spec Kit: None (implementation)
   - Docs: Create /docs/ops/postgresql-backups.md
   
5. [ ] Create integration tests
   - Spec Kit: /speckit.checklist for validation
   - Docs: Update /docs/contributing/testing-guide.md
```

#### Step 6: Implement (One Task at a Time)

**Task 1: Basic PostgreSQL Service**

1. Create NixOS module configuration
2. Test in VM: `nixos-rebuild build-vm --flake .#test-host`
3. Create example documentation: `/docs/examples/nixos/postgresql-basic.md`
4. Create PR: "feat: Add basic PostgreSQL service (spec-010, task 1)"

**Task 2: SSL/TLS Configuration**

1. Add SSL configuration to module
2. Test certificate generation
3. Update security documentation
4. Create PR: "feat: Add PostgreSQL SSL/TLS support (spec-010, task 2)"

Continue for remaining tasks...

#### Step 7: Validation

```
/speckit.checklist
```

Generate validation checklist:
- [ ] All requirements from spec met
- [ ] Acceptance criteria validated
- [ ] Documentation complete
- [ ] Tests passing
- [ ] Security review completed

#### Step 8: Update Documentation Index

Update `/docs/index.md` to include:
- New spec reference
- Links to examples
- Security documentation updates

## Working with AI Agents

### When You Are the AI Agent

If you're GitHub Copilot or another AI agent:

1. **Always check for specs first** before suggesting code
2. **Reference specs in your responses**
3. **Propose spec updates** when requirements are unclear
4. **Generate TODO lists** following the format above
5. **Explain spec alignment** in your implementation suggestions

**Example AI response:**

```
I notice you're asking about GNOME desktop support. Let me check for existing specs...

No spec found for GNOME desktop. I recommend creating one first:

1. Use /speckit.specify to define requirements
2. Key questions to clarify:
   - Which GNOME version? (43, 44, 45?)
   - Essential apps to include?
   - Wayland-only or X11 fallback?
   - GDM or alternative display manager?

Once spec is created at /docs/specs/NNN-gnome-desktop/, I can help with:
- Technical plan using /speckit.plan
- NixOS module configuration
- Integration with existing profiles
- Documentation and examples

Would you like to proceed with spec creation?
```

### Instructing AI Agents

**Good prompts:**

```
"Check /docs/specs/ for PostgreSQL spec, then help implement task 2"

"Create a spec for Redis caching using /speckit.specify"

"Review spec-010 section 3 and suggest implementation approach"

"Generate TODO list for implementing spec-009 with Spec Kit commands and doc updates"
```

**Avoid:**

```
"Just implement PostgreSQL support" (no spec reference)

"Add GNOME desktop" (no spec-first workflow)

"Fix the database" (no spec context)
```

## Integration with GitHub Workflow

### Issue Templates

Issues should reference or prompt for spec creation:

```markdown
## Feature Request

Before requesting a feature, please check:
- [ ] Searched existing specs in /docs/specs/
- [ ] Reviewed project roadmap

If this is a new feature:
- [ ] I will create a spec using /speckit.specify
- [ ] OR I need help creating a spec

Related spec: (if exists)
```

### Pull Request Template

PRs should reference specs:

```markdown
## Pull Request

### Related Specification
- Spec: /docs/specs/NNN-feature-name/
- Task: (task number from tasks.md)

### Changes
- Implementation details...

### Documentation Updated
- [ ] Spec updated (if requirements changed)
- [ ] /docs updated (which files?)
- [ ] Examples added/updated
- [ ] Tests added

### Spec Alignment
Explain how this PR implements the spec...
```

## Tips and Best Practices

### For New Contributors

1. **Read existing specs** - Learn by example
2. **Start small** - Pick a small spec to implement first
3. **Ask questions** - Use clarification phase liberally
4. **Review others' specs** - Learn spec-writing techniques

### For Experienced Contributors

1. **Review specs regularly** - Keep them up-to-date
2. **Mentor others** - Help with spec creation
3. **Create ADRs** - Document architectural decisions
4. **Improve templates** - Contribute to spec quality

### For Project Maintainers

1. **Enforce spec-first** - No code review without spec
2. **Quality gate specs** - Ensure specs are clear before implementation
3. **Archive completed specs** - Keep /docs/specs/ current
4. **Celebrate good specs** - Recognize quality specification work

## Troubleshooting

### "Spec Kit command not working"

1. Check `.github/agents/` for agent definitions
2. Verify GitHub Copilot is enabled
3. See [Spec Kit documentation](../tools/spec-kit.md)

### "Not sure if I need a spec"

Use this decision tree:

```
Is it a bug fix?
├─ Yes → Is it trivial? (< 10 lines)
│  ├─ Yes → No spec needed
│  └─ No → Check if related spec exists
│     ├─ Yes → Update existing spec
│     └─ No → Create new spec
└─ No → Is it a new feature?
   ├─ Yes → **MUST have spec**
   └─ No → Is it infrastructure/refactoring?
      ├─ Yes → **MUST have spec**
      └─ No → Ask in discussions
```

### "Spec and implementation diverged"

1. **Pause implementation**
2. **Update spec** to reflect current understanding
3. **Review changes** with team
4. **Document decision** in spec or ADR
5. **Resume implementation** aligned with updated spec

### "Spec is too large"

1. **Break it down** - Create multiple smaller specs
2. **Use phases** - Implement incrementally
3. **Identify MVP** - What's the minimum viable feature?
4. **Create dependencies** - Link related specs

## Related Documentation

- [Specs Directory README](../specs/README.md) - Spec structure and organization
- [Spec Kit Guide](../tools/spec-kit.md) - Complete Spec Kit documentation
- [Spec Kit Quick Reference](../tools/spec-kit-quick-reference.md) - Command cheat sheet
- [Spec Kit Examples](../tools/spec-kit-examples.md) - Real-world examples
- [pantherOS Constitution](../../.specify/memory/constitution.md) - Project principles
- [Architecture Decisions](../architecture/decisions/) - ADRs affecting development

## Feedback and Questions

- **Found an issue with this workflow?** - Open an issue
- **Have suggestions for improvement?** - Submit a PR
- **Need clarification?** - Ask in GitHub Discussions
- **Want to improve Spec Kit integration?** - Contribute to templates

---

**Last Updated:** 2025-11-17  
**Maintained by:** pantherOS Project  
**Version:** 1.0.0
