{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.hardware.workstations;
in
{
  options.pantherOS.hardware.workstations = {
    enable = mkEnableOption "PantherOS workstation hardware configuration";
    
    enablePowerManagement = mkOption {
      type = types.bool;
      default = true;
      description = "Enable power management for workstation hardware";
    };
    
    enableGraphics = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable graphics support for workstations";
      };
      
      enableNvidia = mkOption {
        type = types.bool;
        default = false;
        description = "Enable NVIDIA graphics support";
      };
      
      enableAMD = mkOption {
        type = types.bool;
        default = false;
        description = "Enable AMD graphics support";
      };
      
      enableIntel = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Intel graphics support";
      };
    };
    
    enableBluetooth = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Bluetooth support";
    };
    
    enablePrinting = mkOption {
      type = types.bool;
      default = true;
      description = "Enable printing support";
    };
    
    enableAudio = mkOption {
      type = types.bool;
      default = true;
      description = "Enable audio support";
    };
    
    enableLaptopSpecific = mkOption {
      type = types.bool;
      default = false;
      description = "Enable laptop-specific hardware features (battery, etc.)";
    };
    
    enableTlp = mkOption {
      type = types.bool;
      default = true;
      description = "Enable TLP for advanced laptop power management";
    };
  };

  config = mkIf cfg.enable {
    # Workstation hardware configuration
    hardware = {
      # Enable graphics based on selection
      graphics = mkIf cfg.enableGraphics.enable {
        enable = cfg.enableGraphics.enable;
        enable32Bit = cfg.enableGraphics.enableNvidia;  # Needed for NVIDIA
        extraPackages = with pkgs; []
          ++ (mkIf cfg.enableGraphics.enableNvidia [ nvidia-vaapi-driver ])
          ++ (mkIf cfg.enableGraphics.enableAMD [ mesa ]);
      };
      
      # Enable bluetooth support
      bluetooth = mkIf cfg.enableBluetooth {
        enable = cfg.enableBluetooth;
        powerOnBoot = true;
      };
    };
    
    # Audio configuration
    hardware.pulseaudio = mkIf cfg.enableAudio {
      enable = cfg.enableAudio;
    };
    
    # Alternative audio configuration using pipewire
    services.pipewire = mkIf cfg.enableAudio {
      enable = cfg.enableAudio;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
    # Printing support
    services.printing = mkIf cfg.enablePrinting {
      enable = cfg.enablePrinting;
      drivers = with pkgs; [ gutenprint hplip ];
    };
    
    # Power management
    services = mkIf cfg.enablePowerManagement {
      # Enable TLP for advanced power management on laptops
      tlp = mkIf (cfg.enableLaptopSpecific && cfg.enableTlp) {
        enable = cfg.enableLaptopSpecific && cfg.enableTlp;
        settings = {
          # Optimized settings for different hardware types
          "USB_DENYLIST" = "1131:1001 05dc:e001 05dc:e002 05dc:e003";
          "CPU_SCALING_GOVERNOR_ON_AC" = "performance";
          "CPU_SCALING_GOVERNOR_ON_BAT" = "powersave";
          "CPU_ENERGY_PERF_POLICY_ON_BAT" = "power";
          "CPU_ENERGY_PERF_POLICY_ON_AC" = "performance";
          "SCHED_POWERSAVE_ON_AC" = 0;
          "SCHED_POWERSAVE_ON_BAT" = 1;
          "START_CHARGE_THRESH_BAT0" = 75;
          "STOP_CHARGE_THRESH_BAT0" = 85;
        };
      };
      
      # Enable powertop for power analysis
      powertop = mkIf cfg.enablePowerManagement {
        enable = cfg.enablePowerManagement;
      };
    };
    
    # Laptop-specific configuration
    services = mkIf cfg.enableLaptopSpecific {
      # Laptop battery and thermal management
      thermald = mkIf cfg.enableLaptopSpecific {
        enable = cfg.enableLaptopSpecific;
      };
    };
    
    # Additional kernel modules for laptop hardware
    boot = {
      kernelModules = []
        ++ (mkIf cfg.enableLaptopSpecific [ "battery" "i915" ])
        ++ (mkIf cfg.enableGraphics.enableAMD [ "amdgpu" ])
        ++ (mkIf cfg.enableGraphics.enableIntel [ "i915" ])
        ++ (mkIf cfg.enableGraphics.enableNvidia [ "nvidia" "nouveau" ]);
      
      extraModulePackages = []
        ++ (mkIf cfg.enableGraphics.enableNvidia [ config.boot.kernelPackages.nvidia_x11 ]);
    };
    
    # Environment packages for workstation hardware
    environment.systemPackages = with pkgs; [
      # Graphics tools
      glxinfo
      vulkan-tools
      
      # Power management tools
      powertop
      tlp
  
      # Audio tools
      pavucontrol
      alsaUtils
      
      # Bluetooth tools
      bluez
    ] ++ (mkIf cfg.enableLaptopSpecific [ acpi ]);
  };
}