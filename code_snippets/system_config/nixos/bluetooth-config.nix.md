# Bluetooth Configuration Module

## Enrichment Metadata
- **Purpose**: Configure Bluetooth for device pairing, audio, and file transfer
- **Layer**: modules/networking/bluetooth
- **Dependencies**: BlueZ, PipeWire (for audio), PulseAudio compatibility
- **Conflicts**: None
- **Platforms**: x86_64-linux, aarch64-linux (requires Bluetooth hardware)

## Configuration Points
- `hardware.bluetooth.enable`: Enable Bluetooth support
- `hardware.bluetooth.powerOnBoot`: Auto-power Bluetooth on boot
- `hardware.bluetooth.settings`: BlueZ daemon configuration
- `services.blueman.enable`: Enable Blueman GUI manager

## Code

```nix
# modules/networking/bluetooth/config.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.pantherOS.networking.bluetooth;
in
{
  options.pantherOS.networking.bluetooth = {
    enable = lib.mkEnableOption "Bluetooth device management";
    
    # Power management
    power = {
      onBoot = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Power on Bluetooth adapter at boot";
      };
      
      autoSuspend = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable USB auto-suspend for Bluetooth adapter";
      };
    };
    
    # Audio configuration
    audio = {
      enable = lib.mkEnableOption "Bluetooth audio support (A2DP, HSP/HFP)";
      
      codecs = {
        sbc = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable SBC codec (basic quality)";
        };
        
        sbcXQ = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable SBC-XQ codec (improved quality)";
        };
        
        aac = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable AAC codec (high quality)";
        };
        
        aptx = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable aptX codec (proprietary, high quality)";
        };
        
        ldac = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable LDAC codec (Sony, highest quality)";
        };
      };
      
      profiles = {
        a2dp = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable A2DP profile (high-quality audio streaming)";
        };
        
        hsp = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable HSP profile (headset)";
        };
        
        hfp = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable HFP profile (hands-free)";
        };
      };
      
      autoSwitch = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically switch audio to Bluetooth devices when connected";
      };
      
      hwVolume = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable hardware volume control for Bluetooth devices";
      };
    };
    
    # Device management
    devices = {
      autoConnect = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically connect to trusted devices";
      };
      
      autoTrust = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Automatically trust paired devices";
      };
      
      discoverable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Make adapter discoverable by default";
      };
      
      discoverableTimeout = lib.mkOption {
        type = lib.types.int;
        default = 180;
        description = "Discoverable timeout in seconds (0 = always discoverable)";
      };
      
      trustedDevices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of MAC addresses to always trust";
        example = [ "00:11:22:33:44:55" ];
      };
    };
    
    # File transfer
    fileTransfer = {
      enable = lib.mkEnableOption "Bluetooth file transfer (OBEX)";
      
      downloadPath = lib.mkOption {
        type = lib.types.str;
        default = "~/Downloads/Bluetooth";
        description = "Default download path for received files";
      };
    };
    
    # Pairing and security
    security = {
      pairMode = lib.mkOption {
        type = lib.types.enum [ "DisplayYesNo" "KeyboardOnly" "NoInputNoOutput" "DisplayOnly" ];
        default = "DisplayYesNo";
        description = "Pairing mode for device authentication";
      };
      
      justWorksRepairing = lib.mkOption {
        type = lib.types.enum [ "never" "confirm" "always" ];
        default = "confirm";
        description = "JustWorks repairing mode";
      };
      
      privacy = lib.mkEnableOption "Enable privacy mode (rotate Bluetooth address)";
    };
    
    # GUI manager
    gui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable GUI Bluetooth manager (Blueman)";
      };
      
      systray = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show Bluetooth icon in system tray";
      };
    };
    
    # Experimental features
    experimental = {
      enable = lib.mkEnableOption "Enable experimental BlueZ features";
      
      features = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "KernelExperimental" ];
        description = "List of experimental features to enable";
      };
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Enable Bluetooth hardware support
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = cfg.power.onBoot;
      
      # BlueZ settings
      settings = {
        # General settings
        General = {
          Enable = lib.concatStringsSep "," (
            [ "Source" "Sink" "Media" "Socket" ] ++
            lib.optional cfg.audio.profiles.a2dp "Gateway" ++
            lib.optional cfg.fileTransfer.enable "Control"
          );
          
          Experimental = cfg.experimental.enable;
          KernelExperimental = lib.mkIf cfg.experimental.enable true;
          
          # Device discovery
          Discoverable = cfg.devices.discoverable;
          DiscoverableTimeout = cfg.devices.discoverableTimeout;
          
          # Privacy
          Privacy = if cfg.security.privacy then "device" else "off";
          JustWorksRepairing = cfg.security.justWorksRepairing;
          
          # Auto-connect
          AutoEnable = cfg.devices.autoConnect;
        };
        
        # Policy settings
        Policy = {
          AutoEnable = cfg.devices.autoConnect;
          ReconnectAttempts = 7;
          ReconnectIntervals = "1,2,4,8,16,32,64";
        };
        
        # Audio settings for A2DP/HSP/HFP
        LE = lib.mkIf cfg.audio.enable {
          # Low Energy audio
          EnableAdvMonInterleaveScan = true;
        };
      };
    };
    
    # Bluetooth audio configuration with PipeWire
    services.pipewire.wireplumber.configPackages = lib.mkIf cfg.audio.enable [
      (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluetooth-config.lua" ''
        -- Bluetooth audio configuration
        bluez_monitor.properties = {
          -- Enable high-quality audio codecs
          ["bluez5.enable-sbc-xq"] = ${if cfg.audio.codecs.sbcXQ then "true" else "false"},
          ["bluez5.enable-msbc"] = ${if cfg.audio.profiles.hfp then "true" else "false"},
          ["bluez5.enable-hw-volume"] = ${if cfg.audio.hwVolume then "true" else "false"},
          
          -- Codec support
          ["bluez5.codecs"] = {
            ${lib.optionalString cfg.audio.codecs.sbc "sbc"}
            ${lib.optionalString cfg.audio.codecs.sbcXQ ", sbc_xq"}
            ${lib.optionalString cfg.audio.codecs.aac ", aac"}
            ${lib.optionalString cfg.audio.codecs.aptx ", aptx"}
            ${lib.optionalString cfg.audio.codecs.ldac ", ldac"}
          },
          
          -- Auto-connect profiles
          ["bluez5.roles"] = {
            ${lib.optionalString cfg.audio.profiles.hsp "hsp_hs, hsp_ag"}
            ${lib.optionalString cfg.audio.profiles.hfp ", hfp_hf, hfp_ag"}
            ${lib.optionalString cfg.audio.profiles.a2dp ", a2dp_sink, a2dp_source"}
          },
        }
        
        -- Auto-switch to Bluetooth audio
        ${lib.optionalString cfg.audio.autoSwitch ''
          bluez_monitor.rules = {
            {
              matches = {
                { "device.name", "matches", "bluez_card.*" },
              },
              apply_properties = {
                ["bluez5.auto-connect"] = { "hfp_hf", "hsp_hs", "a2dp_sink" },
                ["device.profile-set"] = "auto",
              },
            },
          }
        ''}
      '')
    ];
    
    # Blueman GUI manager
    services.blueman.enable = cfg.gui.enable;
    
    # System packages for Bluetooth management
    environment.systemPackages = with pkgs; [
      # Core Bluetooth utilities
      bluez                     # Bluetooth protocol stack
      bluez-tools               # Additional tools (bt-device, bt-network, etc.)
      
      # Audio codec support
    ] ++ lib.optionals cfg.audio.codecs.aac [
      # AAC codec (might need additional packages)
    ] ++ lib.optionals cfg.audio.codecs.aptx [
      # aptX codec support (proprietary)
    ] ++ lib.optionals cfg.audio.codecs.ldac [
      # LDAC codec support
    ] ++ lib.optionals cfg.fileTransfer.enable [
      # File transfer
      obex-data-server          # OBEX file transfer
      obexftp                   # OBEX FTP client
    ] ++ lib.optionals cfg.gui.enable [
      # GUI applications
      blueman                   # Bluetooth manager GUI
    ];
    
    # OBEX file transfer service
    systemd.user.services.obex = lib.mkIf cfg.fileTransfer.enable {
      description = "Bluetooth OBEX file transfer";
      wantedBy = [ "graphical-session.target" ];
      
      serviceConfig = {
        Type = "dbus";
        BusName = "org.bluez.obex";
        ExecStart = "${pkgs.bluez}/libexec/bluetooth/obexd";
      };
    };
    
    # Bluetooth file transfer directory
    systemd.user.tmpfiles.rules = lib.mkIf cfg.fileTransfer.enable [
      "d ${cfg.fileTransfer.downloadPath} 0755 - - -"
    ];
    
    # Auto-trust specified devices
    systemd.services.bluetooth-trust-devices = lib.mkIf (cfg.devices.trustedDevices != []) {
      description = "Trust specified Bluetooth devices";
      after = [ "bluetooth.service" ];
      wantedBy = [ "bluetooth.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeScript "trust-devices" ''
          #!${pkgs.bash}/bin/bash
          
          # Wait for Bluetooth to be ready
          sleep 5
          
          # Trust each device
          ${lib.concatMapStringsSep "\n" (mac: ''
            ${pkgs.bluez-tools}/bin/bt-device -c ${mac} --set Trusted 1 2>/dev/null || true
          '') cfg.devices.trustedDevices}
        '';
      };
    };
    
    # USB power management for Bluetooth adapter
    services.udev.extraRules = lib.mkIf cfg.power.autoSuspend ''
      # Enable auto-suspend for Bluetooth USB adapters
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="*", ATTR{idProduct}=="*", ATTR{bDeviceClass}=="e0", ATTR{bDeviceSubClass}=="01", ATTR{bDeviceProtocol}=="01", TEST=="power/control", ATTR{power/control}="auto"
    '';
    
    # User groups for Bluetooth access
    users.groups.bluetooth = {};
    users.users = lib.mapAttrs (name: user: {
      extraGroups = [ "bluetooth" ];
    }) config.users.users;
  };
}
```

## Usage Examples

### Basic Bluetooth Setup
```nix
{
  pantherOS.networking.bluetooth = {
    enable = true;
  };
}
```

### Bluetooth Audio for Headphones
```nix
{
  pantherOS.networking.bluetooth = {
    enable = true;
    audio = {
      enable = true;
      codecs = {
        sbc = true;
        sbcXQ = true;
        aac = true;
      };
      autoSwitch = true;
      hwVolume = true;
    };
  };
}
```

### High-Quality Bluetooth Audio (LDAC/aptX)
```nix
{
  pantherOS.networking.bluetooth = {
    enable = true;
    audio = {
      enable = true;
      codecs = {
        sbc = true;
        sbcXQ = true;
        aac = true;
        aptx = true;
        ldac = true;
      };
      profiles = {
        a2dp = true;
        hfp = true;
      };
    };
  };
}
```

### Bluetooth File Transfer
```nix
{
  pantherOS.networking.bluetooth = {
    enable = true;
    fileTransfer = {
      enable = true;
      downloadPath = "~/Downloads/Bluetooth";
    };
    gui.enable = true;
  };
}
```

### Trusted Device Auto-Connect
```nix
{
  pantherOS.networking.bluetooth = {
    enable = true;
    devices = {
      autoConnect = true;
      trustedDevices = [
        "00:1A:7D:DA:71:13"  # Bluetooth headphones
        "A4:C1:38:XX:XX:XX"  # Bluetooth keyboard
      ];
    };
  };
}
```

### Secure Bluetooth Configuration
```nix
{
  pantherOS.networking.bluetooth = {
    enable = true;
    power.onBoot = false;  # Manual activation
    devices = {
      discoverable = false;
      autoConnect = false;
      autoTrust = false;
    };
    security = {
      pairMode = "DisplayYesNo";
      privacy = true;
    };
  };
}
```

## Integration Examples

### Complete Laptop Audio Setup
```nix
{
  # Bluetooth for wireless audio
  pantherOS.networking.bluetooth = {
    enable = true;
    audio = {
      enable = true;
      codecs = {
        sbcXQ = true;
        aac = true;
      };
      autoSwitch = true;
    };
    gui.enable = true;
  };
  
  # Audio system with Bluetooth support
  pantherOS.hardware.audio = {
    enable = true;
    features.bluetooth = true;
  };
}
```

### Workstation with Multiple Bluetooth Devices
```nix
{
  pantherOS.networking.bluetooth = {
    enable = true;
    audio.enable = true;
    fileTransfer.enable = true;
    devices = {
      autoConnect = true;
      trustedDevices = [
        "XX:XX:XX:XX:XX:01"  # Keyboard
        "XX:XX:XX:XX:XX:02"  # Mouse
        "XX:XX:XX:XX:XX:03"  # Headphones
      ];
    };
    experimental.enable = true;
  };
}
```

## Troubleshooting

### Check Bluetooth Status
```bash
# Check Bluetooth service
systemctl status bluetooth

# Check adapter status
bluetoothctl show

# List paired devices
bluetoothctl devices

# Check audio devices
pactl list sinks short | grep bluez
```

### Common Issues

#### Bluetooth Not Working
1. Verify hardware:
   ```bash
   lsusb | grep -i bluetooth
   rfkill list bluetooth
   ```

2. Unblock if needed:
   ```bash
   rfkill unblock bluetooth
   ```

3. Restart service:
   ```bash
   systemctl restart bluetooth
   ```

#### Cannot Pair Device
1. Enter pairing mode:
   ```bash
   bluetoothctl
   > power on
   > agent on
   > default-agent
   > scan on
   > pair XX:XX:XX:XX:XX:XX
   ```

2. Remove old pairing:
   ```bash
   bluetoothctl remove XX:XX:XX:XX:XX:XX
   ```

3. Trust device:
   ```bash
   bluetoothctl trust XX:XX:XX:XX:XX:XX
   ```

#### Audio Quality Poor
1. Check active codec:
   ```bash
   pactl list sinks | grep -A10 bluez
   ```

2. Force better codec:
   ```bash
   pactl set-card-profile bluez_card.XX_XX_XX_XX_XX_XX a2dp_sink
   ```

3. Reduce distance and interference

#### Device Won't Auto-Connect
1. Trust and auto-connect:
   ```bash
   bluetoothctl trust XX:XX:XX:XX:XX:XX
   bluetoothctl connect XX:XX:XX:XX:XX:XX
   ```

2. Check power settings:
   ```bash
   bluetoothctl show | grep Powered
   ```

### File Transfer Issues
1. Start OBEX service:
   ```bash
   systemctl --user start obex
   ```

2. Test file send:
   ```bash
   obexftp -b XX:XX:XX:XX:XX:XX -p file.txt
   ```

## Performance Considerations

### Audio Codecs
- **SBC**: Basic quality, universal compatibility, low CPU
- **SBC-XQ**: Improved quality, still efficient
- **AAC**: High quality, moderate CPU usage
- **aptX**: Very good quality, proprietary, low latency
- **LDAC**: Best quality, highest CPU usage, Sony devices

### Connection Stability
- Keep adapter firmware updated
- Minimize USB hub usage (direct connection better)
- Reduce 2.4GHz WiFi interference
- Maintain line-of-sight when possible

### Battery Impact
- Auto-suspend can save ~10-20% battery on laptops
- Disable Bluetooth when not in use
- Lower quality codecs use less power

## Security Recommendations

1. **Pairing Security**: Use "DisplayYesNo" for maximum security
2. **Privacy Mode**: Enable address rotation for public spaces
3. **Disable Discovery**: Only enable when pairing new devices
4. **Trust Carefully**: Only trust known devices
5. **Keep Updated**: Update BlueZ regularly for security patches

## Bluetooth Device Types

### Audio Devices
- Headphones/earbuds: A2DP profile
- Headsets: HFP profile for calls
- Speakers: A2DP profile

### Input Devices
- Keyboards: HID profile
- Mice: HID profile
- Game controllers: HID profile

### Other Devices
- Smartphones: Multiple profiles
- Smartwatches: GATT/LE
- Fitness trackers: GATT/LE

## TODO
- [ ] Add support for Bluetooth LE audio
- [ ] Implement automatic codec selection based on quality/battery
- [ ] Add Bluetooth device battery level monitoring
- [ ] Create GUI for codec preference configuration
- [ ] Add support for Bluetooth tethering
- [ ] Implement multi-device audio switching
- [ ] Add integration with desktop notifications for device events
- [ ] Create Bluetooth proximity-based actions (auto-lock/unlock)
