# OpenSpec Implementation Roadmap

This roadmap provides detailed micro-steps for implementing all OpenSpec change proposals in the correct dependency order.

## Phase 1: Foundation (No Dependencies)

### 1. create-modular-config ✅ COMPLETED
**Proposal**: [create-modular-config/proposal.md](openspec/changes/create-modular-config/proposal.md)

**Micro Steps**:
1. Create `/modules` directory in project root ✅
2. Create `modules/default.nix` with aggregator pattern ✅
3. Extract system packages to `modules/packages/` (core/dev submodules) ✅
4. Extract environment variables to `modules/environment/` ✅
5. Extract user configuration to `modules/users/` ✅
6. Update `hosts/servers/hetzner-vps/configuration.nix` to import modules ✅
7. Test build with `nix flake check` ✅
8. Test system build with `sudo nixos-rebuild build --flake .#hetzner-vps` ✅

### 2. add-home-manager-setup ✅ COMPLETED
**Proposal**: [add-home-manager-setup/proposal.md](openspec/changes/add-home-manager-setup/proposal.md)

**Micro Steps**:
1. Add `home-manager` flake input to `flake.nix` ✅
2. Configure `home-manager` module in `hosts/servers/hetzner-vps/configuration.nix` ✅
3. Set up basic home-manager user configuration for `hbohlen` ✅
4. Test build with `nix flake check` ✅
5. Test system build with `sudo nixos-rebuild build --flake .#hetzner-vps` ✅

## Phase 2: Server Tools (Depends on Phase 1)

### 3. add-terminal-tools ✅ COMPLETED
**Proposal**: [add-terminal-tools/proposal.md](openspec/changes/add-terminal-tools/proposal.md)
**Depends on**: add-home-manager-setup

**Micro Steps**:
1. Add `fzf`, `eza`, and `fish` packages via home-manager in user config ✅
2. Configure fish as default shell for `hbohlen` user ✅
3. Keep bash available for compatibility ✅
4. Test build with `nix flake check` ✅
5. Test system build with `sudo nixos-rebuild build --flake .#hetzner-vps` ✅
6. Verify fish shell works after rebuild ✅

### 4. add-nixvim-setup ✅ PARTIALLY COMPLETED
**Proposal**: [add-nixvim-setup/proposal.md](openspec/changes/add-nixvim-setup/proposal.md)

**Micro Steps**:
1. Add `nixvim` flake input to `flake.nix` ✅
2. Configure basic neovim installation ✅
3. Add `hardtime.nvim` and `precognition.nvim` as required plugins ⏳ (compatibility issues - to be resolved)
4. Add additional ADHD-friendly plugins (vim-tmux-navigator, vim-surround, etc.) ⏳ (compatibility issues - to be resolved)
5. Replace basic vim with neovim as default editor ✅
6. Test build with `nix flake check` ✅
7. Test system build with `sudo nixos-rebuild build --flake .#hetzner-vps` ✅
8. Verify `EDITOR` environment variable changed from `vim` to `nvim` ✅

**Note**: Basic neovim installation completed. Advanced nixvim configuration with plugins deferred due to compatibility issues with current nixvim version. Will be addressed in future update.

**Yoga Host Status**: ✅ Fully configured with nixos-facter-modules integration, ready for deployment.

### 5. add-opencode-ai ✅ COMPLETED
**Proposal**: [add-opencode-ai/proposal.md](openspec/changes/add-opencode-ai/proposal.md)

**Micro Steps**:
1. Add `nix-ai-tools` flake input to `flake.nix` ⏸️ (opencode available directly in nixpkgs)
2. Install `opencode` package via home-manager ✅
3. Make AI coding tool available in user environment ✅
4. Test build with `nix flake check` ✅
5. Test system build with `sudo nixos-rebuild build --flake .#hetzner-vps` ✅
6. Verify `opencode` command is available in PATH ✅

## Phase 3: Personal Device Infrastructure (Hardware Access Required)

### BLOCKER: Hardware Scanning Research & Setup ✅ COMPLETED
**Required before**: add-personal-device-hosts

**Research Steps**:
1. Research `facter` tool capabilities for NixOS hardware detection ✅
2. Study existing facter usage patterns in NixOS community ✅
3. Document hardware scanning workflow for zephyrus and yoga devices ✅
4. Create hardware scanning script/procedure ✅
5. Test facter on available hardware to validate approach ⏳ (requires hardware access)

**Findings**:
- **NixOS Facter**: Modern hardware detection tool (github:nix-community/nixos-facter)
- **NixOS Facter Modules**: Automatic hardware configuration (github:nix-community/nixos-facter-modules)
- **Workflow**: Generate JSON report → Use modules for auto-configuration
- **Script**: `scripts/scan-hardware.sh` created for automated scanning
- **Documentation**: `docs/hardware-scanning-workflow.md` created
- **Yoga Hardware Detected**: AMD Ryzen AI 7 350 (8 cores/16 threads), 16GB RAM, 2 disks, 2 network interfaces

**Implementation Steps**:
1. Run `sudo scripts/scan-hardware.sh zephyrus` on target device ⏳ (requires zephyrus access)
2. Run `sudo scripts/scan-hardware.sh yoga` on target device ✅ COMPLETED
3. Transfer generated JSON reports to project repository ✅ COMPLETED
4. Use nixos-facter-modules for automatic hardware configuration ✅ COMPLETED
5. Create host configurations in `hosts/zephyrus/` and `hosts/yoga/` ✅ COMPLETED (yoga done)

### 6. add-personal-device-hosts
**Proposal**: [add-personal-device-hosts/proposal.md](openspec/changes/add-personal-device-hosts/proposal.md)
**BLOCKED BY**: Hardware scanning completion

**Micro Steps** (after hardware scanning):
1. Create `/hosts/zephyrus/` directory structure
2. Create `/hosts/yoga/` directory structure
3. Generate `hardware.nix` from facter output for zephyrus
4. Generate `hardware.nix` from facter output for yoga
5. Create `disko.nix` partitioning configs for both devices
6. Create `meta.nix` files with hardware specifications
7. Update `flake.nix` to include new hosts (future step)
8. Test flake validity with `nix flake check`

## Phase 4: Personal Device Tools (Depends on Phase 3)

### 7. add-dank-material-shell
**Proposal**: [add-dank-material-shell/proposal.md](openspec/changes/add-dank-material-shell/proposal.md)
**Depends on**: add-personal-device-hosts

**Micro Steps**:
1. Add `dgop` and `DankMaterialShell` flake inputs with proper follows
2. Import DankMaterialShell homeModules in personal device configurations
3. Enable comprehensive DankMaterialShell configuration with feature toggles
4. Configure default settings and session management
5. Set up systemd auto-start and restart-on-change functionality
6. Enable plugin support for extensibility
7. Test build with `nix flake check`
8. Test system builds for zephyrus and yoga hosts

### 8. set-ghostty-as-default-terminal
**Proposal**: [set-ghostty-as-default-terminal/proposal.md](openspec/changes/set-ghostty-as-default-terminal/proposal.md)
**Depends on**: add-personal-device-hosts

**Micro Steps**:
1. Install `ghostty` package on personal device hosts
2. Configure ghostty as default terminal emulator
3. Ensure ghostty integrates with existing fish shell configuration
4. Keep existing terminal utilities available for compatibility
5. Test build with `nix flake check`
6. Test system builds for zephyrus and yoga hosts
7. Verify ghostty launches correctly on personal devices

### 9. add-zed-ide
**Proposal**: [add-zed-ide/proposal.md](openspec/changes/add-zed-ide/proposal.md)
**Depends on**: add-personal-device-hosts

**Micro Steps**:
1. Add Zed flake input to access latest version
2. Configure Zed installation via Home Manager for personal devices
3. Ensure Zed is available in user environment on personal devices
4. Test build with `nix flake check`
5. Test system builds for zephyrus and yoga hosts
6. Verify Zed launches and functions correctly

### 10. add-niri-window-manager
**Proposal**: [add-niri-window-manager/proposal.md](openspec/changes/add-niri-window-manager/proposal.md)
**Depends on**: add-dank-material-shell

**Micro Steps**:
1. Add `niri` flake input from `https://github.com/sodiboo/niri-flake`
2. Import Niri homeModules in personal device configurations
3. Enable Niri integration features in DankMaterialShell (enableKeybinds, enableSpawn)
4. Configure Niri as window manager on personal devices
5. Test build with `nix flake check`
6. Test system builds for zephyrus and yoga hosts
7. Verify Niri starts correctly with DankMaterialShell integration

## Currently Implemented Features (Specs Created)

Based on analysis of current configuration, these features are already implemented with corresponding spec files:

### [networking](openspec/specs/networking/spec.md)
- systemd-networkd configuration
- DHCP and IPv6 setup
- Firewall rules (SSH + Tailscale)

### [ssh-hardening](openspec/specs/ssh-hardening/spec.md)
- SSH daemon configuration
- Key-based authentication only
- Root login restrictions

### [secrets-management](openspec/specs/secrets-management/spec.md)
- 1Password OpNix integration
- Tailscale auth key management
- SSH key distribution

### [container-runtime](openspec/specs/container-runtime/spec.md)
- Podman setup with Docker compatibility
- Container networking configuration
- Subvolume optimization for containers

### [development-environment](openspec/specs/development-environment/spec.md)
- XDG base directory setup
- Language-specific cache configuration
- Development tool environment variables

## Validation Steps

After each phase:
1. Run `nix flake check` to validate flake syntax
2. Run `sudo nixos-rebuild build --flake .#hetzner-vps` to test build
3. For personal devices: `sudo nixos-rebuild build --flake .#zephyrus` and `.#yoga`
4. Test critical functionality after deployment
5. Document any issues or required adjustments

## Risk Mitigation

- **Breaking Changes**: nixvim changes EDITOR from vim to nvim
- **Hardware Dependencies**: Personal device features require physical access
- **Testing**: Always test builds before switching to new configurations
- **Rollbacks**: Keep previous working configurations available</content>
<parameter name="filePath">IMPLEMENTATION_ROADMAP.md