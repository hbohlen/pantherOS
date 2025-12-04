# Change: Add Contabo VPS Server Configuration

## Why
Contabo Cloud VPS provides a cost-effective, high-performance server platform for development workloads. The new Contabo VPS instance (Cloud VPS 40) with 12 vCPU, 48GB RAM, and 250GB NVMe storage requires dedicated NixOS configuration and hardware optimization to match the existing Hetzner and OVH server setups.

## What Changes
- New server host configuration under `hosts/servers/contabo-vps/`
- Optimized disk layout with Btrfs subvolumes for performance workloads
- Hardware-specific kernel modules and configurations for Contabo Cloud KVM
- Performance tuning for 12-core CPU and 48GB RAM system
- Deployment verification and hardware detection scripts
- Initial `facter.json` to be populated by running hardware detection

## Impact
- **Affected specs**: `server-configuration`, `disk-layout`
- **Affected code**:
  - New: `hosts/servers/contabo-vps/` (disko.nix, hardware.nix, default.nix, meta.nix, facter.json)
  - New: `scripts/setup-contabo-vps.sh` (hardware detection and Nix installation script)
  - Modified: `flake.nix` (add contabo-vps to nixosConfigurations)

## Notes
- Initial hardware detection requires running facter on the server
- Configuration uses Hetzner and OVH VPS as reference implementations
- Higher RAM (48GB) and NVMe storage (250GB) support more intensive workloads than Hetzner setup
- Contabo likely uses BIOS boot like OVH, will be verified by facter output

## Timeline
1. Create proposal and base configuration (referencing existing servers)
2. Generate setup script for hardware detection
3. Obtain facter.json from actual Contabo hardware
4. Fine-tune configuration based on actual hardware specs
5. Deploy and verify
