<!-- OPENSPEC:START -->
# OpenSpec Instructions

Open this file whenever the request hints at planning, proposals, or large/ambiguous changes. It points you to `@/openspec/AGENTS.md` for the full change-control rules.
<!-- OPENSPEC:END -->

# pantherOS Root Agent Guide
- **Scope:** Everything in the repo unless a deeper `AGENTS.md` overrides it.
- **Read first:** `brief.md` → `docs/README.md` → relevant doc in `docs/architecture/` or `docs/todos/`.
- **Skills-first:** Load `skills_system-builder|skills_openagent|skills_codebase-agent|skills_commands` and needed platform skills (`skills_pantheros-*`). See `docs/skills/README.md`.
- **Agents:** system-builder (scoping/OpenSpec), openagent (tools/commands), codebase-agent + subagents (implementation/review/testing).
- **Commands:** `/openspec-proposal|apply|archive <name>` for specs; `/research <query>` for delegated research.
- **Docs to consult:** Architecture overview, disk layouts, todo phase files.
- **Rules:** No secrets, prefer modular changes, document alongside code, build/test before deploy when feasible.
- **Emergency:** Roll back to previous generation; use Tailscale or provider console for access.
