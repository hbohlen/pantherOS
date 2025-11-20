# Project Context (OpenSpec)
- **Goal:** Production OpenCode server with persistent memory on Hetzner CPX52. Uses Graphiti + FalkorDB, Valkey cache, Podman pods, Caddy + Cloudflare, Tailscale access, Datadog observability. Keep token use low; favor plugins/SDK over heavy MCP calls.
- **Constraints:** Declarative NixOS (impermanence, /persist), no secrets in Git (OpNix/1Password), localhost-first networking, test before switch when possible.
- **Skills-first:** Load `skills_system-builder|skills_commands` with relevant `skills_pantheros-*` skills when drafting/applying specs; cite skills instead of embedding long context.
- **Tech Pointers:** Nix flake inputs (nixpkgs 25.05, disko, opnix, impermanence), Python/TypeScript/Bash stack, Btrfs with snapshots, object backups to Backblaze B2.
- **Testing Hooks:** `nix flake check`, `nixos-rebuild build-vm --flake .#hetzner-vps`, container image build/run smoke tests, basic pytest for memory components.
- **Operations:** Access via Tailscale/MagicDNS; rollback with Btrfs snapshots or previous generations; keep costs modest (~$75-100/mo across Hetzner, B2, Cloudflare, Datadog, 1Password).
