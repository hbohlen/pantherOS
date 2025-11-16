# NixOS Performance Optimization Guide

**AI Agent Context**: This document describes potential performance optimizations for the NixOS configuration on OVH Cloud VPS.

## Overview

- **Platform**: OVH Cloud VPS (KVM virtualized)
- **OS**: NixOS 25.05 (unstable)
- **Storage**: Single virtual disk with Btrfs
- **Configuration**: Declarative via Nix flakes

## Current Configuration

**AI Agent Context**: The current configuration is minimal and optimized for simplicity and maintainability.

### Btrfs Mount Optimizations (disko.nix)

**AI Agent Context**: Current Btrfs configuration optimized for VM environment.

**Current Settings:**
- `noatime` - Reduces write operations for file access times
- `space_cache=v2` - Improves Btrfs performance for free space management

**Rationale:**
- VM environments benefit from simpler mount options
- Hypervisor handles many low-level optimizations
- `autodefrag` and `ssd_spread` removed as they're less beneficial in virtualized storage

### Potential Future Optimizations

**AI Agent Context**: These are NOT currently implemented but could be added if needed.

#### 1. Btrfs Compression

```nix
# Add to disko.nix subvolume mountOptions
mountOptions = [ "noatime" "space_cache=v2" "compress=zstd:1" ];
```

**Benefits:**
- 20-30% space savings for source code
- Minimal CPU overhead with zstd:1
- Faster for frequently accessed files

**Trade-offs:**
- Slight CPU overhead during compression/decompression
- May reduce performance on already-compressed files

#### 2. Nix Build Parallelism

```nix
# Add to configuration.nix
nix.settings = {
  max-jobs = "auto";  # Use all available cores
  cores = 0;          # Use all cores per job
};
```

**Benefits:**
- Faster parallel builds
- Better CPU utilization

**Trade-offs:**
- Higher memory usage during builds
- May cause system responsiveness issues during large builds

#### 3. Zram Swap

```nix
# Add to configuration.nix
zramSwap = {
  enable = true;
  memoryPercent = 50;  # Use 50% of RAM for compressed swap
};
```

**Benefits:**
- Acts as compressed swap in RAM
- Reduces disk I/O for swap operations
- Useful when memory is constrained

**Trade-offs:**
- Uses RAM for swap storage
- CPU overhead for compression

#### 4. Binary Cache Configuration

```nix
# Add to configuration.nix or flake.nix
nix.settings = {
  substituters = [
    "https://cache.nixos.org"
    # Add additional caches as needed
  ];
  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
};
```

**Benefits:**
- Downloads pre-built packages instead of building locally
- Significantly faster for common packages
- Reduces CPU and disk usage

#### 5. SSD-Specific Optimizations

```nix
# Add to configuration.nix if on SSD storage
boot.kernel.sysctl = {
  "vm.swappiness" = 10;  # Reduce swap usage preference
};

# Add to filesystem options
fileSystems."/".options = [ "noatime" "nodiratime" "discard=async" ];
```

**Benefits:**
- Better SSD longevity with async trim
- Reduced write amplification
- Lower latency for small files

**Note:** VM storage may already handle TRIM at hypervisor level

## Verification Commands

**AI Agent Context**: Commands to verify current system configuration.

```bash
# Check Btrfs mount options
mount | grep btrfs

# Check Nix configuration
nix show-config | grep -E "(max-jobs|cores)"

# Check available memory
free -h

# Check disk usage
df -h

# Check systemd services
systemctl status
```

## Current Configuration Status

**AI Agent Context**: As of last update, the configuration includes:

✅ **Implemented:**
- Basic Btrfs with subvolumes
- noatime mount option
- space_cache=v2
- Declarative disk partitioning via disko
- Home Manager for user environment
- SSH-only access with key auth

❌ **Not Implemented:**
- Btrfs compression
- Swap (zram or regular)
- Custom Nix build parallelism settings
- Additional binary caches
- Container runtime optimizations
- Custom kernel parameters

## When to Apply Optimizations

**AI Agent Context**: Guidelines for when optimizations are beneficial.

### Apply Compression If:
- Disk space is limited
- Storing mostly text files (code, logs, configs)
- CPU resources are abundant
- I/O is not a bottleneck

### Apply Zram If:
- RAM is limited (< 8GB)
- Building large packages that need swap
- Want better swap performance than disk-based

### Apply Nix Parallelism If:
- Building many packages from source
- Have multiple CPU cores available
- Not concerned about high memory usage during builds

### Apply Binary Caches If:
- Building common packages (not custom)
- Have good network bandwidth
- Want to minimize local build time

## Monitoring and Testing

**AI Agent Context**: After applying optimizations, monitor these metrics.

```bash
# Monitor build times
nix-build --show-trace '<nixpkgs>' -A hello 2>&1 | grep "built:"

# Monitor disk usage
btrfs filesystem usage /

# Monitor system resources during builds
htop

# Check compression ratio (if enabled)
sudo compsize /

# Monitor I/O
iostat -x 5
```

## References

- [NixOS Manual - Performance](https://nixos.org/manual/nixos/stable/index.html#sec-performance)
- [Btrfs Wiki](https://btrfs.wiki.kernel.org/)
- [Nix Manual - Configuration](https://nixos.org/manual/nix/stable/command-ref/conf-file.html)
