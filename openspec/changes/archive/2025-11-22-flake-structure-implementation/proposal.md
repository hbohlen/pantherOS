# Change: Implement Core Flake Structure for pantherOS

## Why
The main flake.nix file is empty, which is a critical issue blocking deployment of the entire pantherOS configuration. Without a proper flake definition, the nixosConfigurations for all hosts (including hetzner-vps, yoga, zephyrus) cannot be built or deployed. This makes the current repository non-functional for its primary purpose of managing NixOS configurations across multiple hosts.

## What Changes
- Create a complete flake.nix file with proper inputs and outputs
- Define nixosConfigurations for all existing hosts: yoga, zephyrus, hetzner-vps, ovh-vps
- Integrate existing host configurations from the hosts/ directory
- Add necessary flake inputs: nixpkgs, disko, nixos-hardware, home-manager
- Implement development environment outputs for contributors

## Impact
- Affected specs: core-flake-structure (new capability)
- Affected code:
  - `flake.nix` (creation of complete flake definition)
  - All host configurations in `hosts/` (integration into flake)
- Dependencies: Hardware profiles, module configurations, disko configurations
- Benefits: Enables deployment workflow for all hosts, provides proper NixOS flake integration