# Change: Improve inline documentation and remove commented code

## Why
Several configuration files contain large blocks of commented-out code without clear documentation about why they are disabled or when they should be enabled. This reduces code clarity and makes maintenance harder.

## What Changes
- Document commented-out configuration blocks with clear reasons for being disabled
- Add inline documentation for complex configuration sections
- Remove truly unused commented code or document activation requirements
- Add module-level documentation where missing

## Impact
- Affected specs: configuration
- Affected code: hosts/servers/hetzner-vps/default.nix, hosts/servers/ovh-vps/default.nix, modules/terminal-tools/default.nix
