# PantherOS Terminal & Home Manager Implementation Roadmap

## Overview

This roadmap outlines the implementation of terminal packages (fzf, eza, fish), home-manager setup, opencode.ai integration, and modular configuration structure.

## Research Status ✅

All required packages and configurations have been verified:

- **fzf**: Available in nixpkgs 25.05 (v0.65.2)
- **eza**: Available in nixpkgs 25.05 (v0.23.1)
- **fish**: Available in nixpkgs 25.05 (v4.0.2)
- **opencode**: Available in numtide/nix-ai-tools (v1.0.106)
- **home-manager**: Standard Nix tool, integration patterns known

## Dependency Analysis

### Critical Dependencies

1. **Flake inputs must be added first** - home-manager and nix-ai-tools inputs required
2. **System-level home-manager config** - Must be configured before user packages
3. **Package availability** - All packages must be installed before configuration
4. **Directory structure** - /modules folder must exist before creating modules

### Implementation Sequence Requirements

```
Flake Inputs → System Config → User Packages → Shell Setup → Modules
```

## Implementation Tasks

### Phase 1: Flake Infrastructure

**Status**: Ready for implementation
**Dependencies**: None
**Files**: `flake.nix`

#### Task 1.1: Add home-manager input

- **Action**: Add home-manager input to flake.nix
- **Source**: <https://github.com/nix-community/home-manager>
- **Verification**: `nix flake check` passes
- **Risk**: Low - standard flake input addition

#### Task 1.2: Add nix-ai-tools input

- **Action**: Add numtide/nix-ai-tools input to flake.nix
- **Source**: <https://github.com/numtide/nix-ai-tools>
- **Verification**: `nix flake check` passes
- **Risk**: Low - standard flake input addition

#### Task 1.3: Update flake outputs

- **Action**: Configure home-manager in nixosConfigurations
- **Dependencies**: Tasks 1.1, 1.2 complete
- **Verification**: `nix flake check` passes
- **Risk**: Medium - affects system configuration structure

### Phase 2: System Configuration

**Status**: Ready for implementation
**Dependencies**: Phase 1 complete
**Files**: `hosts/servers/hetzner-vps/configuration.nix`

#### Task 2.1: Import home-manager module

- **Action**: Add home-manager.nixosModules.home-manager to imports
- **Source**: Home Manager manual
- **Verification**: `nixos-rebuild build` succeeds
- **Risk**: Low - standard module import

#### Task 2.2: Configure home-manager

- **Action**: Add home-manager.users.hbohlen configuration block
- **Dependencies**: Task 2.1 complete
- **Verification**: `nixos-rebuild build` succeeds
- **Risk**: Medium - user configuration setup

### Phase 3: Terminal Packages

**Status**: Ready for implementation
**Dependencies**: Phase 2 complete
**Files**: `hosts/servers/hetzner-vps/configuration.nix` (home-manager section)

#### Task 3.1: Add fzf package

- **Action**: Add fzf to home-manager.packages
- **Source**: nixpkgs.fzf
- **Verification**: `fzf --version` works in user shell
- **Risk**: Low - standard package addition

#### Task 3.2: Add eza package

- **Action**: Add eza to home-manager.packages
- **Source**: nixpkgs.eza
- **Verification**: `eza --version` works in user shell
- **Risk**: Low - standard package addition

#### Task 3.3: Add fish package

- **Action**: Add fish to home-manager.packages
- **Source**: nixpkgs.fish
- **Verification**: `fish --version` works in user shell
- **Risk**: Low - standard package addition

### Phase 4: Shell Configuration

**Status**: Ready for implementation
**Dependencies**: Phase 3 complete
**Files**: `hosts/servers/hetzner-vps/configuration.nix` (home-manager section)

#### Task 4.1: Set fish as default shell

- **Action**: Configure home-manager to set fish as shell
- **Dependencies**: Task 3.3 complete
- **Verification**: `echo $SHELL` shows fish path
- **Risk**: Medium - shell change affects user experience

#### Task 4.2: Keep bash compatibility

- **Action**: Ensure bash remains available for compatibility
- **Source**: Keep bash in system packages
- **Verification**: `bash --version` works
- **Risk**: Low - bash already in system packages

### Phase 5: AI Tools Integration

**Status**: Ready for implementation
**Dependencies**: Phase 1 complete
**Files**: `hosts/servers/hetzner-vps/configuration.nix` (home-manager section)

#### Task 5.1: Add opencode package

- **Action**: Add opencode from nix-ai-tools to home-manager.packages
- **Source**: inputs.nix-ai-tools.packages.${pkgs.system}.opencode
- **Dependencies**: Task 1.2 complete
- **Verification**: `opencode --version` works
- **Risk**: Low - standard package addition

### Phase 6: Module Structure

**Status**: Ready for implementation
**Dependencies**: None (can be done in parallel)
**Files**: New module files

#### Task 6.1: Create /modules directory

- **Action**: Create modules/ directory in project root
- **Verification**: Directory exists
- **Risk**: Low - directory creation

#### Task 6.2: Create default.nix aggregator

- **Action**: Create modules/default.nix to import all modules
- **Source**: Follow default.nix exporting pattern from AGENTS.md
- **Verification**: File exists and is valid Nix
- **Risk**: Low - standard Nix file creation

#### Task 6.3: Create fish.nix module

- **Action**: Extract fish configuration into modules/fish.nix
- **Source**: Follow atomic granularity rules from AGENTS.md
- **Dependencies**: Phase 4 complete
- **Verification**: Module loads without errors
- **Risk**: Medium - configuration refactoring

#### Task 6.4: Create terminal-tools.nix module

- **Action**: Extract fzf/eza configuration into modules/terminal-tools.nix
- **Source**: Follow single-purpose rule from AGENTS.md
- **Dependencies**: Phase 3 complete
- **Verification**: Module loads without errors
- **Risk**: Medium - configuration refactoring

#### Task 6.5: Create home.nix module

- **Action**: Extract home-manager base config into modules/home.nix
- **Source**: Follow atomic granularity rules
- **Dependencies**: Phase 2 complete
- **Verification**: Module loads without errors
- **Risk**: Medium - configuration refactoring

### Phase 7: Integration & Testing

**Status**: Ready for implementation
**Dependencies**: All phases complete
**Files**: All modified files

#### Task 7.1: Update configuration.nix imports

- **Action**: Import modules from ./modules in configuration.nix
- **Dependencies**: Phase 6 complete
- **Verification**: `nixos-rebuild build` succeeds
- **Risk**: High - affects entire system configuration

#### Task 7.2: Full system build test

- **Action**: Run complete build and switch
- **Verification**: `sudo nixos-rebuild switch` succeeds
- **Risk**: High - system activation

#### Task 7.3: User environment verification

- **Action**: Test all installed packages and shell
- **Verification**: All tools work in user session
- **Risk**: Low - testing only

## Risk Assessment

### High Risk Tasks

- **Task 7.1**: Configuration refactoring - could break system
- **Task 7.2**: System activation - could affect running system

### Medium Risk Tasks

- **Task 1.3**: Flake outputs change - affects build system
- **Task 2.2**: Home-manager user config - affects user environment
- **Task 4.1**: Shell change - affects user interaction
- **Tasks 6.3-6.5**: Module refactoring - configuration changes

### Low Risk Tasks

- **Tasks 1.1, 1.2**: Input additions - standard Nix operations
- **Tasks 2.1, 3.1-3.3, 5.1**: Package additions - isolated changes
- **Task 4.2**: Bash compatibility - already exists
- **Task 6.1, 6.2**: Directory/file creation - no system impact

## Verification Commands

### Per-Task Verification

- **Flake changes**: `nix flake check`
- **Build tests**: `sudo nixos-rebuild build --flake .#hetzner-vps`
- **Package tests**: `fzf --version`, `eza --version`, `fish --version`, `opencode --version`
- **Shell test**: `echo $SHELL` (after login)
- **Module tests**: `nix-instantiate ./modules/default.nix`

### Full System Test

```bash
# Build test
sudo nixos-rebuild build --flake .#hetzner-vps

# Dry run activation
sudo nixos-rebuild dry-activate --flake .#hetzner-vps

# Full activation (only after successful dry run)
sudo nixos-rebuild switch --flake .#hetzner-vps
```

## Rollback Plan

### Immediate Rollback

- **Flake changes**: Revert flake.nix to previous commit
- **Config changes**: Revert configuration.nix to previous commit

### Emergency Recovery

- **Boot from previous generation**: GRUB menu → select previous NixOS version
- **Command line recovery**: Boot with `systemd.unit=emergency.target`

## Success Criteria

### Functional Requirements

- [ ] Fish shell is default for hbohlen user
- [ ] Bash remains available for compatibility
- [ ] fzf, eza, fish, opencode commands work
- [ ] System builds successfully
- [ ] User environment loads correctly

### Quality Requirements

- [ ] Follows AGENTS.md micro-step rules
- [ ] Uses atomic granularity for modules
- [ ] Maintains declarative configuration
- [ ] Includes proper documentation links
- [ ] Passes all verification checks

## Implementation Notes

### Code Snippet Research Status

- **home-manager integration**: Standard patterns known
- **Fish shell configuration**: Standard home-manager options
- **Module structure**: Follows AGENTS.md patterns
- **Package declarations**: All packages verified in nixpkgs

### No Additional Research Required

All implementation details are available from:

- NixOS manual
- Home Manager manual
- AGENTS.md guidelines
- Verified package availability

### Timeline Estimate

- **Phase 1-2**: 30 minutes (infrastructure)
- **Phase 3-5**: 45 minutes (packages & config)
- **Phase 6**: 60 minutes (module creation)
- **Phase 7**: 30 minutes (integration & testing)
- **Total**: ~3 hours for complete implementation</content>
  <parameter name="filePath">TERMINAL_IMPLEMENTATION_ROADMAP.md
