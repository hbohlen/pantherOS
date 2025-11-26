# Change: Create Modular Configuration Structure

## Why
The current configuration is monolithic and hard to maintain. Creating granular modules following AGENTS.md guidelines will improve readability, maintainability, and reusability. Each module should be atomic and use nested subfolders with default.nix files for exporting.

## What Changes
- Create /modules directory structure with hierarchical organization
- Extract system packages into modules/packages/ with submodules by category
- Extract environment variables into modules/environment/
- Extract user configuration into modules/users/
- Create modules/default.nix aggregator
- Update configuration.nix to import modules

## Impact
- Affected specs: configuration (new capability)
- Affected code: New modules/ directory, updated hosts/servers/hetzner-vps/configuration.nix
- Improves code organization without changing functionality</content>
<parameter name="filePath">openspec/changes/create-modular-config/proposal.md