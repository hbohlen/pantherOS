# Change: Fix missing module imports in ovh-vps configuration

## Why
The ovh-vps configuration doesn't import the common modules directory (../../../modules) while hetzner-vps does. This inconsistency can lead to missing functionality and configuration drift.

## What Changes
- Add ../../../modules import to hosts/servers/ovh-vps/default.nix
- Ensure consistent module structure across all server configurations

## Impact
- Affected specs: configuration
- Affected code: hosts/servers/ovh-vps/default.nix
