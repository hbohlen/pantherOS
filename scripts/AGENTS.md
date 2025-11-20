# Scripts Guide (scripts/)
- **Scope:** Ops/utility scripts here.
- **Standards:** bash with `set -euo pipefail`; ShellCheck-friendly; log to stderr; validate inputs.
- **Skills-first:** Load `skills_commands` and script-relevant skills (`skills_pantheros-*`) to avoid restating context.
- **Safety:** No secrets in code or output; avoid destructive defaults; include `--help`.
- **Testing:** Provide quick sanity command (dry-run if possible); prefer idempotent actions.
- **Docs:** Short README per script family if behavior isn’t obvious; keep usage examples minimal.
- **Agents/Commands:** Same OpenAgents set; OpenSpec only for workflow rewrites.
