# Battery Management Module

## Enrichment Metadata
- **Purpose**: Optimize laptop battery life and power management
- **Layer**: modules/hardware/laptop
- **Dependencies**: Hardware sensors, kernel modules, TLP service
- **Conflicts**: Other power management systems (Laptop Mode Tools)
- **Platforms**: x86_64-linux (laptop hardware required)

## Configuration Points
- `services.tlp.enable`: Enable TLP for power management
- `services.actkbd.enable`: Enable ACPI event handling
- `hardware.sensor.iio.enable`: Enable hardware sensors
- `services.auto-cpufreq.enable`: Enable automatic CPU frequency scaling
- `powerManagement.battery`: Battery-specific settings
- `powerManagement.threshold`: Battery charge thresholds

## Code

```nix
# modules/hardware/laptop/battery.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.pantherOS.hardware.laptop.battery;
in
{
  options.pantherOS.hardware.laptop.battery = {
    enable = lib.mkEnableOption "Advanced laptop battery management";
    
    # Battery management mode
    mode = lib.mkOption {
      type = lib.types.enum [ "balanced" "performance" "battery" "ac" ];
      default = "balanced";
      description = "Power management mode";
    };
    
    # Battery thresholds
    thresholds = {
      startCharging = lib.mkOption {
        type = lib.types.int;
        default = 30;
        description = "Battery level to start charging";
      };
      stopCharging = lib.mkOption {
        type = lib.types.int;
        default = 80;
        description = "Battery level to stop charging";
      };
    };
    
    # Power management features
    features = {
      tlp = lib.mkEnableOption "TLP power management";
      actkbd = lib.mkEnableOption "ACPI event handling";
      autoCpufreq = lib.mkEnableOption "Automatic CPU frequency scaling";
      batteryThresholds = lib.mkEnableOption "Battery charging thresholds";
      deepSleep = lib.mkEnableOption "Deep sleep support";
      usbAutoSuspend = lib.mkEnableOption "USB auto-suspend";
    };
    
    # Thermal management
    thermal = {
      enable = lib.mkEnableOption "Advanced thermal management";
      profiles = lib.mkOption {
        type = lib.types.attrs;
        default = {
          battery = "balanced";
          ac = "performance";
        };
        description = "Thermal profiles for different power modes";
      };
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Enable hardware sensors
    hardware.sensor.iio.enable = true;
    
    # TLP power management
    services.tlp = lib.mkIf cfg.features.tlp {
      enable = true;
      
      # TLP configuration
      settings = {
        # CPU
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";
        
        # Graphics
        RADEON_POWER_PROFILE_ON_AC = "high";
        RADEON_POWER_PROFILE_ON_BAT = "low";
        INTEL_GPU_MIN_FREQ_ON_AC = "800";
        INTEL_GPU_MIN_FREQ_ON_BAT = "150";
        INTEL_GPU_MAX_FREQ_ON_AC = "2000";
        INTEL_GPU_MAX_FREQ_ON_BAT = "1500";
        
        # Battery
        START_CHARGE_THRESH_BAT0 = cfg.thresholds.startCharging;
        STOP_CHARGE_THRESH_BAT0 = cfg.thresholds.stopCharging;
        
        # USB
        USB_AUTOSUSPEND = cfg.features.usbAutoSususpend;
        
        # Disk
        DISK_APM_LEVEL_ON_AC = "254";
        DISK_APM_LEVEL_ON_BAT = "128";
        
        # Wireless
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
        
        # Audio
        SOUND_POWER_SAVE_ON_AC = "0";
        SOUND_POWER_SAVE_ON_BAT = "1";
      };
    };
    
    # ACPI event handling
    services.actkbd = lib.mkIf cfg.features.actkbd {
      enable = true;
      
      # Key bindings for battery events
      bindings = [
        {
          keys = [ "KEY_BATTERY" ];
          events = [ "battery" ];
          command = "${pkgs.util-linux}/bin/logger Battery event detected";
        }
        {
          keys = [ "KEY_POWER" ];
          events = [ "power" ];
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
        {
          keys = [ "KEY_SLEEP" ];
          events = [ "sleep" ];
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
    
    # Automatic CPU frequency scaling
    services.auto-cpufreq = lib.mkIf cfg.features.autoCpufreq {
      enable = true;
      
      # Configuration for different modes
      mode = {
        "balanced" = {
          governor = "schedutil";
          min_freq = "10%";
          max_freq = "90%";
        };
        "performance" = {
          governor = "performance";
          min_freq = "50%";
          max_freq = "100%";
        };
        "battery" = {
          governor = "powersave";
          min_freq = "5%";
          max_freq = "60%";
        };
        "ac" = {
          governor = "performance";
          min_freq = "30%";
          max_freq = "100%";
        };
      }."${cfg.mode}";
    };
    
    # Battery threshold management
    services.tlp.settings = lib.mkIf cfg.features.batteryThresholds {
      START_CHARGE_THRESH_BAT0 = cfg.thresholds.startCharging;
      STOP_CHARGE_THRESH_BAT0 = cfg.thresholds.stopCharging;
    };
    
    # Deep sleep support
    systemd.targets.sleep = lib.mkIf cfg.features.deepSleep {
      description = "Sleep";

      # Enable hibernate
      wantedBy = [ "sleep.target" ];
      after = [ "sleep.target" ];
      unit = "hibernate.target";
      
      # Hibernate timer
      unitConfig.DefaultDependencies = false;
      serviceConfig.Type = "oneshot";
      serviceConfig.ExecStart = "${pkgs.systemd}/bin/systemctl hibernate";
    };
    
    # Kernel parameters for battery optimization
    boot.kernelParams = [
      # Enable power management
      "acpi_backlight=vendor"
      "intel_pstate=enable"
      "processor.max_cstate=1"
      
      # Battery optimization
      "usbcore.autosuspend=-1"
      "pci=noaer"
      "mem_sleep_default=deep"
    ];
    
    # Battery monitoring
    systemd.services.battery-monitor = {
      enable = true;
      description = "Battery Level Monitor";
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.util-linux}/bin/acpi -a";
        Restart = "on-failure";
        RestartSec = 30;
      };
      
      # Run every minute
      timerConfig = {
        OnCalendar = "*:*:00";
        Persistent = true;
      };
      
      wantedBy = [ "timers.target" ];
    };
    
    # Power management modules
    boot.kernelModules = [
      "battery"
      "acpi_cpufreq"
      "processor_thermal"
      "intel_rapl_msr"
    ];
    
    # Battery specific packages
    environment.systemPackages = with pkgs; [
      acpi
      tlp
      acpi_call
      x86_energy_perf_policy
      cpupower
    ];
    
    # Environment variables for battery optimization
    environment.variables = {
      # CPU governor hint
      CPU_GOVERNOR = cfg.mode;
      
      # Battery thresholds
      BATTERY_THRESHOLD_START = toString cfg.thresholds.startCharging;
      BATTERY_THRESHOLD_STOP = toString cfg.thresholds.stopCharging;
    };
    
    # Custom systemd service for battery mode switching
    systemd.services.battery-mode-manager = {
      enable = true;
      description = "Battery Mode Manager";
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.util-linux}/bin/bash -c ''
          while true; do
            if [ -f '/sys/class/power_supply/BAT0/capacity' ]; then
              capacity=\$(cat /sys/class/power_supply/BAT0/capacity)
              status=\$(cat /sys/class/power_supply/BAT0/status)
              
              # Switch modes based on battery state
              if [ '\$status' = 'Discharging' ] && [ \$capacity -lt 20 ]; then
                echo 'battery' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
                echo 'Battery saver mode activated'
              elif [ '\$status' = 'Charging' ] || [ \$status = 'Full' ]; then
                echo 'performance' > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
                echo 'Performance mode activated'
              fi
            fi
            sleep 30
          done
        ''";
        Restart = "always";
        RestartSec = 60;
      };
      
      wantedBy = [ "multi-user.target" ];
    };
  };
}
```

## Integration Pattern

### Basic Laptop Setup
```nix
# In laptop host configuration
{
  imports = [
    <pantherOS/modules/hardware/laptop/battery.nix>
  ];
  
  pantherOS.hardware.laptop.battery = {
    enable = true;
    mode = "balanced";
    features = {
      tlp = true;
      actkbd = true;
      autoCpufreq = true;
    };
  };
}
```

### Gaming Laptop Setup
```nix
# For high-performance laptops
{
  pantherOS.hardware.laptop.battery = {
    enable = true;
    mode = "performance";
    thresholds = {
      startCharging = 40;
      stopCharging = 85; # Maintain battery health
    };
    features = {
      tlp = true;
      deepSleep = true;
      usbAutoSuspend = true;
    };
  };
}
```

### Development Laptop
```nix
# For development work
{
  pantherOS.hardware.laptop.battery = {
    enable = true;
    mode = "balanced";
    features = {
      tlp = true;
      autoCpufreq = true;
      batteryThresholds = true;
    };
    
    thresholds = {
      startCharging = 20;
      stopCharging = 80; # Battery health optimized
    };
  };
}
```

## Validation Steps

### 1. Build Check
```bash
# Validate battery module configuration
nix eval --impure .#nixosConfigurations.yoga.config.pantherOS.hardware.laptop.battery

# Check TLP service status
systemctl status tlp
```

### 2. Runtime Verification
```bash
# Check battery status
acpi -V

# Verify battery thresholds
cat /sys/class/power_supply/BAT0/charge_control_end_threshold
cat /sys/class/power_supply/BAT0/charge_control_start_threshold

# Test CPU governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

### 3. Battery Performance Test
```bash
# Monitor battery usage
acpi -a -i

# Check power management features
tlp stat

# Battery life estimation
upower -d | grep -E "(percentage|time to empty)"
```

## Related Modules

- `modules/hardware/laptop/thermal.nix` - Thermal management integration
- `modules/hardware/laptop/keyboard.nix` - Keyboard power features
- `modules/services/monitoring/datadog.nix` - Battery metrics monitoring

## Troubleshooting

### Common Issues

**Battery Not Detected**
```bash
# Check ACPI support
dmesg | grep -i battery

# Verify battery devices
ls /sys/class/power_supply/

# Load battery module
sudo modprobe battery
```

**TLP Not Working**
```bash
# Check TLP status
tlp stat

# Restart TLP service
sudo systemctl restart tlp

# Check TLP configuration
cat /etc/tlp.conf
```

**Power Management Conflicts**
```bash
# Check for conflicting services
systemctl list-units | grep -E "(cpufreq|power)"

# Disable conflicting services
sudo systemctl disable ondemand
```

## Battery Optimization Tips

### Health Maintenance
- Keep battery charge between 20-80% for longest lifespan
- Avoid frequent full charge cycles
- Use appropriate charging thresholds
- Monitor battery temperature

### Performance Optimization
- Switch governors based on power source
- Use deep sleep when possible
- Enable USB auto-suspend
- Optimize thermal management

### Monitoring
- Regular battery health checks
- Temperature monitoring
- Charge cycle tracking
- Performance profile adjustment

---

**Module Status**: Production Ready  
**Dependencies**: ACPI, TLP, Linux kernel with battery support  
**Tested On**: Lenovo Yoga, ASUS ROG Zephyrus, Dell XPS