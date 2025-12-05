# hosts/yoga/meta.nix
# Lenovo Yoga Hardware Configuration
# Based on hardware scan: yoga-facter.json
# CPU: AMD Ryzen AI 7 350 w/ Radeon 860M
# GPU: AMD Radeon 860M (integrated)
# Storage: NVMe SSD
# Network: WiFi + Ethernet
# Generated: 2025-01-27
#
# This configuration provides AMD Ryzen AI optimizations

{ config, lib, pkgs, ... }:

{
  # ============================================================================
  # HARDWARE-SPECIFIC KERNEL MODULES
  # ============================================================================

  boot = {
    # AMD Ryzen AI platform requires specific kernel modules
    kernelModules = [
      # CPU microcode and power management
      "kvm-amd"
      "k10temp"
      "amd_pmc"
      "amd_pstate"

      # Graphics and display
      "amdgpu"
      "drm"
      "drm_kms_helper"

      # Storage
      "nvme"
      "ahci"

      # Network
      "iwlwifi"
      "r8169"

      # USB and peripherals
      "usbhid"
      "uvcvideo"
      "btusb"
      "btintel"
      "btbcm"

      # AMD-specific
      "amd_sfh"
    ];

    # Kernel parameters optimized for AMD Ryzen AI
    kernelParams = [
      # AMD graphics
      "amdgpu.dc=1"
      "amdgpu.dcdebugmask=0x10"

      # CPU performance
      "amd_pstate=active"

      # Power management
      "pcie_aspm=force"
      "i915.enable_dc=1"

      # Disable problematic features
      "module_blacklist=sp5100_tco"
    ];

    # Extra module options
    extraModprobeConfig = ''
      # AMD graphics optimizations
      options amdgpu dc=1
      options amdgpu dcdebugmask=0x10

      # Intel WiFi optimizations (if present)
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
    # AMD graphics driver configuration
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        amdvlk
      ];
    };

    # CPU microcode updates
    cpu.amd.updateMicrocode = true;

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
    # Power management
    power-profiles-daemon.enable = true;

    # Enhanced Bluetooth management
    blueman.enable = true;
  };

  # ============================================================================
  # POWER MANAGEMENT & PERFORMANCE
  # ============================================================================

  # Enhanced power management
  powerManagement = {
    cpuFreqGovernor = "ondemand";
    powertop.enable = true;
  };

  # ============================================================================
  # NETWORKING
  # ============================================================================

  networking = {
    # NetworkManager with iwd for better WiFi support
    networkmanager = {
      enable = true;
      wifi = {
        powersave = false;
        backend = "iwd";
      };
    };

    # Use iwd for WiFi
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
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.x86_64.json";

      # AMD specific
      AMD_VULKAN_ICD = "RADV";
    };
  };

  # ============================================================================
  # SPECIALIZATIONS & PROFILES
  # ============================================================================

  # This configuration provides AMD Ryzen AI optimizations for Lenovo Yoga
  #
  # Hardware-specific notes:
  # - CPU: AMD Ryzen AI 7 350 (8C/16T)
  # - GPU: AMD Radeon 860M (integrated)
  # - Storage: NVMe SSD
  # - Network: WiFi 6 + Ethernet
  # - Display: 16-inch touchscreen
  # - Peripherals: Integrated camera, fingerprint reader, stylus support
}