# WiFi Network Module

## Enrichment Metadata
- **Purpose**: Configure WiFi networking with NetworkManager for laptop and workstation setups
- **Layer**: modules/networking/wireless
- **Dependencies**: NetworkManager, wpa_supplicant, wireless drivers
- **Conflicts**: wicd, standalone wpa_supplicant configuration
- **Platforms**: x86_64-linux, aarch64-linux (requires WiFi hardware)

## Configuration Points
- `networking.networkmanager.enable`: Enable NetworkManager for network management
- `networking.wireless.enable`: Enable wpa_supplicant (conflicts with NetworkManager)
- `networking.networkmanager.wifi.backend`: WiFi backend (wpa_supplicant or iwd)
- `networking.networkmanager.wifi.powersave`: Power saving mode for WiFi
- `hardware.enableRedistributableFirmware`: Enable proprietary WiFi firmware

## Code

```nix
# modules/networking/wireless/wifi.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.pantherOS.networking.wifi;
in
{
  options.pantherOS.networking.wifi = {
    enable = lib.mkEnableOption "Advanced WiFi network configuration";
    
    # WiFi backend selection
    backend = lib.mkOption {
      type = lib.types.enum [ "wpa_supplicant" "iwd" ];
      default = "wpa_supplicant";
      description = ''
        WiFi backend to use:
        - wpa_supplicant: Traditional, well-tested (default)
        - iwd: Modern, lightweight alternative
      '';
    };
    
    # Power management
    powerManagement = {
      enable = lib.mkEnableOption "WiFi power management";
      
      mode = lib.mkOption {
        type = lib.types.enum [ "off" "on" "adaptive" ];
        default = "adaptive";
        description = ''
          Power saving mode:
          - off: Maximum performance, higher power consumption
          - on: Maximum power saving, may reduce performance
          - adaptive: Balance between performance and power saving
        '';
      };
    };
    
    # Security settings
    security = {
      randomizeMac = lib.mkEnableOption "MAC address randomization for privacy";
      
      preferredProtocols = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "wpa3" "wpa2" "wpa" ]);
        default = [ "wpa3" "wpa2" ];
        description = "Preferred WiFi security protocols in order of preference";
      };
      
      disableInsecure = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Disable insecure protocols (WEP, open networks)";
      };
    };
    
    # Connection management
    connections = {
      autoConnect = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically connect to known networks";
      };
      
      priorityNetworks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of SSIDs to prioritize for connection";
        example = [ "HomeNetwork" "WorkNetwork" ];
      };
    };
    
    # Enterprise WiFi support
    enterprise = {
      enable = lib.mkEnableOption "Enterprise WiFi (802.1X) support";
      
      profiles = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            ssid = lib.mkOption {
              type = lib.types.str;
              description = "Network SSID";
            };
            
            auth = lib.mkOption {
              type = lib.types.enum [ "peap" "ttls" "tls" ];
              description = "Authentication method";
            };
            
            identity = lib.mkOption {
              type = lib.types.str;
              description = "User identity/username";
            };
            
            caCertPath = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Path to CA certificate";
            };
          };
        });
        default = {};
        description = "Enterprise WiFi network profiles";
      };
    };
    
    # Hardware-specific optimizations
    hardware = {
      enableFirmware = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable proprietary WiFi firmware";
      };
      
      driver = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Force specific WiFi driver (e.g., 'iwlwifi', 'ath10k')";
        example = "iwlwifi";
      };
      
      optimizations = {
        intel = lib.mkEnableOption "Intel WiFi optimizations";
        broadcom = lib.mkEnableOption "Broadcom WiFi optimizations";
        atheros = lib.mkEnableOption "Atheros WiFi optimizations";
        realtek = lib.mkEnableOption "Realtek WiFi optimizations";
      };
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Enable NetworkManager for WiFi management
    networking.networkmanager = {
      enable = true;
      
      # WiFi backend
      wifi = {
        backend = cfg.backend;
        
        # Power saving configuration
        powersave = if cfg.powerManagement.enable then
          (if cfg.powerManagement.mode == "off" then false
           else if cfg.powerManagement.mode == "on" then true
           else true)  # adaptive defaults to on
        else false;
        
        # MAC randomization for privacy
        scanRandMacAddress = cfg.security.randomizeMac;
        macAddress = if cfg.security.randomizeMac then "random" else "preserve";
      };
      
      # DNS management
      dns = "systemd-resolved";
      
      # Connection settings
      settings = {
        connection = {
          autoconnect-priority = 100;
        };
        
        # Security settings
        wifi-security = {
          # Prefer WPA3 if available
          pmf = if builtins.elem "wpa3" cfg.security.preferredProtocols then 2 else 1;
        };
      };
      
      # Additional configuration
      appendNameservers = [ "1.1.1.1" "1.0.0.1" ];  # Cloudflare DNS as fallback
      
      # Plugins
      plugins = [
        "keyfile"
        "ifupdown"
      ];
    };
    
    # Disable standalone wpa_supplicant (conflicts with NetworkManager)
    networking.wireless.enable = false;
    
    # Enable WiFi firmware
    hardware.enableRedistributableFirmware = cfg.hardware.enableFirmware;
    
    # Hardware-specific driver configurations
    boot.kernelModules = lib.optionals (cfg.hardware.driver != null) [ cfg.hardware.driver ];
    
    # Intel WiFi optimizations
    boot.extraModprobeConfig = lib.mkMerge [
      (lib.mkIf cfg.hardware.optimizations.intel ''
        # Intel WiFi 6/6E optimizations
        options iwlwifi power_save=1
        options iwlwifi uapsd_disable=0
        options iwlwifi 11n_disable=0
        options iwlwifi bt_coex_active=1
        options iwlwifi swcrypto=0
        options iwlwifi power_scheme=2
      '')
      
      (lib.mkIf cfg.hardware.optimizations.broadcom ''
        # Broadcom WiFi optimizations
        options brcmfmac feature_disable=0x82000
        options brcmfmac roamoff=1
      '')
      
      (lib.mkIf cfg.hardware.optimizations.atheros ''
        # Atheros WiFi optimizations
        options ath10k_core skip_otp=y
        options ath10k_pci irq_mode=0
      '')
      
      (lib.mkIf cfg.hardware.optimizations.realtek ''
        # Realtek WiFi optimizations
        options rtw88_core disable_lps_deep=y
        options rtw88_pci disable_msi=n
        options rtw88_pci disable_aspm=n
      '')
    ];
    
    # System packages for WiFi management
    environment.systemPackages = with pkgs; [
      # NetworkManager tools
      networkmanager
      networkmanagerapplet  # GUI for NetworkManager
      
      # WiFi utilities
      wirelesstools         # iwconfig, iwlist, etc.
      iw                    # Modern wireless tools
      
      # Debugging and monitoring
      wavemon               # Wireless network monitoring
      speedtest-cli         # Network speed testing
      
      # WPA supplicant tools (if using wpa_supplicant backend)
    ] ++ lib.optionals (cfg.backend == "wpa_supplicant") [
      wpa_supplicant
      wpa_supplicant_gui
    ] ++ lib.optionals cfg.enterprise.enable [
      # Enterprise WiFi tools
      openssl               # For certificate management
    ];
    
    # Enterprise WiFi configuration
    environment.etc = lib.mkMerge (lib.mapAttrsToList (name: profile:
      lib.mkIf cfg.enterprise.enable {
        "NetworkManager/system-connections/${name}.nmconnection" = {
          text = ''
            [connection]
            id=${name}
            uuid=${builtins.hashString "sha256" name}
            type=wifi
            autoconnect=true
            
            [wifi]
            ssid=${profile.ssid}
            mode=infrastructure
            
            [wifi-security]
            key-mgmt=wpa-eap
            
            [802-1x]
            eap=${profile.auth}
            identity=${profile.identity}
            ${lib.optionalString (profile.caCertPath != null) "ca-cert=${profile.caCertPath}"}
            
            [ipv4]
            method=auto
            
            [ipv6]
            method=auto
          '';
          mode = "0600";
        };
      }
    ) cfg.enterprise.profiles);
    
    # User groups for network management
    users.users = lib.mapAttrs (name: user: {
      extraGroups = [ "networkmanager" ];
    }) config.users.users;
    
    # Systemd resolved for DNS
    services.resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
    };
  };
}
```

## Usage Examples

### Basic WiFi Setup
```nix
{
  pantherOS.networking.wifi = {
    enable = true;
  };
}
```

### Laptop WiFi with Power Management
```nix
{
  pantherOS.networking.wifi = {
    enable = true;
    powerManagement = {
      enable = true;
      mode = "adaptive";
    };
    security.randomizeMac = true;
  };
}
```

### Enterprise WiFi Configuration
```nix
{
  pantherOS.networking.wifi = {
    enable = true;
    enterprise = {
      enable = true;
      profiles = {
        "CompanyWiFi" = {
          ssid = "CorpNetwork";
          auth = "peap";
          identity = "username@company.com";
          caCertPath = /etc/ssl/certs/company-ca.pem;
        };
      };
    };
  };
}
```

### Intel WiFi with Optimizations
```nix
{
  pantherOS.networking.wifi = {
    enable = true;
    hardware = {
      optimizations.intel = true;
    };
    powerManagement = {
      enable = true;
      mode = "adaptive";
    };
  };
}
```

### High-Performance WiFi
```nix
{
  pantherOS.networking.wifi = {
    enable = true;
    backend = "iwd";  # Modern, faster backend
    powerManagement = {
      enable = false;  # Disable for maximum performance
    };
    security = {
      preferredProtocols = [ "wpa3" "wpa2" ];
      disableInsecure = true;
    };
  };
}
```

## Integration Examples

### Laptop Configuration
```nix
{
  # WiFi with power management
  pantherOS.networking.wifi = {
    enable = true;
    powerManagement = {
      enable = true;
      mode = "adaptive";
    };
    security.randomizeMac = true;
  };
  
  # Battery optimization
  pantherOS.hardware.laptop.battery.enable = true;
}
```

### Travel Configuration
```nix
{
  pantherOS.networking.wifi = {
    enable = true;
    security = {
      randomizeMac = true;
      preferredProtocols = [ "wpa3" "wpa2" ];
      disableInsecure = true;
    };
    connections.autoConnect = false;  # Manual connection for safety
  };
}
```

## Troubleshooting

### Check WiFi Status
```bash
# Check NetworkManager status
nmcli general status

# List available WiFi networks
nmcli device wifi list

# Show current connection
nmcli connection show --active

# Check WiFi hardware
lspci | grep -i network
lsusb | grep -i wireless

# Check driver status
lsmod | grep -E 'iwl|ath|rtw|brcm'
```

### Common Issues

#### WiFi Not Detected
1. Check if hardware is recognized:
   ```bash
   ip link show
   nmcli device status
   ```

2. Verify WiFi is not blocked:
   ```bash
   rfkill list
   rfkill unblock wifi
   ```

3. Check kernel modules:
   ```bash
   lsmod | grep wifi
   dmesg | grep -i wifi
   ```

#### Cannot Connect to Network
1. Check network availability:
   ```bash
   nmcli device wifi list
   ```

2. Connect manually:
   ```bash
   nmcli device wifi connect "SSID" password "PASSWORD"
   ```

3. Check authentication logs:
   ```bash
   journalctl -u NetworkManager -f
   ```

#### Slow WiFi Performance
1. Check signal strength:
   ```bash
   nmcli device wifi list
   wavemon
   ```

2. Disable power saving temporarily:
   ```bash
   sudo iw dev wlan0 set power_save off
   ```

3. Check for interference:
   ```bash
   iw dev wlan0 scan | grep "freq:"
   ```

#### Enterprise WiFi Issues
1. Verify certificate:
   ```bash
   openssl x509 -in /path/to/cert.pem -text -noout
   ```

2. Test credentials:
   ```bash
   nmcli connection edit "NetworkName"
   ```

3. Check 802.1X authentication:
   ```bash
   journalctl -u wpa_supplicant -f
   ```

## Performance Optimization

### Signal Strength Optimization
- Position laptop to maximize signal strength
- Avoid physical obstructions between device and AP
- Consider external WiFi adapter for desktop systems

### Channel Selection
- Use 5GHz bands when available (less interference)
- Manually select less crowded channels
- Use WiFi analyzer tools to identify optimal channels

### Throughput Optimization
```bash
# Check current link speed
iw dev wlan0 link

# Monitor real-time throughput
iftop -i wlan0

# Test network speed
speedtest-cli
```

## Security Best Practices

1. **Always Use WPA3/WPA2**: Disable WEP and open networks
2. **MAC Randomization**: Enable for privacy on public networks
3. **Enterprise Authentication**: Use 802.1X for corporate networks
4. **Regular Updates**: Keep WiFi firmware updated
5. **VPN on Public WiFi**: Always use VPN on untrusted networks

### Secure Configuration Example
```nix
{
  pantherOS.networking.wifi = {
    enable = true;
    security = {
      randomizeMac = true;
      preferredProtocols = [ "wpa3" "wpa2" ];
      disableInsecure = true;
    };
  };
  
  # Enable VPN
  services.tailscale.enable = true;
}
```

## Hardware Compatibility

### Known Working Hardware
- **Intel**: WiFi 6E (AX210/AX211), WiFi 6 (AX200/AX201), WiFi 5 (9260/9560)
- **Broadcom**: BCM43xx series (with proprietary firmware)
- **Atheros**: QCA6174, QCA9377, AR9485
- **Realtek**: RTL8822CE, RTL8821CE, RTL8188EE

### Hardware-Specific Notes
- Intel WiFi usually has best Linux support
- Broadcom requires proprietary firmware
- Realtek may require kernel module compilation
- USB WiFi adapters generally well-supported

## TODO
- [ ] Add support for WiFi hotspot/AP mode
- [ ] Implement automatic channel optimization
- [ ] Add WiFi mesh networking support
- [ ] Create network profile switching based on location
- [ ] Add integration with VPN auto-connect rules
- [ ] Implement WiFi-based location services
