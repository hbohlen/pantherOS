# ROG Zephyrus → NixOS Migration Plan

**verificationStatus**: pending

## Overview
Convert the CachyOS ROG Zephyrus optimization context into a declarative NixOS configuration targeting a workstation laptop. This plan respects the existing flake.nix structure and AGENTS.md guidelines.

## Critical Questions (Blocking)

Before proceeding with implementation, the following must be clarified:

1. **Hardware Model**: The context states "ASUS ROG Zephyrus (model TBD)". Which specific model?
   - Needed for: ASUS/ROG BIOS/firmware integration, GPU detection, thermal profiles
   - Sources: Device specs, `dmidecode`, `lspci` output

2. **GPU Configuration**: Is this a hybrid (Intel iGPU + NVIDIA dGPU) system?
   - Needed for: `supergfxctl` support, CUDA availability, power profiles
   - Impacts: module structure, optional dependencies

3. **1Password Licensing**: Is 1Password available via your account?
   - Note: Home Manager and NixOS have limited 1Password support (CLI/agents mostly)
   - Impacts: Installation method, secret management approach

4. **Secrets Management Strategy**: Which approach for development secrets?
   - Options: `agenix`, `sops-nix`, `1password-cli` with service accounts, or manual env vars
   - Impacts: Module design for authentication and development env

5. **Desktop Session Target**: Confirm Niri as primary display server?
   - Note: Niri is still maturing; fallback plan needed?
   - Needed for: loginctl/session configuration, compatibility testing

## Architecture Overview

```
hosts/
├── zephyrus/                    # New ROG Zephyrus laptop config
│   ├── default.nix              # Main host entry point
│   ├── hardware.nix             # Hardware detection (ASUS, ROG, SSD layout)
│   └── zephyrus-facter.json     # Hardware manifest (from nixos-facter)
│
home/modules/                     # User-level configurations
├── power-management/             # Laptop power profiles and AC/battery detection
│   ├── default.nix
│   ├── power-profiles.nix
│   └── asus-ctl.nix
│
├── shell/                        # Fish shell, Fisher, plugins
│   ├── default.nix
│   ├── fish.nix                 # Enable and basic config
│   ├── fish-plugins.nix         # Fisher plugins/extensions
│   └── fish-settings.nix        # Aliases, functions, environment
│
├── desktop/                      # Niri, DMS, theming, compositor
│   ├── default.nix
│   ├── niri.nix                 # Compositor configuration
│   ├── dms.nix                  # DankMaterialShell
│   ├── theming.nix              # Material Design, matugen
│   └── services.nix             # Systemd user services (cliphist, etc)
│
├── development/                  # Dev tools, containers, version control
│   ├── default.nix
│   ├── podman.nix               # Rootless containers
│   ├── git.nix                  # Git + 1Password SSH integration
│   └── tools.nix                # Language tools, CLI utilities
│
├── security/                     # 1Password, SSH, PolicyKit, GPG
│   ├── default.nix
│   ├── one-password.nix         # 1Password CLI + daemon integration
│   └── polkit.nix               # mate-polkit (PolicyKit agent)
│
└── storage/                      # BTRFS, TRIM, I/O schedulers
    ├── default.nix
    └── ssd-optimization.nix     # Declared via NixOS modules
│
modules/
├── hardware/                     # NixOS-level hardware configuration
│   └── asus-rog.nix             # ROG-specific hardware modules
│
└── desktop-environment/          # System-level desktop/compositor setup
    ├── niri-system.nix
    └── dms-system.nix
```

## Micro-Steps (Implementation Order)

### Phase 1: Hardware & Foundation
- **Step 1.1**: Create `hosts/zephyrus/hardware.nix` with ASUS ROG detection
- **Step 1.2**: Create `hosts/zephyrus/default.nix` main host configuration
- **Step 1.3**: Add zephyrus configuration to flake.nix outputs
- **Verification**: `nix flake check`, `nix build .#nixosConfigurations.zephyrus.config.system.build.toplevel --dry-run`

### Phase 2: System-Level Services & Storage
- **Step 2.1**: Create `modules/hardware/asus-rog.nix` (power management, ASUS utilities)
- **Step 2.2**: Create storage/BTRFS configuration in host default.nix (via fileSystems, boot settings)
- **Step 2.3**: Enable power-profiles-daemon and basic AC/battery detection
- **Verification**: `nixos-rebuild build` (after Step 1.3), check if rebuild succeeds

### Phase 3: Home-Manager User Configuration
- **Step 3.1**: Create `home/modules/power-management/` (systemd user services, battery thresholds)
- **Step 3.2**: Create `home/modules/shell/` (Fish, Fisher, plugins)
- **Step 3.3**: Create `home/modules/security/` (1Password CLI, mate-polkit integration)
- **Step 3.4**: Create `home/modules/development/` (Podman, Git, language tools)
- **Verification**: Build home-manager config: `home-manager build`

### Phase 4: Desktop Environment
- **Step 4.1**: Create `home/modules/desktop/niri.nix` (Wayland compositor)
- **Step 4.2**: Create `home/modules/desktop/dms.nix` (DankMaterialShell)
- **Step 4.3**: Create `home/modules/desktop/theming.nix` (Material Design, matugen)
- **Verification**: Dry-run home-manager, confirm no eval errors

### Phase 5: Integration & System Build
- **Step 5.1**: Enable home-manager in host default.nix
- **Step 5.2**: Test full system build with `nixos-rebuild build`
- **Step 5.3**: Create verification scripts for each domain (hardware, power, shell, desktop, dev)
- **Verification**: Full system build passes, verification scripts present

## Key Module Decisions

### Power Management
- **System-level**: `power-profiles-daemon` (NixOS service)
- **ASUS ROG**: `asusctl` package + udev rules for platform access
- **TODO**: Verify `asusctl` NixOS module availability. If not, manual systemd service wrapping needed.
- **User-level**: Systemd user service to monitor battery and trigger profile switching
- **Source**: [NixOS Manual - Power Management](https://nixos.org/manual/nixos/stable/#ch-power-management)

### Storage Configuration
- **Approach**: Declared via `fileSystems` in hardware.nix + boot.kernelParams for I/O scheduler
- **BTRFS Subvolumes**: Mount via explicit entries (not auto-managed by disko at this stage)
- **TRIM/Discard**: Enable via `discard` option in fileSystems
- **I/O Scheduler**: Set to `mq-deadline` or `none` via boot parameters
- **Source**: [NixOS Manual - File Systems](https://nixos.org/manual/nixos/stable/#sec-file-systems)

### Shell (Fish)
- **Approach**: Modular home-manager configuration (fish.nix, fish-plugins.nix, fish-settings.nix)
- **Fisher**: Declaratively installed via home-manager's `programs.fish.plugins`
- **Cleanup**: ZSH removal is implicit (not declaring zsh programs, home-manager handles cleanup on rebuild)
- **Source**: [Home Manager Manual - Fish](https://nix-community.github.io/home-manager/options.html#opt-programs.fish.enable)

### Desktop Environment
- **Niri**: Already in flake.nix inputs; enable via modules
- **DMS + Quickshell**: Already in flake.nix; wire via home-manager
- **Theming**: `matugen` for dynamic color generation, declared in home-manager
- **Systemd User Services**: `cliphist`, `dgop` as user services
- **Source**: 
  - [Niri Documentation](https://github.com/sodiboo/niri)
  - [DankMaterialShell Repo](https://github.com/AvengeMedia/DankMaterialShell)

### 1Password Integration
- **Limitation**: NixOS Home Manager has no first-class 1Password support (unlike macOS/Homebrew)
- **Approach**: Install via `_1password` package + manual systemd service wrapper for SSH agent
- **TODO**: Confirm `_1password` package availability and licensing requirements
- **Secrets Strategy**: Use environment variables or agenix for CI/development secrets (not 1Password directly in NixOS)
- **Source**: [1Password CLI Docs](https://developer.1password.com/docs/cli), [NixOS Packaging](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/misc/1password/default.nix)

### Security (PolicyKit)
- **Approach**: Declare `polkit.enable = true` + `mate-polkit` as system package
- **Removal of other polkit agents**: Implicit (only mate-polkit declared)
- **Source**: [NixOS Manual - Security](https://nixos.org/manual/nixos/stable/#ch-security)

### Development Environment
- **Podman**: Enable via NixOS module + home-manager user rootless setup
- **Git**: Configure via home-manager with 1Password SSH agent integration
- **AUR Access**: Not directly supported in NixOS (design choice to avoid binary caching issues)
  - **Alternative**: Use `nix-community/NUR`, overlays, or custom packages for equivalent tools
- **Source**: [NixOS Manual - Podman](https://nixos.org/manual/nixos/stable/#sec-container-podman)

## Decisions Not Yet Made (TODOs)

1. **ASUS Hardware Module**: Does `asusctl` have a NixOS module, or do we need custom systemd service wrapping?
2. **Disko Integration**: Should storage layout be managed via disko, or stay in hardware.nix fileSystems?
3. **Secrets Management**: Which strategy for 1Password service accounts + dev secrets? (agenix, sops-nix, or raw 1Password CLI?)
4. **Ghostty Terminal**: Package availability in nixpkgs?
5. **Dual-GPU Management**: If ROG Zephyrus has hybrid GPU, which NixOS module for `supergfxctl`?

## Expected Deliverables

1. ✅ `hosts/zephyrus/default.nix` – Main host configuration
2. ✅ `hosts/zephyrus/hardware.nix` – Hardware detection and BTRFS/SSD config
3. ✅ `home/modules/power-management/` – Battery/AC profiles, ASUS integration
4. ✅ `home/modules/shell/` – Fish, Fisher, plugins
5. ✅ `home/modules/security/` – 1Password, mate-polkit
6. ✅ `home/modules/development/` – Podman, Git, language tools
7. ✅ `home/modules/desktop/` – Niri, DMS, theming, user services
8. ✅ Flake.nix updated with zephyrus configuration
9. ✅ Verification scripts (bash/nix) for each domain
10. ✅ Documentation: migration guide, rollback procedures, known limitations

## Known Risks & Mitigation

| Risk                                     | Impact                           | Mitigation                                                               |
| ---------------------------------------- | -------------------------------- | ------------------------------------------------------------------------ |
| Niri compositor immature                 | Session crashes, display issues  | Have fallback to Gnome/KDE ready; test in dry-run first                  |
| ASUS hardware detection fails            | Power management non-functional  | Manual udev rules fallback; hardware inventory script for diagnosis      |
| 1Password licensing/availability         | SSH agent integration breaks     | Use agenix or sops-nix; document alternative auth flow                   |
| Disko incompatibility with BTRFS subvols | Cannot partition/mount correctly | Stay with manual fileSystems config; use disko only if explicitly needed |
| CUDA/GPU driver conflicts                | System fails to build            | Keep CUDA optional via overlay; use `buildInputs` conditionally          |

## Approval Checkpoint

**Before proceeding to implementation:**

1. Answer the 5 blocking questions above
2. Confirm hardware model and desired secrets management strategy
3. Review and approve the overall architecture
4. Confirm expected deliverables match requirements

---

**Once approved**, implementation will proceed in ordered micro-steps with verification at each phase.
