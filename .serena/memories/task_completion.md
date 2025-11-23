Before handing off work:
1. Run `nix flake check --no-build`; if changes touched hosts/modules, also run `./.github/scripts/test-nixos-build.sh` to mirror CI (flake check, host builds, syntax/doc validation).
2. For host-specific updates, build at least the affected system via `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` or `nixos-rebuild build --flake .#<host>`; switch/apply only after verifying in a safe environment/VM.
3. Update or add documentation in `docs/` (guides, architecture notes, module docs) whenever behavior, modules, or processes change; follow the style guide templates.
4. Reflect significant work in the relevant OpenSpec change proposal or implementation summary so requirements trace back to tasks.
5. If deployment-oriented, run `./verify-deployment.sh` or the Hetzner post-deployment checklist and log any issues found.
6. Ensure secrets remain abstracted through `pantherOS.secrets.*` mappings—never commit raw secret references.
7. Only commit/push after all checks pass; mention relevant hosts/modules and OpenSpec IDs in commit/PR descriptions.