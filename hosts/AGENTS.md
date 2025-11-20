# Host Guide (hosts/)
- **Scope:** Everything under `hosts/`.
- **Order:** Scan/document hardware → finalize disko/hardware configs → import modules → test with `nixos-rebuild build .#<host>`.
- **Skills-first:** Load `skills_commands` plus `skills_pantheros-hardware-scanner` (and other `skills_pantheros-*` skills) before editing; cite skills/paths to avoid long dumps.
- **Layout:** Keep `hardware.nix` for detection, `disko.nix` for storage, `default.nix` for imports/options.
- **Rules:** No secrets, prefer shared modules, keep host-only tweaks local, record hardware notes in `docs/hardware/*.md`.
- **Recovery:** Use previous generations or provider consoles; avoid risky switches without a build.
- **Agents/Commands:** Use OpenSpec for structural changes; rely on root agent set.
