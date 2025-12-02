# Change: Add Home Manager Setup

## Why

The system currently lacks user-level package management and configuration. Home Manager provides declarative user environment management, allowing us to install packages like terminal tools and configure user settings in a reproducible way.

## What Changes

- Add home-manager flake input to flake.nix
- Configure home-manager module in system configuration
- Set up basic home-manager user configuration for hbohlen

## Impact

- Affected specs: home-manager (new capability)
- Affected code: flake.nix, hosts/servers/hetzner-vps/configuration.nix
- No breaking changes to existing functionality
