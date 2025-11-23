## 1. Spec and Docs

- [ ] 1.1 Create `openspec/changes/add-host-hardware-metadata-docs/specs/host-hardware-metadata/spec.md`
      with ADDED requirements for host hardware documentation and agent usage.
- [ ] 1.2 Create `/docs/hosts/yoga.hardware.md` following the new spec.
- [ ] 1.3 Create `/docs/hosts/zephyrus.hardware.md` following the new spec.
- [ ] 1.4 Create `/docs/hosts/hetzner-vps.hardware.md` following the new spec.

## 2. Validation

- [ ] 2.1 Run `openspec validate add-host-hardware-metadata-docs --strict`.
- [ ] 2.2 Fix any validation issues (requirements/scenarios formatting).
- [ ] 2.3 Add/adjust links in `openspec/project.md` or other docs if needed.

## 3. Review / Approval

- [ ] 3.1 Request review of the new capability spec and host docs.
- [ ] 3.2 Only after approval, proceed to any follow-up changes that implement
      `disko` layouts or host-specific modules using this metadata.
