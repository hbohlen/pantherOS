# ASUS ROG Zephyrus M16 GU603ZW - Hardware & Firmware Scan

## System Overview
- **Model**: ASUS ROG Zephyrus M16 GU603ZW
- **CPU**: 12th Gen Intel Core i9-12900H (14-core: 6P+8E, 20 threads)
- **RAM**: 40GB DDR5
- **Display**: 2560x1600 @ 60Hz
- **OS**: NixOS 25.11 (Xantusia), Kernel 6.12.54

## CPU Details
- **Architecture**: x86_64
- **Base Clock**: 1.4GHz average, 400MHz minimum
- **Boost Clock**: 4.9GHz (P-cores), 3.8GHz (E-cores)
- **Features**: Intel VT-x, AES-NI, AVX2, AVX-512, Thunderbolt 3/4
- **Power Management**: Intel P-State driver with HWP (Hardware P-States)

## Graphics Configuration
### Integrated GPU (iGPU)
- **Model**: Intel Alder Lake-P GT2 [Iris Xe Graphics]
- **Device ID**: 8086:46a6
- **Driver**: i915 (kernel module)
- **Memory**: 256MB prefetchable + 16MB non-prefetchable

### Discrete GPU (dGPU)
- **Model**: NVIDIA GA104 [GeForce RTX 3070 Ti Laptop GPU]
- **Device ID**: 10de:24a0
- **Driver**: nvidia (kernel module)
- **Memory**: 8GB VRAM + 32MB prefetchable
- **Audio**: NVIDIA High Definition Audio Controller (10de:228b)

### Graphics Switching
- **Type**: Hybrid graphics with Optimus-like switching
- **Backlight**: NVIDIA backlight control (nvidia_0)
- **Current State**: Both GPUs detected, NVIDIA driver active

## Storage Configuration
### Primary Storage (nvme0n1)
- **Model**: Micron 2450 MTFDKBA1T0TFK
- **Capacity**: 953.87GB
- **Usage**: Encrypted LUKS container with Btrfs filesystem
- **Mounts**: Root (/), /home, /nix, /swap

### Secondary Storage (nvme1n1)
- **Model**: Crucial CT2000P310SSD8
- **Capacity**: 1.82TB
- **Usage**: Boot partition (512MB VFAT) + data partition

### Swap Configuration
- **ZRAM**: 19.43GB compressed swap
- **File swap**: 8GB swapfile
- **Total Swap**: ~27.43GB

## Power & Battery
- **Battery**: 90Wh design capacity, 72.9Wh current (81% health)
- **Current Charge**: 39.6Wh (54.3%)
- **Status**: Discharging
- **AC Adapter**: Status not accessible via standard sysfs

## Thermal Management
### Thermal Zones
- INT3400 Thermal (Intel thermal framework)
- SEN1-4 (Various sensors)
- acpitz (ACPI thermal zone)
- x86_pkg_temp (CPU package temperature)
- TCPU/TCPU_PCI (CPU thermal sensors)
- iwlwifi_1 (WiFi thermal sensor)

### Current Temperatures
- **CPU**: 45.0°C
- **Fan Speed**: 3100 RPM

## USB & Peripherals
- **Webcam**: IMC Networks USB2.0 HD UVC WebCam
- **Bluetooth**: Intel AX211 Bluetooth
- **N-KEY Device**: ASUS N-KEY keyboard controller
- **USB Hubs**: Multiple USB 2.0/3.0 root hubs

## Network Interfaces
- **WiFi**: wlo1 (state: up)
- **Ethernet**: eno2 (state: down)
- **VPN**: tailscale0 (state: unknown)

## Audio System
- **Server**: PipeWire 1.4.9 (active)
- **API**: ALSA kernel-api
- **Hardware**: NVIDIA HDMI audio + Intel audio codec

## Display & Desktop
- **Display Server**: Wayland with Niri compositor
- **Resolution**: 2560x1600 @ 60Hz
- **Graphics API**: EGL (needs eglinfo for details)

## Firmware & UEFI
- **UEFI**: American Megatrends LLC. v GU603ZW.311
- **Release Date**: 12/22/2022
- **Secure Boot**: Status unknown (requires elevated access)

## Performance Considerations
- **CPU Scaling**: Intel P-State with HWP support
- **Memory**: 40GB provides ample headroom for development workloads
- **Storage**: Dual NVMe setup allows for OS/data separation
- **Graphics**: Hybrid setup requires careful power management
- **Thermals**: Active cooling with multiple thermal zones

## NixOS-Specific Notes
- **Impermanence**: Encrypted root with Btrfs subvolumes
- **Swap**: ZRAM + file swap for memory pressure handling
- **Kernel**: Custom 6.12.54 kernel with PREEMPT_DYNAMIC
- **Desktop**: Niri Wayland compositor (tiling window manager)