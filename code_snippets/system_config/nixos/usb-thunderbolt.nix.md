# USB & Thunderbolt Module

## Enrichment Metadata
- **Purpose**: Configure USB device management, Thunderbolt support, and USB-C functionality
- **Layer**: modules/hardware/connectivity
- **Dependencies**: udev, Thunderbolt firmware, USB drivers
- **Conflicts**: None
- **Platforms**: x86_64-linux, aarch64-linux

## Configuration Points
- `services.udev`: Device management rules
- `services.bolt.enable`: Thunderbolt 3 device management
- `hardware.usb`: USB hardware configuration
- `boot.kernelModules`: USB and Thunderbolt kernel modules

## Code

```nix
# modules/hardware/connectivity/usb-thunderbolt.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.pantherOS.hardware.connectivity;
in
{
  options.pantherOS.hardware.connectivity = {
    enable = lib.mkEnableOption "Advanced USB and Thunderbolt configuration";
    
    # USB configuration
    usb = {
      # Power management
      powerManagement = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable USB power management and auto-suspend";
        };
        
        autosuspend = lib.mkOption {
          type = lib.types.int;
          default = 2;
          description = "USB autosuspend delay in seconds (-1 to disable)";
        };
        
        allowList = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "USB device IDs to allow autosuspend (vendor:product)";
          example = [ "046d:c52b" "1234:5678" ];
        };
        
        blockList = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "usb-storage"  # USB storage devices
            "uas"          # USB attached SCSI
          ];
          description = "Device classes to exclude from autosuspend";
        };
      };
      
      # USB storage
      storage = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable USB storage device support";
        };
        
        autoMount = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Automatically mount USB storage devices";
        };
        
        mountPoint = lib.mkOption {
          type = lib.types.str;
          default = "/media";
          description = "Base mount point for USB storage";
        };
        
        filesystem = {
          ntfs = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable NTFS filesystem support";
          };
          
          exfat = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable exFAT filesystem support";
          };
          
          hfs = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable HFS+ filesystem support";
          };
        };
      };
      
      # USB devices
      devices = {
        keyboards = lib.mkEnableOption "USB keyboard support";
        mice = lib.mkEnableOption "USB mouse support";
        webcams = lib.mkEnableOption "USB webcam support";
        printers = lib.mkEnableOption "USB printer support";
        audio = lib.mkEnableOption "USB audio device support";
      };
      
      # USB-C configuration
      usbC = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable USB-C support";
        };
        
        displayPort = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable DisplayPort over USB-C (DP Alt Mode)";
        };
        
        charging = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable USB-C Power Delivery charging";
        };
        
        dataTransfer = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable high-speed data transfer over USB-C";
        };
      };
    };
    
    # Thunderbolt configuration
    thunderbolt = {
      enable = lib.mkEnableOption "Thunderbolt 3/4 support";
      
      # Security levels
      security = lib.mkOption {
        type = lib.types.enum [ "none" "user" "secure" "dponly" ];
        default = "user";
        description = ''
          Thunderbolt security level:
          - none: All devices automatically authorized
          - user: User approval required for new devices
          - secure: User approval + key verification
          - dponly: Only DisplayPort devices allowed
        '';
      };
      
      # Device authorization
      authorization = {
        autoApprove = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Automatically approve trusted Thunderbolt devices";
        };
        
        trustedDevices = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "List of trusted Thunderbolt device UUIDs";
          example = [ "00-11-22-33-44-55-66-77" ];
        };
      };
      
      # Thunderbolt dock support
      dock = {
        enable = lib.mkEnableOption "Thunderbolt dock support";
        
        autoConnect = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Automatically connect Thunderbolt dock on plug";
        };
        
        displayConfig = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Automatically configure displays when dock connected";
        };
      };
    };
    
    # Hot-plug behavior
    hotplug = {
      notifications = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show notifications for device plug/unplug events";
      };
      
      scripts = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        default = {};
        description = "Scripts to run on device events (connect/disconnect)";
        example = {
          "046d:c52b" = /path/to/script.sh;
        };
      };
    };
  };
  
  config = lib.mkIf cfg.enable {
    # USB kernel modules
    boot.kernelModules = [
      "usbcore"          # USB core support
      "usb_storage"      # USB storage
      "uas"              # USB attached SCSI
    ] ++ lib.optionals cfg.usb.storage.filesystem.ntfs [
      "ntfs3"            # NTFS filesystem (kernel driver)
    ] ++ lib.optionals cfg.thunderbolt.enable [
      "thunderbolt"      # Thunderbolt support
      "thunderbolt_net"  # Thunderbolt networking
    ];
    
    # USB filesystem support
    boot.supportedFilesystems = lib.mkMerge [
      (lib.mkIf cfg.usb.storage.filesystem.ntfs [ "ntfs" ])
      (lib.mkIf cfg.usb.storage.filesystem.exfat [ "exfat" ])
      (lib.mkIf cfg.usb.storage.filesystem.hfs [ "hfsplus" ])
    ];
    
    # USB power management
    services.udev.extraRules = lib.mkMerge [
      # USB autosuspend rules
      (lib.mkIf cfg.usb.powerManagement.enable ''
        # Enable autosuspend for USB devices
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="${toString cfg.usb.powerManagement.autosuspend}"
        
        # Block autosuspend for specific device classes
        ${lib.concatMapStringsSep "\n" (devclass: ''
          ACTION=="add", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="${devclass}", TEST=="power/control", ATTR{power/control}="on"
        '') cfg.usb.powerManagement.blockList}
        
        # Allow autosuspend for specific devices
        ${lib.concatMapStringsSep "\n" (id: 
          let
            vendor = lib.head (lib.splitString ":" id);
            product = lib.last (lib.splitString ":" id);
          in ''
            ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="${vendor}", ATTR{idProduct}=="${product}", TEST=="power/control", ATTR{power/control}="auto"
          ''
        ) cfg.usb.powerManagement.allowList}
      '')
      
      # USB storage automount
      (lib.mkIf cfg.usb.storage.autoMount ''
        # Automount USB storage devices
        ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", RUN+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode ${cfg.usb.storage.mountPoint}"
        ACTION=="remove", SUBSYSTEMS=="usb", SUBSYSTEM=="block", RUN+="${pkgs.systemd}/bin/systemd-umount $devnode"
      '')
      
      # Device hotplug notifications
      (lib.mkIf cfg.hotplug.notifications ''
        # USB device connected notification
        ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", RUN+="${pkgs.libnotify}/bin/notify-send 'USB Device Connected' 'Device: $attr{product}'"
        
        # USB device disconnected notification
        ACTION=="remove", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", RUN+="${pkgs.libnotify}/bin/notify-send 'USB Device Disconnected' 'Device removed'"
      '')
      
      # Custom hotplug scripts
      (lib.concatStringsSep "\n" (lib.mapAttrsToList (id: script:
        let
          vendor = lib.head (lib.splitString ":" id);
          product = lib.last (lib.splitString ":" id);
        in ''
          ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="${vendor}", ATTR{idProduct}=="${product}", RUN+="${script}"
        ''
      ) cfg.hotplug.scripts))
    ];
    
    # Thunderbolt support (Bolt)
    services.bolt = lib.mkIf cfg.thunderbolt.enable {
      enable = true;
      # Security level configured via systemd override
    };
    
    # Thunderbolt security configuration
    environment.etc."boltd/boltd.conf" = lib.mkIf cfg.thunderbolt.enable {
      text = ''
        [Policy]
        # Security level: none, user, secure, dponly
        Policy=${cfg.thunderbolt.security}
        
        ${lib.optionalString cfg.thunderbolt.authorization.autoApprove ''
        # Auto-approve trusted devices
        AutoApprove=true
        ''}
      '';
    };
    
    # Trust Thunderbolt devices automatically
    systemd.services.thunderbolt-trust = lib.mkIf (cfg.thunderbolt.enable && cfg.thunderbolt.authorization.trustedDevices != []) {
      description = "Trust specified Thunderbolt devices";
      after = [ "bolt.service" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeScript "thunderbolt-trust" ''
          #!${pkgs.bash}/bin/bash
          
          # Wait for bolt service
          sleep 2
          
          # Trust each device
          ${lib.concatMapStringsSep "\n" (uuid: ''
            ${pkgs.bolt}/bin/boltctl authorize ${uuid} 2>/dev/null || true
          '') cfg.thunderbolt.authorization.trustedDevices}
        '';
      };
    };
    
    # Thunderbolt dock display configuration
    systemd.user.services.thunderbolt-dock-displays = lib.mkIf (cfg.thunderbolt.dock.enable && cfg.thunderbolt.dock.displayConfig) {
      description = "Configure displays on Thunderbolt dock connection";
      
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeScript "dock-displays" ''
          #!${pkgs.bash}/bin/bash
          
          # Wait for displays to be detected
          sleep 3
          
          # Trigger display reconfiguration
          ${pkgs.systemd}/bin/systemctl --user restart display-configure.service
        '';
      };
    };
    
    # Thunderbolt dock udev rule
    services.udev.extraRules = lib.mkIf (cfg.thunderbolt.dock.enable && cfg.thunderbolt.dock.displayConfig) ''
      # Trigger display configuration on Thunderbolt dock connect
      ACTION=="add", SUBSYSTEM=="thunderbolt", ENV{DEVTYPE}=="thunderbolt_device", RUN+="${pkgs.systemd}/bin/systemctl --user start thunderbolt-dock-displays.service"
    '';
    
    # System packages
    environment.systemPackages = with pkgs; [
      # USB utilities
      usbutils           # lsusb and other USB tools
      usb-modeswitch     # Mode switching for USB devices
      
      # Storage utilities
      ntfs3g             # NTFS filesystem support
      exfat              # exFAT filesystem support
    ] ++ lib.optionals cfg.usb.storage.filesystem.hfs [
      hfsprogs           # HFS+ utilities
    ] ++ lib.optionals cfg.thunderbolt.enable [
      # Thunderbolt utilities
      bolt               # Thunderbolt device manager
      thunderbolt-software-user-space  # Thunderbolt tools
    ] ++ lib.optionals cfg.hotplug.notifications [
      libnotify          # Desktop notifications
    ];
    
    # Enable USB device access for users
    users.groups.plugdev = {};
    users.users = lib.mapAttrs (name: user: {
      extraGroups = [ "plugdev" ];
    }) config.users.users;
    
    # USB device permissions
    services.udev.packages = with pkgs; [
      # Common USB device rules
    ] ++ lib.optionals cfg.usb.devices.keyboards [
      # Keyboard-specific rules
    ] ++ lib.optionals cfg.usb.devices.webcams [
      # Webcam-specific rules
    ];
  };
}
```

## Usage Examples

### Basic USB Configuration
```nix
{
  pantherOS.hardware.connectivity = {
    enable = true;
    usb = {
      storage.autoMount = true;
      powerManagement.enable = true;
    };
  };
}
```

### Laptop USB Power Management
```nix
{
  pantherOS.hardware.connectivity = {
    enable = true;
    usb = {
      powerManagement = {
        enable = true;
        autosuspend = 2;
        blockList = [ "usb-storage" "uas" ];
      };
      storage = {
        autoMount = true;
        filesystem = {
          ntfs = true;
          exfat = true;
        };
      };
    };
  };
}
```

### Thunderbolt Dock Setup
```nix
{
  pantherOS.hardware.connectivity = {
    enable = true;
    thunderbolt = {
      enable = true;
      security = "user";
      dock = {
        enable = true;
        autoConnect = true;
        displayConfig = true;
      };
    };
    usb.usbC = {
      enable = true;
      displayPort = true;
      charging = true;
    };
  };
}
```

### Workstation with Thunderbolt Devices
```nix
{
  pantherOS.hardware.connectivity = {
    enable = true;
    usb.powerManagement.enable = false;  # Disable for desktop
    thunderbolt = {
      enable = true;
      security = "user";
      authorization = {
        autoApprove = false;
        trustedDevices = [
          "00-11-22-33-44-55-66-77"  # Thunderbolt dock
          "88-99-AA-BB-CC-DD-EE-FF"  # External GPU
        ];
      };
    };
  };
}
```

### USB-C Laptop Configuration
```nix
{
  pantherOS.hardware.connectivity = {
    enable = true;
    usb = {
      usbC = {
        enable = true;
        displayPort = true;
        charging = true;
        dataTransfer = true;
      };
      storage.autoMount = true;
      powerManagement.enable = true;
    };
    hotplug.notifications = true;
  };
}
```

### Secure Thunderbolt Configuration
```nix
{
  pantherOS.hardware.connectivity = {
    enable = true;
    thunderbolt = {
      enable = true;
      security = "secure";  # Highest security
      authorization = {
        autoApprove = false;
        trustedDevices = [];  # Manual approval only
      };
    };
  };
}
```

## Integration Examples

### Complete Laptop Setup
```nix
{
  pantherOS.hardware.connectivity = {
    enable = true;
    
    # USB configuration
    usb = {
      powerManagement = {
        enable = true;
        autosuspend = 2;
      };
      storage = {
        autoMount = true;
        filesystem = {
          ntfs = true;
          exfat = true;
        };
      };
      usbC = {
        enable = true;
        displayPort = true;
        charging = true;
      };
      devices = {
        keyboards = true;
        mice = true;
        webcams = true;
        audio = true;
      };
    };
    
    # Thunderbolt for dock
    thunderbolt = {
      enable = true;
      security = "user";
      dock = {
        enable = true;
        displayConfig = true;
      };
    };
    
    hotplug.notifications = true;
  };
  
  # Complement with battery management
  pantherOS.hardware.laptop.battery.enable = true;
}
```

## Troubleshooting

### Check USB Devices
```bash
# List all USB devices
lsusb
lsusb -t  # Tree view

# Check USB device details
lsusb -v -d <vendor>:<product>

# Monitor USB events
udevadm monitor --subsystem-match=usb

# Check USB power management
cat /sys/bus/usb/devices/*/power/control
cat /sys/bus/usb/devices/*/power/autosuspend
```

### Check Thunderbolt
```bash
# List Thunderbolt devices
boltctl list

# Check Thunderbolt status
boltctl domains
boltctl info <uuid>

# Authorize Thunderbolt device
boltctl authorize <uuid>

# Check kernel support
dmesg | grep -i thunderbolt
lsmod | grep thunderbolt
```

### Common Issues

#### USB Device Not Detected
1. Check physical connection
2. Verify device power:
   ```bash
   lsusb
   dmesg | tail -50
   ```

3. Check USB port functionality:
   ```bash
   cat /sys/bus/usb/devices/usb*/power/control
   ```

#### USB Storage Not Mounting
1. Check if device is detected:
   ```bash
   lsblk
   ```

2. Mount manually:
   ```bash
   sudo mount /dev/sdX1 /mnt
   ```

3. Check filesystem support:
   ```bash
   cat /proc/filesystems
   ```

#### Thunderbolt Device Not Authorized
1. Check security level:
   ```bash
   boltctl domains
   ```

2. Authorize device:
   ```bash
   boltctl authorize <uuid>
   ```

3. Set to auto-authorize:
   ```bash
   boltctl enroll <uuid>
   ```

#### USB-C Display Not Working
1. Verify DP Alt Mode support
2. Check cable quality (must be USB-C 3.1+ with DP)
3. Update firmware
4. Try different USB-C port

## Performance Considerations

### USB Power Management
- Autosuspend saves power but may cause latency
- Disable for high-performance devices (mice, keyboards)
- Default 2-second delay is good balance

### Thunderbolt Bandwidth
- TB3: 40 Gbps bidirectional
- TB4: 40 Gbps + PCIe 4.0
- Daisy-chaining reduces per-device bandwidth

### USB-C Charging
- Power Delivery negotiation may take 1-2 seconds
- Some devices require specific power profiles
- Quality cables essential for fast charging

## Security Considerations

1. **Thunderbolt Security Levels**:
   - `none`: Convenient but insecure
   - `user`: Good balance for personal devices
   - `secure`: Recommended for sensitive environments
   - `dponly`: Maximum security, displays only

2. **USB Device Security**:
   - Unknown USB devices can pose security risks
   - Consider USB port blocking for public-facing systems
   - Monitor USB device connections

3. **Data Protection**:
   - Encrypt sensitive data on USB storage
   - Use filesystem permissions appropriately
   - Consider disabling USB storage in high-security environments

## Hardware Compatibility

### USB-C Standards
- USB 2.0: 480 Mbps
- USB 3.1 Gen 1: 5 Gbps
- USB 3.1 Gen 2: 10 Gbps
- USB 3.2: 20 Gbps
- USB4: 40 Gbps

### Thunderbolt Versions
- TB1/2: 20 Gbps (mini DisplayPort)
- TB3: 40 Gbps (USB-C)
- TB4: 40 Gbps (USB-C, stricter requirements)

### Common Thunderbolt Docks
- CalDigit TS3/TS4
- OWC Thunderbolt Dock
- Anker PowerExpand
- Dell WD19TB

## TODO
- [ ] Add USB device filtering and whitelisting
- [ ] Implement USB device encryption support
- [ ] Add Thunderbolt network configuration
- [ ] Create dock profile switching
- [ ] Add support for USB device power measurement
- [ ] Implement USB device firmware update system
- [ ] Add Thunderbolt PCIe device passthrough
- [ ] Create USB diagnostic and testing tools
