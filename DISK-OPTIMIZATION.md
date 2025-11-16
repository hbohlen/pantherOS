# Disk Optimization Guide

**AI Agent Context**: ⚠️ OUTDATED - This file describes optimizations not implemented in current configuration.

## Current Status

This file previously described advanced Btrfs optimizations including:
- Multiple subvolumes (@nix, @var-log, @tmp, etc.)
- Advanced compression settings (zstd:3)
- Mount options (autodefrag, ssd_spread)
- I/O scheduler optimizations

## Actual Implementation

The current configuration uses a **simple Btrfs layout**:
- Basic subvolumes: root (/), home (/home), var (/var)
- Simple mount options: noatime, space_cache=v2
- No compression configured
- Default I/O schedulers

See [disko.nix](hosts/servers/ovh-cloud/disko.nix) for actual disk configuration.

## For Optimization Ideas

See [PERFORMANCE-OPTIMIZATIONS.md](PERFORMANCE-OPTIMIZATIONS.md) for potential future optimizations with clear "NOT IMPLEMENTED" markers.

---

**Note**: This file is retained for reference but describes features NOT currently implemented.
