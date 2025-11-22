{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.hardware.yoga;
in
{
  options.pantherOS.hardware.yoga = {
    enable = mkEnableOption "PantherOS Yoga-specific hardware configuration";
    
    enableTouchscreen = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Yoga touchscreen support";
    };
    
    enableRotation = mkOption {
      type = types.bool;
      default = true;
      description = "Enable screen rotation support for Yoga convertibles";
    };
    
    enableStylus = mkOption {
      type = types.bool;
      default = true;
      description = "Enable stylus support";
    };
    
    enablePowerManagement = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Yoga-specific power management";
    };
    
    enableSpecialKeys = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Yoga-specific function keys";
    };
    
    enableCamera = mkOption {
      type = types.bool;
      default = true;
      description = "Enable camera support";
    };
    
    enableAudio = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Yoga-specific audio configuration";
    };
  };

  config = mkIf cfg.enable {
    # Yoga hardware configuration
    hardware = {
      # Enable graphics and input for Yoga features
      graphics = mkIf cfg.enable {
        enable = true;
      };
    };
    
    # Touchscreen and rotation support
    services = mkIf cfg.enableTouchscreen {
      # Enable X11 input configuration for touchscreen
      xserver = mkIf cfg.enableTouchscreen {
        enable = cfg.enableTouchscreen;
        inputClassSections = mkIf cfg.enableRotation [{
          identifier = "Yoga Touchscreen Rotate";
          matchIsTouchscreen = true;
          option "TransformMatrix" "0 0 0 0 0 0 0 0 0";
        }];
      };
    };
    
    # Enable iio-sensor-proxy for accelerometer support on Yoga convertibles
    services.iio-sensor-proxy = mkIf cfg.enableRotation {
      enable = cfg.enableRotation;
    };
    
    # Audio configuration for Yoga devices
    services.pipewire = mkIf cfg.enableAudio {
      enable = cfg.enableAudio;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
    # Hardware-specific kernel modules for Yoga devices
    boot = {
      kernelModules = []
        ++ (mkIf cfg.enableTouchscreen [ 
          "i2c_hid" 
          "i2c_designware_platform" 
          "i2c_designware_core"
        ])
        ++ (mkIf cfg.enableRotation [ 
          "hid_sensor_hub" 
          "hid_sensor_accel_3d" 
          "industrialio_triggered_buffer" 
          "kfifo_buf"
        ])
        ++ (mkIf cfg.enableSpecialKeys [ "ideapad_laptop" ]);
      
      # Additional kernel parameters for Yoga devices
      extraModprobeConfig = ''
        # Enable touchpad gestures
        options hid_apple iso_layout=0
      '';
    };
    
    # Input device configuration for Yoga-specific hardware
    services = mkIf cfg.enableSpecialKeys {
      # ideapad service for function keys
      ideapad = {
        enable = cfg.enableSpecialKeys;
      };
    };
    
    # Power management for Yoga devices
    services = mkIf cfg.enablePowerManagement {
      # Enable laptop power management
      tlp = mkIf cfg.enablePowerManagement {
        enable = cfg.enablePowerManagement;
        settings = {
          "USB_DENYLIST" = "1131:1001";
          "CPU_SCALING_GOVERNOR_ON_AC" = "powersave";
          "CPU_SCALING_GOVERNOR_ON_BAT" = "powersave";
          "CPU_ENERGY_PERF_POLICY_ON_BAT" = "power";
          "CPU_ENERGY_PERF_POLICY_ON_AC" = "power";
          "SCHED_POWERSAVE_ON_AC" = 1;
          "SCHED_POWERSAVE_ON_BAT" = 1;
          "START_CHARGE_THRESH_BAT0" = 75;
          "STOP_CHARGE_THRESH_BAT0" = 80;
        };
      };
    };
    
    # Environment packages specific to Yoga hardware
    environment.systemPackages = with pkgs; [
      # Touchscreen and rotation utilities
      xorg.xrandr
      iio-sensor-proxy-tools
      
      # Hardware information tools
      dmidecode
      vbetool
    ];
    
    # Udev rules for Yoga hardware if needed
    services.udev = {
      packages = [
        # Add Yoga-specific udev rules if needed
      ];
    };
  };
}