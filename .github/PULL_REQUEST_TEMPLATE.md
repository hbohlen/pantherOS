# Pull Request

## Related Specification

**⚠️ This project uses Spec-Driven Development. All non-trivial changes must reference a spec.**

- **Spec:** `/docs/specs/NNN-feature-name/` (link: )
- **Task:** (task number from `tasks.md`, if applicable)
- **Related Issue:** #

**If this is a trivial change** (typo fix, dependency update, etc.), check here: [ ] No spec required

## Changes

### Summary

<!-- Provide a clear summary of what this PR does -->

### Implementation Details

<!-- Explain key implementation decisions and approach -->

### Files Changed

<!-- List main files added/modified and why -->

- `path/to/file.nix` - 
- `docs/path/to/doc.md` - 

## Spec Alignment

### Which part of the spec does this implement?

<!-- Reference specific sections, requirements, or user stories from the spec -->

- Section: 
- Requirement ID: (if applicable)
- User Story: (if applicable)

### How does this implementation align with the spec?

<!-- Explain how your implementation satisfies spec requirements -->

## Documentation Updated

**Required for all code changes:**

- [ ] **Spec updated** (if requirements or design changed during implementation)
- [ ] **`/docs` updated** (which files?)
  - [ ] `/docs/specs/NNN-feature-name/` - Updated with implementation notes
  - [ ] `/docs/examples/` - Added code examples
  - [ ] `/docs/reference/` - Updated configuration reference
  - [ ] `/docs/howto/` - Added or updated guides
  - [ ] Other: _____________
- [ ] **Code examples added/updated** (if applicable)
- [ ] **Architecture docs updated** (if architecture changed)

**Documentation files modified in this PR:**

- 
- 

## Tests

- [ ] **Tests added** (describe what tests)
- [ ] **Tests updated** (describe which tests)
- [ ] **Tests run successfully** (include relevant output or screenshots)
- [ ] **No tests needed** (explain why)

**Test details:**

```bash
# Commands used to test
nix build .#nixosConfigurations.<host>.config.system.build.toplevel

# Or describe manual testing performed
```

## Quality Checklist

- [ ] Code follows [NixOS style guidelines](../../docs/contributing/spec-driven-workflow.md)
- [ ] Code formatted with `nixpkgs-fmt` (for Nix files)
- [ ] No secrets committed to repository
- [ ] Configuration builds successfully
- [ ] Changes are minimal and focused
- [ ] PR aligned with single task from spec
- [ ] Constitution principles followed

## Deployment Notes

### Pre-deployment considerations

<!-- Any special considerations before deploying? -->

### Rollback plan

<!-- How can this change be rolled back if needed? -->

### Post-deployment validation

<!-- How to verify this change works in production? -->

## Breaking Changes

- [ ] This PR includes breaking changes
- [ ] Breaking changes are documented
- [ ] Migration guide provided (where?)

**Breaking change details:**

<!-- If breaking changes, explain impact and migration path -->

## Additional Context

<!-- Any other context, screenshots, or information reviewers should know -->

---

## For Reviewers

### Spec Alignment Review

- [ ] Implementation matches spec requirements
- [ ] Design decisions align with spec
- [ ] No spec violations or deviations (or deviations documented)

### Code Quality Review

- [ ] Code is clean and maintainable
- [ ] NixOS best practices followed
- [ ] No unnecessary complexity
- [ ] Error handling is appropriate

### Documentation Review

- [ ] Documentation is clear and complete
- [ ] Examples are helpful and accurate
- [ ] Cross-references are correct
- [ ] Documentation updates match code changes

---

**Related Documentation:**
- [Spec-Driven Workflow Guide](../../docs/contributing/spec-driven-workflow.md)
- [Specification README](../../docs/specs/README.md)
- [pantherOS Constitution](../../.specify/memory/constitution.md)
