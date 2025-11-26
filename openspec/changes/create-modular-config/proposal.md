# Change: Create Modular Configuration Structure

## Why
The current configuration is monolithic and hard to maintain. Creating granular modules following AGENTS.md guidelines will improve readability, maintainability, and reusability.

## What Changes
- Create /modules directory structure
- Extract home-manager configuration into modules/home.nix
- Extract terminal tools configuration into modules/terminal-tools.nix
- Extract fish shell configuration into modules/fish.nix
- Create modules/default.nix aggregator
- Update configuration.nix to import modules

## Impact
- Affected specs: configuration (new capability)
- Affected code: New modules/ directory, updated hosts/servers/hetzner-vps/configuration.nix
- Improves code organization without changing functionality</content>
<parameter name="filePath">openspec/changes/create-modular-config/proposal.md