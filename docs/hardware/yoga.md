# Lenovo Yoga 7 Hardware Specifications

## Overview
- **Host Name**: yoga
- **Host Type**: Lightweight Mobile Workstation
- **Primary Purpose**: Lightweight programming, research, web browsing, 2-in-1 flexibility
- **Use Cases**: Mobile development, documentation, presentations, media consumption
- **Performance Requirements**: Balanced power consumption with responsive development environment

## Hardware Specifications

### CPU
- **Model**: AMD Ryzen 7 5800U (zen3) or Intel Core i7-1165G7/1195G7 (11th gen)
- **Cores**: 8 cores / 16 threads
- **Base Clock**: 1.9 GHz (AMD) / 2.8 GHz (Intel)
- **Boost Clock**: 4.4 GHz (AMD) / 4.7 GHz (Intel)
- **Architecture**: x86_64
- **TDP**: 15W (configurable for ultrabook efficiency)
- **Special Features**: 
  - Advanced power management with precision boost
  - Hardware virtualization (AMD-V/Intel VT-x)
  - AES-NI encryption acceleration
  - Low-power idle states for battery optimization

### Memory
- **Total RAM**: 16GB (soldered LPDDR4X/DDR4)
- **Memory Speed**: 4266MHz (LPDDR4X) / 3200MHz (DDR4)
- **Configuration**: Dual-channel (4GB x 4 or 8GB x 2)
- **Upgradeability**: None (soldered memory)
- ** ECC Support**: No (consumer hardware)
- **Implications**: Memory management critical for development workloads

### Storage
- **Primary Storage**: 512GB NVMe PCIe 3.0 SSD
- **Storage Interface**: M.2 2280 NVMe
- **Performance**: ~3500 MB/s read, ~3000 MB/s write
- **Secondary Storage**: None (single drive configuration)
- **Expansion**: USB 3.2 Gen 2 (10Gbps) external storage support
- **Optimization Focus**: Battery life through efficient I/O patterns

### Graphics
- **Integrated Graphics**: AMD Radeon Graphics (Renoir) or Intel Iris Xe Graphics
- **Dedicated Graphics**: None
- **VRAM**: Shared system memory (up to 2GB allocated)
- **Display Support**: 
  - Internal: 14" OLED/IPS, 1920x1080 or 2880x1800 (HiDPI)
  - External: Single 4K@60Hz via USB-C DisplayPort
  - Multiple monitors: USB-C to HDMI/DisplayPort hubs supported
- **Driver Requirements**: AMDGPU/RadeonSI or Intel i915
- **Special Features**: Hardware video acceleration (AV1/H.265)

### Network
- **Ethernet**: None (requires USB-C to Ethernet adapter)
- **Wireless**: 
  - WiFi 6 (802.11ax) with Bluetooth 5.0/5.1
  - Realtek RTL8852AE or Intel AX201
  - 2x2 MIMO, up to 2402Mbps theoretical
- **Special Features**: 
  - WiFi Direct support
  - Bluetooth audio low latency
  - Wake-on-LAN via USB adapters

### Special Hardware
- **Touchscreen**: Capacitive multitouch (10-finger support)
- **Stylus Support**: Active pen input (1024+ pressure levels)
- **Convertible Hinge**: 360-degree rotation for laptop/tablet modes
- **Fingerprint Reader**: Windows Hello compatible (Synaptics/COMOSS)
- **Camera**: HD webcam (720p/1080p) with privacy shutter
- **Audio**: Quad speakers with Dolby Atmos
- **Sensors**: 
  - Accelerometer for auto-rotation
  - Ambient light sensor for display brightness
  - Gyroscope for tablet mode
- **Keyboard**: Backlit keyboard with function row
- **Touchpad**: Precision touchpad with gesture support

## Optimizations

### Power Management
```nix
# Battery-focused power management
powerManagement = {
  cpuGovernor = "powersave";  # Balanced performance/battery
  graphicsPowerManagement = true;  # Disable dGPU (none anyway)
  wlanPowerManagement = true;  # WiFi power savings
  usbPowerManagement = true;  # Peripheral power control
  diskPowerManagement = "auto";  # Aggressive spin-down for HDDs
  thermalManagement = "balanced";  # Silent operation priority
};
```

### Performance Tuning
```nix
# Development-focused performance
performance = {
  # Compiler optimization
  kernelParameters = [
    "mitigations=off"  # Security vs performance tradeoff
    "nowatchdog"  # Reduce interrupt overhead
  ];
  
  # CPU governor optimization
  cpuGovernor = "schedutil";  # Dynamic scaling based on demand
  
  # Memory management
  vm.swappiness = 10;  # Reduce swap usage
  vm.vfs_cache_pressure = 50;  # Aggressive cache preservation
};
```

### SSD Optimization
```nix
# NVMe optimization for battery life
fileSystems."/" = {
  device = "/dev/disk/by-uuid/yoga-nixos";
  fsType = "btrfs";
  options = [
    "compress=zstd:3"  # Space and power savings
    "noatime"  # Reduce write operations
    "ssd"  # Enable SSD-specific optimizations
    "space_cache=v2"  # Efficient space management
    "discard=async"  # Non-blocking TRIM
    "subvol=root"
  ];
};
```

### Thermal Management
```nix
# Thermal optimization for portable use
thermal = {
  fanControl = true;
  passiveCooling = true;  # Silent operation when possible
  cpuTemperatureLimit = 85;  # Throttle before thermal throttling
  fanProfile = "balanced";  # Quiet office use priority
  coolingPads = "supported";  # For extended performance sessions
};
```

### Network Optimization
```nix
# WiFi optimization for mobile use
networking.wireless = {
  powerSaving = true;
  roamingAggressive = true;
  antennaDiversity = true;
  bandSteering = true;  # Prefer 5GHz when available
};
```

## Disk Layout

### Btrfs Sub-Volume Design
Based on the [disk layouts architecture](../architecture/disk-layouts.md), yoga implements a mobile-focused Btrfs strategy:

```nix
# Yoga-specific subvolume configuration
btrfsConfig = {
  label = "yoga-nixos";
  features = [ "block-group-tree" ];
  
  subvolumes = [
    # Ephemeral system root (1GB ESP)
    {
      name = "root";
      mountpoint = "/";
      compress = "zstd:3";
      snapshotStrategy = "manual";
    }
    
    # User data priority (mobile workflow)
    {
      name = "home";
      mountpoint = "/home";
      compress = "zstd:3";
      neededForBoot = true;
    }
    
    # Development with auto-activation
    {
      name = "dev";
      mountpoint = "/home/hbohlen/dev";
      compress = "zstd:2";
      autoActivate = true;  # DevShell integration
    }
    
    # Fast Nix access for package operations
    {
      name = "nix";
      mountpoint = "/nix";
      compress = "zstd:1";
      neededForBoot = true;
      performance = "fast";
    }
    
    # Mobile-optimized containers
    {
      name = "containers";
      mountpoint = "/var/lib/containers";
      compress = "zstd:1";
      mountOptions = [ "nodatacow" ];
      sizeLimit = "50G";  # Battery-conscious container footprint
    }
    
    # Desktop application data
    {
      name = "desktop";
      mountpoint = "/home/hbohlen/.local";
      compress = "zstd:3";
      syncInterval = "hourly";
    }
    
    # System logs and cache
    {
      name = "cache";
      mountpoint = "/var/cache";
      compress = "zstd:3";
      cleanupInterval = "daily";
    }
    
    {
      name = "logs";
      mountpoint = "/var/log";
      compress = "zstd:3";
      neededForBoot = true;
      cleanupInterval = "weekly";
    }
    
    # Recovery snapshots
    {
      name = "snapshots";
      mountpoint = "/.snapshots";
      compress = "zstd:3";
      retentionPolicy = "development-milestones";
    }
  ];
};
```

### Mount Strategy
- **ESP Size**: 1GB (sufficient for single kernel + backup)
- **Compression Levels**: Aggressive compression for battery life
- **Snapshot Schedule**: Manual snapshots for development milestones
- **Recovery Focus**: Point-in-time recovery for development work

## Known Issues

### Hardware Compatibility
- **Touchscreen Calibration**: Some Yoga models require manual calibration
  - **Workaround**: `xinput set-prop <device-id> "libinput Calibration Matrix" 1 0 0 0 1 0 0 0 1`
- **Stylus Latency**: Active pen input may have noticeable latency
  - **Workaround**: Disable tablet mode for precision work
- **Fingerprint Reader**: Limited Linux support on some models
  - **Workaround**: Use PAM USB keychain or PIN authentication

### Driver Issues
- **AMD iGPU Driver**: Some Renoir models experience display corruption
  - **Workaround**: Use kernel parameter `amdgpu.modif_bp=1`
  - **Permanent Fix**: Updated firmware/BIOS from Lenovo
- **WiFi Stability**: Realtek WiFi cards may drop connections intermittently
  - **Workaround**: Disable power management (`iwconfig wlan0 power off`)
- **Touchpad Gestures**: Limited multi-touch gesture support
  - **Workaround**: libinput configuration adjustments

### Performance Issues
- **Thermal Throttling**: Sustained loads cause aggressive throttling
  - **Prevention**: Use cooling pad for extended development sessions
- **Memory Pressure**: Soldered 16GB may be limiting for large containers
  - **Management**: Aggressive swap configuration, lightweight IDEs
- **NVMe Performance**: Some models have PCIe 3.0 limited throughput
  - **Optimization**: Use fast compression to reduce I/O

### Mobility Issues
- **Battery Life**: Expected 8-12 hours for typical development work
- **Port Availability**: Limited ports may require USB-C hub
- **Weight**: 1.4-1.6kg (acceptable for mobile development)
- **Hinge Durability**: Convertible hinges may wear over time

### Linux-Specific Considerations
- **Modern Standby**: Limited support for S0ix modern standby
- **Tablet Mode**: Auto-rotation may require manual configuration
- **Keyboard Shortcuts**: Some function keys require firmware configuration
- **Audio**: Dolby Atmos may require specific ALSA configuration

## Performance Benchmarks

### Expected Performance Characteristics
```bash
# CPU Performance (estimated)
Geekbench 6 Single-Core: ~1800-2000 points
Geekbench 6 Multi-Core: ~6500-7500 points
CPU Mark: ~15000-17000

# Storage Performance
Sequential Read: 3500 MB/s
Sequential Write: 3000 MB/s
Random Read IOPS: ~500K
Random Write IOPS: ~400K

# Memory Performance
Memory Bandwidth: ~50-68 GB/s
Memory Latency: 50-60ns

# Battery Life Expectations
Idle: 15-18 hours
Light Development: 10-14 hours
Heavy Development: 6-10 hours
Streaming Video: 12-16 hours
```

## Configuration References

### Related Architecture Documents
- [System Architecture Overview](../architecture/overview.md)
- [Host Classification System](../architecture/host-classification.md)
- [Disk Layouts Strategy](../architecture/disk-layouts.md)
- [Security Model](../architecture/security-model.md)

### Hardware Discovery Guide
- [Hardware Discovery Process](../guides/hardware-discovery.md)
- [Host Configuration Guide](../guides/host-configuration.md)

### Configuration Files
- **Disk Layout**: `../../hosts/yoga/disko.nix`
- **System Configuration**: `../../hosts/yoga/default.nix`
- **Hardware Configuration**: `../../hosts/yoga/hardware.nix`

---

**Maintained by:** hbohlen  
**Last Updated:** 2025-11-20  
**Version:** 1.0