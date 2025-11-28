# Change: Add Zed IDE

## Why

Zed is a high-performance, multiplayer code editor that provides a modern development experience. Adding Zed to personal devices will give users access to a fast, feature-rich editor for coding tasks while maintaining the existing terminal-based workflow.

## What Changes

- Add Zed as a flake input to access the latest version
- Configure Zed installation via Home Manager for personal devices (zephyrus and yoga)
- Ensure Zed is available in the user environment on personal devices
- **BLOCKER**: Zed must be successfully built from source before it can be installed

## Impact

- Affected specs: development-tools (new capability)
- Affected code: flake.nix (new input), home-manager user configuration
- Adds Zed IDE to personal devices without affecting server configurations</content>
  <parameter name="filePath">openspec/changes/add-zed-ide/proposal.md
