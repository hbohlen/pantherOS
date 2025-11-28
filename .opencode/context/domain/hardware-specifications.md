# Hardware Specifications and Optimization

## Overview

This document contains hardware specifications, optimization strategies, and hardware-specific configurations for all pantherOS hosts.

## Host Hardware Profiles

### Workstation Hardware

#### Lenovo Yoga 7 2-in-1 14AKP10 (yoga)

**System Information:**

- **CPU**: Intel Core i7-1260P (12 cores: 4P + 8E, up to 4.7GHz)
- **GPU**: Intel Iris Xe Graphics (96 EUs)
- **RAM**: 16GB LPDDR5 (soldered, dual-channel)
- **Storage**: 512GB NVMe SSD (PCIe 4.0)
- **Display**: 14" 2.8K (2880x1800) IPS touchscreen
- **Battery**: 71Whr, up to 18 hours
- **Weight**: 1.4kg

**Optimization Strategy:**

- **Power Management**: Battery life prioritized
- **CPU Governor**: `powersave` with boost on demand
- **Storage**: Btrfs with compression and SSD optimization
- **Graphics**: Integrated GPU power saving
- **Thermal**: Conservative thermal profile

**NixOS Configuration:**

```nix
# hosts/yoga/hardware.nix
{ pkgs, ... }:

{
  # CPU configuration
  powerManagement.cpuFreqGovernor = "powersave";
  hardware.cpu.intel.updateMicrocode = true;

  # Graphics
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [ intel-media-driver ];

  # Storage optimization
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Power management
  powerManagement.enable = true;
  services.tlp.enable = true;
  services.thermald.enable = true;

  # Audio
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Touchscreen and input
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
    };
  };
}
```

#### ASUS ROG Zephyrus M16 GU603ZW (zephyrus)

**System Information:**

- **CPU**: Intel Core i9-12900H (14 cores: 6P + 8E, up to 5.0GHz)
- **GPU**: NVIDIA RTX 3070 Ti (8GB GDDR6) + Intel Iris Xe
- **RAM**: 32GB DDR5 4800MHz (2x16GB, upgradeable to 64GB)
- **Storage**: 1TB NVMe SSD (PCIe 4.0) + 1TB NVMe SSD (secondary)
- **Display**: 16" QHD (2560x1600) 165Hz IPS
- **Cooling**: Liquid metal thermal compound + vapor chamber
- **RGB**: Per-key RGB keyboard

**Optimization Strategy:**

- **Performance**: Raw performance prioritized
- **CPU Governor**: `performance` with thermal management
- **GPU**: NVIDIA Optimus with PRIME
- **Storage**: Dual SSD with performance optimization
- **Thermal**: Aggressive cooling profile

**NixOS Configuration:**

```nix
# hosts/zephyrus/hardware.nix
{ pkgs, ... }:

{
  # CPU configuration
  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = true;

  # Graphics (NVIDIA Optimus)
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    nvidiaPackages.beta
  ];
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA configuration
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;  # Use proprietary driver
    nvidiaSettings = true;
  };

  # Storage optimization
  boot.kernel.sysctl = {
    "vm.swappiness" = 5;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;
  };

  # High-performance settings
  powerManagement.enable = false;  # Disable for performance
  services.thermald.enable = false;  # Use ROG cooling

  # Gaming/development optimizations
  boot.kernelParams = [
    "nvidia.NVreg_RegistryDwords=PowerMizerEnable=0x1"
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];
}
```

### Server Hardware

#### Hetzner Cloud VPS (hetzner-vps)

**System Information:**

- **CPU**: AMD EPYC 7763 (8 vCPUs, 2.45GHz base)
- **RAM**: 32GB DDR4 ECC
- **Storage**: 240GB NVMe SSD
- **Network**: 1Gbps public + 10Gbps private
- **Location**: Nuremberg, Germany
- **Backup**: Daily snapshots + weekly offsite

**Optimization Strategy:**

- **Server Workloads**: Optimized for services and containers
- **CPU Governor**: `ondemand` with performance boost
- **Storage**: Btrfs with server optimization
- **Network**: Optimized for throughput
- **Security**: Server hardening

**NixOS Configuration:**

```nix
# hosts/hetzner-vps/hardware.nix
{ pkgs, ... }:

{
  # CPU configuration
  powerManagement.cpuFreqGovernor = "ondemand";
  hardware.cpu.amd.updateMicrocode = true;

  # Server optimization
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 65536 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    "vm.swappiness" = 10;
    "fs.file-max" = 2097152;
  };

  # Storage optimization
  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_expire_centisecs" = 12000;
    "vm.dirty_writeback_centisecs" = 1500;
  };

  # Network optimization
  boot.kernel.sysctl = {
    "net.core.netdev_max_backlog" = 5000;
    "net.core.somaxconn" = 65535;
    "net.ipv4.tcp_max_syn_backlog" = 65535;
  };

  # Server-specific packages
  environment.systemPackages = with pkgs; [
    htop
    iotop
    nload
    tcpdump
    strace
  ];
}
```

#### OVH Cloud VPS (ovh-vps)

**System Information:**

- **CPU**: Intel Xeon E5-2670 (8 vCPUs, 2.6GHz base)
- **RAM**: 16GB DDR4 ECC
- **Storage**: 160GB SSD
- **Network**: 1Gbps public + 10Gbps private
- **Location**: Paris, France
- **Backup**: Daily snapshots + weekly offsite

**Optimization Strategy:**

- **Backup Server**: Optimized for redundancy and backup
- **CPU Governor**: `conservative` for stability
- **Storage**: Btrfs with backup optimization
- **Network**: Optimized for backup traffic
- **Reliability**: Maximum stability

**NixOS Configuration:**

```nix
# hosts/ovh-vps/hardware.nix
{ pkgs, ... }:

{
  # CPU configuration
  powerManagement.cpuFreqGovernor = "conservative";
  hardware.cpu.intel.updateMicrocode = true;

  # Reliability optimization
  boot.kernel.sysctl = {
    "vm.panic_on_oops" = 1;
    "vm.panic_on_unrecovered_nmi" = 1;
    "kernel.panic" = 10;
    "vm.swappiness" = 5;
  };

  # Storage optimization (backup focus)
  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 10;
    "vm.dirty_expire_centisecs" = 6000;
    "vm.dirty_writeback_centisecs" = 500;
  };

  # Network optimization (backup traffic)
  boot.kernel.sysctl = {
    "net.core.rmem_default" = 262144;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_default" = 262144;
    "net.core.wmem_max" = 16777216;
  };
}
```

## Hardware-Specific Modules

### CPU Optimization Module

```nix
# modules/nixos/hardware/cpu-optimization.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.cpu-optimization;
in {
  options.hardware.cpu-optimization = {
    enable = mkEnableOption "CPU optimization";

    profile = mkOption {
      type = types.enum [ "performance" "balanced" "powersave" ];
      default = "balanced";
      description = "CPU optimization profile";
    };

    vendor = mkOption {
      type = types.enum [ "intel" "amd" "auto" ];
      default = "auto";
      description = "CPU vendor for optimizations";
    };
  };

  config = mkIf cfg.enable {
    # CPU frequency governor
    powerManagement.cpuFreqGovernor = {
      performance = "performance";
      balanced = "ondemand";
      powersave = "powersave";
    }.${cfg.profile};

    # Microcode updates
    hardware.cpu = {
      intel.updateMicrocode = cfg.vendor == "intel" || cfg.vendor == "auto";
      amd.updateMicrocode = cfg.vendor == "amd" || cfg.vendor == "auto";
    };

    # Profile-specific optimizations
    boot.kernel.sysctl = {
      # Performance profile
      "vm.swappiness" = mkIf (cfg.profile == "performance") 1;
      "vm.vfs_cache_pressure" = mkIf (cfg.profile == "performance") 50;

      # Balanced profile
      "vm.swappiness" = mkIf (cfg.profile == "balanced") 10;
      "vm.vfs_cache_pressure" = mkIf (cfg.profile == "balanced") 50;

      # Power save profile
      "vm.swappiness" = mkIf (cfg.profile == "powersave") 20;
      "vm.vfs_cache_pressure" = mkIf (cfg.profile == "powersave") 75;
    };
  };
}
```

### Storage Optimization Module

```nix
# modules/nixos/hardware/storage-optimization.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.hardware.storage-optimization;
in {
  options.hardware.storage-optimization = {
    enable = mkEnableOption "Storage optimization";

    profile = mkOption {
      type = types.enum [ "performance" "balanced" "longevity" ];
      default = "balanced";
      description = "Storage optimization profile";
    };

    ssd = mkOption {
      type = types.bool;
      default = true;
      description = "Optimize for SSD storage";
    };
  };

  config = mkIf cfg.enable {
    # SSD-specific optimizations
    boot.kernel.sysctl = mkIf cfg.ssd {
      "vm.swappiness" = {
        performance = 1;
        balanced = 10;
        longevity = 20;
      }.${cfg.profile};

      "vm.vfs_cache_pressure" = {
        performance = 50;
        balanced = 50;
        longevity = 75;
      }.${cfg.profile};

      "vm.dirty_ratio" = {
        performance = 5;
        balanced = 10;
        longevity = 15;
      }.${cfg.profile};

      "vm.dirty_background_ratio" = {
        performance = 2;
        balanced = 5;
        longevity = 10;
      }.${cfg.profile};

      "vm.dirty_expire_centisecs" = {
        performance = 3000;
        balanced = 6000;
        longevity = 12000;
      }.${cfg.profile};

      "vm.dirty_writeback_centisecs" = {
        performance = 500;
        balanced = 1500;
        longevity = 3000;
      }.${cfg.profile};
    };

    # I/O scheduler
    services.udev.extraRules = mkIf cfg.ssd ''
      # Use deadline scheduler for SSDs
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"

      # Enable NCQ for SSDs
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/nr_requests}="128"
    '';
  };
}
```

## Hardware Discovery Process

### Automated Scanning

```bash
#!/bin/bash
# hardware-scan.sh - Comprehensive hardware scanning

echo "=== Hardware Scan for $(hostname) ==="
echo "Date: $(date)"
echo ""

# CPU Information
echo "=== CPU Information ==="
lscpu | grep -E "(Model name|CPU\(s\)|Thread|Core|Socket)"
cat /proc/cpuinfo | grep -E "(model name|cpu MHz)" | head -1
echo ""

# Memory Information
echo "=== Memory Information ==="
free -h
echo ""
dmidecode -t memory | grep -E "(Size|Type|Speed|Manufacturer)" | head -20
echo ""

# Storage Information
echo "=== Storage Information ==="
lsblk -f
echo ""
for disk in /dev/sd?; do
  if [[ -b "$disk" ]]; then
    echo "Disk: $disk"
    sudo smartctl -i "$disk" | grep -E "(Device Model|Serial Number|Capacity|Rotation Rate)"
    echo ""
  fi
done
echo ""

# GPU Information
echo "=== GPU Information ==="
lspci -v | grep -A 20 VGA
echo ""
if command -v nvidia-smi &> /dev/null; then
  nvidia-smi
  echo ""
fi
echo ""

# Network Information
echo "=== Network Information ==="
ip addr show
echo ""
lspci | grep -i network
echo ""

# Audio Information
echo "=== Audio Information ==="
aplay -l
echo ""
cat /proc/asound/cards
echo ""

# USB Information
echo "=== USB Information ==="
lsusb
echo ""

# System Information
echo "=== System Information ==="
dmidecode -t system | grep -E "(Manufacturer|Product Name|Version|Serial Number)"
echo ""

# BIOS Information
echo "=== BIOS Information ==="
dmidecode -t bios | grep -E "(Vendor|Version|Release Date)"
echo ""

echo "=== Hardware Scan Complete ==="
```

### Hardware Profile Generation

```python
#!/usr/bin/env python3
# hardware-profile.py - Generate hardware profile

import subprocess
import json
import re
from datetime import datetime

def run_command(cmd):
    """Run command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip()
    except:
        return ""

def get_cpu_info():
    """Get CPU information"""
    cpu_info = {}

    # Get CPU model
    model = run_command("grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs")
    cpu_info["model"] = model

    # Get core count
    cores = run_command("nproc")
    cpu_info["cores"] = int(cores)

    # Get thread count
    threads = run_command("grep -c processor /proc/cpuinfo")
    cpu_info["threads"] = int(threads)

    # Get CPU frequency
    freq = run_command("lscpu | grep 'CPU max MHz' | awk '{print $4}'")
    if freq:
        cpu_info["max_frequency_mhz"] = float(freq)

    return cpu_info

def get_memory_info():
    """Get memory information"""
    mem_info = {}

    # Get total memory
    total = run_command("free -h | grep Mem | awk '{print $2}'")
    mem_info["total"] = total

    # Get memory details from dmidecode
    try:
        output = run_command("sudo dmidecode -t memory")
        # Parse memory details
        size_match = re.search(r"Size: (\d+ \w+)", output)
        if size_match:
            mem_info["module_size"] = size_match.group(1)

        type_match = re.search(r"Type: (\w+)", output)
        if type_match:
            mem_info["type"] = type_match.group(1)

        speed_match = re.search(r"Speed: (\d+ \w+)", output)
        if speed_match:
            mem_info["speed"] = speed_match.group(1)
    except:
        pass

    return mem_info

def get_storage_info():
    """Get storage information"""
    storage_info = []

    # Get block devices
    devices = run_command("lsblk -d -o NAME,SIZE,ROTA,MODEL | grep -v NAME").split('\n')

    for device in devices:
        if device.strip():
            parts = device.split()
            if len(parts) >= 4:
                storage_info.append({
                    "device": f"/dev/{parts[0]}",
                    "size": parts[1],
                    "rotational": parts[2] == "1",
                    "model": " ".join(parts[3:])
                })

    return storage_info

def get_gpu_info():
    """Get GPU information"""
    gpu_info = []

    # Get PCI devices
    output = run_command("lspci -v")
    gpu_sections = output.split('\n\n')

    for section in gpu_sections:
        if "VGA" in section:
            gpu = {}

            # Get device name
            name_match = re.search(r"(.+): (.+ \[.+\])", section)
            if name_match:
                gpu["name"] = name_match.group(2)

            # Get memory
            mem_match = re.search(r"Memory at (.+) \((.+)\)", section)
            if mem_match:
                gpu["memory"] = mem_match.group(2)

            gpu_info.append(gpu)

    return gpu_info

def get_network_info():
    """Get network information"""
    network_info = []

    # Get network interfaces
    output = run_command("ip addr show")
    interfaces = output.split('\n\n')

    for interface in interfaces:
        if "state UP" in interface:
            name_match = re.search(r"^\d+: (\w+):", interface)
            if name_match:
                network_info.append({
                    "name": name_match.group(1),
                    "status": "UP"
                })

    return network_info

def generate_hardware_profile():
    """Generate complete hardware profile"""
    profile = {
        "hostname": run_command("hostname"),
        "timestamp": datetime.now().isoformat(),
        "cpu": get_cpu_info(),
        "memory": get_memory_info(),
        "storage": get_storage_info(),
        "gpu": get_gpu_info(),
        "network": get_network_info()
    }

    return profile

if __name__ == "__main__":
    profile = generate_hardware_profile()

    # Save as JSON
    with open(f"hardware-profile-{profile['hostname']}.json", "w") as f:
        json.dump(profile, f, indent=2)

    print(f"Hardware profile saved: hardware-profile-{profile['hostname']}.json")
```

## Hardware Optimization Guidelines

### CPU Optimization

#### Workstation Optimization

- **Performance Mode**: Maximum clock speeds, aggressive turbo
- **Balanced Mode**: Dynamic scaling based on load
- **Power Save Mode**: Reduced frequencies, extended battery life

#### Server Optimization

- **Performance Mode**: High clock speeds for compute workloads
- **Balanced Mode**: On-demand scaling with boost
- **Efficiency Mode**: Conservative scaling for 24/7 operation

### Storage Optimization

#### SSD Optimization

- **Filesystem**: Btrfs with compression (zstd:1)
- **Mount Options**: `noatime,compress=zstd:1,ssd,space_cache`
- **TRIM**: Weekly TRIM operations
- **Swap**: Minimal swap on SSD systems

#### HDD Optimization (if applicable)

- **Filesystem**: Btrfs with compression (zstd:3)
- **Mount Options**: `noatime,compress=zstd:3,space_cache`
- **Scheduler**: `deadline` or `cfq`
- **Swap**: Adequate swap for memory pressure

### Memory Optimization

#### Workstation Memory

- **ZRAM**: Enable for compressed swap
- **Swappiness**: 10-20 for balanced performance
- **Cache Pressure**: 50 for balanced caching

#### Server Memory

- **ZRAM**: Enable for memory efficiency
- **Swappiness**: 5-10 for performance focus
- **Cache Pressure**: 50-75 for server workloads

## Integration Points

- **Hardware Discovery Agent**: Automated scanning and profiling
- **Module Generator**: Hardware-specific module creation
- **Security Agent**: Hardware security features
- **Deployment Orchestrator**: Hardware-aware deployment
- **Observability Agent**: Hardware performance monitoring

---

This document provides comprehensive hardware specifications and optimization strategies for all pantherOS hosts.
