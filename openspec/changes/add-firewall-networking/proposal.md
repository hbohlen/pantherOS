# Change: Add Firewall and Network Management Module

## Why

The system currently has basic network configuration but lacks:
- Centralized firewall management
- VPN configuration and management
- Network security hardening
- Per-host network profiles
- DNS configuration and filtering
- Network monitoring and diagnostics

A comprehensive networking module would provide secure, manageable network configuration across all hosts with consistent security policies.

## What Changes

- Create `modules/networking/firewall.nix` for firewall management (using nftables)
- Create `modules/networking/vpn.nix` for VPN configuration (WireGuard, Tailscale)
- Create `modules/networking/dns.nix` for DNS management and filtering
- Add network security hardening options
- Create per-host network profiles
- Add network diagnostic tools and utilities
- Integrate with existing Tailscale installation

## Impact

### Affected Specs
- Modified capability: `networking` (extend from basic to comprehensive networking)
- New capability: `firewall` (port management, rules, zones)
- New capability: `vpn` (WireGuard and Tailscale configuration)

### Affected Code
- New module: `modules/networking/firewall.nix`
- New module: `modules/networking/vpn.nix`
- New module: `modules/networking/dns.nix`
- Modified: `modules/networking/default.nix` to orchestrate networking modules
- Host configurations: Add network profiles per host
- New packages: Network diagnostic tools in `modules/packages/networking/default.nix`

### Benefits
- Consistent firewall rules across hosts
- Secure default network configuration
- Easy VPN setup and management
- DNS filtering and ad-blocking capabilities
- Network troubleshooting tools readily available
- Zero-trust network security model support

### Considerations
- Firewall misconfigurations could lock out SSH access
- VPN configuration requires external coordination (keys, peers)
- DNS filtering may break some applications
- Complexity increases with multiple network interfaces
