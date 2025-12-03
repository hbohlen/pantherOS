# OpenSpec Implementation Plan

_Generated: Thu Nov 27 2025_

## Executive Summary

This plan analyzes the current state of the pantherOS OpenSpec specifications and provides a prioritized roadmap for implementing the remaining change proposals. The analysis reveals that 8 core specifications are implemented, 4 are partially implemented, and 6 change proposals require full implementation.

**Current Status:**

- ✅ **Implemented:** 8 specs (ai-tools, container-runtime, development-environment, networking, secrets-management, ssh-hardening)
- ⚠️ **Partially Implemented:** 4 specs (home-manager, neovim, terminal-tools, configuration)
- ❌ **Not Implemented:** 6 change proposals (dank-material-shell, niri-window-manager, nixvim-setup, opencode-ai, personal-device-hosts, zed-ide, modular-config, ghostty-terminal)

**Key Blockers:** Hardware scanning (zephyrus), Zed source build, dependency chains

---

## Current Implementation Status

### ✅ Fully Implemented Specifications

1. **Container Runtime** - Podman with Docker compatibility
2. **Development Environment** - XDG compliance, language cache optimization
3. **Networking** - systemd-networkd with firewall rules
4. **Secrets Management** - 1Password OpNix integration
5. **SSH Hardening** - Key-based authentication only
6. **AI Tools** - OpenCode.ai (via nix-ai-tools input)

### ⚠️ Partially Implemented Specifications

7. **Home Manager** - Basic setup exists but incomplete
8. **Neovim** - Basic neovim installed, nixvim input exists but not configured
9. **Terminal Tools** - fzf, eza, fish installed but not modularized
10. **Configuration** - Basic modules structure exists but incomplete

### ❌ Not Implemented Change Proposals

1. **DankMaterialShell** - Modern material design shell
2. **Niri Window Manager** - Scrollable-tiling Wayland window manager
3. **Zed IDE** - High-performance code editor
4. **Ghostty Terminal** - Fast terminal emulator for personal devices
5. **Personal Device Hosts** - zephyrus and yoga configurations
6. **Modular Configuration** - Complete module system

---

## Implementation Priority Matrix

### Tier 1: Critical Infrastructure (Must Fix First)

#### 1.1 Complete Personal Device Hosts Configuration

**Status:** 🔴 BLOCKED | **Dependencies:** Hardware scanning with facter

**Blocker Details:**

- zephyrus hardware scan required using `nix-shell -p facter --run "facter --json"`
- Create `meta.nix` files for both zephyrus and yoga
- Generate `hardware.nix` and `disko.nix` based on facter data

**Implementation Steps:**

1. Run facter on zephyrus device (requires physical access)
2. Generate `/hosts/zephyrus/meta.nix` from facter output
3. Create `/hosts/zephyrus/hardware.nix` and `disko.nix`
4. Verify yoga configuration completeness (appears partially done)
5. Enable zephyrus in flake.nix (currently commented out)
6. Test flake builds for both personal devices

**Files to Create/Modify:**

- `/hosts/zephyrus/meta.nix` (NEW)
- `/hosts/zephyrus/hardware.nix` (NEW)
- `/hosts/zephyrus/disko.nix` (NEW)
- `/hosts/zephyrus/default.nix` (NEW)
- `flake.nix` (uncomment zephyrus configuration)

#### 1.2 Complete nixvim Implementation

**Status:** 🟡 READY | **Dependencies:** None

**Current State:** nixvim input exists in flake.nix but not used in configurations

**Implementation Steps:**

1. Remove basic neovim from home.packages
2. Configure nixvim with plugins: hardtime, precognition, which-key, flash, gitsigns, todo-comments, trouble
3. Test hardtime and precognition plugins specifically for ADHD-friendly workflow
4. Verify EDITOR environment variable correctly points to nvim

**Files to Modify:**

- `hosts/servers/hetzner-vps/default.nix`
- `modules/environment/default.nix` (update EDITOR variables)

#### 1.3 Complete Modular Configuration Structure

**Status:** 🟡 READY | **Dependencies:** None

**Current State:** Basic module structure exists but host configs don't fully use it

**Implementation Steps:**

1. Create `modules/terminal-tools/default.nix` (fzf, eza, fish configuration)
2. Create `modules/home-manager/default.nix` (home-manager integration)
3. Update `hosts/servers/hetzner-vps/default.nix` to import modules instead of inline config
4. Move terminal tools from home.packages to terminal-tools module
5. Test configuration builds successfully

**Files to Create:**

- `modules/terminal-tools/default.nix` (NEW)
- `modules/home-manager/default.nix` (NEW)

### Tier 2: Personal Device Enhancements (High Value)

#### 2.1 Implement DankMaterialShell Configuration

**Status:** 🟡 READY | **Dependencies:** Personal device hosts completion

**Current State:** Proposal exists but not implemented

**Implementation Steps:**

1. Add `dgop` and `DankMaterialShell` flake inputs with follows configuration
2. Import DankMaterialShell modules in zephyrus and yoga configs
3. Enable comprehensive DankMaterialShell with feature toggles
4. Configure system monitoring, clipboard, VPN, brightness controls
5. Set up systemd auto-start functionality

**Files to Modify:**

- `flake.nix` (add inputs)
- `hosts/zephyrus/default.nix` (NEW)
- `hosts/yoga/default.nix` (MODIFY)

#### 2.2 Set Ghostty as Default Terminal on Personal Devices

**Status:** 🟡 READY | **Dependencies:** Personal device hosts completion

**Current State:** Proposal exists but not implemented

**Implementation Steps:**

1. Add ghostty package to personal device configurations
2. Configure ghostty as default terminal emulator
3. Verify integration with existing fish shell configuration
4. Ensure compatibility with existing terminal utilities

**Files to Modify:**

- `hosts/zephyrus/default.nix` (NEW)
- `hosts/yoga/default.nix` (MODIFY)

#### 2.3 Implement Niri Window Manager

**Status:** 🟡 READY | **Dependencies:** DankMaterialShell completion

**Current State:** Proposal exists but not implemented

**Implementation Steps:**

1. Add `niri` flake input from https://github.com/sodiboo/niri-flake
2. Configure Niri as window manager on personal devices
3. Enable DankMaterialShell Niri integration features
4. Test keyboard-driven workflow functionality

**Files to Modify:**

- `flake.nix` (add input)
- `hosts/zephyrus/default.nix` (MODIFY)
- `hosts/yoga/default.nix` (MODIFY)

### Tier 3: Additional Tools (Nice to Have)

#### 3.1 Implement Zed IDE

**Status:** 🔴 BLOCKED | **Dependencies:** Zed source build success

**Blocker Details:** Zed must be successfully built from source before installation

**Implementation Steps:**

1. Research Zed NixOS packaging status
2. Attempt Zed source build and resolve any issues
3. Add Zed configuration to personal devices only
4. Test Zed launches and basic functionality

**Priority:** Low (alternative editors available)

---

## Dependency Analysis

### Critical Dependencies

```
Hardware Scanning → Personal Device Hosts → DankMaterialShell → Niri
                      ↓
               Ghostty Terminal
```

### Non-Critical Dependencies

```
nixvim → Complete (independent)
Modular Config → Complete (independent)
Zed IDE → BLOCKED by build issues
```

---

## Risk Assessment

### High Risk Items

1. **Hardware Scanning Failure** - Cannot complete zephyrus configuration without device access
2. **Zed Build Issues** - Uncertain build success, may require significant troubleshooting

### Medium Risk Items

1. **Module Integration Complexity** - May encounter import/dependency issues when modularizing
2. **DankMaterialShell Configuration** - Complex multi-component system, may need iterative tuning

### Low Risk Items

1. **nixvim Setup** - Well-documented, low complexity
2. **Terminal Tools** - Simple package additions

---

## Resource Requirements

### Time Estimates

- **Hardware Scanning:** 2-4 hours (includes device setup and facter execution)
- **nixvim Implementation:** 1-2 hours
- **Modular Configuration:** 2-3 hours
- **Personal Device Hosts:** 3-4 hours (per device)
- **DankMaterialShell:** 4-6 hours (complex multi-component setup)
- **Niri Window Manager:** 2-3 hours
- **Ghostty Terminal:** 1 hour
- **Zed IDE:** Variable (build-dependent)

### Pre-requisites

- Access to zephyrus device for hardware scanning
- Familiarity with NixOS flake development
- Understanding of home-manager and nixvim configuration patterns

---

## Implementation Order Recommendation

1. **Phase 1: Foundation (Week 1)**
   - Complete nixvim implementation
   - Complete modular configuration structure
   - Begin personal device hosts (schedule hardware scanning)

2. **Phase 2: Personal Devices (Week 2)**
   - Complete hardware scanning for zephyrus
   - Implement personal device host configurations
   - Deploy DankMaterialShell to personal devices

3. **Phase 3: Desktop Environment (Week 3)**
   - Configure Ghostty terminal on personal devices
   - Implement Niri window manager
   - Test complete personal device workflow

4. **Phase 4: Enhancement (Week 4)**
   - Attempt Zed IDE implementation (if build succeeds)
   - Final validation and testing
   - Documentation updates

---

## Success Criteria

### Technical Validation

- [ ] All configurations build successfully with `nix flake check`
- [ ] Personal device hosts deploy without errors
- [ ] nixvim plugins function as expected (hardtime, precognition, etc.)
- [ ] DankMaterialShell auto-starts and key features work
- [ ] Niri window manager provides keyboard-driven workflow

### Functional Validation

- [ ] Development environment provides ADHD-friendly workflow
- [ ] Terminal tools (fzf, eza, fish) work seamlessly
- [ ] AI tools (OpenCode) integrate properly
- [ ] Container runtime maintains Docker compatibility
- [ ] Security configurations (SSH, firewall) remain effective

### Documentation Requirements

- [ ] Update AGENTS.md with implementation status
- [ ] Create deployment guides for personal devices
- [ ] Document any breaking changes for users
- [ ] Update OpenSpec project.md with completion status

---

## Notes and Considerations

### Breaking Changes

- EDITOR environment variable changes from `vim` to `nvim` (minimal impact)
- Fish becomes default shell (bash remains available)
- Personal device users will see significant desktop environment changes

### Backward Compatibility

- Server configurations (hetzner-vps, ovh-vps) remain stable
- Existing development workflows continue to function
- SSH and security configurations unchanged

### Future Considerations

- Plan for additional personal device integrations
- Consider automation for hardware scanning
- Evaluate additional AI tools as they become available

---

_This plan should be updated as implementation progresses and dependencies are resolved._
