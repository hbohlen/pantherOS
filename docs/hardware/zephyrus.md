# ASUS ROG Zephyrus M16 Hardware Specifications

## Overview
- **Host Name**: zephyrus
- **Host Type**: High-Performance Mobile Workstation
- **Primary Purpose**: Heavy development, Podman containers, AI tools, machine learning
- **Use Cases**: Resource-intensive development, container orchestration, AI model training, high-resolution video work
- **Performance Requirements**: Maximum processing power with thermal management for sustained workloads

## Hardware Specifications

### CPU
- **Model**: Intel Core i9-12900H (12th gen) or AMD Ryzen 9 6900HS
- **Cores**: 14 cores / 20 threads (Intel) / 8 cores / 16 threads (AMD)
- **Base Clock**: 2.5 GHz (Intel) / 3.3 GHz (AMD)
- **Boost Clock**: 5.0 GHz (Intel) / 4.9 GHz (AMD)
- **Architecture**: x86_64
- **TDP**: 45W (base) / 65W (boost) configurable
- **Cache**: 24MB L3 (Intel) / 16MB L3 (AMD)
- **Special Features**: 
  - Hardware virtualization (Intel VT-x/AMD-V)
  - AVX-512 support (Intel) / AVX-256 (AMD)
  - DLBoost AI acceleration
  - Precision Boost 2.0 (AMD) / Thermal Velocity Boost (Intel)

### Memory
- **Total RAM**: 32GB DDR5-4800 or 64GB DDR5-4800
- **Memory Speed**: 4800MHz (DDR5) / 6400MHz (DDR5-6400 on some models)
- **Configuration**: 2x16GB or 2x32GB dual-channel
- **Upgradeability**: User-replaceable (2 slots, max 64GB)
- **ECC Support**: No (consumer hardware)
- **Memory Controller**: Dual-channel DDR5 controller
- **Implications**: High bandwidth for AI/ML workloads, large container footprints

### Storage
- **Primary NVMe**: 1TB PCIe 4.0 NVMe SSD (Samsung 980 PRO/980 PRO+)
- **Secondary NVMe**: 1TB PCIe 4.0 NVMe SSD (Samsung 980 PRO/980 PRO+)
- **Storage Interface**: 2x M.2 2280 NVMe slots
- **Performance**: 
  - Primary: ~7000 MB/s read, ~5000 MB/s write
  - Secondary: ~7000 MB/s read, ~5000 MB/s write
- **RAID Support**: Btrfs RAID1 for data, RAID0 for performance
- **Expansion**: 2x USB 3.2 Gen 2 (10Gbps) external storage support
- **Optimization Focus**: Maximum throughput for development and containers

### Graphics
- **Integrated Graphics**: Intel Iris Xe (12th gen) / AMD Radeon 680M (Ryzen 9)
- **Dedicated Graphics**: NVIDIA GeForce RTX 3070 Ti (8GB VRAM) or RTX 3080 Ti (16GB VRAM)
- **VRAM**: 8GB/16GB GDDR6, 448 GB/s memory bandwidth
- **Display Support**: 
  - Internal: 16" QHD+ (2560x1600) 165Hz Pantone-validated
  - External: 2x 4K@144Hz or 1x 8K@60Hz via USB-C DisplayPort
  - Multiple monitors: USB-C + HDMI 2.1 for triple monitor setup
- **Driver Requirements**: NVIDIA proprietary driver (470+), Intel i915/AMDGPU
- **Special Features**: 
  - Hardware ray tracing (RT cores 2nd gen)
  - DLSS 3.0 support
  - CUDA cores (6144/8960)
  - Hardware video encoding/decoding
  - MUX switch for hybrid graphics optimization

### Network
- **Ethernet**: 2.5G Ethernet (Realtek RTL8125)
- **Wireless**: 
  - WiFi 6E (802.11ax) with Bluetooth 5.2
  - Intel AX211 or MediaTek MT7922
  - 2x2 MIMO, up to 2402Mbps theoretical (6GHz band)
- **Special Features**: 
  - 2.5G Ethernet for high-speed NAS access
  - WiFi 6E tri-band support (6GHz for low latency)
  - Bluetooth 5.2 LE Audio support
  - Multi-gigabit networking capability

### Special Hardware
- **Keyboard**: Per-key RGB backlit keyboard (Aura Sync compatible)
- **Touchpad**: Precision glass touchpad with gesture support
- **Camera**: 720p HD webcam with IR (Windows Hello support)
- **Audio**: 6-speaker system with Dolby Atmos
- **Cooling**: ROG Intelligent Cooling with liquid metal thermal compound
- **Ports**: 
  - 2x USB-C (Thunderbolt 4 / USB4)
  - 2x USB-A 3.2 Gen 2
  - 1x HDMI 2.1
  - 1x 2.5G Ethernet
  - 1x 3.5mm audio jack
  - 1x microSD card reader

## Optimizations

### Performance Management
```nix
# Maximum performance configuration
powerManagement = {
  cpuGovernor = "performance";  # Always-on performance
  graphicsPowerManagement = false;  # Disable GPU power gating
  wlanPowerManagement = false;  # Network performance priority
  usbPowerManagement = false;  # Peripheral performance
  diskPowerManagement = "max_performance";  # Never spin down
  thermalManagement = "performance";  # Aggressive cooling
  fanProfile = "turbo";  # Maximum cooling when plugged in
};
```

### CPU Optimization
```nix
# High-performance CPU tuning
kernelParameters = [
  "processor.max_cstate=1"  # Disable power states for performance
  "intel_pstate=disable"  # Use acpi-cpufreq
  "initcall_blacklist=acpi_cpufreq_init"  # Alternative CPU scaling
  "nowatchdog"  # Disable watchdog for performance
  "nmi_watchdog=0"  # Disable NMI watchdog
];

# CPU governor settings
systemd.services."cpu-performance" = {
  enable = true;
  serviceConfig = {
    ExecStart = ''
      echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
      echo 100 > /sys/devices/system/cpu/intel_pstate/min_perf_pct
      echo 100 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
    '';
  };
};
```

### GPU Optimization
```nix
# Dual GPU management
graphics = {
  # Enable NVIDIA discrete GPU
  nvidia = {
    enable = true;
    powerManagement.enable = false;  # Always-on performance
    powerManagement.level = "preferMaximumPerformance";
    prime = {
      offload.enable = true;
      offload.renderOffload = "nvidia";
    };
  };
  
  # MUX switch optimization
  muxSwitch = {
    enable = true;
    mode = "hybrid";  # Use iGPU for display, dGPU for compute
  };
};
```

### Memory Optimization
```nix
# High-bandwidth memory configuration
memory = {
  # Large shared memory for AI workloads
  vm.overcommit_memory = 1;  # Never overcommit
  vm.swappiness = 10;  # Minimize swap usage
  vm.vfs_cache_pressure = 25;  # Aggressive cache preservation
  vm.dirty_ratio = 15;  # Start background writes early
  vm.dirty_background_ratio = 5;  # Start background writes aggressively
  
  # NUMA optimization for multi-socket systems
  numa_balancing = false;  # Manual NUMA policy
};
```

### Storage Optimization
```nix
# High-performance storage configuration
fileSystems = {
  # Primary NVMe - System and containers
  "/" = {
    device = "/dev/disk/by-uuid/zephyrus-nixos";
    fsType = "btrfs";
    options = [
      "compress=zstd:1"  # Fast compression for performance
      "noatime"  # Reduce metadata writes
      "ssd"  # Enable SSD optimizations
      "space_cache=v2"  # Efficient space management
      "discard=async"  # Non-blocking TRIM
      "subvol=root"
    ];
  };
  
  # Secondary NVMe - AI models and databases
  "/mnt/databases" = {
    device = "/dev/disk/by-uuid/zephyrus-data";
    fsType = "btrfs";
    options = [
      "compress=zstd:1"  # Fast access for databases
      "noatime"
      "ssd"
      "nodatacow"  # No copy-on-write for database files
      "space_cache=v2"
      "discard=async"
      "subvol=databases"
    ];
  };
};
```

## Disk Layout

### Dual-NVMe Btrfs Configuration
Based on the [disk layouts architecture](../architecture/disk-layouts.md), zephyrus implements a performance-focused strategy:

```nix
# Zephyrus dual-NVMe layout
disko.devices = {
  disk = {
    "nvme0n1" = {  # Primary NVMe - System
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # Large ESP for multiple kernels
          esp = {
            size = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "umask=0077"
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };
          
          # Secondary ESP for dual-boot testing
          esp2 = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountOptions = [ "noauto" ];
            };
          };
          
          # Primary Btrfs system
          primary = {
            size = "max";
            type = "8300";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              btrfsConfig = {
                label = "zephyrus-nixos";
                features = [ "block-group-tree" ];
              };
              
              subvolumes = [
                # System subvolumes
                {
                  name = "root";
                  mountpoint = "/";
                  compress = "zstd:3";
                }
                
                {
                  name = "nix";
                  mountpoint = "/nix";
                  compress = "zstd:1";
                  neededForBoot = true;
                  performance = "fast";
                }
                
                # Performance-focused user data
                {
                  name = "home";
                  mountpoint = "/home";
                  compress = "zstd:1";  # Fast for frequent access
                  performance = "fast";
                }
                
                # Large development projects
                {
                  name = "projects";
                  mountpoint = "/home/hbohlen/dev";
                  compress = "zstd:1";  # Fast compilation
                  performance = "fast";
                }
                
                # Container storage optimization
                {
                  name = "containers";
                  mountpoint = "/var/lib/containers";
                  compress = "zstd:1";
                  mountOptions = [ "nodatacow" ];
                  performance = "fast";
                }
                
                # AI model storage
                {
                  name = "ai-models";
                  mountpoint = "/home/hbohlen/.cache/ai-models";
                  compress = "zstd:2";
                  mountOptions = [ "nodatacow" ];  # Large model files
                  sizeLimit = "200G";
                }
                
                # High-performance temporary storage
                {
                  name = "tmp";
                  mountpoint = "/tmp";
                  compress = "zstd:1";
                  mountOptions = [ "nodatacow" ];
                  performance = "fast";
                }
                
                # System logs and cache
                {
                  name = "cache";
                  mountpoint = "/var/cache";
                  compress = "zstd:3";
                }
                
                {
                  name = "logs";
                  mountpoint = "/var/log";
                  compress = "zstd:3";
                  neededForBoot = true;
                }
                
                # Recovery snapshots
                {
                  name = "snapshots";
                  mountpoint = "/.snapshots";
                  compress = "zstd:3";
                }
              ];
            };
          };
        };
      };
    };
    
    "nvme1n1" = {  # Secondary NVMe - Data
      type = "disk";
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        btrfsConfig = {
          label = "zephyrus-data";
          features = [ "block-group-tree" ];
        };
        
        subvolumes = [
          {
            name = "databases";
            mountpoint = "/mnt/databases";
            compress = "zstd:1";
            mountOptions = [ "nodatacow" ];
            performance = "maximum";
          }
          
          {
            name = "container-data";
            mountpoint = "/mnt/container-data";
            compress = "zstd:1";
            mountOptions = [ "nodatacow" ];
            performance = "maximum";
          }
          
          {
            name = "backup";
            mountpoint = "/mnt/backup";
            compress = "zstd:3";
            retentionPolicy = "90-days";
          }
          
          {
            name = "tmp-high-performance";
            mountpoint = "/mnt/tmp";
            compress = "zstd:1";
            mountOptions = [ "nodatacow" ];
            performance = "maximum";
            cleanupInterval = "daily";
          }
        ];
      };
    };
  };
};
```

### Performance Strategy
- **Primary NVMe**: System, user data, and active containers
- **Secondary NVMe**: High-performance data, databases, and temporary files
- **RAID Options**: Btrfs RAID1 for data safety, RAID0 for maximum performance
- **Compression**: Fast compression (zstd:1) for performance-critical data
- **NoCopy-on-Write**: Disabled for databases and large model files

## Known Issues

### Hardware Compatibility
- **NVIDIA Driver Issues**: RTX 3070 Ti/3080 Ti may experience instability with open drivers
  - **Workaround**: Use NVIDIA proprietary driver (470+)
  - **Configuration**: `hardware.nvidia.modesetting.enable = false`
- **2.5G Ethernet**: Realtek 2.5G may have driver stability issues
  - **Workaround**: Use r8125 vendor driver or fallback to 1G
- **WiFi 6E**: Limited Linux driver support for 6GHz band on some models
  - **Workaround**: Fallback to 5GHz/2.4GHz bands

### Thermal Issues
- **Sustained Load**: CPU may thermal throttle under prolonged heavy load
  - **Prevention**: Use Turbo mode with high-performance cooling
  - **Monitoring**: `sensors` command to track CPU/GPU temps
- **GPU Thermal Throttling**: RTX 3070 Ti/3080 Ti reaches thermal limit quickly
  - **Management**: Custom fan curves, thermal pads, cooling pad recommended
- **Liquid Metal**: Potential for evaporation over time
  - **Maintenance**: Professional service recommended after 2-3 years

### Performance Issues
- **Memory Bandwidth**: DDR5-4800 may bottleneck on intensive AI workloads
  - **Upgrade**: Consider DDR5-6400 memory if available
- **NVMe Thermal Throttling**: High-speed PCIe 4.0 drives throttle under load
  - **Solution**: Thermal pads on NVMe drives, case fans for cooling
- **USB-C Bandwidth**: Multiple high-bandwidth devices may saturate bandwidth
  - **Management**: Prioritize critical devices, use dedicated controllers

### Linux-Specific Issues
- **NVIDIA Optimus**: Hybrid graphics switching may require manual configuration
  - **Solution**: Use PRIME render offload for optimal battery/perf balance
- **RGB Keyboard**: Limited control under Linux (basic on/off only)
  - **Workaround**: ASUS Aura SDK or basic sysfs interface
- **Touchpad Gestures**: Some multi-touch gestures may not work perfectly
  - **Solution**: libinput configuration adjustments

### AI/ML Specific Issues
- **CUDA Compatibility**: Newer CUDA versions may not support older RTX cards
  - **Management**: Pin CUDA version for stability
- **Memory Requirements**: Large AI models may exceed 16GB VRAM
  - **Solution**: CPU offloading, gradient checkpointing, or model sharding
- **Storage I/O**: Large dataset processing may saturate NVMe bandwidth
  - **Optimization**: Use secondary NVMe for datasets, primary for models

## Performance Benchmarks

### Expected Performance Characteristics
```bash
# CPU Performance
Geekbench 6 Single-Core: ~2000-2200 points
Geekbench 6 Multi-Core: ~12000-14000 points
CPU Mark: ~25000-28000

# GPU Performance (RTX 3070 Ti)
3DMark Time Spy: ~11000-12000 points
CUDA Compute: ~15-16 TFLOPS
RT Performance: ~25-30 TFLOPS (with RT cores)

# Storage Performance (Primary NVMe)
Sequential Read: 7000 MB/s
Sequential Write: 5000 MB/s
Random Read IOPS: ~1M
Random Write IOPS: ~850K

# Secondary NVMe (same specs)
Storage Bandwidth: 14 GB/s total

# Memory Performance
Memory Bandwidth: ~75 GB/s (DDR5-4800)
Memory Latency: 40-50ns

# AI/ML Performance
PyTorch FP32: ~12 TFLOPS (GPU)
PyTorch FP16: ~24 TFLOPS (GPU)
CPU Training: ~800 GFLOPS
```

### Container Performance
```bash
# Podman container performance
Container Build Time: ~50% faster than Yoga
Concurrent Containers: 20+ containers simultaneously
Memory per Container: 2-4GB typical
Network Throughput: 10+ Gbps with 2.5G Ethernet
Storage I/O: 100K+ IOPS per container
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
- **Disk Layout**: `../../hosts/zephyrus/disko.nix`
- **System Configuration**: `../../hosts/zephyrus/default.nix`
- **Hardware Configuration**: `../../hosts/zephyrus/hardware.nix`

---

**Maintained by:** hbohlen  
**Last Updated:** 2025-11-20  
**Version:** 1.0