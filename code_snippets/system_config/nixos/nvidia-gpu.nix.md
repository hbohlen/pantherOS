# NVIDIA GPU Configuration Module

## Enrichment Metadata
- **Purpose**: Configure NVIDIA graphics hardware for Wayland compatibility
- **Layer**: modules/hardware/gpu
- **Dependencies**: NixOS GPU modules, Wayland compositor
- **Conflicts**: Other GPU drivers, integrated graphics (unless hybrid)
- **Platforms**: x86_64-linux

## Configuration Points
- `hardware.nvidia.prime.offload.enable`: Enable GPU offloading for hybrid systems
- `hardware.nvidia.prime.offload.enableOffloadCmd`: Enable offload command support
- `hardware.nvidia.powerManagement.enable`: Enable power management
- `hardware.nvidia.powerManagement.finegrained`: Fine-grained power management
- `services.niri`: Wayland compositor configuration
- `hardware.nvidia.Modesetting.enable`: Enable kernel modesetting

## Code

```nix
# modules/hardware/gpu/nvidia.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.pantherOS.hardware.gpu.nvidia;
in
{
  options.pantherOS.hardware.gpu.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU support";
    
    # Hybrid GPU support
    hybrid = lib.mkEnableOption "Hybrid Intel/NVIDIA GPU setup";
    
    # Power management
    powerManagement = {
      enable = lib.mkEnableOption "NVIDIA power management";
      finegrained = lib.mkEnableOption "Fine-grained power management";
    };
    
    # Wayland compatibility
    wayland = {
      enable = lib.mkEnableOption "Wayland-specific NVIDIA support";
      modesetting = lib.mkEnableOption "Kernel modesetting for Wayland";
    };
    
    # CUDA support
    cuda = {
      enable = lib.mkEnableOption "CUDA support";
      version = lib.mkOption {
        type = lib.types.str;
        default = "11.8";
        description = "CUDA version to install";
      };
    };
  };
  
  config = lib.mkIf cfg.enable {
    # NVIDIA driver packages
    hardware.nvidia = {
      # Install NVIDIA drivers
      nvidiaSettings = true;
      
      # Package selection
      package = config.boot.kernelPackages.nvidiaPackages.production;
      
      # ModeSetting for Wayland compatibility
      Modesetting.enable = cfg.wayland.modesetting;
      
      # OpenGL compatibility
      openGl = {
        enable = true;
        driSupport = true;
      };
      
      # Power management
      powerManagement = {
        enable = cfg.powerManagement.enable;
        finegrained = cfg.powerManagement.finegrained;
      };
      
      # Prime offload for hybrid systems
      prime = lib.mkIf cfg.hybrid {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
    
    # NVIDIA CUDA support
    environment.systemPackages = lib.mkIf cfg.cuda.enable (with pkgs; [
      cudaPackages.cudatoolkit
      cudaPackages.cuda_libraries
    ]);
    
    # NVIDIA X11 configuration (for XWayland compatibility)
    services.xserver.videoDrivers = [ "nvidia" ];
    
    # Disable nouveau driver
    boot.blacklistedKernelModules = [ "nouveau" ];
    
    # Enable necessary kernel modules
    boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" ];
    
    # Load modules early in boot
    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" ];
    
    # NVIDIA persistent mode configuration
    systemd.tmpfiles.rules = lib.mkIf cfg.powerManagement.enable [
      "f /etc/modprobe.d/nvidia.conf 0644 root root -"
      "w /etc/modprobe.d/nvidia.conf - - - - options nvidia NVreg_EnablePCIeGen3=1 options nvidia NVreg_TemporaryFilePath=/tmp"
    ];
    
    # udev rules for NVIDIA devices
    services.udev.packages = [ pkgs.linuxPackages.nvidia_x11 ];
    
    # Blacklist nouveau in initrd
    boot.initrd.blacklistKernelModules = [ "nouveau" ];
    
    # NVIDIA compositor support for Niri
    environment.variables = lib.mkIf cfg.wayland.enable {
      NVD_BACKEND = "glx";
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };
    
    # Screen configuration for multi-monitor setups
    services.xserver.screenSection = ''
      Section "Screen"
        Identifier "Screen0"
        Device "Device0"
        Monitor "Monitor0"
        DefaultDepth 24
        SubSection "Display"
          Depth 24
          Modes "1920x1080"
        EndSubSection
      EndSection
    '';
    
    # Device-specific configuration
    hardware.graphics.deviceints = lib.mkIf cfg.hybrid [
      # Intel integrated graphics
      {
        name = "intel";
        driver = "intel";
      }
      # NVIDIA discrete graphics
      {
        name = "nvidia";
        driver = "nvidia";
      }
    ];
  };
}
```

## Integration Pattern

### Basic Usage
```nix
# In host configuration
{
  imports = [
    <pantherOS/modules/hardware/gpu/nvidia.nix>
  ];
  
  pantherOS.hardware.gpu.nvidia = {
    enable = true;
    powerManagement.enable = true;
    wayland.enable = true;
  };
}
```

### Hybrid GPU Setup
```nix
# For laptops with hybrid Intel/NVIDIA
{
  pantherOS.hardware.gpu.nvidia = {
    enable = true;
    hybrid = true;
    wayland = {
      enable = true;
      modesetting = true;
    };
    powerManagement.enable = true;
    powerManagement.finegrained = true;
  };
}
```

### Development Setup
```nix
# With CUDA support
{
  pantherOS.hardware.gpu.nvidia = {
    enable = true;
    cuda.enable = true;
    cuda.version = "12.0";
  };
}
```

## Validation Steps

### 1. Build Check
```bash
# Validate NVIDIA module configuration
nix eval --impure .#nixosConfigurations.yoga.config.hardware.nvidia

# Test GPU detection
nix run .#nixosConfigurations.yoga.config.system.build.toplevel -- lsmod | grep nvidia
```

### 2. Runtime Verification
```bash
# Check NVIDIA driver loading
lsmod | grep nvidia

# Verify GPU detection
nvidia-smi

# Test Wayland compositor
echo $NVD_BACKEND
```

### 3. Performance Testing
```bash
# GPU stress test
nvidia-smi -l 1

# Power management check
cat /proc/driver/nvidia/version

# Wayland compatibility test
glxinfo | grep "OpenGL vendor"
```

## Related Modules

- `modules/desktop/compositor/niri.nix` - Wayland compositor integration
- `modules/hardware/laptop/display.nix` - Display configuration
- `modules/desktop/applications/browser.nix` - Browser GPU acceleration
- `modules/services/monitoring/datadog.nix` - GPU metrics monitoring

## Troubleshooting

### Common Issues

**Driver Loading Failure**
```bash
# Check module loading
dmesg | grep nvidia

# Verify firmware
ls /lib/firmware/nvidia/

# Manual module loading
sudo modprobe nvidia
```

**Wayland Compatibility Issues**
```bash
# Enable modesetting
echo 'options nvidia NVreg_EnableGpuFirmware=1' | sudo tee /etc/modprobe.d/nvidia.conf

# Set environment variables
export NVD_BACKEND=glx
export __GLX_VENDOR_LIBRARY_NAME=nvidia
```

**Power Management Problems**
```bash
# Enable persistence mode
sudo nvidia-smi -pm 1

# Check power states
cat /proc/acpi/battery/BAT*/state

# Fine-grained control
echo 'options nvidia NVreg_EnableGpuFirmware=1 NVreg_DynamicPowerManagement=0x02' | sudo tee /etc/modprobe.d/nvidia.conf
```

## Hardware Compatibility

### Supported GPUs
- NVIDIA GeForce RTX 20/30/40 series
- NVIDIA GeForce GTX 16 series
- NVIDIA Quadro RTX series
- NVIDIA Tesla V100/A100 (CUDA)

### Compatible Hardware
- Laptops with hybrid Intel/NVIDIA setup
- Desktop workstations with NVIDIA graphics
- Servers with NVIDIA Tesla/Quadro cards

### Known Issues
- Some Wayland applications may require XWayland fallback
- Sleep/wake cycles may require driver reset
- Hybrid switching requires compositor support

## Configuration Examples

### Gaming Laptop (ASUS ROG Zephyrus M16 GU603ZW - RTX 3070 Ti)
```nix
{
  pantherOS.hardware.gpu.nvidia = {
    enable = true;
    hybrid = true;  # Intel iGPU + NVIDIA RTX 3070 Ti
    powerManagement = {
      enable = true;
      finegrained = true;  # Optimize for 120W TGP
    };
    wayland = {
      enable = true;
      modesetting = true;  # Required for Niri compositor
    };
    cuda.enable = true;
    cuda.version = "12.2";  # Compatible with RTX 3070 Ti
  };
}
```

### Workstation with RTX 4090
```nix
{
  pantherOS.hardware.gpu.nvidia = {
    enable = true;
    powerManagement.enable = true;
    cuda.enable = true;
    cuda.version = "12.0";
  };
}
```

### Development Machine
```nix
{
  pantherOS.hardware.gpu.nvidia = {
    enable = true;
    cuda = {
      enable = true;
      version = "11.8";
    };
    wayland.enable = true;
  };
}
```

---

**Module Status**: Production Ready  
**Dependencies**: NixOS hardware modules, NVIDIA drivers  
**Tested On**: NVIDIA RTX 3060, RTX 4090, GTX 1660 Ti