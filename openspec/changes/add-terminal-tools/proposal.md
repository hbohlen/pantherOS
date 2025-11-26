# Change: Add Terminal Tools

## Why
Users need modern terminal utilities for efficient development workflows. fzf provides fuzzy finding, eza offers enhanced file listing, and fish provides a user-friendly shell experience.

## What Changes
- Add fzf, eza, and fish packages via home-manager
- Configure fish as the default shell for hbohlen user
- Keep bash available for compatibility

## Impact
- Affected specs: terminal-tools (new capability)
- Affected code: hosts/servers/hetzner-vps/configuration.nix (home-manager section)
- Dependencies: Requires home-manager-setup to be completed first</content>
<parameter name="filePath">openspec/changes/add-terminal-tools/proposal.md