# Change: Add Personal Device Hosts

## Why

To support personal devices (zephyrus and yoga) in the NixOS configuration, we need to create dedicated host configurations that can be deployed to these machines. This will enable consistent configuration management across all devices.

## What Changes

- Create `/hosts/zephyrus/` directory with `default.nix`, `disko.nix`, `hardware.nix`, and `meta.nix`
- Create `/hosts/yoga/` directory with `default.nix`, `disko.nix`, `hardware.nix`, and `meta.nix`
- **BLOCKER**: Hardware scanning with facter must be completed for both devices to generate `meta.nix` files before `hardware.nix` and `disko.nix` can be implemented
- Use facter from nixpkgs to automatically detect and structure hardware specifications
- Update flake.nix to include the new hosts (future change)

## Impact

- Affected specs: configuration (extended capability)
- Affected code: New host directories, potential flake.nix updates
- Adds support for personal device management without affecting existing server configurations</content>
  <parameter name="filePath">openspec/changes/add-personal-device-hosts/proposal.md
