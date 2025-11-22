# Thermal Management Module

## Enrichment Metadata
- **Purpose**: Configure advanced thermal management and fan control for laptops and workstations
- **Layer**: modules/hardware/thermal
- **Dependencies**: lm_sensors, fancontrol, thermald, kernel thermal drivers
- **Conflicts**: None
- **Platforms**: x86_64-linux (primarily laptop hardware)

## Configuration Points
- `services.thermald.enable`: Enable Intel thermal daemon
- `hardware.sensor.lm_sensors.enable`: Enable hardware sensor monitoring
- `services.undervolt`: Intel CPU undervolting (if supported)
- `boot.kernelModules`: Thermal-related kernel modules

## Code

```nix
# modules/hardware/thermal/management.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.pantherOS.hardware.thermal;
in
{
  options.pantherOS.hardware.thermal = {
    enable = lib.mkEnableOption "Advanced thermal management";
    
    # Thermal profile
    profile = lib.mkOption {
      type = lib.types.enum [ "silent" "balanced" "performance" "custom" ];
      default = "balanced";
      description = ''
        Thermal management profile:
        - silent: Maximum fan reduction, higher temperatures
        - balanced: Balance between noise and cooling
        - performance: Aggressive cooling, lower temperatures
        - custom: User-defined custom configuration
      '';
    };
    
    # CPU thermal management
    cpu = {
      # Temperature thresholds
      thresholds = {
        critical = lib.mkOption {
          type = lib.types.int;
          default = 95;
          description = "Critical temperature threshold (°C)";
        };
        
        warning = lib.mkOption {
          type = lib.types.int;
          default = 85;
          description = "Warning temperature threshold (°C)";
        };
        
        target = lib.mkOption {
          type = lib.types.int;
          default = 75;
          description = "Target temperature for thermal management (°C)";
        };
      };
      
      # Thermal throttling
      throttling = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable thermal throttling protection";
        };
        
        threshold = lib.mkOption {
          type = lib.types.int;
          default = 90;
          description = "Temperature to start throttling (°C)";
        };
      };
      
      # Intel-specific options
      intel = {
        undervolting = {
          enable = lib.mkEnableOption "CPU undervolting (reduces heat and power consumption)";
          
          coreOffset = lib.mkOption {
            type = lib.types.int;
            default = -50;
            description = "Core voltage offset in mV (negative = undervolt)";
          };
          
          gpuOffset = lib.mkOption {
            type = lib.types.int;
            default = -50;
            description = "GPU voltage offset in mV (negative = undervolt)";
          };
          
          cacheOffset = lib.mkOption {
            type = lib.types.int;
            default = -50;
            description = "Cache voltage offset in mV (negative = undervolt)";
          };
        };
        
        turboBoost = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Intel Turbo Boost";
        };
      };
      
      # AMD-specific options
      amd = {
        coolAndQuiet = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable AMD Cool'n'Quiet";
        };
      };
    };
    
    # Fan control
    fan = {
      enable = lib.mkEnableOption "Custom fan curve configuration";
      
      # Fan curve points (temp -> speed percentage)
      curve = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            temp = lib.mkOption {
              type = lib.types.int;
              description = "Temperature in Celsius";
            };
            
            speed = lib.mkOption {
              type = lib.types.int;
              description = "Fan speed percentage (0-100)";
            };
          };
        });
        default = [
          { temp = 40; speed = 30; }
          { temp = 50; speed = 40; }
          { temp = 60; speed = 50; }
          { temp = 70; speed = 70; }
          { temp = 80; speed = 90; }
          { temp = 90; speed = 100; }
        ];
        description = "Custom fan curve (temperature to fan speed mapping)";
      };
      
      minSpeed = lib.mkOption {
        type = lib.types.int;
        default = 25;
        description = "Minimum fan speed percentage";
      };
      
      maxSpeed = lib.mkOption {
        type = lib.types.int;
        default = 100;
        description = "Maximum fan speed percentage";
      };
      
      hysteresis = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Temperature hysteresis for fan speed changes (°C)";
      };
    };
    
    # Monitoring and alerts
    monitoring = {
      enable = lib.mkEnableOption "Thermal monitoring and alerts";
      
      interval = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Temperature monitoring interval (seconds)";
      };
      
      alerts = {
        enable = lib.mkEnableOption "Temperature alerts";
        
        warning = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable warning alerts";
        };
        
        critical = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable critical alerts";
        };
      };
      
      logging = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable thermal event logging";
      };
    };
    
    # Hardware-specific optimizations
    hardware = {
      laptop = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "yoga" "zephyrus" "thinkpad" "dell-xps" "generic" ]);
        default = null;
        description = "Laptop model for hardware-specific optimizations";
      };
      
      enableNbfc = lib.mkEnableOption "NoteBook FanControl (alternative fan control)";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Enable hardware sensor monitoring
    hardware.sensor.lm_sensors.enable = true;
    
    # Intel thermal daemon (for Intel CPUs)
    services.thermald = {
      enable = true;
      configFile = pkgs.writeText "thermal-conf.xml" ''
        <?xml version="1.0"?>
        <ThermalConfiguration>
          <Platform>
            <Name>Default Platform</Name>
            <ProductName>*</ProductName>
            <Preference>QUIET</Preference>
            <ThermalZones>
              <ThermalZone>
                <Type>cpu</Type>
                <TripPoints>
                  <TripPoint>
                    <SensorType>cpu</SensorType>
                    <Temperature>${toString cfg.cpu.thresholds.target}000</Temperature>
                    <Type>Passive</Type>
                    <CoolingDevice>
                      <index>0</index>
                      <type>rapl_controller</type>
                    </CoolingDevice>
                  </TripPoint>
                  <TripPoint>
                    <SensorType>cpu</SensorType>
                    <Temperature>${toString cfg.cpu.thresholds.warning}000</Temperature>
                    <Type>Active</Type>
                    <CoolingDevice>
                      <index>0</index>
                      <type>intel_powerclamp</type>
                    </CoolingDevice>
                  </TripPoint>
                  <TripPoint>
                    <SensorType>cpu</SensorType>
                    <Temperature>${toString cfg.cpu.thresholds.critical}000</Temperature>
                    <Type>Critical</Type>
                  </TripPoint>
                </TripPoints>
              </ThermalZone>
            </ThermalZones>
          </Platform>
        </ThermalConfiguration>
      '';
    };
    
    # Intel undervolting
    services.undervolt = lib.mkIf cfg.cpu.intel.undervolting.enable {
      enable = true;
      coreOffset = cfg.cpu.intel.undervolting.coreOffset;
      gpuOffset = cfg.cpu.intel.undervolting.gpuOffset;
      uncoreOffset = cfg.cpu.intel.undervolting.cacheOffset;
      temp = cfg.cpu.thresholds.critical;
    };
    
    # Kernel modules for thermal management
    boot.kernelModules = [
      "coretemp"       # Intel Core temperature monitoring
      "k10temp"        # AMD K10 temperature monitoring
      "acpi_call"      # ACPI call support for fan control
    ];
    
    # Kernel parameters for thermal management
    boot.kernelParams = lib.mkMerge [
      # Intel Turbo Boost control
      (lib.mkIf (!cfg.cpu.intel.turboBoost) [ "intel_pstate=disable" ])
      
      # Thermal throttling
      (lib.mkIf cfg.cpu.throttling.enable [
        "processor.max_cstate=1"
        "intel_idle.max_cstate=1"
      ])
    ];
    
    # Fan control service
    systemd.services.fancontrol = lib.mkIf cfg.fan.enable {
      description = "Custom fan curve control";
      wantedBy = [ "multi-user.target" ];
      after = [ "lm_sensors.service" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeScript "fancontrol-custom" ''
          #!${pkgs.bash}/bin/bash
          
          # Find fan control device
          FAN_DEVICE=$(find /sys/class/hwmon -name "pwm1" | head -1)
          TEMP_DEVICE=$(find /sys/class/hwmon -name "temp1_input" | head -1)
          
          if [ -z "$FAN_DEVICE" ] || [ -z "$TEMP_DEVICE" ]; then
            echo "Fan control devices not found"
            exit 1
          fi
          
          # Enable manual fan control
          echo 1 > "$(dirname $FAN_DEVICE)/pwm1_enable"
          
          # Fan curve control loop
          while true; do
            TEMP=$(($(cat $TEMP_DEVICE) / 1000))
            
            # Calculate fan speed based on curve
            SPEED=${toString cfg.fan.minSpeed}
            ${lib.concatMapStringsSep "\n" (point: ''
              if [ $TEMP -ge ${toString point.temp} ]; then
                SPEED=${toString point.speed}
              fi
            '') cfg.fan.curve}
            
            # Apply fan speed
            PWM_VALUE=$((255 * $SPEED / 100))
            echo $PWM_VALUE > $FAN_DEVICE
            
            sleep ${toString cfg.monitoring.interval}
          done
        '';
        Restart = "always";
      };
    };
    
    # Temperature monitoring service
    systemd.services.thermal-monitor = lib.mkIf cfg.monitoring.enable {
      description = "Thermal monitoring and alerts";
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeScript "thermal-monitor" ''
          #!${pkgs.bash}/bin/bash
          
          while true; do
            # Read CPU temperature
            TEMP=$(${pkgs.lm_sensors}/bin/sensors -A | grep -i "package id 0" | awk '{print $4}' | sed 's/+//;s/°C//' | cut -d'.' -f1)
            
            if [ -z "$TEMP" ]; then
              TEMP=$(${pkgs.lm_sensors}/bin/sensors -A | grep -i "core 0" | head -1 | awk '{print $3}' | sed 's/+//;s/°C//' | cut -d'.' -f1)
            fi
            
            # Check thresholds
            ${lib.optionalString cfg.monitoring.alerts.critical ''
              if [ $TEMP -ge ${toString cfg.cpu.thresholds.critical} ]; then
                ${pkgs.libnotify}/bin/notify-send -u critical "🔥 Critical Temperature" "CPU: $TEMP°C - System will throttle!"
                ${lib.optionalString cfg.monitoring.logging ''
                  logger -t thermal-monitor "CRITICAL: CPU temperature $TEMP°C"
                ''}
              fi
            ''}
            
            ${lib.optionalString cfg.monitoring.alerts.warning ''
              if [ $TEMP -ge ${toString cfg.cpu.thresholds.warning} ] && [ $TEMP -lt ${toString cfg.cpu.thresholds.critical} ]; then
                ${pkgs.libnotify}/bin/notify-send -u normal "⚠️ High Temperature" "CPU: $TEMP°C"
                ${lib.optionalString cfg.monitoring.logging ''
                  logger -t thermal-monitor "WARNING: CPU temperature $TEMP°C"
                ''}
              fi
            ''}
            
            sleep ${toString cfg.monitoring.interval}
          done
        '';
        Restart = "always";
      };
    };
    
    # System packages for thermal management
    environment.systemPackages = with pkgs; [
      # Sensor monitoring
      lm_sensors          # Hardware sensor monitoring
      psensor             # GUI temperature monitor
      
      # Fan control
      fancontrol          # Automatic fan control
      
      # System monitoring
      htop                # Process and system monitor
      powertop            # Power consumption monitor
      
      # Thermal utilities
      stress              # CPU stress testing
      s-tui               # Terminal UI for monitoring
    ] ++ lib.optionals cfg.hardware.enableNbfc [
      # NoteBook FanControl
      # nbfc would be added here if packaged
    ] ++ lib.optionals cfg.cpu.intel.undervolting.enable [
      undervolt           # Intel undervolting tool
    ];
    
    # Hardware-specific configurations
    boot.extraModprobeConfig = lib.mkMerge [
      # ASUS ROG Zephyrus optimizations
      (lib.mkIf (cfg.hardware.laptop == "zephyrus") ''
        options asus-nb-wmi throttle_thermal_policy=0
      '')
      
      # ThinkPad optimizations
      (lib.mkIf (cfg.hardware.laptop == "thinkpad") ''
        options thinkpad_acpi fan_control=1
      '')
    ];
    
    # Profile-based presets
    pantherOS.hardware.thermal = lib.mkMerge [
      # Silent profile
      (lib.mkIf (cfg.profile == "silent") {
        cpu.thresholds.target = 85;
        fan.minSpeed = 20;
        fan.curve = [
          { temp = 50; speed = 25; }
          { temp = 60; speed = 30; }
          { temp = 70; speed = 40; }
          { temp = 80; speed = 60; }
          { temp = 90; speed = 100; }
        ];
      })
      
      # Performance profile
      (lib.mkIf (cfg.profile == "performance") {
        cpu.thresholds.target = 65;
        cpu.intel.turboBoost = true;
        fan.minSpeed = 40;
        fan.curve = [
          { temp = 40; speed = 50; }
          { temp = 50; speed = 60; }
          { temp = 60; speed = 70; }
          { temp = 70; speed = 85; }
          { temp = 80; speed = 100; }
        ];
      })
    ];
  };
}
```

## Usage Examples

### Basic Thermal Management
```nix
{
  pantherOS.hardware.thermal = {
    enable = true;
    profile = "balanced";
  };
}
```

### Silent Laptop Configuration
```nix
{
  pantherOS.hardware.thermal = {
    enable = true;
    profile = "silent";
    hardware.laptop = "yoga";
    monitoring = {
      enable = true;
      alerts.warning = false;  # Reduce distractions
    };
  };
}
```

### High-Performance Workstation
```nix
{
  pantherOS.hardware.thermal = {
    enable = true;
    profile = "performance";
    cpu = {
      intel = {
        turboBoost = true;
        undervolting.enable = false;  # Maximize performance
      };
    };
    fan = {
      enable = true;
      minSpeed = 50;  # Aggressive cooling
    };
  };
}
```

### Custom Fan Curve for Gaming
```nix
{
  pantherOS.hardware.thermal = {
    enable = true;
    profile = "custom";
    cpu.thresholds.target = 75;
    fan = {
      enable = true;
      curve = [
        { temp = 45; speed = 40; }
        { temp = 55; speed = 50; }
        { temp = 65; speed = 65; }
        { temp = 75; speed = 80; }
        { temp = 85; speed = 100; }
      ];
    };
    monitoring = {
      enable = true;
      alerts.critical = true;
    };
  };
}
```

### Intel Laptop with Undervolting (ASUS ROG Zephyrus)
```nix
{
  pantherOS.hardware.thermal = {
    enable = true;
    profile = "balanced";
    hardware.laptop = "zephyrus";
    cpu = {
      thresholds = {
        target = 75;
        warning = 85;
        critical = 95;
      };
      intel = {
        turboBoost = true;
        undervolting = {
          enable = true;
          coreOffset = -80;   # Aggressive undervolt for Zephyrus
          gpuOffset = -50;
          cacheOffset = -80;
        };
      };
    };
    fan.enable = true;
    monitoring = {
      enable = true;
      alerts.enable = true;
    };
  };
}
```

## Integration Examples

### Complete Laptop Configuration
```nix
{
  # Thermal management
  pantherOS.hardware.thermal = {
    enable = true;
    profile = "balanced";
    hardware.laptop = "zephyrus";
    cpu.intel.undervolting.enable = true;
    monitoring.enable = true;
  };
  
  # Battery optimization
  pantherOS.hardware.laptop.battery = {
    enable = true;
    mode = "balanced";
  };
  
  # Power management
  services.power-profiles-daemon.enable = true;
}
```

## Troubleshooting

### Check Thermal Status
```bash
# View all sensor data
sensors

# Monitor temperatures in real-time
watch -n 1 sensors

# Check CPU frequency and throttling
cat /proc/cpuinfo | grep MHz
cpupower frequency-info

# View thermal zones
cat /sys/class/thermal/thermal_zone*/temp
cat /sys/class/thermal/thermal_zone*/type
```

### Common Issues

#### High CPU Temperatures
1. Check current temperature:
   ```bash
   sensors | grep -i core
   ```

2. Verify thermal throttling:
   ```bash
   dmesg | grep -i thermal
   ```

3. Clean fans and vents (physical maintenance)

4. Apply thermal paste if temperatures remain high

#### Fan Not Spinning
1. Check fan status:
   ```bash
   cat /sys/class/hwmon/hwmon*/fan*_input
   ```

2. Enable manual fan control:
   ```bash
   echo 1 > /sys/class/hwmon/hwmon0/pwm1_enable
   echo 255 > /sys/class/hwmon/hwmon0/pwm1
   ```

3. Check for hardware issues

#### Undervolting Not Working
1. Verify CPU supports undervolting:
   ```bash
   undervolt --read
   ```

2. Test with conservative values:
   ```bash
   sudo undervolt --core -50 --cache -50
   ```

3. Monitor stability with stress testing:
   ```bash
   stress --cpu 8 --timeout 300
   ```

## Performance Considerations

### Thermal Profiles
- **Silent**: Quieter operation, may throttle under load
- **Balanced**: Best for most users, good performance/noise ratio
- **Performance**: Maximum cooling, higher noise, best temperatures

### Undervolting Benefits
- 10-20% power reduction
- 5-15°C lower temperatures
- Potential instability if too aggressive
- Test thoroughly before production use

### Fan Curve Design
- Lower minimum speed = quieter but warmer at idle
- Steeper curve = more responsive to temperature changes
- Flatter curve = more stable fan speed, less acoustic variation

## Safety Considerations

1. **Never Disable Thermal Protection**: Always keep critical thresholds enabled
2. **Test Undervolting**: Stress test for stability before daily use
3. **Monitor Temperatures**: Keep CPU below 90°C under sustained load
4. **Physical Maintenance**: Clean fans and vents regularly
5. **Thermal Paste**: Replace every 2-3 years for optimal performance

## Hardware-Specific Notes

### ASUS ROG Zephyrus
- Excellent cooling system
- Supports aggressive undervolting (-80mV typical)
- Fan control via `asus-nb-wmi` kernel module
- May benefit from manual fan curves

### Lenovo ThinkPad
- ThinkPad-specific kernel module for fan control
- Generally conservative thermal management
- Excellent Linux support for thermal features

### Dell XPS
- Aggressive thermal throttling by default
- Benefits from undervolting
- May require BIOS updates for thermal improvements

## TODO
- [ ] Add GPU thermal management
- [ ] Implement liquid cooling support
- [ ] Add automatic thermal profile switching
- [ ] Create thermal stress testing utilities
- [ ] Add integration with system performance governors
- [ ] Implement thermal history logging and analysis
- [ ] Add support for external temperature sensors
- [ ] Create thermal emergency shutdown procedures
