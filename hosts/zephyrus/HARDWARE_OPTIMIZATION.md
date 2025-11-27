# ASUS ROG Zephyrus G15 Hardware Optimization

## Overview

This configuration uses a **hybrid approach** that combines community-validated base configurations from `nixos-hardware` with comprehensive custom optimizations tailored to your specific hardware profile.

## Configuration Structure

```
hosts/zephyrus/
├── default.nix           # Main host configuration (imports meta.nix)
├── meta.nix             # Hybrid hardware configuration
├── disko.nix            # Disk configuration
├── hardware.nix         # Legacy (now replaced by meta.nix)
└── HARDWARE_OPTIMIZATION.md  # This documentation
```

## Hybrid Approach Benefits

### Base Configuration (nixos-hardware)
- **GU603H profile**: Community-tested configuration specifically for your laptop model
- **NVIDIA Prime**: Hybrid graphics setup with proper bus ID configuration
- **Intel CPU**: Standard optimizations for 12th Gen Intel processors
- **Laptop Support**: Generic laptop hardware enablement
- **SSD Support**: NVMe SSD optimizations

### Custom Optimizations
- **Advanced Kernel Parameters**: Alder Lake + NVIDIA specific tuning
- **WiFi 6E Optimization**: Intel AX211 specific configurations
- **Bluetooth 5.3**: Enhanced settings for latest Bluetooth
- **ASUS ROG Features**: Complete support for laptop-specific controls
- **Performance Tuning**: CPU governors, thermal management, power profiles
- **Hardware Monitoring**: Comprehensive tools for system monitoring

## Key Hardware Components

| Component | Model | Configuration |
|-----------|-------|---------------|
| CPU | Intel Core i9-12900H | Alder Lake optimizations |
| GPU | Intel Iris Xe + NVIDIA RTX 3060/3070 | Prime hybrid setup |
| Storage | Dual NVMe SSDs (2TB + 1TB) | SSD optimizations + fstrim |
| Network | Intel AX211 WiFi 6E + Realtek Ethernet | WiFi 6E + Bluetooth 5.3 |
| Display | 2560×1600 internal + external | Multi-monitor support |
| Peripherals | ASUS keyboard, Elan touchpad, webcam | Full support |

## Configuration Highlights

### Graphics
- **NVIDIA Prime Offloading**: Enable with `nvidia-offload` command
- **Intel Integration**: Hardware-accelerated video decoding
- **Vulkan Support**: Full GPU compute and gaming support
- **Wayland Compatibility**: Enhanced for modern desktop environments

### Performance
- **CPU Governor**: Performance mode for sustained high performance
- **Memory Management**: Optimized for 64GB RAM configuration
- **Thermal Management**: Enhanced cooling profiles for gaming workloads
- **Power Profiles**: Automatic switching between performance and battery saver

### Connectivity
- **WiFi 6E**: Latest wireless standard with 6GHz band support
- **Bluetooth 5.3**: Enhanced audio and device connectivity
- **Ethernet**: High-speed wired connectivity optimization

## Usage

### For Gaming
The system is optimized for gaming workloads with:
- NVIDIA discrete GPU for graphics-intensive applications
- Performance CPU governor for maximum responsiveness
- Enhanced thermal management for sustained performance

### For Development
Configured for development with:
- High-performance CPU settings for compilation
- Multiple monitor support for productivity
- Comprehensive development tools and monitoring

### For Battery Life
When needed, the system includes battery optimization features:
- Intel integrated graphics for power efficiency
- Power management profiles
- WiFi power saving optimizations

## Maintenance

### Updates
- **nixos-hardware**: Updates automatically through channel
- **Custom optimizations**: Maintained in `meta.nix`
- **Hardware profiles**: Can be extended as needed

### Monitoring
The configuration includes comprehensive monitoring tools:
- `nvtop`: GPU and system monitoring
- `intel-gpu-tools`: Intel graphics diagnostics
- `powertop`: Power consumption analysis
- `turbostat`: CPU performance monitoring

## Troubleshooting

### Graphics Issues
If you encounter graphics problems:
1. Check nvidia-offload is available: `which nvidia-offload`
2. Verify Prime setup: `nvidia-smi` should show NVIDIA GPU
3. Check Intel graphics: `intelgpu` tools should work

### Performance Issues
1. Ensure performance governor is active: `cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`
2. Check thermal status: `sensors` command
3. Monitor GPU usage: `nvidia-smi -l 1`

### Network Issues
1. Verify WiFi 6E support: `iw dev` should show your device
2. Check Bluetooth: `bluetoothctl list` should show devices
3. Test connectivity: `ping` and `speedtest-cli`

## Future Enhancements

Potential areas for future optimization:
- **Gaming profiles**: Specific profiles for different game types
- **Development profiles**: Optimizations for specific development workflows
- **Hardware monitoring**: Enhanced fan control and temperature management
- **Power management**: More granular battery optimization

## References

- [nixos-hardware repository](https://github.com/NixOS/nixos-hardware)
- [ASUS ROG Zephyrus G15](https://rog.asus.com/laptops/rog-zephyrus/)
- [NVIDIA Prime documentation](https://download.nvidia.com/XFree86/Linux-x86_64/470.57.06/README/prime.html)
- [Intel AX211 specifications](https://www.intel.com/content/www/us/en/products/details/connectivity/intel-wi-fi-6e/ax211.html)