# Host Configurations Review

## Current Status Summary

Based on hardware discovery and file system review as of 2025-11-21:

### Host Configuration Status Matrix

| Host | default.nix | hardware.nix | disko.nix | Status |
|------|-------------|--------------|-----------|--------|
| yoga | ❌ Empty (0 lines) | ❌ Empty (0 lines) | ❌ Empty (0 lines) | **NEEDS COMPLETE SETUP** |
| zephyrus | ❌ Empty (0 lines) | ❌ Empty (0 lines) | ❌ Empty (0 lines) | **NEEDS COMPLETE SETUP** |
| hetzner-vps | ✅ Detailed (230+ lines) | ⚠️ Placeholder only | ✅ Detailed (200+ lines) | **85% COMPLETE** |
| ovh-vps | ❌ Empty (0 lines) | ❌ Empty (0 lines) | ❌ Empty (0 lines) | **NEEDS COMPLETE SETUP** |

## Detailed Findings

### 1. hetzner-vps (Most Complete)

**What Works:**
- ✅ Tailscale networking configured
- ✅ Firewall rules (Tailscale-only access)
- ✅ OpenSSH fallback
- ✅ Impermanence configuration (ephemeral root)
- ✅ Comprehensive disko.nix with Btrfs sub-volumes
- ✅ OpNix integration for secrets

**Issues Found:**
- ⚠️ Comment mentions `hetzner-cloud` but directory is `hetzner-vps` (inconsistency)
- ⚠️ `hardware.nix` is just a placeholder with QEMU guest profile
- ⚠️ Currently configured for ext4/mbr in comments but disko.nix uses Btrfs
- ⚠️ Boot loader configured for `/dev/sda` but discovery shows NVMe storage

**What Needs Fixing:**
1. ✅ Update `hardware.nix` with actual hardware discovery data
2. ✅ Fix boot loader configuration for NVMe (was `/dev/sda`, should be `/dev/nvme0n1`)
3. ✅ Verify disko.nix matches hardware (currently configured for 457GB SSD but discovery shows 440GB)

### 2. yoga (Completely Empty)

**Hardware (from discovery):**
- CPU: AMD Ryzen AI 7 350 w/ Radeon 860M (16 cores)
- RAM: 14GB
- Storage: 1x NVMe SSD (~1TB, Btrfs already)
- GPU: Integrated Radeon 860M
- Wireless: wlan0
- Battery: Yes
- Form Factor: Laptop (31)

**Status:**
- ❌ All configuration files are empty
- ✅ Already using Btrfs (from discovery)
- ✅ Should be easier setup than VPS

**What Needs Creation:**
1. `default.nix` - Main system configuration
2. `hardware.nix` - AMD Ryzen hardware config
3. `disko.nix` - Btrfs sub-volumes for laptop

**Priority:** Medium (after hetzner-vps is complete)

### 3. zephyrus (Completely Empty)

**Hardware (from discovery):**
- CPU: Intel i9-12900H (20 cores)
- RAM: 38GB
- Storage: 2x NVMe SSDs (~2.7TB each, Btrfs already)
- GPU: NVIDIA RTX 3070 Ti Laptop
- Wireless: wlan0
- Battery: Yes
- Form Factor: Laptop (10)
- **Note:** Tailscale already installed

**Status:**
- ❌ All configuration files are empty
- ✅ Already using Btrfs
- ✅ Tailscale already running
- ⚠️ Most complex hardware (dual NVMe, NVIDIA GPU)

**What Needs Creation:**
1. `default.nix` - Main system configuration with NVIDIA drivers
2. `hardware.nix` - Intel + NVIDIA hardware config
3. `disko.nix` - Dual NVMe Btrfs layout

**Priority:** High (primary development workstation)

### 4. ovh-vps (Completely Empty)

**Hardware (from discovery):**
- CPU: Intel Haswell (8 cores)
- RAM: 22GB
- Storage: 1x SSD (~195GB, ext4)
- Virtualized: KVM
- Form Factor: Server (1)

**Status:**
- ❌ All configuration files are empty
- ✅ Can mirror hetzner-vps configuration (smaller)
- ⚠️ Smallest storage (195GB) - needs efficient layout

**What Needs Creation:**
1. `default.nix` - Mirror hetzner-vps but smaller
2. `hardware.nix` - Intel Haswell KVM config
3. `disko.nix` - Btrfs migration from ext4

**Priority:** Low (after yoga is complete)

## Implementation Plan

### Phase 3A: Complete hetzner-vps (Immediate)
1. ✅ Fix `hardware.nix` with AMD EPYC Genoa specs
2. ✅ Update disko.nix for actual storage size (440GB not 457GB)
3. ✅ Fix boot loader for NVMe device path
4. ✅ Test build: `nixos-rebuild build .#hetzner-vps`

### Phase 3B: Create yoga Configuration
1. Create `hardware.nix` with AMD Ryzen 7 350 specs
2. Create `disko.nix` with laptop-optimized Btrfs sub-volumes
3. Create `default.nix` with:
   - Network (WiFi + Tailscale)
   - Desktop environment (Niri + DankMaterialShell)
   - Development tools
   - Battery optimization
4. Test build: `nixos-rebuild build .#yoga`

### Phase 3C: Create zephyrus Configuration
1. Create `hardware.nix` with Intel i9 + NVIDIA RTX specs
2. Create `disko.nix` with dual NVMe layout
3. Create `default.nix` with:
   - Network (WiFi + Tailscale - already installed!)
   - NVIDIA drivers
   - Desktop environment (Niri + DankMaterialShell)
   - Development tools
   - Power profiles
4. Test build: `nixos-rebuild build .#zephyrus`

### Phase 3D: Create ovh-vps Configuration
1. Create `hardware.nix` with Intel Haswell specs
2. Create `disko.nix` with efficient Btrfs layout
3. Create `default.nix` - mirror hetzner-vps but smaller
4. Test build: `nixos-rebuild build .#ovh-vps`

## Issues to Address

### Critical Issues

1. **Hardware Documentation Missing**
   - yoga: 0 hardware.nix content
   - zephyrus: 0 hardware.nix content
   - ovh-vps: 0 hardware.nix content
   - hetzner-vps: placeholder only

2. **Inconsistency in Naming**
   - hetzner-vps config comments reference `hetzner-cloud`
   - Should be consistent with directory name

3. **Storage Mismatch**
   - hetzner-vps disko.nix configured for 457GB
   - Discovery shows 440GB available
   - Need to update partition sizes

### Configuration Gaps

1. **Desktop Environment**
   - Niri + DankMaterialShell not configured in any host
   - Fish shell not configured
   - Ghostty terminal status unknown

2. **AI Tools Integration**
   - nix-ai-tools added to flake but not configured in hosts
   - Need home-manager configs for user-level tools

3. **1Password Integration**
   - OpNix imported in flake
   - But not configured in host defaults
   - Need to set up auth keys, SSH agent integration

4. **Home Manager Configs**
   - flake.nix has homeManagerConfigurations
   - But `home/hbohlen/` files likely empty or minimal
   - Need fish, ghostty, development tools configs

## Next Steps Priority Order

1. **Week 1: Complete hetzner-vps**
   - Fix hardware.nix
   - Test build successfully
   - Deploy to test

2. **Week 2: Create yoga configuration**
   - Start with hardware.nix
   - Add disko.nix (already on Btrfs)
   - Add desktop environment
   - Test build

3. **Week 3: Create zephyrus configuration**
   - Most complex (NVIDIA, dual NVMe)
   - Already has Tailscale and Btrfs
   - Focus on NVIDIA drivers and power management

4. **Week 4: Create ovh-vps configuration**
   - Mirror hetzner-vps but smaller
   - Btrfs migration from ext4

## Files to Update

### Immediate Actions Required

1. **Update `pantherOS.md`**
   - ✅ Hardware specs documented (DONE)
   - ✅ Disk configuration status updated (DONE)
   - ⏳ Add link to Btrfs layout plan
   - ⏳ Add link to Ghostty research

2. **Update `flake.nix`**
   - ✅ nix-ai-tools already added
   - ✅ opnix already added
   - ✅ disko already added
   - ⏳ Need niri-flake and dankmaterialshell inputs

3. **Create `docs/tasks/` directory**
   - Track Phase 3 implementation tasks
   - Document current progress per host

## Conclusion

**Current State:** Early Phase 1 complete, Phase 2-3 pending
**Next Phase:** Complete hetzner-vps configuration (simplest)
**Long-term:** Sequential host deployment (hetzner → yoga → zephyrus → ovh)

**Key Success Metrics:**
1. All 4 hosts build successfully
2. Hardware specs integrated into configs
3. Modular structure followed
4. Zero configuration drift between hosts
