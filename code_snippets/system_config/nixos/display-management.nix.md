# Display Management Module

## Enrichment Metadata
- **Purpose**: Configure multi-monitor setups, display scaling, and color management for Wayland
- **Layer**: modules/hardware/display
- **Dependencies**: Wayland compositor (Niri), video drivers, display hardware
- **Conflicts**: X11-specific display managers
- **Platforms**: x86_64-linux, aarch64-linux

## Configuration Points
- `services.niri`: Wayland compositor configuration
- `hardware.opengl.enable`: Enable OpenGL/Vulkan support
- `environment.variables.GDK_SCALE`: GTK scaling factor
- `environment.variables.QT_SCALE_FACTOR`: Qt scaling factor
- `environment.variables.XCURSOR_SIZE`: Cursor size scaling

## Code

```nix
# modules/hardware/display/management.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.pantherOS.hardware.display;
in
{
  options.pantherOS.hardware.display = {
    enable = lib.mkEnableOption "Advanced display management";
    
    # Display scaling for high-DPI displays
    scaling = {
      enable = lib.mkEnableOption "High-DPI display scaling";
      
      factor = lib.mkOption {
        type = lib.types.enum [ "1.0" "1.25" "1.5" "1.75" "2.0" "2.5" "3.0" ];
        default = "1.0";
        description = "Global display scaling factor";
      };
      
      perMonitor = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Per-monitor scaling factors";
        example = {
          "DP-1" = "2.0";
          "HDMI-A-1" = "1.0";
        };
      };
      
      cursorSize = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Cursor size in pixels";
      };
    };
    
    # Multi-monitor configuration
    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Monitor identifier (e.g., 'DP-1', 'HDMI-A-1')";
          };
          
          enabled = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable this monitor";
          };
          
          primary = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Set as primary monitor";
          };
          
          resolution = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Monitor resolution (e.g., '2560x1600')";
            example = "2560x1600";
          };
          
          refreshRate = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "Refresh rate in Hz";
            example = 144;
          };
          
          position = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Position relative to other monitors";
            example = "0,0";
          };
          
          rotation = lib.mkOption {
            type = lib.types.enum [ "normal" "left" "right" "inverted" ];
            default = "normal";
            description = "Monitor rotation";
          };
          
          scale = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Monitor-specific scaling factor";
            example = "2.0";
          };
        };
      });
      default = [];
      description = "List of monitor configurations";
    };
    
    # Color management
    color = {
      enable = lib.mkEnableOption "Color management and calibration";
      
      temperature = lib.mkOption {
        type = lib.types.int;
        default = 6500;
        description = "Display color temperature in Kelvin (5000-10000)";
      };
      
      nightLight = {
        enable = lib.mkEnableOption "Night light (blue light reduction)";
        
        temperature = {
          day = lib.mkOption {
            type = lib.types.int;
            default = 6500;
            description = "Daytime color temperature";
          };
          
          night = lib.mkOption {
            type = lib.types.int;
            default = 4500;
            description = "Nighttime color temperature";
          };
        };
        
        schedule = lib.mkOption {
          type = lib.types.enum [ "sunset-sunrise" "manual" ];
          default = "sunset-sunrise";
          description = "Night light schedule type";
        };
        
        manualSchedule = lib.mkOption {
          type = lib.types.nullOr (lib.types.submodule {
            options = {
              start = lib.mkOption {
                type = lib.types.str;
                default = "20:00";
                description = "Start time (24-hour format)";
              };
              
              end = lib.mkOption {
                type = lib.types.str;
                default = "06:00";
                description = "End time (24-hour format)";
              };
            };
          });
          default = null;
          description = "Manual schedule for night light";
        };
      };
      
      profiles = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = {};
        description = "ICC color profiles for monitors";
        example = {
          "DP-1" = /path/to/profile.icc;
        };
      };
    };
    
    # HDMI/DisplayPort configuration
    external = {
      autoDetect = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically detect and configure external displays";
      };
      
      hotplug = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable hot-plug support for external displays";
      };
      
      profileSwitching = lib.mkEnableOption "Automatic profile switching on display connect/disconnect";
    };
    
    # Laptop display settings
    laptop = {
      internalDisplay = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Internal laptop display identifier";
        example = "eDP-1";
      };
      
      disableOnLidClose = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Disable internal display when lid is closed";
      };
      
      brightnessControl = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable brightness control for internal display";
        };
        
        defaultLevel = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = "Default brightness level (0-100)";
        };
      };
    };
    
    # Display presets for common scenarios
    preset = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ 
        "laptop-only"
        "external-only"
        "laptop-and-external"
        "triple-monitor"
        "presentation"
      ]);
      default = null;
      description = "Use a predefined display configuration preset";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Enable OpenGL/Vulkan support
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    # Display scaling environment variables
    environment.variables = lib.mkMerge [
      (lib.mkIf cfg.scaling.enable {
        # GTK scaling
        GDK_SCALE = cfg.scaling.factor;
        GDK_DPI_SCALE = "1.0";
        
        # Qt scaling
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_SCALE_FACTOR = cfg.scaling.factor;
        
        # Cursor size
        XCURSOR_SIZE = toString cfg.scaling.cursorSize;
        
        # Wayland-specific
        WAYLAND_DISPLAY = "wayland-1";
        XDG_SESSION_TYPE = "wayland";
      })
      
      # Color management
      (lib.mkIf cfg.color.enable {
        # Color profile location
        XCURSOR_THEME = "Adwaita";
      })
    ];
    
    # System packages for display management
    environment.systemPackages = with pkgs; [
      # Display utilities
      wdisplays          # Wayland display configuration GUI
      wlr-randr          # Wayland display control (like xrandr)
      
      # Brightness control
      brightnessctl      # Backlight control
      ddcutil            # Control external monitors via DDC/CI
      
      # Color management
      colord             # Color management daemon
      argyllcms          # Color calibration tools
      
      # Night light
      wlsunset           # Wayland day/night gamma adjustments
      
      # Display info
      wayland-utils      # Wayland debugging utilities
      weston             # Wayland reference compositor (for testing)
    ] ++ lib.optionals cfg.laptop.brightnessControl.enable [
      light              # Another brightness control tool
    ];
    
    # Brightness control permissions
    services.udev.extraRules = lib.mkIf cfg.laptop.brightnessControl.enable ''
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl*", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
      ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*::kbd_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/leds/%k/brightness"
    '';
    
    # Color management daemon
    services.colord = lib.mkIf cfg.color.enable {
      enable = true;
    };
    
    # Night light service (wlsunset)
    systemd.user.services.wlsunset = lib.mkIf cfg.color.nightLight.enable {
      description = "Day/night gamma adjustments for Wayland";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      
      serviceConfig = {
        ExecStart = let
          schedule = if cfg.color.nightLight.schedule == "sunset-sunrise"
            then ""  # Automatic based on location
            else "-S ${cfg.color.nightLight.manualSchedule.start} -s ${cfg.color.nightLight.manualSchedule.end}";
        in "${pkgs.wlsunset}/bin/wlsunset -t ${toString cfg.color.nightLight.temperature.night} -T ${toString cfg.color.nightLight.temperature.day} ${schedule}";
        Restart = "on-failure";
      };
    };
    
    # Display hotplug monitoring
    services.udev.extraRules = lib.mkIf cfg.external.hotplug ''
      # Monitor for display hotplug events
      ACTION=="change", SUBSYSTEM=="drm", RUN+="${pkgs.bash}/bin/bash -c 'systemctl --user restart display-configure.service'"
    '';
    
    # Automatic display configuration service
    systemd.user.services.display-configure = lib.mkIf cfg.external.autoDetect {
      description = "Automatic display configuration";
      wantedBy = [ "graphical-session.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeScript "display-configure" ''
          #!${pkgs.bash}/bin/bash
          
          # Wait for compositor to be ready
          sleep 2
          
          # Configure monitors using wlr-randr
          ${lib.concatMapStringsSep "\n" (monitor: ''
            ${if monitor.enabled then ''
              ${pkgs.wlr-randr}/bin/wlr-randr --output ${monitor.name} \
                ${lib.optionalString (monitor.resolution != null) "--mode ${monitor.resolution}"} \
                ${lib.optionalString (monitor.refreshRate != null) "@${toString monitor.refreshRate}"} \
                ${lib.optionalString (monitor.position != null) "--pos ${monitor.position}"} \
                ${lib.optionalString (monitor.scale != null) "--scale ${monitor.scale}"} \
                ${lib.optionalString (monitor.rotation != "normal") "--transform ${monitor.rotation}"} \
                ${if monitor.primary then "--preferred" else ""}
            '' else ''
              ${pkgs.wlr-randr}/bin/wlr-randr --output ${monitor.name} --off
            ''}
          '') cfg.monitors}
        '';
      };
    };
    
    # Laptop lid close handling
    services.logind = lib.mkIf (cfg.laptop.internalDisplay != null) {
      lidSwitch = if cfg.laptop.disableOnLidClose then "suspend" else "ignore";
      lidSwitchExternalPower = if cfg.laptop.disableOnLidClose then "ignore" else "ignore";
    };
    
    # Set default brightness on boot
    systemd.services.set-brightness = lib.mkIf cfg.laptop.brightnessControl.enable {
      description = "Set default display brightness";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-backlight@.service" ];
      
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.brightnessctl}/bin/brightnessctl set ${toString cfg.laptop.brightnessControl.defaultLevel}%";
      };
    };
  };
}
```

## Usage Examples

### Basic Display Setup
```nix
{
  pantherOS.hardware.display = {
    enable = true;
  };
}
```

### High-DPI Laptop Display (e.g., ASUS ROG Zephyrus WQXGA)
```nix
{
  pantherOS.hardware.display = {
    enable = true;
    scaling = {
      enable = true;
      factor = "1.5";  # 2560x1600 at 150% scaling
      cursorSize = 32;
    };
    laptop = {
      internalDisplay = "eDP-1";
      brightnessControl = {
        enable = true;
        defaultLevel = 70;
      };
    };
  };
}
```

### Dual Monitor Workstation
```nix
{
  pantherOS.hardware.display = {
    enable = true;
    monitors = [
      {
        name = "DP-1";
        primary = true;
        resolution = "2560x1440";
        refreshRate = 144;
        position = "0,0";
        scale = "1.0";
      }
      {
        name = "HDMI-A-1";
        resolution = "1920x1080";
        refreshRate = 60;
        position = "2560,180";  # Aligned vertically
        scale = "1.0";
      }
    ];
  };
}
```

### Triple Monitor Setup
```nix
{
  pantherOS.hardware.display = {
    enable = true;
    monitors = [
      {
        name = "DP-1";
        primary = true;
        resolution = "2560x1440";
        position = "1920,0";
        scale = "1.0";
      }
      {
        name = "HDMI-A-1";
        resolution = "1920x1080";
        position = "0,180";
        rotation = "left";
      }
      {
        name = "HDMI-A-2";
        resolution = "1920x1080";
        position = "4480,180";
        rotation = "right";
      }
    ];
  };
}
```

### Laptop with External Display
```nix
{
  pantherOS.hardware.display = {
    enable = true;
    scaling = {
      enable = true;
      perMonitor = {
        "eDP-1" = "2.0";      # High-DPI internal display
        "HDMI-A-1" = "1.0";   # Standard external display
      };
    };
    laptop = {
      internalDisplay = "eDP-1";
      disableOnLidClose = true;
    };
    external = {
      autoDetect = true;
      hotplug = true;
    };
  };
}
```

### Color-Managed Display with Night Light
```nix
{
  pantherOS.hardware.display = {
    enable = true;
    color = {
      enable = true;
      temperature = 6500;
      nightLight = {
        enable = true;
        temperature = {
          day = 6500;
          night = 4000;
        };
        schedule = "manual";
        manualSchedule = {
          start = "20:00";
          end = "07:00";
        };
      };
      profiles = {
        "DP-1" = /path/to/calibrated-profile.icc;
      };
    };
  };
}
```

## Integration Examples

### Complete Laptop Setup (Yoga/Zephyrus)
```nix
{
  pantherOS.hardware.display = {
    enable = true;
    scaling = {
      enable = true;
      factor = "1.5";
      cursorSize = 32;
    };
    laptop = {
      internalDisplay = "eDP-1";
      brightnessControl = {
        enable = true;
        defaultLevel = 75;
      };
      disableOnLidClose = true;
    };
    color.nightLight = {
      enable = true;
      schedule = "sunset-sunrise";
    };
    external = {
      autoDetect = true;
      hotplug = true;
    };
  };
  
  # Complement with power management
  pantherOS.hardware.laptop.battery.enable = true;
}
```

### Gaming Workstation with High Refresh Rate
```nix
{
  pantherOS.hardware.display = {
    enable = true;
    monitors = [
      {
        name = "DP-1";
        primary = true;
        resolution = "2560x1440";
        refreshRate = 165;  # High refresh for gaming
        scale = "1.0";
      }
    ];
  };
  
  # NVIDIA GPU for gaming
  pantherOS.hardware.gpu.nvidia = {
    enable = true;
    wayland.enable = true;
  };
}
```

## Troubleshooting

### Check Display Configuration
```bash
# List all outputs
wlr-randr

# Get detailed display information
wayland-info | grep -A5 "wl_output"

# Check current scaling
echo $GDK_SCALE
echo $QT_SCALE_FACTOR

# Monitor brightness
brightnessctl get
brightnessctl max
```

### Common Issues

#### Display Not Detected
1. Check if display is recognized:
   ```bash
   wlr-randr
   ls /sys/class/drm/
   ```

2. Verify video drivers are loaded:
   ```bash
   lsmod | grep -E 'i915|amdgpu|nouveau|nvidia'
   ```

3. Check kernel messages:
   ```bash
   dmesg | grep -i drm
   journalctl -b | grep -i display
   ```

#### Incorrect Scaling
1. Check environment variables:
   ```bash
   env | grep -E 'GDK|QT|SCALE'
   ```

2. Test different scaling factors:
   ```bash
   GDK_SCALE=2 gtk4-demo
   QT_SCALE_FACTOR=1.5 qtcreator
   ```

3. Per-application scaling:
   ```bash
   GDK_DPI_SCALE=0.5 firefox  # Reduce internal scaling
   ```

#### Brightness Control Not Working
1. Check backlight devices:
   ```bash
   ls /sys/class/backlight/
   ```

2. Test brightness control:
   ```bash
   sudo brightnessctl set 50%
   sudo light -S 75
   ```

3. Verify permissions:
   ```bash
   ls -l /sys/class/backlight/*/brightness
   ```

#### Multiple Monitor Issues
1. Check monitor configuration:
   ```bash
   wlr-randr
   ```

2. Manually configure displays:
   ```bash
   wlr-randr --output DP-1 --mode 2560x1440@144
   wlr-randr --output HDMI-A-1 --pos 2560,0
   ```

3. Disable problematic output:
   ```bash
   wlr-randr --output HDMI-A-1 --off
   ```

## Performance Considerations

### Scaling Performance
- Integer scaling (1.0, 2.0, 3.0) performs better than fractional (1.25, 1.5)
- Fractional scaling requires more GPU processing
- Consider per-application scaling for better performance

### Refresh Rate
- Higher refresh rates require more GPU bandwidth
- Match refresh rate to monitor capabilities
- Consider adaptive sync (FreeSync/G-Sync) for variable rates

### Multi-Monitor Performance
- Each monitor requires additional GPU resources
- Different refresh rates can cause synchronization issues
- Consider disabling unused outputs

## Display Recommendations

### Laptop Displays
- **1080p (1920x1080)**: Scale 1.0
- **QHD (2560x1440)**: Scale 1.25 or 1.5
- **4K (3840x2160)**: Scale 2.0
- **WQXGA (2560x1600)**: Scale 1.5 (optimal for Zephyrus)

### External Monitors
- **1080p**: Scale 1.0, 60Hz+
- **1440p**: Scale 1.0, 144Hz recommended
- **4K**: Scale 1.5-2.0, 60Hz minimum
- **Ultrawide**: Scale 1.0, consider resolution and size

## TODO
- [ ] Add automatic display profile switching based on connected monitors
- [ ] Implement display arrangement wizard/GUI
- [ ] Add support for display mirroring/cloning
- [ ] Create templates for common multi-monitor layouts
- [ ] Add integration with window manager workspace assignments
- [ ] Implement automatic color calibration workflow
- [ ] Add support for portrait mode displays
- [ ] Create display power management presets
