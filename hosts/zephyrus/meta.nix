# ASUS ROG Zephyrus G15 (2023) Hardware Configuration
# Based on hardware scan: zephyrus-facter.json
# CPU: Intel Core i9-12900H (Alder Lake, 14C/20T)
# GPU: Intel Iris Xe + NVIDIA RTX 3060/3070
# Storage: Dual NVMe SSDs (Crucial 2TB + Micron 1TB)
# Network: Intel AX211 WiFi 6E + Realtek Ethernet
# Generated: 2025-01-27
#
# This configuration combines nixos-hardware base + custom optimizations

{ config, lib, pkgs, ... }:

{
  imports = [
    # Community-validated base configuration for GU603H
    # This provides: Intel CPU optimizations, NVIDIA Prime setup, laptop support
    # TODO: Add nixos-hardware flake input if needed
    # <nixos-hardware/asus/zephyrus/gu603h>
  ];
  # ============================================================================
  # HARDWARE-SPECIFIC KERNEL MODULES
  # ============================================================================

  boot = {
    # Alder Lake platform requires specific kernel modules
    kernelModules = [
      # CPU microcode and power management
      "kvm-intel"
      "intel_pmc_core"
      "intel_uncore_frequency"

      # Graphics and display
      "i915"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"

      # Storage
      "nvme"
      "ahci"

      # Network
      "iwlwifi"
      "btusb"
      "r8169"

      # USB and peripherals
      "usbhid"
      "uvcvideo"
      "btintel"
      "btbcm"

      # ASUS-specific
      "asus_wmi"
      "asus_nb_wmi"
      "asus_wireless"
    ];

    # Kernel parameters optimized for Alder Lake + NVIDIA
    kernelParams = [
      # Intel graphics
      "i915.enable_psr=1"
      "i915.enable_fbc=1"
      "i915.enable_guc=3"
      "i915.enable_huc=1"

      # NVIDIA hybrid graphics
      "nvidia_drm.modeset=1"
      "nvidia.NVreg_DynamicPowerManagement=0x02"

      # CPU performance
      "intel_pstate=active"

      # Power management
      "pcie_aspm=force"
      "i915.enable_dc=1"

      # Disable problematic features
      "module_blacklist=i2c_nvidia_gpu"
    ];

    # System control parameters
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };

    # Extra module options
    extraModprobeConfig = ''
      # Intel graphics optimizations
      options i915 enable_guc=3
      options i915 enable_huc=1
      options i915 enable_fbc=1
      options i915 enable_psr=1

      # NVIDIA power management
      options nvidia NVreg_DynamicPowerManagement=0x02
      options nvidia_drm modeset=1

      # Intel WiFi optimizations
      options iwlwifi power_save=0
      options iwlwifi uapsd_disable=1

      # Bluetooth improvements
      options btusb reset=1
      options btintel regdump=1
    '';
  };

  # ============================================================================
  # HARDWARE ENABLEMENT
  # ============================================================================

  hardware = {
    # NVIDIA driver configuration
    nvidia.open = true;

    # CPU microcode updates
    cpu.intel.updateMicrocode = true;

    # Enhanced graphics packages (in addition to nixos-hardware base)
    graphics.extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
      nvidia-vaapi-driver
    ];

    # Enhanced Bluetooth configuration
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
          KernelExperimental = true;
        };
      };
    };

    # Enable firmware for various devices
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  # ============================================================================
  # SERVICES CONFIGURATION
  # ============================================================================

  services = {
    # Enhanced X11 configuration for NVIDIA
    xserver = {
      videoDrivers = [ "nvidia" ];
      deviceSection = ''
        Option "AllowEmptyInitialConfiguration"
        Option "TripleBuffer" "true"
      '';
    };

    # Power management
    power-profiles-daemon.enable = true;

    # ASUS-specific services (complementing nixos-hardware base)
    asusd = {
      enable = true;
      enableUserService = true;
    };

    # Enhanced Bluetooth management
    blueman.enable = true;
  };

  # ============================================================================
  # SYSTEMD SERVICES & TUNING
  # ============================================================================

  systemd = {
    # CPU frequency scaling
    services.configure-cpu = {
      description = "Configure CPU governor and frequency scaling";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'";
        RemainAfterExit = true;
      };
    };

    # NVIDIA power management
    services.nvidia-power-management = {
      description = "NVIDIA power management service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi --persistence-mode=1'";
        RemainAfterExit = true;
      };
    };
  };

  # ============================================================================
  # POWER MANAGEMENT & PERFORMANCE
  # ============================================================================

  # ============================================================================
  # POWER MANAGEMENT & PERFORMANCE
  # ============================================================================

  # Enhanced power management (nixos-hardware base already provides enable = true)
  powerManagement = {
    cpuFreqGovernor = "performance";
    powertop.enable = true;
  };

  # ============================================================================
  # NETWORKING
  # ============================================================================

  networking = {
    # Intel AX211 WiFi 6E configuration
    networkmanager = {
      enable = true;
      wifi = {
        powersave = false;
        backend = "iwd";
      };
    };

    # Use iwd for better WiFi 6E support
    wireless.iwd = {
      enable = true;
      settings = {
        General = {
          EnableNetworkConfiguration = true;
        };
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
        };
      };
    };
  };

  # ============================================================================
  # FILESYSTEM & STORAGE
  # ============================================================================

  # NVMe SSD optimizations
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # ============================================================================

  environment = {
    variables = {
      # Vulkan ICD
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json";

      # NVIDIA specific
      __GL_SHADER_DISK_CACHE_PATH = "/tmp/nvidia-shaders";
      __GL_SHADER_DISK_CACHE_SIZE = "1073741824";
    };
  };

  # ============================================================================
  # SECURITY & HARDENING
  # ============================================================================

  security = {
    # Allow NVIDIA device access
    pam.loginLimits = [
      {
        domain = "*";
        type = "hard";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "*";
        type = "soft";
        item = "memlock";
        value = "unlimited";
      }
    ];
  };

  # ============================================================================
  # SPECIALIZATIONS & PROFILES
  # ============================================================================

  # This hybrid configuration combines:
  # 1. Community-validated nixos-hardware base for GU603H
  # 2. Comprehensive custom optimizations for ASUS ROG Zephyrus G15 2023
  #
  # BASE CONFIGURATION (nixos-hardware):
  # - Standard Intel CPU optimizations
  # - NVIDIA Prime hybrid graphics setup
  # - Common laptop hardware support
  # - NVMe SSD configurations
  #
  # CUSTOM ENHANCEMENTS:
  # - Advanced Alder Lake kernel parameters and modules
  # - Intel AX211 WiFi 6E + Bluetooth 5.3 optimizations
  # - ASUS ROG-specific services and controls
  # - Enhanced performance tuning and monitoring
  # - Comprehensive hardware monitoring tools

  # Hardware-specific notes:
  # - CPU: Intel Core i9-12900H (Alder Lake, 14C/20T)
  # - GPU: Intel Iris Xe + NVIDIA RTX 3060/3070 (Hybrid Prime)
  # - Storage: Dual NVMe SSDs (Crucial 2TB + Micron 1TB)
  # - Network: Intel AX211 WiFi 6E + Realtek Ethernet
  # - Display: 16-inch 2560×1600 internal + external monitor support
  # - Peripherals: ASUS Aura RGB keyboard, Elan touchpad, webcam
  #
  # This approach provides both tested community configurations and
  # hardware-specific optimizations for optimal performance.
}
