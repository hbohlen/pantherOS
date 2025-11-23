# pantherOS – Design Overview

pantherOS is a personal NixOS flake that manages all of my development machines
(laptops + VPS) in a **declarative, modular, and reproducible** way.

The goal is to eliminate configuration drift between:

- Personal laptops (`yoga`, `zephyrus`)
- Cloud servers (`hetzner-vps`, `ovh-vps`)
- Per-user environments (home-manager)

and to make it easy for AI agents to understand, audit, and evolve the
configuration.

## Goals

- Single flake for all hosts and users.
- Strictly declarative system + user configuration (NixOS + home-manager).
- Btrfs + disko-managed disk layouts tuned per host.
- Batteries-included dev environment:
  - DevShell that auto-activates in `~/dev`.
  - Language toolchains (Node/TS, Python, Go, Rust, Nix, etc.) with LSP + formatter.
  - First-class support for terminal AI coding agents (opencode, Claude Code, Qwen Code, etc.).
- Opinionated desktop stack (Niri + DankMaterialShell + Ghostty + fish).
- Seamless secrets management with 1Password + OpNix.
- Secure, VPN-first networking using Tailscale, with firewalls tuned around it.

## Non-Goals (for now)

- Running local LLMs on GPUs.
- Multi-user / team infrastructure.
- Complex multi-tenant service hosting beyond my personal workflows.

## Global Constraints

- NixOS + flakes everywhere.
- Btrfs for all disks, managed via disko.
- 1Password for all secrets (service account + GUI).
- Tailscale for secure networking; public SSH should be minimized or disabled.
- Prefer open-source tools; allow `unfree` when necessary (1Password, Zed, etc.).

## Success Criteria

- New machine can be bootstrapped from bare metal to "fully usable dev box"
  using this flake + minimal manual steps.
- Re-deploying a host from scratch preserves:
  - Configured tools and languages.
  - Secrets (via 1Password).
  - Personal data (via well-defined subvolumes and backup strategy).
- AI agents can:
  - Understand the directory layout and module structure.
  - Safely add or modify modules without breaking other hosts.
  - Run targeted flake checks/tests before proposing changes.

---

## Repository Layout (canonical)

```
/flake.nix      – flake entrypoint, inputs, outputs.
/lib            – helper functions (e.g. `mkHost`, `mkSystem`, shared options).
/overlays       – package overlays.
/pkgs           – custom packages.
/profiles       – reusable bundles (e.g. `desktop`, `server`, `devbox`).
/modules
  /system       – NixOS modules grouped by domain.
  /home         – home-manager modules grouped by domain.
/hosts
  /yoga
    - disko.nix
    - hardware.nix
    - configuration.nix or default.nix
    - meta.nix (hardware metadata)
  /zephyrus
  /servers/ovh-cloud
  /servers/hetzner-cloud
/home
  /hbohlen
    - home.nix
    - optional modules/ for user-specific extras.
/docs
  /agents       – docs and prompts for AI agents.
  /infra        – human-oriented docs.
```

This matches common multi-system flake patterns: `hosts + modules + profiles + home`.

---

## Host Metadata & Hardware

All hosts must have a `hosts/<name>/meta.nix` (or `.md`) describing:

- CPU model, core count, SMT.
- GPU(s) and rough class (iGPU only / midrange / high-end).
- RAM size.
- Disk layout: devices, sizes, SSD vs HDD, NVMe vs SATA.
- Special capabilities (e.g. "Zephyrus has Nvidia dGPU; OK for GPU workloads").

**Hardware detection plan (for agents):**

- Use `lscpu`, `lsblk -f`, `lspci`, `lsusb` and record relevant fields.
- Detect NVMe vs SATA to tune I/O scheduler and mount-opts.
- Detect dGPU to decide whether to include GPU drivers or not.

---

## Hosts

### Lenovo Yoga 7 (`yoga`)

**Role:** lightweight dev + research; **battery life > raw performance**.

- Hardware: see `hosts/yoga/meta.nix`.
- Performance profile: favor powersaving CPU governor, minimal background services.
- Disk: single SSD with btrfs, subvolumes optimized for laptop (see Disk section).

**Open questions for agents (yoga-specific):**

- Which services should *not* auto-start on battery-first laptop?
- Any GPU-related quirks (Wayland/Niri on Intel/AMD iGPU)?

### ASUS ROG Zephyrus M16 (`zephyrus`)

**Role:** performance workstation; containers, multi-SSD, GPU workloads.

- Hardware: see `hosts/zephyrus/meta.nix`.
- Performance profile: favor performance, aggressive swap tuning.
- Disk: multiple SSDs with btrfs, separate volumes for containers.
- GPU: Nvidia dGPU enabled.

**Open questions for agents (zephyrus-specific):**

- Container runtime tuning (Podman performance on NVMe).
- GPU driver configuration for Wayland/Niri.

### Hetzner VPS (`hetzner-vps`)

**Role:** primary cloud development server, Attic cache host.

- Hardware: see `hosts/servers/hetzner-cloud/meta.nix`.
- Profile: stable, Tailnet-first, conservative upgrades.
- Services: Attic binary cache, Caddy reverse proxy.

**Open questions for agents (hetzner-vps-specific):**

- Optimal disk layout for cache storage.
- Backup strategy for Attic state.

### OVH VPS (`ovh-vps`)

**Role:** secondary cloud server.

- Hardware: see `hosts/servers/ovh-cloud/meta.nix`.
- Profile: stable, Tailnet-first.

---

## Disk Configuration (btrfs via disko)

All hosts use btrfs with the following **baseline** subvolumes:

- `@`          – root filesystem (`/`)
- `@home`      – `/home`
- `@nix`       – `/nix` (separate for GC & snapshots)
- `@log`       – `/var/log` (optional but nice for pruning)
- `@snap`      – `/snapshots` (if using snapper/btrbk/etc.)

**Developer-specific subvolumes:**

- `@dev`       – `/home/<user>/dev` (all project code)
- `@containers` – `/var/lib/containers` (Podman)

Each host can extend or override (e.g. extra drive for containers on zephyrus).

**Agents can then:**

- Generate `disko.nix` per host from this template.
- Add mount options (`compress=zstd`, `ssd`, `noatime`, etc.).
- Ensure `@home`, `@dev`, and `@containers` are never wiped on reinstall.

**What must survive rebuilds:**

- `/home` (`@home`)
- `~/dev` (`@dev`)
- `/var/lib/containers` (`@containers`)

**What can be nuked:**

- `/` (`@`)
- `/nix` (`@nix`) – can be rebuilt
- `/var/log` (`@log`)

---

## Secrets Management

**Secrets provider:** 1Password (GUI + service account).

**Nix integration:** OpNix with `op://` references.

**Vault model:**

- `pantherOS` vault: bootstrap + shared infra secrets (API keys, Tailnet keys).
- Future per-project vaults: `proj-<name>` (optional).

**Secret naming convention:**

- `<scope>.<service>.<purpose>` (e.g. `infra.tailscale.authkey`, `ai.openrouter.api_key`).

**All long-lived credentials must be referenced in Nix as:**

- `op://<vault>/<item>/<field>` (preferred) or
- `op:<vault>/<item>/<field>` when needed for OpNix.

**Tasks for agents:**

1. Inventory secrets.
2. Map each one to a canonical name + `op://` path.
3. Update Nix modules so no secret is in plaintext.

**Open questions:**

- How to handle 1Password agent.toml and SSH agent config declaratively (not just manually toggling in GUI).
- Service account tokens / S3 keys / Tailscale keys – where are they referenced in Nix (OpNix patterns, `op://` vs `op:<vault>/...`).

---

## Security Model

**Core assumption:** All sensitive services are reachable **only** via Tailscale.

**SSH:**

- Laptops: SSH primarily via Tailscale; local LAN allowed.
- VPS: SSH allowed **only on Tailscale interface** when possible.

**Firewalls:**

- Default deny inbound.
- Allow:
  - Tailscale UDP port (`services.tailscale.port`).
  - Service ports bound to `tailscale0` when needed (e.g. internal Caddy).

**Tailscale tags:**

- `tag:dev-laptop`   – yoga, zephyrus.
- `tag:codespace`    – hetzner-vps, ovh-vps.
- `tag:infra`        – any infra services host (Attic, etc.).

**Agents can then:**

- Implement `services.tailscale.*` in a module.
- Configure `networking.firewall` in a reusable `modules/system/networking/tailscale-firewall.nix`.

---

## SSH Strategy

**SSH key storage:** 1Password (per-device items: `yogaSSH`, `zephyrusSSH`, etc.).

**SSH agent:** 1Password SSH agent + `~/.config/1Password/ssh/agent.toml` managed by home-manager.

**`~/.ssh/config`:**

- `IdentityAgent ~/.1password/agent.sock`
- Host entries prefer `100.x.x.x` Tailscale IPs.

**Tailscale SSH** may be added later but is not the default yet.

**Then an agent can:**

- Create a home-manager module that manages `agent.toml` + `~/.ssh/config` based on host tags.

---

## DNS and Proxy

**DNS / domains:** Cloudflare is the DNS provider.

**Reverse proxy:** Caddy runs on `hetzner-vps` (primary) and optionally `ovh-vps`.

**Access model:**

- Public internet: No access to personal UIs by default.
- Tailnet: UIs (e.g. web dashboards, internal docs) bound to `tailscale0` and/or use Tailscale serve / funnel features where appropriate.

**Certificates:**

- Use Caddy's automatic HTTPS with Cloudflare DNS or Tailscale certificates.

**Agents then know to:**

- Create a caddy module that binds to specific interfaces only.
- Use Cloudflare API tokens from 1Password for DNS challenges.

---

## DevShell Contract

**Auto-activates when entering `~/dev`** (via `direnv` + `nix-direnv`).

**Provides:**

- Git, direnv, nix tooling (`nix`, `nix fmt`, `nix flake check`).
- Language toolchains: Node, Python, Go, Rust, Nix.
- LSP servers:
  - TS/JS: `typescript-language-server`
  - Python: `pyright` or `pylsp`
  - Go: `gopls`
  - Rust: `rust-analyzer`
  - Nix: `nil` or `rnix-lsp`
- Formatters:
  - `prettier` for web.
  - `black`/`ruff` for Python.
  - `gofmt`/`goimports` for Go.
  - `rustfmt`.
  - `nixfmt` or `alejandra` for Nix.

**Philosophy:**

- No global `npm install -g` for critical tools; prefer `nodePackages`/`devShell`.

**Now agents can fill in `flake.nix` / `devShells.default` concretely.**

---

## Language Tooling Policy

| Language | Version source      | Package manager      | LSP                         | Formatter             |
|---------:|---------------------|----------------------|-----------------------------|-----------------------|
| Node/TS  | `pkgs.nodejs_latest`| `pnpm` (preferred)   | `typescript-language-server`| `prettier`            |
| Python   | `python3` in shell  | `uv` / `pip-tools`   | `pyright`                   | `black` + `ruff`      |
| Go       | `go` from pkgs      | `go` modules         | `gopls`                     | `gofmt`/`goimports`   |
| Rust     | `rustup` or pkgs    | `cargo`              | `rust-analyzer`             | `rustfmt`             |
| Nix      | `nixpkgs-fmt`/`nil` | n/a                  | `nil`/`rnix-lsp`            | `nixfmt`/`alejandra`  |

**Agents can then:**

- Implement `modules/home/dev/languages.nix` that wires all this up.

---

## Desktop Modules

Desktop-related config is split as:

- `modules/system/desktop` – display server, compositor, greeter, portals.
- `modules/home/desktop`  – DMS, theming, shortcuts.
- `modules/home/shell`    – fish config, prompts, completions.
- `modules/home/terminal` – Ghostty config.

**That gives agents a place to attach the Niri + DMS snippets you already collected.**

### Desktop Stack (Niri + DankMaterialShell + Ghostty + fish)

**Compositor:** Niri (scrollable-tiling Wayland compositor).

**Shell:** DankMaterialShell (DMS) + fish.

**Terminal:** Ghostty.

**Key components:**

- `modules/system/desktop/niri.nix`
- `modules/home/desktop/dms.nix`
- `modules/home/shell/fish.nix`
- `modules/home/terminal/ghostty.nix`

**Dependencies:**

- `mate-polkit` (only polkit daemon).
- `wl-clipboard`, portals, etc.

---

## System Authentication (polkit / PAM / 1Password)

**Only `mate-polkit` is used** (no multiple polkit daemons).

**`_1password-gui` handles:**

- System auth prompts (via polkit).
- Biometric unlock where supported.

**Goal:** When `_1password-gui` is unlocked, system prompts should allow "Authenticate" without re-entering main password.

**Then agents can:**

- Write NixOS modules that ensure only `mate-polkit` is active, and that 1Password integrates correctly.

---

## AI Coding Agents Stack

Installed via `numtide/nix-ai-tools` flake input.

**Primary tools:**

- `claude-code` + `claude-code-acp`
- `opencode`
- `qwen-code`
- `gemini-cli`
- `catnip` (optional, for agentic workflows)

**Design:**

- All tools share:
  - Common config dir: `~/.config/pantherOS/ai/`.
  - API keys provided via 1Password/OpNix (no plain env vars in Git).
- Usage pattern:
  - `claude-code` for large, multi-step codebase work and CI.
  - `opencode` as orchestrator/launcher for other tools.
  - `qwen-code` & `gemini-cli` for lower-cost experimentation.

**That gives you a foundation for AI agents configuring other AI agents.**

---

## Private Nix Cache (Attic + Backblaze B2)

**Binary cache server:** Attic running on `hetzner-vps`.

**Storage:** Backblaze B2 bucket `pantheros-nix-cache`.

**Access:**

- Attic credentials stored in 1Password (`infra.attic.*` items).
- All hosts are configured to:
  - Upload builds if they are "builder" hosts.
  - Use the cache for substitutes by default.

**CI:**

- GitHub Actions build selected hosts and push to Attic.

**Attic docs explicitly support S3-compatible stores like B2.**

---

## CI / Testing / Deploy

**nix flake check usage:**

- Run `nix flake check` to validate all configurations.

**GitHub Actions:**

- Builds configurations.
- Pushes to Attic.

**How you deploy:**

- `nixos-rebuild --flake` for local.
- `deploy-rs` or `colmena` for remote (TBD).

---

## Logging / Observability

**Decisions needed:**

- Persistent logs (`/var/log` subvolume? journald config).
- Basic system metrics/monitoring (even if lightweight).

---

## Documentation for Agents

**Where "agent-facing" docs live:** `/docs/agents/**`.

**How prompts / SKILL.md files are organized for different agents.**

---

## Biggest Gaps / Fuzzy Areas

These are the main "holes" that will trip agents up unless you codify them:

### Architecture & modules

- No explicit "how flakes are wired" section: `outputs.nixosConfigurations`, `outputs.homeConfigurations`, shared `lib.mkSystem`/`mkHost`.
- You hint at modularity but don't define a module taxonomy (e.g. `modules/system/{networking,security,desktop,...}`, `modules/home/{cli,apps,desktop,...}`, profiles, etc.).

### Disk / data / backups

- No backup/restore strategy (Borg/Restic, etc.) for at least `/home` and `~/dev`.

### Secrets & 1Password

- Vault naming patterns and per-host vs shared vaults.
- Where `agent.toml` and SSH agent config live and how they're declared (not just manually toggling in GUI).
- How service account tokens / S3 keys / Tailscale keys are referenced in Nix (OpNix patterns, `op://` vs `op:<vault>/...`).

### Security / networking

- No clear stance on SSH: Tailscale-only? Public SSH allowed for some hosts? Use Tailscale SSH, 1Password SSH, or both?
- No concrete firewall policy (e.g. "only Tailscale + loopback + specific service ports; no public SSH on VPS").
- No basic ACL/tag plan ("dev-laptop", "codespace-server", "infra-services", etc.).

### DevShell & languages

- No explicit language versions & tools (e.g. "Node via `nodejs_latest` + pnpm", "Python via `uv`", etc.).
- No standard LSP + formatter mapping for each language.
- No policy for Node/npm on NixOS (e.g. node2nix, pnpm, or `nixpkgs.nodePackages` to avoid global npm weirdness).

### AI tools & agents

- No unified "AI agent workflow" section that describes:
  - Which CLIs are "primary" vs "nice to have".
  - How they share API keys, logs, context directories.
- No per-agent expectations (e.g. "Claude Code is used for multi-step repo work; opencode as orchestrator; Qwen Code for cheap iterations").

### Binary cache / Attic

- Which host runs Attic.
- How the S3 bucket is named & provisioned.
- How your flake / machines are configured to use that cache.

### CI / testing / deploy

- Nothing about:
  - `nix flake check` usage.
  - GitHub Actions or other CI that:
    - Builds configurations.
    - Pushes to Attic.
  - How you deploy (e.g. `nixos-rebuild --flake`, `deploy-rs`, `colmena`).

### Logging / observability

- No decisions about:
  - Persistent logs (`/var/log` subvolume? journald config).
  - Basic system metrics/monitoring (even if lightweight).

### Documentation for agents

- You don't yet define:
  - Where "agent-facing" docs live (`/docs/agents/**?`).
  - How prompts / SKILL.md files are organized for different agents.

---

## Agent Task Packs (Ready-to-Use Bundles)

Here's how I'd group the work into small, testable agent prompts.

You can literally turn each bullet into a SKILL.md or a Claude Code task.

### Pack 1 – Hardware & hosts

**Goal:** Populate `hosts/*/meta.nix` and hardware context.

**Tasks for the agent:**

For host `<name>`:

1. Gather hardware data (from user-provided logs or shell commands).
2. Create `hosts/<name>/meta.nix` with:
   - CPU, GPU, RAM, disks, capabilities.
3. Update the host's section in OVERVIEW.md to reference `meta.nix` instead of blank CPU/GPU lines.

**Pause and test:**

- Verify `meta.nix` is valid Nix and can be imported without errors.

---

### Pack 2 – Disk & disko

**Goal:** Implement the standard btrfs layout with per-host overrides.

**Tasks:**

1. Take the canonical subvolume design (`@`, `@home`, `@nix`, `@log`, `@snap`, `@dev`, `@containers`).
2. For host `<name>`, generate a first-pass `hosts/<name>/disko.nix`.
3. Ensure:
   - Correct devices and sizes based on `meta.nix`.
   - Subvol mountpoints match the spec.
4. Add a short `docs/disk/<name>.md` explaining the layout.

**Pause and test:**

- `nix fmt` + `nix flake check`.
- For a VM or test host, run disko in dry-run mode.

---

### Pack 3 – Secrets & 1Password/OpNix

**Goal:** Create a machine-readable secrets inventory and 1Password referencing scheme.

**Tasks:**

1. Parse the overview and any existing configs to list all secrets:
   - Tailscale keys, GitHub PAT, API keys, Attic creds, etc.
2. Normalize into an inventory file (`docs/secrets/inventory.md` or `.json`) with:
   - `canonical_name`
   - `vault`
   - `item`
   - `field`
   - usage notes.
3. Propose a 1Password item structure that matches your naming scheme.
4. Identify all `op://` references in the code and:
   - Flag inconsistencies.
   - Suggest refactors to match the inventory.

**Pause and test:**

- Manually check a couple of `op://` references match reality before letting agents refactor paths.

---

### Pack 4 – Security, Tailscale, firewall

**Goal:** Implement the policy you defined.

**Tasks:**

1. Create `modules/system/networking/tailscale.nix`:
   - `services.tailscale.enable = true;`
   - `useRoutingFeatures` settings per host role.
2. Create `modules/system/networking/firewall.nix`:
   - Default deny inbound.
   - Allow Tailscale port + specific service ports.
   - Optionally restrict SSH to Tailscale IPs for VPS.
3. Add Tailscale tag outputs (as comments or docs) for each host.

**Pause and test:**

- `nixos-rebuild build --flake .#hetzner-vps` and inspect firewall rules.

---

### Pack 5 – DevShell & languages

**Goal:** Make `devShells.default` match your language tooling policy.

**Tasks:**

1. Implement `devShells.default` in `flake.nix` with:
   - core CLIs (git, direnv, nix tools).
   - all language toolchains + LSPs + formatters as per the table.
2. Add direnv + nix-direnv integration docs for `~/dev`.
3. Create `docs/devshell.md` describing what's available.

**Pause and test:**

- Enter `~/dev` in a test repo and confirm tools resolve.

---

### Pack 6 – AI tools stack

**Goal:** Install and standardize AI CLIs via nix-ai-tools.

**Tasks:**

1. Add `nix-ai-tools` as a flake input and wire into `environment.systemPackages`.
2. Create `modules/home/ai-tools.nix` that:
   - Installs your chosen CLIs.
   - Sets up `~/.config/pantherOS/ai/`.
3. Draft a `docs/agents/ai-tools.md` describing:
   - When to use which tool.
   - Where configs and logs live.

**Pause and test:**

- Run `claude-code --help`, `opencode --help`, etc., on a host.

---

### Pack 7 – Desktop stack

**Goal:** Make Niri + DMS + Ghostty + fish modular and reproducible.

**Tasks:**

1. Create:
   - `modules/system/desktop/niri.nix`
   - `modules/home/desktop/dms.nix`
   - `modules/home/shell/fish.nix`
   - `modules/home/terminal/ghostty.nix`
2. Move your existing Niri / DMS snippets into those modules.
3. Ensure `mate-polkit`, `wl-clipboard`, portals, etc. are included.

**Pause and test:**

- Build one desktop host config and boot it in a VM or on yoga.

---

### Pack 8 – Attic + CI

**Goal:** Wire up Attic and a minimal CI.

**Tasks:**

1. Create `modules/system/infra/attic.nix` for the server host:
   - Attic service.
   - B2 bucket config via secrets.
2. Configure all hosts to use the Attic cache.
3. Add a simple GitHub Action that:
   - Runs `nix flake check`.
   - Builds a subset of hosts.
   - Pushes results to Attic.

**Pause and test:**

- Verify a "cold" machine pulls from Attic instead of building from source.

---

**Built with ❤️ using NixOS**
