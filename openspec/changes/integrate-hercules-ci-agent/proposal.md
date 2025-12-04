# Change: Integrate Hercules CI Agent

## Why

The pantherOS project needs continuous integration capabilities specifically tailored for NixOS. Hercules CI provides native Nix/NixOS integration for building, testing, and deploying NixOS configurations. The CI module infrastructure is already built but not yet enabled or configured on any host.

## What Changes

- Enable Hercules CI agent on hetzner-vps host
- Configure OpNix secret management for Hercules CI credentials
- Create dedicated hercules-ci.nix configuration module
- Add documentation for Hercules CI setup and operation
- Integrate with existing 1Password/OpNix secret management

## Impact

- Affected specs: hercules-ci (new capability)
- Affected code: hosts/servers/hetzner-vps/default.nix, hosts/servers/hetzner-vps/hercules-ci.nix
- No breaking changes to existing functionality
- Builds on existing CI module infrastructure (modules/ci/default.nix)
