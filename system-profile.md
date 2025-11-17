# ASUS ROG Zephyrus – System Profile

## Overview
- **Model**: ASUS ROG Zephyrus M16 GU603ZW
- **CPU**: 12th Gen Intel Core i9-12900H (14 cores: 6P+8E, 20 threads)
- **GPU(s)**: Intel Alder Lake-P GT2 [Iris Xe Graphics] + NVIDIA GA104 [GeForce RTX 3070 Ti Laptop GPU]
- **RAM**: 38GB (40GB total - 38GB available)
- **Storage devices**: 
  - Micron 2450 1TB NVMe (encrypted system)
  - Crucial P310 2TB NVMe (data)
- **Display**: 2560x1600 @ 60Hz (from previous scan)
- **Network**: Intel Alder Lake-P WiFi + Realtek RTL8125 2.5GbE Ethernet
- **Current distro / kernel**: NixOS 25.11 (Xantusia), Kernel 6.12.54
- **Boot mode**: UEFI 64-bit (confirmed via /sys/firmware/efi/fw_platform_size = 64)

## CPU
- **Model**: 12th Gen Intel Core i9-12900H
- **Cores/Threads**: 14 cores (6 Performance + 8 Efficient), 20 threads
- **Base/Boost**: 400MHz minimum, 4.9GHz boost (P-cores), 3.8GHz (E-cores)
- **Cache**: 544KB L1d, 704KB L1i, 11.5MB L2, 24MB L3
- **Flags**: VMX (Intel VT-x), AES-NI, AVX2, AVX-512, Thunderbolt support
- **Virtualization**: Intel VT-x with EPT, 1GB pages, unrestricted guest
- **NixOS Notes**: 
  - Intel microcode updates essential
  - HWP (Hardware P-States) support for fine-grained power control
  - Excellent virtualization host capabilities

## GPU & Graphics (Summary only; details in Prompt 2)
- **Discrete GPU**: NVIDIA GA104 [GeForce RTX 3070 Ti Laptop GPU]
- **Integrated GPU**: Intel Alder Lake-P GT2 [Iris Xe Graphics]
- **Current driver stack**: NVIDIA proprietary + Intel i915
- **Hybrid mode**: ASUS MUX switch with discrete GPU mode (asus_mux_discreet)
- **Graphics control**: supergfxctl available, currently in discrete mode

## Memory
- **Total RAM**: 40GB DDR5
- **Available**: 38GB (3.7GB used)
- **Swap**: 27GB total (19.4GB ZRAM + 8GB file swap)
- **Notes**: Ample memory for development workloads, ZRAM provides responsive swap

## Storage
- **Primary (nvme0n1)**: Micron 2450 MTFDKBA1T0TFK, 953.87GB
  - Encrypted LUKS container with Btrfs filesystem
  - Current layout: single partition covering entire system
- **Secondary (nvme1n1)**: Crucial CT2000P310SSD8, 1.82TB
  - 512MB VFAT boot partition
  - 1.8TB ext4 data partition (currently unused)
- **NixOS Layout Notes**: 
  - Current setup uses encrypted Btrfs with subvolumes for /, /home, /nix, /swap
  - Secondary drive available for data separation or backup
  - Good candidate for disko-based reproducible partitioning

## Networking
- **Wi-Fi**: Intel Alder Lake-P PCH CNVi WiFi (likely AX211 based on previous scan)
- **Ethernet**: Realtek RTL8125 2.5GbE Controller
- **Current Status**: WiFi active (192.168.4.133/22), Ethernet down
- **Additional**: Tailscale VPN interface present
- **Notes**: Both chipsets well-supported on Linux, 2.5GbE provides high-speed wired networking

## Audio
- **Primary**: Intel Alder Lake PCH-P High Definition Audio Controller
- **Secondary**: NVIDIA GA104 High Definition Audio Controller (HDMI/DP output)
- **Current Stack**: PipeWire 1.4.9 with ALSA backend
- **Notes**: Standard Intel HDA codec, NVIDIA audio for display output

## Sensors & Thermals
- **CPU Temperatures**: Package 66°C, cores ranging 50-66°C (idle)
- **Storage**: NVMe drives at 35-37°C
- **Fans**: CPU fan 3400 RPM, GPU fan 0 RPM (idle)
- **Battery**: 15.86V, 39.89W draw
- **Thermal Zones**: ACPI, coretemp, NVMe, WiFi, ASUS custom sensors
- **Notes**: Good thermal headroom, active fan control available

## ASUS / ROG-Specific Capabilities
- **asusctl**: v6.1.15 installed and functional
  - Keyboard brightness control (off/low/med/high)
  - Battery charge limiting (20-100%)
  - Performance profiles: Quiet/Balanced/Performance (currently Performance)
  - Fan curve control supported
  - Aura keyboard lighting control
- **supergfxctl**: v5.2.7 installed
  - Current mode: asus_mux_discrete
  - ASUS MUX switch support
  - Only discrete mode available (no Optimus switching)
- **Special Features**: 
  - ASUS MUX switch for direct dGPU output
  - Custom fan curves
  - RGB keyboard control
  - Battery charge limiting
  - Multiple performance profiles

## GPU & Display Stack – Detailed

### GPU Hardware
- **Integrated GPU**: Intel Alder Lake-P GT2 [Iris Xe Graphics]
  - PCI ID: 8086:46a6
  - Memory: 256MB prefetchable + 16MB non-prefetchable
  - Driver: i915 (kernel module loaded)
  - Status: Detected but not currently driving display

- **Discrete GPU**: NVIDIA GA104 [GeForce RTX 3070 Ti Laptop GPU]
  - PCI ID: 10de:24a0
  - VRAM: 8GB GDDR6
  - Driver: NVIDIA proprietary 580.95.05
  - Current Usage: 489MB/8192MB (6% utilization)
  - Temperature: 50°C, Power: 12W/55W
  - Status: Active and driving internal display

### Graphics Mode
- **Type**: ASUS MUX switch (not Optimus/PRIME)
- **Current Mode**: asus_mux_discrete (dGPU-only mode)
- **Display Output**: Internal panel (eDP-1) connected to NVIDIA dGPU
- **Session**: Wayland with Niri compositor
- **OpenGL**: 4.6.0 NVIDIA 580.95.05, full OpenGL ES 3.2 support

### Display Configuration
- **Internal Display**: eDP-1, 2560x1600 @ 60Hz (primary)
- **Resolution Support**: Wide range from 320x200 to 2560x1600
- **Refresh Rate**: 60Hz fixed (no VRR detected)
- **DRI Devices**: card1 (Intel), card2 (NVIDIA), renderD128/D129 available

### Audio Output
- **NVIDIA Audio**: GA104 High Definition Audio Controller (10de:228b)
- **Intel Audio**: Alder Lake PCH-P High Definition Audio Controller
- **Usage**: NVIDIA for HDMI/DP, Intel for analog/headphones

### NixOS GPU / Display Strategy (Draft)

#### Plugged-in (AC, Performance Mode)
```nix
{
  # NVIDIA proprietary driver for maximum performance
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # Enable NVIDIA settings and power management
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false; # Proprietary driver for RTX 3070 Ti
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
  
  # ASUS MUX switch - force discrete mode for performance
  hardware.nvidia.prime = {
    offload.enable = false; # Not using Optimus
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };
  
  # Kernel parameters for NVIDIA
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_RegistryDwords=PowerMizerEnable=0x1"
  ];
  
  # Enable supergfxctl service for graphics switching
  services.supergfxd.enable = true;
  
  # TODO: Check nixos-hardware for an ASUS ROG Zephyrus-specific module and include it here if available.
}
```

#### Battery/Light-Work Mode
```nix
{
  # For battery mode, we'd want to switch to integrated graphics
  # However, ASUS MUX switch requires reboot to change modes
  # Alternative approach: power limit the dGPU
  
  hardware.nvidia = {
    powerManagement.enable = true;
    powerManagement.finegrained = true; # Enable fine-grained power management
    # Reduce power limits for battery operation
    nvidiaSettings = true;
  };
  
  # Set lower power limits via nvidia-settings
  environment.shellAliases = {
    battery-gpu = "nvidia-smi -pl 30"; # Limit to 30W on battery
    performance-gpu = "nvidia-smi -pl 55"; # Full 55W on AC
  };
  
  # Use asusctl to set quiet profile
  programs.asusctl = {
    enable = true;
    enableUserService = true;
  };
  
  # Auto-switch to quiet profile on battery
  services.power-profiles-daemon.enable = true;
  systemd.services.asus-battery-profile = {
    description = "Set ASUS quiet profile on battery";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.asusctl}/bin/asusctl profile -p quiet";
      RemainAfterExit = true;
    };
  };
}
```

#### Display Configuration
```nix
{
  # Wayland/Niri configuration
  programs.niri = {
    enable = true;
    settings = {
      outputs = {
        "eDP-1" = {
          mode = {
            width = 2560;
            height = 1600;
            refresh = 60.0;
          };
          position = { x = 0; y = 0; };
        };
      };
    };
  };
  
  # Enable hardware video acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      intel-media-driver
    ];
  };
}
```

## NixOS-Relevant Notes (Initial)

- **CPU Governor**: Intel HWP support enables fine-grained power control
- **GPU Driver**: NVIDIA proprietary required for dGPU, Intel i915 for iGPU
- **Graphics Switching**: ASUS MUX switch (not Optimus) - requires reboot to change modes
- **Storage**: Current encrypted Btrfs setup is good foundation for disko
- **ASUS Integration**: asusctl/supergfxctl integration essential for full functionality
- **Power Management**: Multiple profiles available for performance vs battery life
- **Thermal Control**: Custom fan curves for optimized cooling
- **Memory**: ZRAM + file swap provides good memory pressure handling
- **UEFI**: 64-bit UEFI with secure boot capabilities
- **Virtualization**: Excellent VT-x support for VM/container workloads
- **Display**: Wayland+Niri with NVIDIA proprietary driver, 2560x1600 @ 60Hz
- **Graphics Strategy**: Use dGPU for performance, power limiting for battery (MUX switch limitation)

## Power & Thermals

### Current Tools and Daemons
- **power-profiles-daemon**: Active and running
  - Available profiles: performance, balanced, power-saver
  - Current profile: balanced (default)
  - CPU driver: intel_pstate
  - Platform driver: platform_profile
- **tlp**: Not installed
- **asusctl**: v6.1.15 installed and functional
  - Current profile: Performance
  - Fan curves: CPU enabled, GPU disabled
  - Available profiles: Quiet, Balanced, Performance
- **supergfxctl**: v5.2.7 installed (asus_mux_discrete mode)
- **cpupower**: Available via nix-shell for frequency management

### Thermal Behavior (From Sensors)
- **CPU Temperatures**: Package 66°C, cores ranging 50-66°C (idle)
- **GPU Temperature**: 50°C (idle, 12W/55W power usage)
- **Storage**: NVMe drives at 35-37°C
- **Fans**: CPU fan 3400 RPM, GPU fan 0 RPM (idle)
- **Thermal Headroom**: Excellent - plenty of headroom for performance tuning
- **Battery**: 48% capacity, currently discharging

### CPU Frequency & Governors
- **Driver**: Intel P-State with HWP (Hardware P-States)
- **Current Governor**: powersave (all cores)
- **Frequency Range**: 400MHz - 4.9GHz (P-cores), 3.8GHz (E-cores)
- **Available Governors**: performance, powersave
- **Boost State**: Supported and active
- **Current Frequency**: ~3.64GHz (asserted by kernel)
- **Intel P-State**: Active with fine-grained control

### Fan Curve Configuration
- **CPU Fan Curve**: Enabled
  - 35°C: 21%, 58°C: 34%, 61°C: 47%, 64°C: 64%, 67°C: 77%, 70°C: 100%
- **GPU Fan Curve**: Disabled (GPU fan not active at idle)
- **Custom Curves**: Supported via asusctl

## Proposed NixOS Power Profiles

### AC / Performance Profile
**Goals**: Maximum CPU/GPU performance, high responsiveness, acceptable fan noise
**Behavior Examples**:
- Performance CPU governor with Intel HWP optimization
- Full dGPU power (55W) for rendering
- Enable turbo boost and all performance cores
- High refresh rate (60Hz) maintained
- Aggressive fan curves for cooling
- Disable power saving features

### Battery / Light-Work Profile
**Goals**: Quiet operation, cooler temperatures, extended battery life
**Behavior Examples**:
- Conservative CPU governor (powersave) with HWP power saving
- dGPU power limited to 30W or disabled if possible
- Lower CPU frequencies for light workloads
- More aggressive thermal management
- Enable PCIe/USB power saving where safe
- Quiet fan curves for noise reduction

### Draft NixOS Implementation

```nix
# Draft: Power management and profiles for ASUS ROG Zephyrus
{
  # Enable power-profiles-daemon for automatic profile switching
  services.power-profiles-daemon.enable = true;
  
  # ASUS utilities integration
  programs.asusctl = {
    enable = true;
    enableUserService = true;
  };
  
  services.supergfxd.enable = true;
  
  # CPU frequency management with Intel P-State
  powerManagement.cpuFreqGovernor = "ondemand"; # Default, will be overridden by profiles
  
  # Custom systemd services for profile switching
  systemd.services = {
    # Performance profile service
    asus-performance = {
      description = "Set ASUS performance profile";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.asusctl}/bin/asusctl profile -p performance";
        ExecStartPost = "${pkgs.asusctl}/bin/asusctl fan-curve -m performance -f cpu -D";
        RemainAfterExit = true;
      };
    };
    
    # Battery profile service
    asus-battery = {
      description = "Set ASUS battery/quiet profile";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.asusctl}/bin/asusctl profile -p quiet";
        ExecStartPost = "${pkgs.asusctl}/bin/asusctl fan-curve -m quiet -f cpu -D";
        RemainAfterExit = true;
      };
    };
  };
  
  # Udev rules for automatic profile switching
  services.udev.extraRules = ''
    # Switch to performance profile when AC is connected
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start asus-performance"
    
    # Switch to battery profile when AC is disconnected
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl start asus-battery"
  '';
  
  # Power management settings
  powerManagement = {
    enable = true;
    # Disable CPU frequency scaling to let Intel P-State handle it
    cpuFreqGovernor = lib.mkDefault null;
  };
  
  # Kernel parameters for power management
  boot.kernelParams = [
    # Intel P-State settings
    "intel_pstate=active"
    "intel_pstate=hwp_active"
    # Power management
    "pcie_aspm=performance" # Override for battery mode via udev
  ];
  
  # Environment variables for easy profile switching
  environment.shellAliases = {
    perf-mode = "systemctl start asus-performance";
    battery-mode = "systemctl start asus-battery";
    balanced-mode = "asusctl profile -p balanced";
  };
  
  # TODO: Refine fan curves based on actual thermal testing
  # TODO: Test automatic profile switching with udev rules
  # TODO: Consider integrating with desktop environment for profile indicators
}
```

### Profile Switching Scripts

```bash
#!/usr/bin/env bash
# Draft: Manual profile switching script
# Place in ~/bin/switch-profile.sh

case "$1" in
  "performance"|"perf")
    echo "Switching to performance profile..."
    asusctl profile -p performance
    powerprofilesctl set performance
    nvidia-smi -pl 55  # Full GPU power
    ;;
  "battery"|"bat")
    echo "Switching to battery profile..."
    asusctl profile -p quiet
    powerprofilesctl set power-saver
    nvidia-smi -pl 30  # Reduced GPU power
    ;;
  "balanced"|"bal")
    echo "Switching to balanced profile..."
    asusctl profile -p balanced
    powerprofilesctl set balanced
    nvidia-smi -pl 40  # Moderate GPU power
    ;;
  *)
    echo "Usage: $0 {performance|battery|balanced}"
    echo "  perf/performance - Maximum performance"
    echo "  bat/battery     - Battery saving mode"
    echo "  bal/balanced    - Balanced mode"
    exit 1
    ;;
esac
```

## Storage & Filesystem Layout

### Physical Drives
- **nvme0n1**: Micron 2450 MTFDKBA1T0TFK, 953.9GB (SSD, non-rotational)
  - Firmware: V5MA010
  - Usage: Primary system drive with encrypted LUKS container
- **nvme1n1**: Crucial CT2000P310SSD8, 1.8TB (SSD, non-rotational)
  - Firmware: V8CR000
  - Usage: Boot partition + unused data partition

### Current Partitioning Scheme
#### nvme0n1 (System Drive - Encrypted)
- **nvme0n1p1**: 512MB VFAT (unused, duplicate EFI)
- **nvme0n1p2**: 953.4GB LUKS container (`crypted`)
  - Contains Btrfs filesystem with subvolumes

#### nvme1n1 (Boot/Data Drive)
- **nvme1n1p1**: 512MB VFAT (`/boot`, labeled `disk-main-ESP`)
- **nvme1n1p2**: 1.8TB ext4 (currently unused, labeled `disk-main-root`)

### Btrfs Subvolumes (on encrypted nvme0n1)
- **@root** (`/`): Root filesystem, 25GB used
- **@home** (`/home`): User data, mounted with same device
- **@nix** (`/nix`): Nix store, also mounted at `/nix/store` (read-only)
- **@swap** (`/swap`): Contains 8GB swapfile

### Current Mount Options
- **Btrfs Options**: `noatime,compress=zstd:3,ssd,discard=async,space_cache=v2`
- **Boot**: VFAT with defaults
- **Compression**: ZSTD level 3 for good balance of speed/ratio
- **Discard**: Async TRIM for SSD performance

### Swap Configuration
- **ZRAM**: 19.4GB compressed swap (priority 5)
- **File Swap**: 8GB swapfile in `/swap/swapfile` (priority -2)
- **Total**: ~27.4GB available swap

### Performance Characteristics
- **All SSD**: No rotational devices, excellent random access
- **NVMe**: High-speed storage with modern firmware
- **Encryption**: LUKS encryption on system drive (minimal performance impact)
- **Compression**: ZSTD level 3 provides good space savings with CPU overhead

### Suggested NixOS Layout (Draft)

#### Option 1: Optimized Single-Drive (Recommended)
Keep current encrypted Btrfs approach but optimize for performance:
- **nvme0n1**: Encrypted system with optimized subvolumes
- **nvme1n1**: Data/media storage or backup target
- **Benefits**: Security, snapshot capabilities, compression
- **Use Case**: Daily driver with good performance and data safety

#### Option 2: Dual-Drive Performance
Separate concerns across drives:
- **nvme0n1**: OS and applications (encrypted)
- **nvme1n1**: User data and large files (optional encryption)
- **Benefits**: Parallel I/O, easier backup strategy
- **Use Case**: Heavy development with large datasets

### Recommended Btrfs Subvolume Layout
```
@ (root)           - System root
@home              - User data
@nix               - Nix store
@log               - System logs
@swap              - Swap files
@snapshots         - System snapshots (optional)
@tmp               - Temporary files
```

### Performance Optimizations
- **Compression**: ZSTD:3 for balance (ZSTD:1 for max speed, ZSTD:5 for max compression)
- **Mount Options**: `noatime,ssd,discard=async,space_cache=v2`
- **Swap Strategy**: ZRAM + file swap for memory pressure handling
- **Scheduler**: `mq-deadline` or `none` for NVMe drives

### Draft Disko Configuration

```nix
# Draft: Disko configuration for ASUS ROG Zephyrus
# Double-check device paths before applying
{
  disko.devices = {
    disk = {
      # Primary system drive (Micron 1TB)
      nvme0n1 = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition (boot)
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            # LUKS encrypted system partition
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # Add your LUKS passphrase here or use keyfile
                # passwordFile = "/path/to/keyfile";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Force format
                  subvolumes = {
                    # Root subvolume
                    "@" = {
                      mountpoint = "/";
                      mountOptions = [
                        "noatime"
                        "compress=zstd:3"
                        "ssd"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    # Home subvolume
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "noatime"
                        "compress=zstd:3"
                        "ssd"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    # Nix store subvolume
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "noatime"
                        "compress=zstd:3"
                        "ssd"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    # Log subvolume
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "noatime"
                        "compress=zstd:1"  # Faster compression for logs
                        "ssd"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                    # Swap subvolume
                    "@swap" = {
                      mountpoint = "/swap";
                      mountOptions = [
                        "relatime"  # Allow atime for swap files
                        "ssd"
                        "discard=async"
                        "space_cache=v2"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
      
      # Secondary data drive (Crucial 2TB)
      nvme1n1 = {
        device = "/dev/nvme1n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # Optional: Second EFI for redundancy
            backup-ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot-backup";
                mountOptions = [ "defaults" ];
              };
            };
            # Data partition
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                extraArgs = [ "-f" ];
                mountpoint = "/data";
                mountOptions = [
                  "noatime"
                  "compress=zstd:3"
                  "ssd"
                  "discard=async"
                  "space_cache=v2"
                ];
              };
            };
          };
        };
      };
    };
    
    # Swap configuration
    swapDevices = [
      {
        device = "/swap/swapfile";
        size = "8G";
      }
    ];
    
    # ZRAM configuration
    zram = {
      enable = true;
      memoryPercent = 50; # Use 50% of RAM for ZRAM
      algorithm = "zstd";
    };
  };
}
```

### Alternative: Minimal Layout

```nix
# Simplified disko configuration for single-drive setup
{
  disko.devices = {
    disk.nvme0n1 = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/" = {
                    mountpoint = "/";
                    mountOptions = [ "noatime" "compress=zstd:3" "ssd" ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "noatime" "compress=zstd:3" "ssd" ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "noatime" "compress=zstd:3" "ssd" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
```

### Performance Notes
- **ZSTD:3**: Good balance of compression ratio vs CPU overhead
- **noatime**: Eliminates unnecessary metadata writes
- **ssd**: Enables SSD-specific optimizations
- **discard=async**: Async TRIM for better performance
- **space_cache=v2**: Faster Btrfs operations
- **ZRAM**: Compressed swap for memory pressure handling

### TODO Items
- Verify device paths (`/dev/nvme0n1`, `/dev/nvme1n1`) before deployment
- Consider backup strategy for secondary drive
- Test performance with different ZSTD levels
- Evaluate need for separate data partition encryption