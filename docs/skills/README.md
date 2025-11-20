# OpenCode Skills Guide

## Overview
- `opencode-skills` mirrors Claude skills: each skill is auto-discovered from `.opencode/skills/**/SKILL.md` and loaded on demand to cut token use.
- Skills bundle focused context (YAML header + markdown) and may include `references/`, `scripts/`, `assets/`, or nested folders for grouping.
- Prefer linking to skills instead of duplicating prompts; load only the skills needed for the task.

## Authoring skills
- Structure: `.opencode/skills/<group>/<skill-name>/SKILL.md` with frontmatter `name` (matches the skill folder) + `description` followed by concise guidance.
- Keep content checklist-style; place long examples or data in `references/` and scripts/tools in `scripts/`.
- Nest skills to organize domains; plugin resolves directories recursively.

## Using skills with agents
- Load the smallest set of skills for the request (e.g., `skills_system-builder`, `skills_commands`, platform skills like `skills_pantheros-*`).
- Call skills explicitly as `skills_<skill-name>`; the `name` frontmatter must equal the skill directory name.
- Reference skills by path instead of pasting context. Note file paths and commands rather than quoting sections.
- Pair `/openspec-*` commands with skills to keep planning/apply/archive flows lightweight.

## Migration plan (skills-first agents)
- Core skills added: `skills_system-builder`, `skills_openagent`, `skills_codebase-agent`, `skills_commands`.
- Update agent prompts and AGENTS guides to direct users to load skills first, then use commands/tools.
- Future work: convert legacy subagent prompts into skills and move large references into `.opencode/skills/**/references/` to shrink prompt footprints.
