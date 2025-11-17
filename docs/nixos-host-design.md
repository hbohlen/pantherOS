# ASUS ROG Zephyrus – NixOS Host Design

## 1. System Overview
- **CPU**: 12th Gen Intel Core i9-12900H (14 cores: 6P+8E, 20 threads, 4.9GHz boost)
- **GPU**: NVIDIA RTX 3070 Ti (8GB) + Intel Iris Xe (ASUS MUX switch, discrete-only mode)
- **RAM**: 40GB DDR5 with 27GB swap (19.4GB ZRAM + 8GB file)
- **Storage**: Dual NVMe - 1TB encrypted system + 2TB data drive (both SSD)
- **Display**: 2560x1600 @ 60Hz internal panel via Wayland+Niri
- **Network**: Intel AX211 WiFi + Realtek 2.5GbE Ethernet + Tailscale VPN

**Key Performance Traits:**
- High-performance CPU with Intel HWP fine-grained power control
- Powerful dGPU with 55W power budget and excellent thermal headroom
- Fast NVMe storage with current Btrfs compression and optimization
- ASUS MUX switch provides direct dGPU output (no Optimus overhead)
- Excellent virtualization capabilities with VT-x support

## 2. NixOS Goals for This Host
- **Maximum Performance**: Full CPU/GPU power when plugged in, responsive for development/gaming
- **Battery Efficiency**: Quiet, cool operation for light work (browsing, notes, coding)
- **Stable Graphics**: Reliable Wayland+Niri with NVIDIA proprietary driver
- **ASUS Integration**: Full support for performance modes, fan control, RGB, charge limiting
- **Reproducible Storage**: Disko-based encrypted Btrfs with optimized subvolumes

## 3. Hardware-Specific Considerations

### CPU Tuning
- **Intel Microcode**: Essential for i9-12900H stability and security
- **HWP Support**: Hardware P-States enable fine-grained power control
- **Governor Strategy**: Performance on AC, powersave on battery with automatic switching
- **Virtualization**: Excellent VT-x support for VM/container workloads

### GPU/Graphics
- **ASUS MUX Switch**: Direct dGPU output (not Optimus), requires reboot to change modes
- **Current Mode**: Discrete GPU driving internal display via NVIDIA proprietary driver
- **Power Strategy**: 55W full power on AC, 30W limited on battery
- **Driver Stack**: NVIDIA proprietary 580.95.05 + Intel i915 (for audio)
- **Display**: Wayland+Niri compositor, 2560x1600 @ 60Hz

### Storage Layout
- **Current Setup**: Encrypted Btrfs with optimized subvolumes (@root, @home, @nix, @swap)
- **Performance**: ZSTD:3 compression, async TRIM, SSD optimizations
- **Dual Drive**: 1TB system (encrypted) + 2TB data (available for backup/media)
- **Swap Strategy**: ZRAM (50% RAM) + 8GB file swap for memory pressure

### Networking & Audio
- **WiFi**: Intel AX211 (well-supported, firmware included)
- **Ethernet**: Realtek RTL8125 2.5GbE (high-speed wired networking)
- **Audio**: Intel HDA + NVIDIA HDMI/DP via PipeWire 1.4.9
- **VPN**: Tailscale integration for secure remote access

### ASUS/ROG Integration
- **asusctl v6.1.15**: Performance profiles, fan curves, RGB control, charge limiting
- **supergfxctl v5.2.7**: Graphics mode management (MUX switch control)
- **Profiles**: Quiet/Balanced/Performance with automatic AC/battery switching
- **Thermals**: Custom fan curves with excellent thermal headroom

## 4. Draft NixOS Configuration Skeleton

```nix
{ config, pkgs, lib, ... }:

{
  # Host name and basic identity
  networking.hostName = "asus-rog-zephyrus";
  
  # Hardware imports
  imports = [
    ./hardware-configuration.nix
    # TODO: Check nixos-hardware for ASUS ROG Zephyrus module
    # <nixos-hardware/asus/rog-zephyrus>  # If available
  ];
  
  # CPU / microcode / performance hints
  hardware.cpu.intel.updateMicrocode = true;  # Essential for i9-12900H
  
  # Intel P-State with HWP support
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault null;  # Let Intel P-State handle it
  };
  
  boot.kernelParams = [
    "intel_pstate=active"
    "intel_pstate=hwp_active"
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_RegistryDwords=PowerMizerEnable=0x1"
  ];
  
  # GPU / graphics configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;  # Disable for performance mode
    open = false;  # Proprietary driver required for RTX 3070 Ti
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    
    # Prime configuration (though MUX switch bypasses this)
    prime = {
      offload.enable = false;  # Not using Optimus
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };
  
  # Enable supergfxctl for MUX switch management
  services.supergfxd.enable = true;
  
  # Wayland/Niri display configuration
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
  
  # Hardware video acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      intel-media-driver
    ];
  };
  
  # Filesystems and disko layout
  # TODO: Import and configure disko based on Prompt 4 design
  # imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];
  
  # Power profiles: AC / performance mode
  systemd.services.asus-performance = {
    description = "Set ASUS performance profile";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.asusctl}/bin/asusctl profile -p performance";
      ExecStartPost = "${pkgs.asusctl}/bin/asusctl fan-curve -m performance -f cpu -D";
      ExecStartPost = "${pkgs.nvidia-smi}/bin/nvidia-smi -pl 55";  # Full GPU power
      RemainAfterExit = true;
    };
  };
  
  # Power profiles: Battery / light-work mode
  systemd.services.asus-battery = {
    description = "Set ASUS battery/quiet profile";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.asusctl}/bin/asusctl profile -p quiet";
      ExecStartPost = "${pkgs.asusctl}/bin/asusctl fan-curve -m quiet -f cpu -D";
      ExecStartPost = "${pkgs.nvidia-smi}/bin/nvidia-smi -pl 30";  # Reduced GPU power
      RemainAfterExit = true;
    };
  };
  
  # Services, daemons, and ASUS/ROG utilities
  services.power-profiles-daemon.enable = true;
  
  programs.asusctl = {
    enable = true;
    enableUserService = true;
  };
  
  # Automatic AC/battery profile switching
  services.udev.extraRules = ''
    # Switch to performance profile when AC is connected
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start asus-performance"
    
    # Switch to battery profile when AC is disconnected
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl start asus-battery"
  '';
  
  # Networking configuration
  networking = {
    # WiFi configuration via NetworkManager
    networkmanager.enable = true;
    
    # Enable Tailscale
    tailscale.enable = true;
  };
  
  # Audio configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # Host-specific programs and tweaks
  environment.shellAliases = {
    perf-mode = "systemctl start asus-performance";
    battery-mode = "systemctl start asus-battery";
    balanced-mode = "asusctl profile -p balanced";
    gpu-full = "nvidia-smi -pl 55";
    gpu-eco = "nvidia-smi -pl 30";
  };
  
  # Virtualization support
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;  # For virt-manager
  
  # TODO: Add user-specific configurations
  # TODO: Configure backup strategy for secondary drive
  # TODO: Test and refine fan curves based on thermal testing
  # TODO: Consider desktop environment integration for profile indicators
}
```

## 5. AC vs Battery – Practical Usage

### When Plugged In (Performance)
**Profile**: `perf-mode` or automatic AC detection

**What to expect:**
- Full CPU performance with Intel HWP optimization (4.9GHz boost)
- NVIDIA RTX 3070 Ti at full 55W power
- ASUS Performance profile with aggressive fan curves
- Higher fan noise but excellent thermal management
- Maximum responsiveness for gaming, development, compilation

**Manual toggles:**
```bash
perf-mode          # Switch to performance profile
gpu-full           # Set GPU to full 55W power
asusctl profile -p performance  # Direct ASUS profile control
```

### When on Battery (Light Work)
**Profile**: `battery-mode` or automatic battery detection

**Trade-offs:**
- Conservative CPU governor with power saving (powersave)
- NVIDIA GPU limited to 30W (still usable for light tasks)
- ASUS Quiet profile with minimal fan noise
- Extended battery life with cooler operation
- Slightly reduced responsiveness but adequate for browsing, coding, notes

**How to switch:**
```bash
battery-mode        # Switch to battery profile
gpu-eco            # Set GPU to 30W power
asusctl profile -p quiet     # Direct ASUS quiet mode
```

**Automatic switching:** Udev rules detect AC/battery changes and apply appropriate profiles automatically.

**Battery optimization tips:**
- Use browser extensions that limit background tabs
- Close unnecessary applications when on battery
- Consider using lighter terminal editors (vim/nano vs heavy IDEs)
- Monitor battery usage with `powerprofilesctl` and `asusctl`

**Performance indicators:**
- Check current profile: `powerprofilesctl`
- Monitor GPU power: `nvidia-smi`
- ASUS status: `asusctl profile -p`
- Thermal status: `sensors`

This design provides maximum performance when needed while maintaining excellent battery life for light work, with automatic switching and manual override capabilities.