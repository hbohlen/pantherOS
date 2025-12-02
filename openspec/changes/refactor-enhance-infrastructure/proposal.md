# Change: Refactor and Enhance Infrastructure

## Why

The codebase has grown organically and now requires refactoring to improve maintainability and add missing capabilities:

1. **Module Size**: Several modules (widgets.nix: 407 lines, services.nix: 333 lines) have grown too large and need decomposition
2. **Hardware Detection**: facter.json files contain rich hardware data that isn't fully utilized in meta.nix configurations
3. **Terminal Multiplexing**: No terminal multiplexer configured, limiting developer productivity
4. **Development Shell**: Current devShell is minimal and lacks essential development tools
5. **Security Configuration**: 1Password configuration is inconsistent across hosts and not following official documentation patterns

## What Changes

- **Module Refactoring**: Break down large modules into smaller, focused components
  - Split `modules/desktop-shells/dankmaterial/widgets.nix` (407 lines) into focused widget modules
  - Split `modules/desktop-shells/dankmaterial/services.nix` (333 lines) into service-specific modules
  - Split `modules/home-manager/dotfiles/opencode-ai.nix` (275 lines) into logical sections
  - Consider splitting `modules/hardware/detection-scripts.nix` (263 lines) if appropriate

- **Hardware Detection Enhancement**: Integrate facter.json data into meta.nix files
  - Parse and utilize CPU, GPU, memory, storage, and network data from facter.json
  - Create reusable patterns for hardware-specific optimizations
  - Add documentation for hardware detection workflow

- **Terminal Multiplexer**: Add zellij as the default terminal multiplexer
  - Configure zellij with sensible defaults
  - Integrate with existing fish shell and terminal tools
  - Provide keyboard-driven workflow improvements

- **Enhanced DevShell**: Expand development shell with essential tools
  - Add build and test utilities
  - Add NixOS-specific development tools
  - Add code quality and linting tools
  - Add documentation and exploration tools

- **Security Standardization**: Standardize 1Password integration across personal devices
  - Create reusable security module following 1Password developer documentation
  - Apply consistent configuration to all personal devices (zephyrus, yoga)
  - Ensure proper polkit integration for system authentication

## Impact

- Affected specs: module-structure (new), hardware-detection (enhanced), terminal-multiplexer (new), development-shell (enhanced), security-integration (new)
- Affected code: 
  - `modules/desktop-shells/dankmaterial/` (refactoring)
  - `modules/home-manager/dotfiles/` (refactoring)
  - `modules/security/` (new - 1Password integration module)
  - `hosts/*/meta.nix` (enhancement)
  - `hosts/zephyrus/default.nix` (security standardization)
  - `hosts/yoga/default.nix` (security standardization)
  - `flake.nix` (devShell enhancement)
  - New module directories for decomposed components
- **BREAKING**: None - all changes maintain backward compatibility
- Improves code maintainability, security consistency, and developer experience
