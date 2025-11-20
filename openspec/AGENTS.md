# OpenSpec Guide (openspec/)
- **Scope:** All OpenSpec content and commands.
- **Skills-first:** Load `skills_system-builder|skills_commands` before drafting/applying specs; cite skills instead of pasting templates.
- **Use OpenSpec when:** Architecture shifts, breaking changes, security model updates, or new workflows/skills.
- **Commands:** `/openspec-proposal <name>` → draft; `/openspec-apply <name>` → track execution; `/openspec-archive <name>` → close and document.
- **Content:** Keep specs concise (problem, options, plan, risks, tests, rollout/backout). Link to affected docs/code.
- **Agents:** system-builder leads proposals, openagent coordinates commands/tools, codebase-agent executes and updates docs.
- **Docs:** `openspec/project.md` holds project context; keep it in sync with specs and repo realities.
