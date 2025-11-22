# Change: Add Comprehensive Hetzner VPS Hardware Documentation

## Why
The current Hetzner VPS hardware documentation exists but lacks comprehensive coverage of server-specific optimizations, detailed performance characteristics, and complete configuration references. This creates gaps in understanding the hardware capabilities, applying appropriate optimizations, and troubleshooting hardware-specific issues for the primary development server.

## What Changes
- Create comprehensive hardware documentation covering all aspects of Hetzner VPS hardware
- Add detailed server-specific optimizations and security hardening configurations  
- Include complete disk layout with impermanence and snapshot strategy
- Document network services configuration and container orchestration setup
- Add backup strategies, monitoring setup, and performance benchmarks
- Include known issues, troubleshooting guides, and configuration references
- Establish template pattern for other server hardware documentation

## Impact
- Affected specs: documentation (new capability)
- Affected code: `/docs/hardware/hetzner-vps.md` (enhancement)
- Dependencies: Hardware discovery process, host configuration guides
- Benefits: Single source of truth for Hetzner VPS hardware, improved configuration and optimization work, better troubleshooting capabilities