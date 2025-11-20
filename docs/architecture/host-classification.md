# Host Classification Architecture

This document defines the classification system and design patterns for different host types in the pantherOS infrastructure.

## Host Type Classification

The pantherOS infrastructure consists of 4 hosts, categorized by primary purpose and operational requirements.

### Workstation Hosts

Workstations are personal computing devices optimized for interactive development work, with emphasis on user experience, battery life, and local development capabilities.

#### Design Philosophy
- **User Experience First**: Optimized for daily development workflows
- **Resource Management**: Balance performance with power consumption
- **Local Development**: Full development environment with auto-activation
- **Multi-Purpose**: Support for browsing, development, and testing

#### yoga - Mobile Workstation
```
Host: yoga
Type: Lenovo Yoga 7 2-in-1 14AKP10
Category: Lightweight Mobile Workstation
Primary Purpose: Lightweight programming, research, web browsing
```

**Configuration Priorities:**
- **Battery Optimization**: Power management profiles, CPU governor tuning
- **Portability**: Lightweight software stack, minimal services
- **Display**: HiDPI scaling, touch support, rotation handling
- **Connectivity**: WiFi optimization, Bluetooth management

**Design Patterns:**
```nix
# Battery-focused configuration
powerManagement = {
  cpuGovernor = "powersave";
  graphicsPowerManagement = true;
  wlanPowerManagement = true;
};

# Minimal service footprint  
systemd.services = {
  disable = [ "heavy-service-1" "heavy-service-2" ];
};

# Display optimization
services.xserver = {
  displayManager.enable = true;
  desktopEnvironment = "niri";
  display = {
    dpi = 160;
    rotation = "auto";
  };
};
```

**Resource Allocation:**
- CPU: Performance scaling based on battery state
- RAM: Aggressive memory management for mobility
- Storage: SSD optimization for battery life
- Network: WiFi-first with minimal background services

#### zephyrus - Performance Workstation
```
Host: zephyrus  
Type: ASUS ROG Zephyrus M16 GU603ZW
Category: High-Performance Mobile Workstation
Primary Purpose: Heavy development, Podman containers, AI tools
```

**Configuration Priorities:**
- **Raw Performance**: Maximum processing power when plugged in
- **Multi-SSD Support**: RAID configuration for speed/redundancy  
- **Graphics**: Dual GPU management (integrated + dedicated)
- **Thermal Management**: Fan curves, power limits, cooling

**Design Patterns:**
```nix
# Performance-focused configuration
powerManagement = {
  cpuGovernor = "performance";
  graphicsPowerManagement = false;  // Always-on dedicated GPU
  thermalManagement = "aggressive";
};

# Multi-SSD configuration
fileSystems = {
  "/mnt/nvme1" = {
    device = "/dev/disk/by-uuid/nvme1-uuid";
    fsType = "btrfs";
    options = [ "compress=zstd" "ssd" ];
  };
  "/mnt/nvme2" = {
    device = "/dev/disk/by-uuid/nvme2-uuid"; 
    fsType = "btrfs";
    options = [ "compress=zstd" "ssd" ];
  };
};

# Container optimization
virtualisation = {
  podman = {
    enable = true;
    dockerCompat = true;
    memoryLimit = "32G";
    cpuLimit = "all";
  };
};
```

**Resource Allocation:**
- CPU: Performance-first with dynamic scaling
- RAM: 32GB+ configurations supported
- Storage: Multi-SSD with Btrfs RAID capabilities  
- Network: High-throughput ethernet support

### Server Hosts

Servers are headless infrastructure hosts optimized for remote access, network services, and long-running workloads.

#### Design Philosophy
- **Remote-First**: Designed for headless operation and remote management
- **Service Availability**: Maximum uptime, minimum maintenance windows
- **Network Services**: Web services, databases, reverse proxies
- **Security**: Zero-trust access, hardened configuration

#### hetzner-vps - Primary Server
```
Host: hetzner-vps
Type: Hetzner Cloud VPS  
Category: Headless Server
Primary Purpose: Primary codespace server, remote development
```

**Configuration Priorities:**
- **Network Services**: Web server, reverse proxy, SSH gateway
- **Resource Efficiency**: Minimal memory footprint, efficient CPU usage
- **Remote Access**: Tailscale optimization, SSH hardening
- **Availability**: High uptime, automatic restarts

**Design Patterns:**
```nix
# Headless server configuration
services = {
  ssh.enable = true;
  openssh.permitRootLogin = "no";
  
  caddy.enable = true;
  reverseProxy = {
    defaultProxy = true;
    acmeCloudflare = true;
  };
  
  tailscale.enable = true;
  exitNode = true;  // For other hosts
};

# Minimal footprint
environment = {
  systemd.services = {
    " graphical-session-prepare".enable = false;
  };
  services = {
    displayManager.enable = false;
    xserver.enable = false;
  };
};

# Security hardening
security = {
  hardening = {
    systemProtectHome = true;
    kernelRandomizeizeStack = true;
  };
};
```

#### ovh-vps - Secondary Server  
```
Host: ovh-vps
Type: OVH Cloud VPS
Category: Redundant Server  
Primary Purpose: Secondary server for redundancy and additional workloads
```

**Configuration Priorities:**
- **Mirror Configuration**: Similar to hetzner-vps with redundancy features
- **Geographic Distribution**: Different data center location
- **Backup Services**: Data replication, backup coordination
- **Load Distribution**: Additional capacity for peak usage

**Design Patterns:**
```nix
# Redundant server configuration
services = {
  caddy.enable = true;
  # Mirrored proxy configuration
  tailscale.enable = true;
  # Same as primary but with backup policies
};

# Backup-specific services
backup = {
  rsync = true;
  syncWithPrimary = "hetzner-vps";
  frequency = "hourly";
};
```

## Classification Decision Matrix

| Characteristic | Workstation | Server |
|----------------|-------------|---------|
| **Primary Interface** | Direct user interaction | Remote access only |
| **Power Management** | Battery/AC switching | Performance-first |
| **Display Services** | Full desktop environment | Headless minimal |
| **Service Footprint** | User applications | Network services only |
| **Network Priority** | WiFi optimization | Tailscale optimization |
| **Storage Priority** | User data preservation | Service data reliability |
| **Security Model** | User convenience balanced | Security-first harderning |
| **Maintenance Windows** | User-driven reboots | Service-driven uptime |

## Configuration Layers

Each host type implements the same three-layer approach but with different priorities:

### Layer 1: Hardware (hosts/*/hardware.nix)
```nix
{
  hardware = {
    workstation = { yoga, zephyrus }: {
      cpu = "workstation-specific";
      graphics = "workstation-specific"; 
      power = "battery-optimized";
    };
    server = { hetzner-vps, ovh-vps }: {
      cpu = "server-optimized";
      virtualisation = true;
      power = "performance-first";
    };
  };
}
```

### Layer 2: Disk (hosts/*/disko.nix)
```nix
{
  diskLayout = {
    workstation = {
      btrfs = {
        subvolumes = [ "@root" "@home" "@dev" "@cache" ];
        compression = "zstd:3";  // Balanced for space and speed
      };
    };
    server = {
      btrfs = {
        subvolumes = [ "@root" "@var" "@nix" "@containers" ];
        compression = "zstd:1";  // Fast for services
        nodatacow = [ "@containers" ];  // Database optimization
      };
    };
  };
}
```

### Layer 3: System (hosts/*/default.nix)
```nix
{
  systemConfiguration = {
    workstation = {
      imports = [
        <modules/home-manager/desktop>
        <modules/home-manager/development>
        <modules/nixos/services/ssh>  # But with GUI support
      ];
      services = {
        displayManager.enable = true;
        networkManager.enable = true;
      };
    };
    server = {
      imports = [
        <modules/nixos/services/caddy>
        <modules/nixos/services/tailscale>
        <modules/nixos/security/hardening>
      ];
      services = {
        displayManager.enable = false;
        networkManager.enable = false;  # Systemd-networkd instead
      };
    };
  };
}
```

## Cross-Reference Implementation

### Module Compatibility
Modules must declare host type compatibility:
```nix
# modules/nixos/services/example-service.nix
{ config, lib, ... }:

{
  options.services.example = {
    enable = lib.mkEnableOption "example-service";
    hostTypes = lib.mkOption {
      type = lib.types.enum [ "workstation" "server" "all" ];
      default = "all";
    };
  };
  
  config = lib.mkIf (config.services.example.enable && 
    (config.services.example.hostTypes == "all" || 
     config.services.example.hostTypes == config.pantherOS.hostType)) {
    # Configuration logic
  };
}
```

### Profile Application
```nix
# profiles/workstation.nix
{
  pantherOS.hostType = "workstation";
  
  # Enable workstation-specific modules
  imports = [
    <profiles/base>
    <profiles/desktop>
    <profiles/development>
  ];
}

# profiles/server.nix  
{
  pantherOS.hostType = "server";
  
  # Enable server-specific modules
  imports = [
    <profiles/base>
    <profiles/services>
    <profiles/security>
  ];
}
```

## Migration Between Classifications

### Converting Workstation to Server
When a host changes role, the transition involves:

1. **Hardware Layer Changes**
   - Disable graphics support
   - Enable headless kernel parameters
   - Remove power management dependencies

2. **Service Layer Changes**
   - Remove desktop environment
   - Add network services
   - Implement security hardening

3. **Profile Changes**
   - Switch from `workstation` to `server` profile
   - Remove desktop-specific modules
   - Add server-specific modules

### Converting Server to Workstation
The reverse process:

1. **Hardware Layer Changes**
   - Enable graphics support
   - Add power management
   - Configure display outputs

2. **Service Layer Changes**
   - Add desktop environment
   - Remove unnecessary network services
   - Balance security with usability

3. **Profile Changes**
   - Switch from `server` to `workstation` profile
   - Add desktop-specific modules
   - Remove server-specific modules

## Design Pattern Principles

### Separation of Concerns
- **Hardware Layer**: Device-specific configuration only
- **Disk Layer**: Filesystem structure and performance
- **System Layer**: Service and application configuration

### Type-Based Customization
- Configuration decisions based on host type classification
- Modules declare compatibility with host types
- Profiles provide type-specific configuration bundles

### Migration Safety
- Clear migration path between classifications
- Reversible configuration changes
- Configuration validation per type

## Related Documentation

- [System Architecture Overview](./overview.md)
- [Security Model](./security-model.md) 
- [Disk Layouts](./disk-layouts.md)
- [Module Organization](./module-organization.md)
- [Hardware Discovery Guide](../guides/hardware-discovery.md)
- [Host Configuration Guide](../guides/host-configuration.md)

---

**Maintained by:** hbohlen  
**Last Updated:** 2025-11-20  
**Version:** 1.0