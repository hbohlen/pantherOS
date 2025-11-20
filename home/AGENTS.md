# Home-Manager Guide (home/)
- **Scope:** User configs under `home/`.
- **Principles:** One concern per module; keep host/user overrides separate from shared pieces.
- **Skills-first:** Load `skills_commands` and relevant `skills_pantheros-*` skills; cite skills and file paths to keep context short.
- **Flow:** Update shared defaults → layer host/user specifics → `home-manager switch --flake .#<user>` when possible.
- **Practices:** No secrets, keep package lists lean, favor reusable options, document notable choices in `docs/modules/home-manager/`.
- **Troubleshooting:** Use `home-manager build --show-trace` for errors; rollback via `home-manager switch --generation`.
- **Agents/Commands:** Same OpenAgents set; use OpenSpec only for structural shifts.
