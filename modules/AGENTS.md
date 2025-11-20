# Module Guide (modules/)
- **Scope:** NixOS, home-manager, and shared modules.
- **Single concern:** One feature per file; push host quirks to host configs.
- **Skills-first:** Load `skills_commands` and relevant `skills_pantheros-*` skills; cite skill paths instead of large excerpts.
- **Flow:** Design options → add docs in `docs/modules/` → implement → `nixos-rebuild build .#<host>` when practical.
- **Patterns:** Use `lib.mkIf/lib.mkMerge`, typed options with defaults, no secrets, keep imports minimal.
- **Testing:** Build at least one host that exercises the module; mention coverage in commits/notes.
- **Agents/Commands:** Follow root agent set and `/openspec-*` when changes are architectural.
