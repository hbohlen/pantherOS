{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.hardware.zephyrus;
in
{
  options.pantherOS.hardware.zephyrus = {
    enable = mkEnableOption "PantherOS Zephyrus-specific hardware configuration";
    
    enableGpuSwitching = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GPU switching between integrated and discrete";
    };
    
    enableRgbKeyboard = mkOption {
      type = types.bool;
      default = true;
      description = "Enable RGB keyboard backlight control";
    };
    
    enableSpecialKeys = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Zephyrus-specific function keys";
    };
    
    enablePowerManagement = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Zephyrus-specific power management";
    };
    
    enablePerformanceMode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable gaming performance mode";
    };
    
    enableAudio = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Zephyrus-specific audio configuration";
    };
    
    enableFanControl = mkOption {
      type = types.bool;
      default = false;
      description = "Enable custom fan control";
    };
  };

  config = mkIf cfg.enable {
    # Zephyrus hardware configuration
    hardware = {
      # Enable graphics for gaming laptop
      graphics = mkIf cfg.enable {
        enable = true;
        enable32Bit = true;
      };
    };
    
    # Audio configuration for Zephyrus devices
    services.pipewire = mkIf cfg.enableAudio {
      enable = cfg.enableAudio;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
    # Fan control if enabled
    services = mkIf cfg.enableFanControl {
      auto-cpufreq = mkIf cfg.enableFanControl {
        enable = cfg.enableFanControl;
        # Use auto-cpufreq for dynamic CPU scaling
      };
    };
    
    # Hardware-specific kernel modules for Zephyrus devices
    boot = {
      kernelModules = []
        ++ (mkIf cfg.enableGpuSwitching [ "nouveau" ])
        ++ (mkIf cfg.enableSpecialKeys [ 
          "asus-nb-wmi" 
          "asus-wmi" 
          "sparse-keymap"
        ]);
      
      # Additional kernel parameters for Zephyrus devices
      extraModprobeConfig = ''
        # NVIDIA Optimus configuration
        options nvidia "NVreg_RegistryDwords='PerfLevelSrc=0x2222'"
      '';
    };
    
    # Power management for Zephyrus devices
    services = mkIf cfg.enablePowerManagement {
      # Enable laptop power management
      tlp = mkIf cfg.enablePowerManagement {
        enable = cfg.enablePowerManagement;
        settings = {
          "CPU_SCALING_GOVERNOR_ON_AC" = mkIf cfg.enablePerformanceMode "performance";
          "CPU_SCALING_GOVERNOR_ON_BAT" = "powersave";
          "CPU_ENERGY_PERF_POLICY_ON_BAT" = "power";
          "CPU_ENERGY_PERF_POLICY_ON_AC" = mkIf cfg.enablePerformanceMode "performance";
          "SCHED_POWERSAVE_ON_AC" = mkIf (!cfg.enablePerformanceMode) 1;
          "SCHED_POWERSAVE_ON_BAT" = 1;
          "START_CHARGE_THRESH_BAT0" = 75;
          "STOP_CHARGE_THRESH_BAT0" = 80;
          
          # Gaming laptop specific settings
          "NMI_WATCHDOG" = 0;  # Disable NMI watchdog for better performance
        };
      };
    };
    
    # ASUS laptop services
    services = mkIf cfg.enableSpecialKeys {
      # ASUS WMI services for function keys
      asus-wmi = mkIf cfg.enableSpecialKeys {
        enable = cfg.enableSpecialKeys;
      };
    };
    
    # Environment packages specific to Zephyrus hardware
    environment.systemPackages = with pkgs; [
      # GPU management tools
      nvidia-vaapi-driver  # For hardware video acceleration
      
      # Keyboard RGB control
      openrgb
      
      # ASUS hardware tools
      asusctl  # If available
      vial-gtk  # For keyboard customization
      
      # Performance monitoring
      nvidia-smi
      nvtop
    ];
    
    # Udev rules for Zephyrus hardware
    services.udev = {
      packages = mkIf cfg.enableSpecialKeys [
        # ASUS WMI udev rules
      ];
    };
    
    # Additional gaming-specific configurations
    programs = mkIf cfg.enableGpuSwitching {
      gamescope = mkIf cfg.enableGpuSwitching {
        # Enable gamescope for better gaming experience
        enable = cfg.enableGpuSwitching;
      };
    };
  };
}