# Overlays Guide (overlays/)
- **Scope:** Package overlays and pins.
- **Keep lean:** Only add overlays you need; remove stale ones.
- **Skills-first:** Load `skills_commands` plus any relevant `skills_pantheros-*` skills; cite skills and paths instead of copying long notes.
- **Basics:** Prefer small overrides; document pins; avoid embedding secrets; ensure licensing metadata.
- **Validation:** `nix build .#<pkg>` or `nix flake check` when feasible; note any deviations.
- **Integration:** Wire overlays through the flake outputs; keep paths/attr names stable.
- **Agents/Commands:** Use root agent set; escalate via OpenSpec for broad package policy changes.
