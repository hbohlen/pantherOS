# AI Agent Brief: pantherOS NixOS Configuration

## PROJECT MISSION

Build a comprehensive, modular NixOS configuration repository for a solo developer managing 4+ hosts across workstations and servers. **CRITICAL**: This is a multi-phase project starting with hardware discovery and documentation, not code generation.

## REPOSITORY CONTEXT

**Repository Path**: `/home/hbohlen/dev/pantherOS`

**Current State**: Empty directory structure with minimal files. All configuration files are currently empty or contain placeholder content. Primary document is `pantherOS.md` which contains the full vision and TODO items.

**Git Status**: Active repository on `refactor` branch. Recent commits show initial flake setup and host configurations started.

## HOSTS TO CONFIGURE

### Workstations
1. **yoga** - Lenovo Yoga 7 2-in-1 14AKP10
   - Purpose: Lightweight programming, web browsing
   - Priority: Battery life over performance
   - Status: Hardware specs TODO - needs discovery

2. **zephyrus** - ASUS ROG Zephyrus M16 GU603ZW
   - Purpose: Heavy development, Podman containers, AI coding tools
   - Priority: Performance with power profiles
   - Tools: Claude Code CLI, Zed IDE, OpenCode.ai
   - Status: Hardware specs TODO - needs discovery

### Servers
3. **hetzner-vps** - Hetzner Cloud VPS
   - Purpose: Personal codespace server
   - Tools: AI coding CLI tools, Podman, Caddy reverse proxy
   - Security: Tailscale, 1password CLI service account, OpNix
   - Status: Hardware specs TODO - needs discovery

4. **ovh-vps** - OVH Cloud VPS
   - Purpose: Secondary server (mirrors hetzner)
   - Status: Hardware specs TODO - needs discovery

## CORE REQUIREMENTS

### 1. FLAKE CONFIGURATION
- Multi-host flake setup
- DevShell for development work
- Support for custom packages, overlays, and modules
- Integration with nix-ai-tools for AI coding assistants

### 2. MODULAR ARCHITECTURE
**MANDATORY**: All configuration must be modular and single-concern.

```
modules/
├── nixos/              # System modules
│   ├── core/           # Essential services
│   ├── services/       # Network/database services
│   ├── security/       # Firewall, SSH, Tailscale
│   └── hardware/       # Hardware-specific
├── home-manager/       # User modules
│   ├── shell/          # Fish, Ghostty, terminals
│   ├── applications/   # Zed, Zen Browser, 1Password
│   ├── development/    # Languages, LSPs, AI tools
│   └── desktop/        # Niri, DankMaterialShell
└── shared/             # Shared between nixos & hm
```

**Guidelines**:
- Each module = one concern
- Modules can be nested (e.g., modules/nixos/services/network/)
- Import using relative paths
- Document each module in docs/modules/

### 3. DISK CONFIGURATION (DISKO)
- **Filesystem**: Btrfs for all hosts
- **Layout**: Optimized sub-volumes per host purpose
- **Special**: `~/dev` for all coding projects
- **Containers**: Dedicated sub-volumes for Podman
- **SSD**: Optimizations for SSD longevity

**Required Files Per Host**:
- `hosts/<hostname>/disko.nix` - Disk layout
- `hosts/<hostname>/hardware.nix` - Hardware detection output
- `hosts/<hostname>/default.nix` - System configuration

### 4. DESKTOP ENVIRONMENT
**Window Manager Stack**:
- **Niri** - Wayland compositor (via niri-flake)
- **DankMaterialShell** - Material Design UI layer
  - DankGreeter - Login screen
  - DankGop - System monitoring (CPU/GPU/memory)
  - DankSearch - Application launcher
  - Full Niri integration

**Integration Requirements**:
```nix
niri = {
  url = "github:sodiboo/niri-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};

dankMaterialShell = {
  url = "github:danklinux/dankmaterialshell";
};
```

**Required Packages**:
- `wl-clipboard` - Wayland clipboard
- `accountsservice` - User account info
- `xdg-desktop-portal-gtk` - Desktop portal
- `matugen` - Dynamic wallpapers (recommended)
- `cliphist` - Clipboard history
- `hyprpicker` - Color picker
- `xwayland-satellite` - XWayland support

**Terminal & Shell**:
- **Ghostty** - Default terminal (verify package name for NixOS)
- **Fish** - Default shell with full completions
- **Auto-activation** in `~/dev` directory

**Authentication**:
- **Polkit**: `mate-polkit` (DankMaterialShell default)
- **Biometric**: 1Password integration with system auth
- **PAM**: Full configuration for polkit compatibility

### 5. APPLICATIONS

**Development**:
- **Zed IDE** - High-performance editor
- **Zen Browser** - Privacy-focused Firefox fork
- **1Password GUI** + CLI with biometric unlock

**AI Tools** (via nix-ai-tools):
```nix
programs.claude-code.enable = true;
programs.opencode.enable = true;
programs.qwen-code.enable = true;
programs.gemini-cli.enable = true;
programs.codex-acp.enable = true;
programs.catnip.enable = true;
```

**Quality of Life**:
- `zoxide`, `exa`, `ripgrep`, `fzf`
- `tmux`, `zellij`

### 6. LANGUAGES & FRAMEWORKS
Each language must include: package manager, LSP, formatter, AI tool compatibility.

**Required**:
- Node.js / npm compatibility (note: NixOS npm requires special handling)
- JavaScript / TypeScript
- ReactJS
- Python
- Go
- Rust
- Nix

### 7. SECRET MANAGEMENT
**Tool**: 1Password Service Account + OpNix

**Service Account**: `pantherOS`
- Vault: `pantherOS` (created with `--can-create-vaults`)
- SSH Keys: `yogaSSH`, `zephyrusSSH`, `desktopSSH`, `phoneSSH`

**Reference Format**: `op:<vault>/<item>/[section]/<field>`

**Implementation**:
- Use OpNix for NixOS integration
- Configure in flake.nix
- Reference in modules via special args

**CRITICAL**: Never commit secrets. All secrets pulled dynamically from 1Password.

### 8. NETWORK SECURITY
**Tailscale** - Primary network layer
- All devices in single Tailnet
- Research needed: ACLs, tags, role-based access
- No public-facing services

**SSH**:
- 1Password as SSH agent
- Keys managed via service account
- Access restricted to Tailnet devices

**Firewall**:
- Configure per host type
- **CRITICAL**: Never lock out SSH access
- Workstation vs server rules

**DNS & Reverse Proxy**:
- Cloudflare for DNS
- Caddy for reverse proxy
- Domain acquisition needed
- **Goal**: Web UI only accessible via Tailnet
- External visitors: page should not load

### 9. HOME MANAGER CONFIGURATION

**Structure**:
```
home/hbohlen/
├── home.nix                    # Main config
├── configs/                    # Dotfiles
│   ├── fish/                   # Fish shell config
│   ├── ghostty/                # Terminal config
│   ├── opencode/              # opencode.jsonc + dirs
│   │   ├── agent/
│   │   ├── tool/
│   │   ├── plugin/
│   │   ├── skills/
│   │   └── command/
│   ├── claude-code/           # settings.json
│   └── zed/                   # Zed config
└── profiles/                  # User profiles
    ├── development/
    └── workstation/
```

**OpenCode Configuration**:
- Global config: `~/.config/opencode/opencode.jsonc`
- Feature directories: `~/.config/opencode/{agent,tool,plugin,skills,command}/`
- Managed entirely by home-manager

### 10. DEVELOPMENT SHELL

**Activation**: Auto-activate when entering `~/dev` directory

**Tools**: All development languages, formatters, linters, AI tools, Nix tools

## IMPLEMENTATION PHASES

### Phase 1: Hardware Discovery & Documentation
**Priority**: IMMEDIATE - Must complete before any code generation

**Tasks**:
1. **Scan all 4 hosts** for hardware specs:
   - CPU model, cores, threads
   - GPU model (integrated + dedicated)
   - RAM amount, speed, configuration
   - Storage devices (SSD/HDD, NVMe/SATA, size)
   - Network interfaces
   - Special hardware (fingerprint reader, etc.)

2. **Update pantherOS.md**:
   - Fill in hardware specs for each host
   - Document optimization decisions per host
   - Mark hardware discovery tasks complete

3. **Create optimal disk layouts**:
   - Research Btrfs sub-volume best practices
   - Design layouts per host purpose
   - Consider Podman sub-volumes
   - Plan SSD optimizations

### Phase 2: Module Development
**Approach**: System modules → Home-manager modules → Integration

**System Modules Priority Order**:
1. Core (network, users, services)
2. Security (firewall, SSH, Tailscale)
3. Services (Podman, Caddy, etc.)
4. Hardware-specific optimizations

**Home-Manager Modules Priority Order**:
1. Shell (fish, ghostty, completions)
2. Terminal applications
3. Desktop environment (Niri, DankMaterialShell)
4. Development tools
5. AI tools
6. Applications

### Phase 3: Host Configuration
**Approach**: One host at a time, complete before moving to next

**Order**:
1. hetzner-vps (simplest, headless)
2. ovh-vps (copy of hetzner)
3. yoga (workstation, simpler hardware)
4. zephyrus (workstation, complex hardware)

### Phase 4: Testing & Refinement
**Tasks**:
- Build testing on each host
- Configuration validation
- Security audit
- Performance optimization
- Documentation updates

## TECHNICAL SPECIFICATIONS

### Flake Inputs (Required)
- `nixpkgs` - Stable channel
- `nixos-hardware` - Hardware-specific configs
- `home-manager` - User configuration management
- `niri-flake` - Niri window manager
- `dankmaterialshell` - Desktop environment
- `nix-ai-tools` - AI coding assistants
- `opnix` - 1Password integration
- `disko` - Declarative disk management

### File Naming Conventions
- **Modules**: kebab-case (e.g., `my-service.nix`)
- **Documentation**: kebab-case, matches module name (e.g., `my-service.md`)
- **Host directories**: lowercase, no special chars (e.g., `yoga`, `zephyrus`)
- **Profile directories**: kebab-case (e.g., `workstation`, `headless-server`)

### Import Conventions
- System modules: `../../modules/nixos/<category>/<name>.nix`
- Home-manager modules: `../../modules/home-manager/<category>/<name>.nix`
- Shared modules: `../../modules/shared/<name>.nix`
- Profiles: `../../profiles/<type>/<name>.nix`

### Module Structure Template
```nix
{ config, lib, pkgs, ... }:

{
  options = {
    services.my-service = {
      enable = lib.mkEnableOption "my-service";
      # additional options
    };
  };

  config = lib.mkIf config.services.my-service.enable {
    # configuration
  };
}
```

## AGENT GUIDELINES

### DO:
- Follow exact modular structure specified
- Create documentation alongside code
- Use relative imports
- Test builds before marking complete
- Research package names for NixOS compatibility
- Verify software versions are compatible
- Check for existing modules before creating new ones
- Document all TODO items in docs/todos/

### DON'T:
- Commit any secrets or hardcoded credentials
- Skip module documentation
- Create monolithic configuration files
- Mix concerns in a single module
- Assume hardware specs without verification
- Deploy to production hosts without testing builds
- Ignore NixOS-specific packaging differences

### VERIFICATION CHECKLIST:
Before marking any task complete:
- [ ] Code follows modular structure
- [ ] Module has documentation
- [ ] Imports are correct and relative
- [ ] No hardcoded secrets
- [ ] Build succeeds: `nixos-rebuild build .#<hostname>`
- [ ] Documentation updated
- [ ] Related TODO items marked complete

## CURRENT TODOS (FROM pantherOS.md)

**Hardware Discovery**:
- Research relevant hardware information per device
- Develop hardware scanning script
- Update hardware specs in pantherOS.md

**Secrets Management**:
- Research 1Password service account usage patterns
- Create secrets inventory
- Analyze and plan restructuring
- Update OpNix paths

**Security Research**:
- Tailscale ACLs and role-based access
- Best practices for solo developer infrastructure

**Package Research**:
- Verify Ghostty package name for NixOS
- Analyze developer workflow for additional tools
- Research language-specific NixOS configurations

**Modularization**:
- Research NixOS module best practices
- Translate system config to modules
- Research home-manager modularization

**Disk Configuration**:
- Determine optimal layouts per host
- Create disko.nix files

## SUCCESS CRITERIA

**Configuration is complete when**:
1. All 4 hosts build successfully
2. Hardware specs documented and optimized
3. All TODO items from pantherOS.md addressed
4. Modular structure followed throughout
5. Documentation complete and up-to-date
6. Security properly configured
7. All applications working
8. AI tools integrated and functional
9. Development shell auto-activates in ~/dev
10. Zero configuration drift between hosts

## CRITICAL WARNINGS

1. **No code without hardware specs** - Always scan hardware first
2. **Never commit secrets** - All secrets via 1Password/OpNix
3. **Test builds** - Never switch without building successfully
4. **Backup before switching** - Have recovery plan
5. **One host at a time** - Don't try to configure all simultaneously
6. **Firewall caution** - Never lock out SSH access
7. **NixOS npm** - Requires special handling, research before implementing

## EMERGENCY PROCEDURES

**If locked out of server**:
- Access via Tailscale from another device
- Use out-of-band console access (Hetzner/OVH web console)
- Physical access for workstations
- Rollback to previous generation: `nixos-rebuild switch --rollback`

**If system won't boot**:
- Select previous generation at GRUB menu
- Check logs: `journalctl -b-1`
- Hardware issue: boot from USB, chroot, fix config

---

**END OF BRIEF**

This brief contains the complete requirements for implementing pantherOS. Review all sections before beginning work. Follow phases in order. Verify completion criteria for each phase before proceeding.
