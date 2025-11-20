# AGENTS.md Audit Snapshot
- **Status:** All scoped `AGENTS.md` files exist and point to OpenAgents + `/openspec-*` commands with skill-first guidance.
- **Checks:**
  - Root: Repo-wide rules, skill loading (`skills_*`, `skills_pantheros-*`), and OpenSpec entrypoint.
  - Subdirs (`docs/`, `modules/`, `hosts/`, `home/`, `overlays/`, `scripts/`, `openspec/`): Each defines scope, key rules, when to escalate to OpenSpec, and how to reference skills instead of long context.
- **Maintenance:** Re-scan after workflow/tool/model/skill changes; verify paths, commands, and skill references resolve; keep guidance short to reduce context bloat.
