---
name: commands
description: Quick reference for `/openspec-*` slash commands and skill-first context usage within OpenCode.
---

# OpenAgents Command Skill

## Commands
- `/openspec-proposal <name>`: Draft spec (problem, options, plan, risks, tests, rollout/backout).
- `/openspec-apply <name>`: Execute approved spec; track tasks, coverage, and links.
- `/openspec-archive <name>`: Close spec with changelog, follow-ups, and pointers to merged work.

## Usage
- Load this skill before running commands to avoid repeating instructions in prompts.
- Pair with `skills_system-builder` for planning and `skills_openagent` for coordination.
- Keep command outputs short; cite file paths and skills instead of restating context.
