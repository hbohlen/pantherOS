# pantherOS Implementation Research Plan

This document identifies all missing areas, implementation details, code snippets, and research needed before implementing the 8 Agent Task Packs from [OVERVIEW.md](../../OVERVIEW.md).

**Generated:** 2025-11-23
**Status:** Research Planning Phase

---

## Current State Analysis

### ✅ What Already Exists

#### Documentation
- ✅ Hardware specifications with detailed profiles for all hosts (`.opencode/context/domain/hardware-specifications.md`)
- ✅ Comprehensive disk layout documentation (`docs/architecture/disk-layouts.md`)
- ✅ Security model documentation (`docs/architecture/security-model.md`)
- ✅ Module organization guide (`docs/architecture/module-organization.md`)
- ✅ Host classification (`docs/architecture/host-classification.md`)

#### Code & Modules
- ✅ Basic flake.nix with all 4 hosts configured
- ✅ Tailscale modules (`modules/nixos/services/networking/tailscale-*.nix`)
- ✅ Fish shell modules (`modules/home-manager/shell/fish/`)
- ✅ User management modules (`modules/nixos/core/users/`)
- ✅ Basic disko configurations for all hosts
- ✅ SSH service module (`modules/nixos/services/ssh.nix`)
- ✅ Podman module (`modules/nixos/services/podman.nix`)
- ✅ Some btrfs filesystem modules (`modules/shared/filesystems/`)

#### Configuration
- ✅ All 4 hosts have basic structure (default.nix, disko.nix, hardware.nix)
- ✅ Home-manager integration in flake
- ✅ Disko integration in flake

### ❌ What's Missing

Based on OVERVIEW.md and current codebase analysis, here are the critical gaps:

---

## Task Pack 1: Hardware & Hosts

### Current State
- ✅ **Hardware specs documented** - Comprehensive hardware profiles exist in `.opencode/context/domain/hardware-specifications.md`
- ❌ **No meta.nix files** - OVERVIEW.md calls for `hosts/<name>/meta.nix` but none exist yet
- ❌ **Hardware detection automation** - Scripts exist in docs but not integrated

### Research Needed

#### 1.1 Meta.nix Structure
**Status:** Design needed
**Priority:** High

**Questions:**
- Should `meta.nix` be a simple attribute set or a NixOS module?
- Should it be imported by `default.nix` or just documentation?
- What fields are mandatory vs. optional?

**Proposed Structure:**
```nix
# hosts/yoga/meta.nix
{
  hardware = {
    cpu = {
      model = "Intel Core i7-1260P";
      cores = 12;
      threadsPerCore = 1;
      maxFrequencyMhz = 4700;
      vendor = "intel";
    };
    gpu = [
      {
        model = "Intel Iris Xe Graphics";
        vendor = "intel";
        type = "integrated";
        memory = "shared";
      }
    ];
    memory = {
      totalGb = 16;
      type = "LPDDR5";
      speed = "5200MT/s";
    };
    storage = [
      {
        device = "/dev/nvme0n1";
        size = "512GB";
        type = "nvme";
        interface = "PCIe 4.0";
      }
    ];
    display = {
      size = "14\"";
      resolution = "2880x1800";
      touchscreen = true;
    };
    battery = {
      capacity = "71Whr";
      estimatedHours = 18;
    };
  };

  capabilities = {
    gpu = false;  # No discrete GPU
    containers = "light";  # Limited container workloads
    aiWorkloads = false;
  };

  optimizationProfile = "battery-life";  # battery-life | balanced | performance
}
```

**Action Items:**
1. ✅ Extract data from existing hardware-specifications.md
2. ❌ Design meta.nix schema (see above proposal)
3. ❌ Create `lib/mkMeta.nix` helper function (optional)
4. ❌ Generate meta.nix for all 4 hosts
5. ❌ Update host default.nix to reference meta.nix

---

## Task Pack 2: Disk & Disko

### Current State
- ✅ **Detailed disk layout documentation** exists
- ✅ **Basic disko.nix** for all hosts
- ❌ **Current disko configs don't match OVERVIEW.md canonical layout**
  - Current: `@`, `@home`, `@nix`, `@snapshots` (simple)
  - OVERVIEW.md: `@`, `@home`, `@nix`, `@log`, `@snap`, `@dev`, `@containers` (comprehensive)

### Research Needed

#### 2.1 Disko Configuration Standardization
**Status:** Gap between docs and implementation
**Priority:** High

**Current Gap:**
- Existing disko configs use simplified layouts
- OVERVIEW.md proposes richer subvolume structure
- docs/architecture/disk-layouts.md has even MORE detailed layouts with different names

**Questions:**
- Should we adopt OVERVIEW.md canonical layout or disk-layouts.md detailed version?
- How to migrate existing hosts without data loss?
- Should we create a `lib/mkDisko.nix` helper for consistency?

**Recommendation:**
- Use OVERVIEW.md baseline as minimum
- Extend per-host as documented in disk-layouts.md
- Create reusable disko templates in `lib/disko/`

**Action Items:**
1. ❌ Reconcile OVERVIEW.md vs disk-layouts.md naming (`@snap` vs `@snapshots`, `@log` vs `@logs`)
2. ❌ Create `lib/disko/workstation.nix` template
3. ❌ Create `lib/disko/server.nix` template
4. ❌ Update all hosts to use templates
5. ❌ Document migration path for existing deployments
6. ❌ Add per-host `docs/disk/<hostname>.md` explaining layout

#### 2.2 Mount Options Research
**Status:** Need validation
**Priority:** Medium

**Questions:**
- Are `space_cache=v2` and `discard=async` safe for all NVMe?
- Should we use different schedulers for NVMe vs SATA?
- What's the optimal `dirty_ratio` for each host type?

**Action Items:**
1. ❌ Research NixOS best practices for btrfs mount options
2. ❌ Test mount options on each host type
3. ❌ Document rationale for each option
4. ❌ Create per-profile mount option sets

---

## Task Pack 3: Secrets & 1Password/OpNix

### Current State
- ❌ **No OpNix integration** - Not in flake inputs
- ❌ **No 1Password service account configured**
- ❌ **No secrets inventory**
- ❌ **No agent.toml management**

### Research Needed

#### 3.1 OpNix Integration
**Status:** Not implemented
**Priority:** Critical

**Missing:**
- OpNix flake input
- OpNix NixOS module configuration
- Service account token management

**Action Items:**
1. ❌ Add OpNix to flake inputs: `opnix.url = "github:mrjones2014/opnix";`
2. ❌ Research OpNix module options and patterns
3. ❌ Create bootstrap documentation for 1Password service account
4. ❌ Design secrets referencing pattern (`op://` vs `op:<vault>/...`)
5. ❌ Create example secrets module

**Example Research Needed:**
```nix
# How do we reference secrets in modules?
# Option A: OpNix module
services.tailscale.authKeyFile = config.opnix.secrets."infra.tailscale.authkey".path;

# Option B: Direct op:// reference (if supported)
services.tailscale.authKey = "op://pantherOS/tailscale/authkey";

# Which pattern is correct?
```

#### 3.2 Secrets Inventory
**Status:** Not created
**Priority:** High

**Questions:**
- What secrets do we currently need?
- How should they be organized in 1Password vaults?
- What's the naming convention?

**Identified Secrets (so far):**
```yaml
# Infrastructure
- infra.tailscale.authkey (for each host?)
- infra.attic.s3_access_key
- infra.attic.s3_secret_key
- infra.cloudflare.api_token

# AI Services
- ai.openai.api_key
- ai.anthropic.api_key
- ai.openrouter.api_key

# Git/GitHub
- git.github.pat_token

# SSH Keys (managed by 1Password SSH agent)
- ssh.yoga.private_key
- ssh.zephyrus.private_key
- ssh.hetzner-vps.private_key
- ssh.ovh-vps.private_key
```

**Action Items:**
1. ❌ Audit all services and identify required secrets
2. ❌ Create `docs/secrets/inventory.md` or `docs/secrets/inventory.json`
3. ❌ Set up 1Password pantherOS vault structure
4. ❌ Create items in 1Password following naming convention
5. ❌ Document secret rotation procedures

#### 3.3 SSH Agent Integration
**Status:** Not implemented
**Priority:** High

**Missing:**
- 1Password SSH agent configuration via home-manager
- agent.toml declarative management
- SSH config with Tailscale IPs

**Research Needed:**
- How to manage `~/.config/1Password/ssh/agent.toml` declaratively?
- Should we use 1Password SSH agent OR Tailscale SSH?
- Can they coexist?

**Action Items:**
1. ❌ Research home-manager 1Password SSH agent module
2. ❌ Create `modules/home/ssh/1password-agent.nix`
3. ❌ Create `modules/home/ssh/config.nix` with Tailscale IPs
4. ❌ Document SSH workflow for AI agents

---

## Task Pack 4: Security, Tailscale, Firewall

### Current State
- ✅ **Tailscale modules exist** (`tailscale-service.nix`, `tailscale-firewall.nix`)
- ❌ **Not using Tailscale tags**
- ❌ **Firewall rules are minimal** (only opens Tailscale UDP port)
- ❌ **No host-specific firewall policies**

### Research Needed

#### 4.1 Tailscale Configuration
**Status:** Basic implementation exists
**Priority:** High

**Current Implementation:**
```nix
# modules/nixos/services/networking/tailscale-firewall.nix
# Only opens UDP port, no advanced features
```

**Missing:**
- Tailscale tags configuration
- `useRoutingFeatures` settings
- Exit nodes, subnet routing (if needed)
- MagicDNS configuration

**Questions:**
- Should we enable `--advertise-exit-node` on VPS hosts?
- Should we use `--accept-routes` on workstations?
- How to manage tags via `--advertise-tags=tag:dev-laptop`?

**Action Items:**
1. ❌ Research Tailscale NixOS options (`services.tailscale.*`)
2. ❌ Design per-host Tailscale configuration
3. ❌ Configure tags:
   - `tag:dev-laptop` (yoga, zephyrus)
   - `tag:codespace` (hetzner-vps, ovh-vps)
   - `tag:infra` (Attic host)
4. ❌ Enable ACLs in Tailscale admin console
5. ❌ Document Tailscale architecture

#### 4.2 Firewall Policy
**Status:** Too permissive
**Priority:** Critical (security)

**OVERVIEW.md Policy:**
> Default deny inbound.
> Allow: Tailscale UDP port + service ports bound to tailscale0.
> VPS: SSH only on Tailscale interface.

**Current Gap:**
- No interface-specific bindings
- No service port restrictions
- SSH accessible on all interfaces (probably)

**Action Items:**
1. ❌ Research NixOS firewall interface-specific rules
2. ❌ Create firewall profiles:
   - `modules/nixos/security/firewall/workstation.nix`
   - `modules/nixos/security/firewall/server.nix`
3. ❌ Implement SSH restriction to Tailscale interface only (VPS)
4. ❌ Document firewall testing procedures
5. ❌ Add firewall validation to CI

**Example Research Needed:**
```nix
# How to restrict SSH to Tailscale interface?
networking.firewall = {
  enable = true;
  interfaces = {
    "tailscale0".allowedTCPPorts = [ 22 ];  # SSH only on Tailscale
  };
  # No SSH on public interface
};

# Or use services.openssh.listenAddresses?
services.openssh.listenAddresses = [
  { addr = "100.x.x.x"; port = 22; }  # Tailscale IP only
];
```

---

## Task Pack 5: DevShell & Languages

### Current State
- ✅ **Basic devShell exists** with nix tools
- ❌ **No language toolchains** (Node, Python, Go, Rust)
- ❌ **No LSP servers**
- ❌ **No formatters**
- ❌ **No direnv integration documented**

### Research Needed

#### 5.1 DevShell Enhancement
**Status:** Minimal implementation
**Priority:** High

**Current DevShell:**
```nix
buildInputs = with pkgs; [
  nix git nixos-rebuild nixos-generators
  nil nixfmt hmCli diskoCli
];
```

**OVERVIEW.md Requirements:**
- Node/TS + pnpm + typescript-language-server + prettier
- Python + uv + pyright + black + ruff
- Go + gopls + gofmt + goimports
- Rust + rust-analyzer + rustfmt
- Nix + nil + nixfmt/alejandra

**Questions:**
- Should this be in flake.nix `devShells.default` or a separate module?
- How to handle multiple Node/Python versions per project?
- Should we use `nix-direnv` for per-project environments?

**Action Items:**
1. ❌ Research nix-direnv integration
2. ❌ Design layered devShell approach:
   - Global devShell (flake.nix) - Infrastructure tooling
   - Project devShells (~/dev/*/.envrc) - Language-specific
3. ❌ Add all language toolchains to global devShell
4. ❌ Create `modules/home/dev/direnv.nix`
5. ❌ Document devShell usage in `docs/devshell.md`
6. ❌ Create example .envrc for common project types

#### 5.2 Node/npm Strategy
**Status:** Not defined
**Priority:** Medium

**OVERVIEW.md hints at issue:**
> No policy for Node/npm on NixOS (node2nix, pnpm, nixpkgs.nodePackages)

**Questions:**
- Should we use `nodePackages` from nixpkgs?
- Use `pnpm` globally or per-project?
- How to handle global npm installs?
- Use `fnm` (Fast Node Manager) module that already exists?

**Existing Code:**
```
modules/home-manager/development/node/fnm.nix  # Already have fnm!
modules/home-manager/shell/fnm.nix
```

**Action Items:**
1. ❌ Review existing fnm module
2. ❌ Decide: fnm vs. nixpkgs Node vs. both
3. ❌ Document Node.js workflow for pantherOS
4. ❌ Add pnpm configuration
5. ❌ Test with real Node.js project

---

## Task Pack 6: AI Tools Stack

### Current State
- ❌ **nix-ai-tools NOT in flake inputs**
- ❌ **No AI CLI tools installed**
- ❌ **No shared config directory**
- ❌ **No API key management**

### Research Needed

#### 6.1 nix-ai-tools Integration
**Status:** Not implemented
**Priority:** Medium (nice to have, not critical)

**Missing:**
- Flake input for `numtide/nix-ai-tools`
- Package installation
- Configuration

**Questions:**
- Which tools from nix-ai-tools do we actually need?
- How stable is nix-ai-tools (it's very new)?
- Should we pin a specific revision?

**OVERVIEW.md Tools:**
- claude-code + claude-code-acp ✅ (available)
- opencode ✅
- qwen-code ✅
- gemini-cli ✅
- catnip (?)

**Action Items:**
1. ❌ Research nix-ai-tools package list
2. ❌ Add to flake: `nix-ai-tools.url = "github:numtide/nix-ai-tools";`
3. ❌ Test which tools work well
4. ❌ Create `modules/home/ai-tools.nix`
5. ❌ Set up `~/.config/pantherOS/ai/` directory structure

#### 6.2 API Key Management
**Status:** Not defined
**Priority:** Medium

**Questions:**
- How to provide API keys to CLI tools?
- Environment variables vs. config files?
- Per-tool configs or shared?

**Proposed Structure:**
```
~/.config/pantherOS/ai/
  config.toml          # Shared config
  openai-api-key       # From 1Password via OpNix
  anthropic-api-key
  openrouter-api-key
  logs/
    claude-code.log
    opencode.log
```

**Action Items:**
1. ❌ Design config directory structure
2. ❌ Create home-manager module for AI tools
3. ❌ Link API keys from OpNix secrets
4. ❌ Create `docs/agents/ai-tools.md`

---

## Task Pack 7: Desktop Stack

### Current State
- ❌ **No Niri compositor** configured
- ❌ **No DankMaterialShell**
- ❌ **No Ghostty** terminal
- ✅ **Fish shell modules exist**
- ✅ **mate-polkit mentioned** in docs but not configured

### Research Needed

#### 7.1 Niri Compositor
**Status:** Not implemented
**Priority:** High (if desktop is needed)

**Missing:**
- Niri package/module
- Wayland session configuration
- Portal configuration

**Questions:**
- Is Niri in nixpkgs yet or do we need an overlay?
- How to configure Niri declaratively?
- What portals are needed (xdg-desktop-portal-wlr)?

**Action Items:**
1. ❌ Research Niri availability in nixpkgs
2. ❌ Find/create Niri NixOS module
3. ❌ Check code_snippets/ for existing config (might be there!)
4. ❌ Create `modules/system/desktop/niri.nix`
5. ❌ Configure required portals
6. ❌ Test on yoga/zephyrus

#### 7.2 DankMaterialShell
**Status:** Unknown
**Priority:** Medium

**Questions:**
- What is DankMaterialShell exactly?
- Is it a Niri theme? Separate app? Shell (like bash/fish)?
- Where to get it?
- How to configure it in NixOS?

**Action Items:**
1. ❌ Research DankMaterialShell (is it a real project?)
2. ❌ Find installation/config method
3. ❌ Create module or document manual setup
4. ❌ Add to `modules/home/desktop/dms.nix` (if applicable)

#### 7.3 Ghostty Terminal
**Status:** Not implemented
**Priority:** Medium

**Questions:**
- Is Ghostty in nixpkgs?
- Configuration format?
- Integration with fish shell?

**Action Items:**
1. ❌ Check Ghostty availability
2. ❌ Research Ghostty configuration
3. ❌ Create `modules/home/terminal/ghostty.nix`
4. ❌ Configure fonts, colors, keybindings
5. ❌ Test with fish + Niri

#### 7.4 Desktop Module Organization
**Status:** Structure needed
**Priority:** Low

**OVERVIEW.md Structure:**
```
modules/system/desktop/  # Compositor, display server, greeter, portals
modules/home/desktop/    # DMS, theming, shortcuts
modules/home/shell/      # fish (already exists!)
modules/home/terminal/   # ghostty
```

**Current Structure:**
```
modules/home-manager/shell/fish/  # ✅ Exists
modules/home-manager/development/ # ✅ Exists
```

**Action Items:**
1. ❌ Decide: restructure to match OVERVIEW.md or update OVERVIEW.md?
2. ❌ Create missing module directories
3. ❌ Update imports in hosts

---

## Task Pack 8: Attic + CI

### Current State
- ❌ **No Attic** configured
- ❌ **No binary cache**
- ❌ **No CI** (GitHub Actions)
- ❌ **No Backblaze B2** integration

### Research Needed

#### 8.1 Attic Server Setup
**Status:** Not implemented
**Priority:** Low (optimization, not critical)

**Missing:**
- Attic NixOS module
- S3-compatible storage (Backblaze B2)
- Server configuration on hetzner-vps

**Questions:**
- How to install Attic on NixOS?
- How to configure B2 as storage backend?
- Authentication for uploading builds?
- How do clients authenticate to Attic?

**OVERVIEW.md Spec:**
> Binary cache server: Attic running on hetzner-vps
> Storage: Backblaze B2 bucket pantheros-nix-cache
> Access: Credentials in 1Password (infra.attic.*)

**Action Items:**
1. ❌ Research Attic NixOS module/package
2. ❌ Set up Backblaze B2 account and bucket
3. ❌ Store B2 credentials in 1Password
4. ❌ Create `modules/system/infra/attic.nix`
5. ❌ Configure Attic server on hetzner-vps
6. ❌ Test uploading/downloading from cache

#### 8.2 Cache Client Configuration
**Status:** Not implemented
**Priority:** Low

**Missing:**
- Nix cache configuration for all hosts
- Trusted public keys
- Substituter URLs

**Action Items:**
1. ❌ Generate Attic cache signing keys
2. ❌ Configure `nix.settings.substituters`
3. ❌ Configure `nix.settings.trusted-public-keys`
4. ❌ Test cache on all hosts
5. ❌ Document cache usage

#### 8.3 GitHub Actions CI
**Status:** Not implemented
**Priority:** Low

**Missing:**
- .github/workflows/
- Build matrix for all hosts
- Attic upload step

**Questions:**
- Should we build all hosts or just some?
- How to cache Nix builds in GitHub Actions?
- How to authenticate to Attic from CI?

**Action Items:**
1. ❌ Research NixOS CI best practices
2. ❌ Create `.github/workflows/build.yml`
3. ❌ Configure secrets in GitHub
4. ❌ Add `nix flake check` job
5. ❌ Add per-host build jobs
6. ❌ Add Attic push step
7. ❌ Document CI workflow

---

## Additional Research Areas

### Not in Task Packs but Critical

#### A. Flake Architecture
**Status:** Needs improvement
**Priority:** High

**Current Issues:**
- No `lib/` helpers (mkHost, mkSystem)
- Repetitive host configurations
- No shared module imports

**Research Needed:**
1. ❌ Study best practices for large NixOS flakes
2. ❌ Create `lib/mkHost.nix` abstraction
3. ❌ Create `lib/mkHomeConfiguration.nix`
4. ❌ Refactor flake.nix to use helpers

**Example Target:**
```nix
# flake.nix (simplified)
outputs = { self, nixpkgs, ... }@inputs:
  let
    lib = import ./lib { inherit inputs; };
  in {
    nixosConfigurations = {
      yoga = lib.mkHost { hostname = "yoga"; system = "x86_64-linux"; hostType = "workstation"; };
      zephyrus = lib.mkHost { hostname = "zephyrus"; system = "x86_64-linux"; hostType = "workstation"; };
      hetzner-vps = lib.mkHost { hostname = "hetzner-vps"; system = "x86_64-linux"; hostType = "server"; };
      ovh-vps = lib.mkHost { hostname = "ovh-vps"; system = "x86_64-linux"; hostType = "server"; };
    };
  };
```

#### B. Profiles System
**Status:** Not implemented
**Priority:** Medium

**OVERVIEW.md mentions:**
> /profiles – reusable bundles (e.g. desktop, server, devbox)

**Missing:**
- No profiles/ directory
- Duplicate config across hosts

**Research Needed:**
1. ❌ Design profile system
2. ❌ Create profiles:
   - `profiles/workstation.nix`
   - `profiles/server.nix`
   - `profiles/desktop.nix`
   - `profiles/headless.nix`
3. ❌ Import profiles in hosts

#### C. Impermanence
**Status:** Documented but not implemented
**Priority:** Low (servers only)

**Current:**
- Extensive docs in disk-layouts.md
- Module skeleton in modules/shared/filesystems/server-impermanence.nix
- Not enabled on any host

**Questions:**
- Which hosts should use impermanence?
- What paths need to persist?
- How to bootstrap first time?

#### D. Backup Strategy
**Status:** Not defined
**Priority:** High

**OVERVIEW.md Gap:**
> No backup/restore strategy (Borg/Restic) for /home and ~/dev

**Research Needed:**
1. ❌ Choose backup tool (Borg vs. Restic vs. Backblaze B2 sync)
2. ❌ Design backup schedule
3. ❌ Configure backup targets
4. ❌ Test restore procedures
5. ❌ Document backup strategy

---

## Priority Matrix

### P0 - Critical (Blocks Everything)
1. **Secrets (Pack 3)** - Need OpNix + 1Password integration to secure anything
2. **Firewall (Pack 4)** - Security risk if VPS is exposed

### P1 - High (Core Functionality)
3. **Hardware Meta (Pack 1)** - Needed for per-host optimization
4. **Disk Standardization (Pack 2)** - Foundation for everything
5. **Tailscale Config (Pack 4)** - Needed for secure networking
6. **DevShell (Pack 5)** - Essential for development workflow
7. **Flake Architecture (Additional A)** - Makes everything else easier

### P2 - Medium (Quality of Life)
8. **SSH Integration (Pack 3)** - Improves workflow but not blocking
9. **Desktop Stack (Pack 7)** - Only if using yoga/zephyrus as desktop
10. **Profiles (Additional B)** - Reduces duplication
11. **Backup (Additional D)** - Important but can wait

### P3 - Low (Nice to Have)
12. **AI Tools (Pack 6)** - Enhancement, not critical
13. **Attic + CI (Pack 8)** - Optimization for later
14. **Impermanence (Additional C)** - Advanced feature

---

## Recommended Implementation Order

### Phase 1: Security & Foundation (Week 1)
1. Set up 1Password service account
2. Add OpNix to flake
3. Create secrets inventory
4. Implement firewall policies
5. Configure Tailscale properly

### Phase 2: Core Infrastructure (Week 2)
6. Create meta.nix for all hosts
7. Standardize disko configs
8. Create lib/ helpers (mkHost, etc.)
9. Implement profiles system
10. Enhance devShell

### Phase 3: Developer Experience (Week 3)
11. SSH agent integration
12. Language tooling in devShell
13. direnv + nix-direnv
14. Backup strategy

### Phase 4: Desktop & Optional (Week 4+)
15. Niri + Desktop stack (if needed)
16. AI tools integration
17. Attic binary cache
18. GitHub Actions CI
19. Impermanence (servers)

---

## OpenSpec Integration

For each task pack, create an OpenSpec proposal:

```
.openspec/changes/
  2025-11-23-secrets-management/
    proposal.md
    tasks.md
    specs/
      opnix-integration/spec.md
      secrets-inventory/spec.md

  2025-11-23-hardware-metadata/
    proposal.md
    tasks.md
    specs/
      meta-nix-schema/spec.md

  2025-11-23-disk-standardization/
    proposal.md
    tasks.md
    specs/
      disko-templates/spec.md

  # ... etc for each pack
```

---

## Next Steps

1. **Review this document** - Validate gaps and research questions
2. **Prioritize** - Decide which packs to implement first
3. **Create OpenSpec proposals** - One per task pack
4. **Begin research** - For P0/P1 items
5. **Implement incrementally** - One pack at a time
6. **Test thoroughly** - Each pack before moving to next

---

**Maintained by:** Claude Code
**For:** pantherOS Implementation Planning
