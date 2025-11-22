# Touchpad & Input Module

## Enrichment Metadata
- **Purpose**: Configure touchpad, mouse, and keyboard input devices for optimal user experience
- **Layer**: modules/hardware/input
- **Dependencies**: libinput, X11/Wayland input handling, kernel input drivers
- **Conflicts**: synaptics driver (deprecated)
- **Platforms**: x86_64-linux, aarch64-linux (primarily laptop hardware)

## Configuration Points
- `services.xserver.libinput.enable`: Enable libinput for input device handling
- `services.xserver.libinput.touchpad`: Touchpad-specific settings
- `services.xserver.libinput.mouse`: Mouse-specific settings
- `services.xserver.xkb`: Keyboard layout configuration
- `hardware.input`: Input device hardware configuration

## Code

```nix
# modules/hardware/input/touchpad.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.pantherOS.hardware.input;
in
{
  options.pantherOS.hardware.input = {
    enable = lib.mkEnableOption "Advanced input device configuration";
    
    # Touchpad configuration
    touchpad = {
      enable = lib.mkEnableOption "Touchpad support";
      
      # Touch behavior
      tapping = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable tap-to-click";
      };
      
      tapAndDrag = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable tap-and-drag gesture";
      };
      
      dragLock = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable drag lock after tap-and-drag";
      };
      
      # Natural scrolling
      naturalScrolling = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable natural (reverse) scrolling";
      };
      
      # Scrolling method
      scrollMethod = lib.mkOption {
        type = lib.types.enum [ "twofinger" "edge" "button" ];
        default = "twofinger";
        description = ''
          Scrolling method:
          - twofinger: Two-finger scrolling (modern touchpads)
          - edge: Edge scrolling (older touchpads)
          - button: Middle button scrolling
        '';
      };
      
      # Click methods
      clickMethod = lib.mkOption {
        type = lib.types.enum [ "clickfinger" "buttonareas" ];
        default = "clickfinger";
        description = ''
          Click method:
          - clickfinger: Areas determined by finger count
          - buttonareas: Traditional button areas
        '';
      };
      
      # Acceleration
      accelSpeed = lib.mkOption {
        type = lib.types.float;
        default = 0.0;
        description = "Acceleration speed (-1.0 to 1.0, 0 = default)";
      };
      
      accelProfile = lib.mkOption {
        type = lib.types.enum [ "adaptive" "flat" ];
        default = "adaptive";
        description = ''
          Acceleration profile:
          - adaptive: Acceleration based on velocity
          - flat: No acceleration
        '';
      };
      
      # Disable while typing
      disableWhileTyping = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Disable touchpad while typing";
      };
      
      # Middle mouse emulation
      middleEmulation = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Emulate middle mouse button (left+right click)";
      };
      
      # Gestures
      gestures = {
        enable = lib.mkEnableOption "Advanced touchpad gestures";
        
        swipeFingers = lib.mkOption {
          type = lib.types.int;
          default = 3;
          description = "Number of fingers for swipe gestures";
        };
        
        pinchFingers = lib.mkOption {
          type = lib.types.int;
          default = 2;
          description = "Number of fingers for pinch gestures";
        };
      };
    };
    
    # Mouse configuration
    mouse = {
      enable = lib.mkEnableOption "Mouse configuration";
      
      naturalScrolling = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable natural scrolling for mouse";
      };
      
      accelSpeed = lib.mkOption {
        type = lib.types.float;
        default = 0.0;
        description = "Mouse acceleration speed (-1.0 to 1.0)";
      };
      
      accelProfile = lib.mkOption {
        type = lib.types.enum [ "adaptive" "flat" ];
        default = "flat";
        description = "Mouse acceleration profile";
      };
      
      middleEmulation = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Emulate middle mouse button";
      };
    };
    
    # Keyboard configuration
    keyboard = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Keyboard layout";
        example = "us,de";
      };
      
      variant = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Keyboard layout variant";
        example = "dvorak";
      };
      
      options = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "XKB keyboard options";
        example = [ "ctrl:nocaps" "compose:ralt" ];
      };
      
      repeatDelay = lib.mkOption {
        type = lib.types.int;
        default = 300;
        description = "Keyboard repeat delay in milliseconds";
      };
      
      repeatRate = lib.mkOption {
        type = lib.types.int;
        default = 30;
        description = "Keyboard repeat rate (repeats per second)";
      };
      
      numlock = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable numlock on boot";
        };
      };
    };
    
    # Gaming mode
    gaming = {
      enable = lib.mkEnableOption "Gaming mode input optimizations";
      
      disableTouchpad = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Disable touchpad in gaming mode";
      };
      
      mouseAcceleration = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Disable mouse acceleration for gaming";
      };
    };
    
    # Accessibility
    accessibility = {
      slowKeys = lib.mkEnableOption "Slow keys (require key press duration)";
      stickyKeys = lib.mkEnableOption "Sticky keys (modifier keys stay active)";
      mouseKeys = lib.mkEnableOption "Mouse keys (control mouse with keyboard)";
      repeatKeys = lib.mkEnableOption "Repeat keys when held down";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # libinput configuration
    services.xserver.libinput = {
      enable = true;
      
      # Touchpad settings
      touchpad = lib.mkIf cfg.touchpad.enable {
        tapping = cfg.touchpad.tapping;
        tappingDragLock = cfg.touchpad.dragLock;
        naturalScrolling = cfg.touchpad.naturalScrolling;
        scrollMethod = cfg.touchpad.scrollMethod;
        clickMethod = cfg.touchpad.clickMethod;
        accelSpeed = toString cfg.touchpad.accelSpeed;
        accelProfile = cfg.touchpad.accelProfile;
        disableWhileTyping = cfg.touchpad.disableWhileTyping;
        middleEmulation = cfg.touchpad.middleEmulation;
        
        # Additional libinput options
        additionalOptions = ''
          Option "TapAndDrag" "${if cfg.touchpad.tapAndDrag then "on" else "off"}"
        '';
      };
      
      # Mouse settings
      mouse = lib.mkIf cfg.mouse.enable {
        naturalScrolling = cfg.mouse.naturalScrolling;
        accelSpeed = toString cfg.mouse.accelSpeed;
        accelProfile = cfg.mouse.accelProfile;
        middleEmulation = cfg.mouse.middleEmulation;
      };
    };
    
    # Keyboard configuration
    services.xserver.xkb = {
      layout = cfg.keyboard.layout;
      variant = cfg.keyboard.variant;
      options = lib.concatStringsSep "," cfg.keyboard.options;
    };
    
    # Keyboard repeat rate
    services.xserver.autoRepeatDelay = cfg.keyboard.repeatDelay;
    services.xserver.autoRepeatInterval = lib.mkForce (1000 / cfg.keyboard.repeatRate);
    
    # Numlock on boot
    services.xserver.displayManager.setupCommands = lib.mkIf cfg.keyboard.numlock.enable ''
      ${pkgs.numlockx}/bin/numlockx on
    '';
    
    # Touchpad gestures support (libinput-gestures)
    systemd.user.services.libinput-gestures = lib.mkIf cfg.touchpad.gestures.enable {
      description = "Touchpad gesture recognition";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.libinput-gestures}/bin/libinput-gestures";
        Restart = "on-failure";
      };
    };
    
    # Gesture configuration file
    home-manager.users = lib.mkMerge (lib.mapAttrsToList (username: user:
      lib.mkIf cfg.touchpad.gestures.enable {
        ${username}.home.file.".config/libinput-gestures.conf".text = ''
          # Swipe gestures
          gesture swipe up ${toString cfg.touchpad.gestures.swipeFingers} niri msg action workspace-down
          gesture swipe down ${toString cfg.touchpad.gestures.swipeFingers} niri msg action workspace-up
          gesture swipe left ${toString cfg.touchpad.gestures.swipeFingers} niri msg action focus-window-left
          gesture swipe right ${toString cfg.touchpad.gestures.swipeFingers} niri msg action focus-window-right
          
          # Pinch gestures
          gesture pinch in ${toString cfg.touchpad.gestures.pinchFingers} niri msg action zoom-out
          gesture pinch out ${toString cfg.touchpad.gestures.pinchFingers} niri msg action zoom-in
        '';
      }
    ) config.users.users);
    
    # Gaming mode toggle script
    environment.systemPackages = with pkgs; [
      # Input utilities
      libinput                    # libinput utilities
      xorg.xinput                 # X input device utilities
      evtest                      # Input event debugging
      
      # Keyboard utilities
      xorg.xkbcomp                # XKB compiler
      xorg.xmodmap                # Keyboard modifier mapping
      numlockx                    # Numlock control
      
      # Touchpad gesture support
    ] ++ lib.optionals cfg.touchpad.gestures.enable [
      libinput-gestures           # Gesture recognition
      wmctrl                      # Window management for gestures
    ] ++ lib.optionals cfg.gaming.enable [
      # Gaming mode toggle script
      (pkgs.writeScriptBin "gaming-mode-toggle" ''
        #!${pkgs.bash}/bin/bash
        
        TOUCHPAD_ID=$(${pkgs.libinput}/bin/libinput list-devices | grep -A1 "Touchpad" | grep "Kernel:" | cut -d':' -f2 | tr -d ' ')
        
        if [ -z "$TOUCHPAD_ID" ]; then
          echo "No touchpad found"
          exit 1
        fi
        
        CURRENT_STATE=$(${pkgs.libinput}/bin/libinput list-devices | grep -A20 "$TOUCHPAD_ID" | grep "Tap-to-click:" | awk '{print $2}')
        
        if [ "$CURRENT_STATE" == "enabled" ]; then
          echo "Enabling gaming mode..."
          ${pkgs.xorg.xinput}/bin/xinput disable "$TOUCHPAD_ID"
          ${if !cfg.gaming.mouseAcceleration then ''
            ${pkgs.xorg.xinput}/bin/xinput set-prop "pointer:" "libinput Accel Profile Enabled" 0, 1
          '' else ""}
        else
          echo "Disabling gaming mode..."
          ${pkgs.xorg.xinput}/bin/xinput enable "$TOUCHPAD_ID"
          ${if cfg.mouse.accelProfile == "adaptive" then ''
            ${pkgs.xorg.xinput}/bin/xinput set-prop "pointer:" "libinput Accel Profile Enabled" 1, 0
          '' else ""}
        fi
      '')
    ];
    
    # Input device permissions
    users.groups.input = {};
    users.users = lib.mapAttrs (name: user: {
      extraGroups = [ "input" ];
    }) config.users.users;
    
    # Accessibility features
    services.xserver.displayManager.sessionCommands = lib.mkMerge [
      (lib.mkIf cfg.accessibility.slowKeys ''
        ${pkgs.xorg.xset}/bin/xset r rate ${toString cfg.keyboard.repeatDelay} ${toString cfg.keyboard.repeatRate}
      '')
      
      (lib.mkIf cfg.accessibility.mouseKeys ''
        ${pkgs.xorg.xkbcomp}/bin/xkbcomp -I$HOME/.xkb ~/.xkb/keymap/mykb $DISPLAY
      '')
    ];
  };
}
```

## Usage Examples

### Basic Touchpad Setup
```nix
{
  pantherOS.hardware.input = {
    enable = true;
    touchpad = {
      enable = true;
      tapping = true;
      naturalScrolling = true;
    };
  };
}
```

### Advanced Touchpad with Gestures
```nix
{
  pantherOS.hardware.input = {
    enable = true;
    touchpad = {
      enable = true;
      tapping = true;
      tapAndDrag = true;
      naturalScrolling = true;
      scrollMethod = "twofinger";
      clickMethod = "clickfinger";
      accelSpeed = 0.3;
      disableWhileTyping = true;
      gestures = {
        enable = true;
        swipeFingers = 3;
        pinchFingers = 2;
      };
    };
  };
}
```

### Gaming Configuration
```nix
{
  pantherOS.hardware.input = {
    enable = true;
    touchpad = {
      enable = true;
      # Basic touchpad settings
    };
    mouse = {
      enable = true;
      accelProfile = "flat";  # No acceleration for gaming
      accelSpeed = 0.0;
    };
    gaming = {
      enable = true;
      disableTouchpad = true;
      mouseAcceleration = false;
    };
  };
}
```

### Custom Keyboard Layout
```nix
{
  pantherOS.hardware.input = {
    enable = true;
    keyboard = {
      layout = "us,de";
      variant = "";
      options = [
        "grp:alt_shift_toggle"  # Switch layouts with Alt+Shift
        "ctrl:nocaps"           # Caps Lock as Ctrl
        "compose:ralt"          # Right Alt as Compose key
      ];
      repeatDelay = 250;
      repeatRate = 35;
      numlock.enable = true;
    };
  };
}
```

### Accessibility Configuration
```nix
{
  pantherOS.hardware.input = {
    enable = true;
    keyboard = {
      repeatDelay = 500;  # Slower repeat
      repeatRate = 20;    # Slower rate
    };
    accessibility = {
      slowKeys = true;
      stickyKeys = true;
      mouseKeys = true;
    };
  };
}
```

## Integration Examples

### Complete Laptop Setup (Yoga/Zephyrus)
```nix
{
  pantherOS.hardware.input = {
    enable = true;
    
    # Precision touchpad
    touchpad = {
      enable = true;
      tapping = true;
      tapAndDrag = true;
      naturalScrolling = true;
      scrollMethod = "twofinger";
      clickMethod = "clickfinger";
      accelSpeed = 0.2;
      disableWhileTyping = true;
      gestures = {
        enable = true;
        swipeFingers = 3;
        pinchFingers = 2;
      };
    };
    
    # External mouse support
    mouse = {
      enable = true;
      naturalScrolling = false;
      accelProfile = "flat";
    };
    
    # Keyboard
    keyboard = {
      layout = "us";
      options = [ "ctrl:nocaps" ];
      numlock.enable = true;
    };
  };
  
  # Complement with display management
  pantherOS.hardware.display.enable = true;
}
```

### Workstation Setup
```nix
{
  pantherOS.hardware.input = {
    enable = true;
    
    # Disable laptop touchpad (using external mouse)
    touchpad.enable = false;
    
    # High-precision mouse for productivity
    mouse = {
      enable = true;
      accelProfile = "flat";
      accelSpeed = 0.0;
    };
    
    # Programmer keyboard layout
    keyboard = {
      layout = "us";
      variant = "altgr-intl";
      options = [
        "ctrl:nocaps"
        "compose:ralt"
      ];
      repeatDelay = 200;
      repeatRate = 40;
    };
  };
}
```

## Troubleshooting

### Check Input Devices
```bash
# List all input devices
libinput list-devices

# List xinput devices
xinput list

# Check touchpad properties
xinput list-props "Touchpad"

# Test input events
evtest

# Check keyboard layout
setxkbmap -query
```

### Common Issues

#### Touchpad Not Working
1. Check if touchpad is detected:
   ```bash
   libinput list-devices | grep -i touchpad
   xinput list | grep -i touchpad
   ```

2. Verify touchpad is enabled:
   ```bash
   xinput list-props "Touchpad" | grep "Device Enabled"
   xinput enable "Touchpad"
   ```

3. Check kernel drivers:
   ```bash
   dmesg | grep -i touchpad
   lsmod | grep -E 'hid|input'
   ```

#### Tapping Not Working
1. Check tapping is enabled:
   ```bash
   xinput list-props "Touchpad" | grep "Tapping Enabled"
   ```

2. Enable tapping:
   ```bash
   xinput set-prop "Touchpad" "libinput Tapping Enabled" 1
   ```

#### Gestures Not Working
1. Verify libinput-gestures is running:
   ```bash
   systemctl --user status libinput-gestures
   ```

2. Check gesture configuration:
   ```bash
   cat ~/.config/libinput-gestures.conf
   ```

3. Test gestures manually:
   ```bash
   libinput-gestures -d  # Debug mode
   ```

#### Keyboard Layout Issues
1. Check current layout:
   ```bash
   setxkbmap -query
   ```

2. Set layout manually:
   ```bash
   setxkbmap us
   setxkbmap -option ctrl:nocaps
   ```

3. Verify XKB configuration:
   ```bash
   xkbcomp $DISPLAY /tmp/xkb.dump
   cat /tmp/xkb.dump
   ```

## Performance Considerations

### Touchpad Responsiveness
- Lower acceleration speed = more precise, slower cursor
- Higher acceleration speed = faster cursor movement
- Flat profile = consistent speed (preferred for precision work)
- Adaptive profile = dynamic speed (preferred for general use)

### Gesture Latency
- Gesture recognition adds minimal latency (<10ms)
- May impact battery life slightly
- Can be disabled when not needed

### Keyboard Repeat Rate
- Higher repeat rate = faster text input
- May cause unintended repeats if too high
- Default (30/s) is good balance

## Input Device Recommendations

### Touchpads
- **Precision Touchpad**: Full gesture support, excellent tracking
- **Synaptics**: Legacy, basic features only
- **ALPS**: Moderate support, may require tuning
- **Elan**: Good support in recent kernels

### Mice
- **Gaming**: 1000+ DPI, disable acceleration
- **Productivity**: 800-1600 DPI, flat profile
- **General**: 400-800 DPI, adaptive profile

### Keyboards
- **Mechanical**: Excellent tactile feedback
- **Scissor**: Low-profile, quiet
- **Membrane**: Budget option, basic functionality

## TODO
- [ ] Add support for tablet/stylus input devices
- [ ] Implement touchscreen gesture configuration
- [ ] Add automatic profile switching (gaming/productivity)
- [ ] Create GUI for gesture customization
- [ ] Add support for programmable mouse buttons
- [ ] Implement keyboard macro system
- [ ] Add haptic feedback configuration (if supported)
- [ ] Create input device calibration tools
