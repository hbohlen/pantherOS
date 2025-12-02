# Implementation Tasks: Refactor and Enhance Infrastructure

## 1. Module Structure Refactoring

### 1.1 DankMaterialShell Widgets Refactoring
- [ ] 1.1.1 Analyze current widgets.nix structure and identify logical groupings
- [ ] 1.1.2 Create `modules/desktop-shells/dankmaterial/widgets/` directory
- [ ] 1.1.3 Split into focused modules: system-monitoring.nix, media-controls.nix, network-status.nix, etc.
- [ ] 1.1.4 Update main widgets.nix to import split modules
- [ ] 1.1.5 Test that all widgets continue to function correctly

### 1.2 DankMaterialShell Services Refactoring
- [ ] 1.2.1 Analyze current services.nix structure and identify service categories
- [ ] 1.2.2 Create `modules/desktop-shells/dankmaterial/services/` directory
- [ ] 1.2.3 Split into focused modules: systemd-services.nix, background-tasks.nix, etc.
- [ ] 1.2.4 Update main services.nix to import split modules
- [ ] 1.2.5 Test that all services start correctly

### 1.3 OpenCode AI Dotfiles Refactoring
- [ ] 1.3.1 Analyze current opencode-ai.nix structure
- [ ] 1.3.2 Create `modules/home-manager/dotfiles/opencode/` directory
- [ ] 1.3.3 Split into logical sections: config.nix, agents.nix, workflows.nix, aliases.nix
- [ ] 1.3.4 Update main opencode-ai.nix to import split modules
- [ ] 1.3.5 Test OpenCode functionality

## 2. Hardware Detection Enhancement

### 2.1 Facter Data Integration
- [ ] 2.1.1 Create utility functions to parse facter.json files
- [ ] 2.1.2 Extract CPU information from facter.json into meta.nix
- [ ] 2.1.3 Extract GPU information from facter.json into meta.nix
- [ ] 2.1.4 Extract memory information from facter.json into meta.nix
- [ ] 2.1.5 Extract storage information from facter.json into meta.nix
- [ ] 2.1.6 Extract network information from facter.json into meta.nix

### 2.2 Hardware-Specific Optimizations
- [ ] 2.2.1 Create helper functions for CPU-based kernel module selection
- [ ] 2.2.2 Create helper functions for GPU-based driver configuration
- [ ] 2.2.3 Create helper functions for storage-based filesystem options
- [ ] 2.2.4 Document hardware detection patterns in meta.nix

### 2.3 Documentation
- [ ] 2.3.1 Document facter.json → meta.nix workflow
- [ ] 2.3.2 Create examples for adding new hardware configurations
- [ ] 2.3.3 Add comments explaining hardware-specific decisions

## 3. Terminal Multiplexer Integration

### 3.1 Zellij Configuration
- [ ] 3.1.1 Add zellij package to home-manager configuration
- [ ] 3.1.2 Create zellij default configuration file
- [ ] 3.1.3 Configure zellij keybindings for productivity
- [ ] 3.1.4 Configure zellij layout templates
- [ ] 3.1.5 Set up zellij autostart behavior (optional)

### 3.2 Shell Integration
- [ ] 3.2.1 Add zellij aliases to fish shell configuration
- [ ] 3.2.2 Configure fish shell to work seamlessly with zellij
- [ ] 3.2.3 Test zellij with existing terminal tools (fzf, eza)
- [ ] 3.2.4 Document zellij workflow and keybindings

### 3.3 Terminal Emulator Integration
- [ ] 3.3.1 Ensure zellij works correctly with ghostty
- [ ] 3.3.2 Configure terminal colors and theming for zellij
- [ ] 3.3.3 Test zellij session management

## 4. Enhanced Development Shell

### 4.1 Build and Test Tools
- [ ] 4.1.1 Add nixos-rebuild wrapper or helper scripts
- [ ] 4.1.2 Add nix-build utilities
- [ ] 4.1.3 Add test runners and validation tools
- [ ] 4.1.4 Add deployment utilities

### 4.2 NixOS Development Tools
- [ ] 4.2.1 Add nix-diff for comparing derivations
- [ ] 4.2.2 Add nix-info for system information
- [ ] 4.2.3 Add nix-index for package searching
- [ ] 4.2.4 Add nix-du for analyzing disk usage
- [ ] 4.2.5 Keep existing tools (nil, nixd, nixpkgs-fmt, etc.)

### 4.3 Code Quality Tools
- [ ] 4.3.1 Add statix for Nix linting
- [ ] 4.3.2 Add deadnix for dead code detection
- [ ] 4.3.3 Add shellcheck for shell script validation
- [ ] 4.3.4 Add pre-commit hooks framework (optional)

### 4.4 Documentation and Exploration
- [ ] 4.4.1 Add manix for Nix function documentation
- [ ] 4.4.2 Add nix-doc for inline documentation
- [ ] 4.4.3 Add documentation browser/viewer
- [ ] 4.4.4 Add quick reference guides

### 4.5 Developer Experience
- [ ] 4.5.1 Add welcome message with available commands
- [ ] 4.5.2 Add shell aliases for common tasks
- [ ] 4.5.3 Configure shell prompt for nix-shell detection
- [ ] 4.5.4 Add tab completion for nix commands

## 5. Testing and Validation

### 5.1 Module Refactoring Tests
- [ ] 5.1.1 Verify all refactored modules build successfully
- [ ] 5.1.2 Verify no functionality was lost in refactoring
- [ ] 5.1.3 Test on all affected hosts (zephyrus, yoga)

### 5.2 Hardware Detection Tests
- [ ] 5.2.1 Verify meta.nix correctly uses facter.json data
- [ ] 5.2.2 Test hardware-specific optimizations
- [ ] 5.2.3 Verify all hosts build with enhanced meta.nix

### 5.3 Integration Tests
- [ ] 5.3.1 Test zellij in various scenarios
- [ ] 5.3.2 Test devShell on all development machines
- [ ] 5.3.3 Verify all tools are available and functional

### 5.4 Documentation Tests
- [ ] 5.4.1 Review all documentation for accuracy
- [ ] 5.4.2 Test all documented workflows
- [ ] 5.4.3 Verify examples work as documented

## 6. Documentation

### 6.1 Code Documentation
- [ ] 6.1.1 Add comments to refactored modules
- [ ] 6.1.2 Document module organization patterns
- [ ] 6.1.3 Add examples for common patterns

### 6.2 User Documentation
- [ ] 6.2.1 Document zellij usage and workflows
- [ ] 6.2.2 Document devShell tools and utilities
- [ ] 6.2.3 Document hardware detection process
- [ ] 6.2.4 Create quick start guide for new developers

### 6.3 Developer Documentation
- [ ] 6.3.1 Document module refactoring guidelines
- [ ] 6.3.2 Document when to split vs keep modules together
- [ ] 6.3.3 Document hardware configuration best practices

## Acceptance Criteria

- ✅ All large modules (>250 lines) are split into focused components
- ✅ meta.nix files fully utilize facter.json hardware data
- ✅ Zellij is configured and integrated with shell/terminal
- ✅ devShell provides comprehensive development tooling
- ✅ All configurations build successfully
- ✅ No functionality is lost in refactoring
- ✅ Documentation is complete and accurate
