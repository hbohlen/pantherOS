# Change: Set Ghostty as Default Terminal on Personal Devices

## Why

Ghostty is a fast, native, feature-rich terminal emulator that provides modern terminal features and better performance compared to traditional terminal emulators. Setting it as the sole terminal on personal devices (zephyrus and yoga) will provide a consistent, high-performance terminal experience for development work while maintaining compatibility with existing workflows.

## What Changes

- Install ghostty package on personal device hosts (zephyrus and yoga)
- Configure ghostty as the default terminal emulator
- Ensure ghostty integrates properly with the existing fish shell configuration
- Keep existing terminal utilities (fzf, eza) available for compatibility

## Impact

- Affected specs: terminal-emulator (new capability)
- Affected code: hosts/zephyrus/default.nix and hosts/yoga/default.nix (add ghostty package and configuration)
- Dependencies: Requires personal-device-hosts setup to be completed first
- No impact on server configurations (hetzner-vps remains unchanged)</content>
  <parameter name="filePath">openspec/changes/set-ghostty-as-default-terminal/proposal.md
