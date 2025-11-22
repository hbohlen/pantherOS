# Change: Implement Basic NixOS Configuration for Hetzner VPS Deployment

## Why
The Hetzner VPS configuration files currently exist but are completely empty, making deployment impossible. This blocks the standard NixOS deployment workflow and prevents utilization of the primary development server infrastructure.

## What Changes
- Create working basic NixOS server configuration for Hetzner VPS
- Implement functional disko configuration for disk setup with Btrfs
- Add hardware.nix template with server-specific optimizations
- Integrate Hetzner VPS into flake.nix outputs for deployment
- Configure basic security (SSH hardening, Tailscale integration)
- Enable essential services (Podman, networking basics)

## Impact
- Affected specs: nixos-base-configuration (new capability)
- Affected code: 
  - `hosts/servers/hetzner-vps/default.nix` (implementation)
  - `hosts/servers/hetzner-vps/disko.nix` (implementation) 
  - `hosts/servers/hetzner-vps/hardware.nix` (implementation)
  - `flake.nix` (integration)
- Dependencies: Hardware discovery documentation, disk layout architecture
- Benefits: Enables immediate deployment workflow, provides foundation for server services, establishes base infrastructure pattern