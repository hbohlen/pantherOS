# Host Configuration for pantherOS

## Overview

Host configuration in pantherOS follows a hardware-first approach where each host is configured based on its specific hardware capabilities and intended purpose. All hosts use a three-layer configuration system.

## Hardware-First Approach

Always scan and document hardware before configuration:

### 1. Hardware Discovery
```bash
# Scan hardware specifications
./skills/pantheros-hardware-scanner/scripts/scan-hardware.sh <host>

# Review hardware documentation
cat docs/hardware/<host>.md

# Identify optimization opportunities
```

### 2. Hardware Analysis
- **Performance Requirements**: CPU, RAM, storage needs
- **Power Considerations**: Battery vs performance optimization
- **Storage Layout**: SSD optimization, Btrfs design
- **Special Features**: GPU, fingerprint reader, etc.

### 3. Configuration Planning
- Select appropriate modules based on hardware
- Plan disk layout for storage devices
- Identify hardware-specific optimizations
- Document configuration decisions

## Configuration Layers

Each host has three configuration layers:

### Layer 1: Hardware Detection (`hardware.nix`)
Hardware-specific configuration and detection:

```nix
{ config, lib, pkgs, ... }:

{
  # Hardware detection results
  # Kernel parameters
  # Firmware configuration
  # Device-specific settings
  
  # Example: Enable specific kernel modules
  boot.kernelModules = [ "kvm-intel" ];
  
  # Example: Hardware-specific kernel parameters
  boot.kernelParams = [ "intel_iommu=on" ];
  
  # Example: Firmware packages
  hardware.firmware = with pkgs; [
    intel-ucode
  ];
}
```

### Layer 2: Disk Layout (`disko.nix`)
Declarative disk configuration using Disko:

```nix
{ ... }:

{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/dev" = {
                    mountpoint = "/home/hbohlen/dev";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/var" = {
                    mountpoint = "/var";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
```

### Layer 3: System Configuration (`default.nix`)
Main system configuration:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./disko.nix
    
    # Core modules
    ../../modules/nixos/core/base.nix
    ../../modules/nixos/core/boot.nix
    
    # Security modules
    ../../modules/nixos/security/firewall.nix
    ../../modules/nixos/security/ssh.nix
    
    # Service modules
    ../../modules/nixos/services/tailscale.nix
    
    # Hardware-specific modules
    ../../modules/nixos/hardware/ssd-optimization.nix
  ];

  # Host-specific configuration
  networking.hostName = "yoga";
  
  # Host-specific modules
  modules.hardware.batteryOptimization = {
    enable = true;
    powerProfile = "powersave";
  };
  
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Host-specific tools
  ];
}
```

## Host-Specific Guidelines

### Workstation Configuration

#### Lenovo Yoga (Battery-Optimized)
- **Purpose**: Lightweight programming, web browsing
- **Optimization**: Battery life over performance
- **Special Features**: 2-in-1 functionality, touch screen
- **Power Management**: Aggressive power saving

```nix
{
  # Battery optimization
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";
  
  # Touch screen support
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad = {
    tapping = true;
    naturalScrolling = true;
  };
  
  # Tablet mode support
  hardware.sensor.iio.enable = true;
}
```

#### ASUS ROG Zephyrus (Performance)
- **Purpose**: Heavy development, Podman containers, AI tools
- **Optimization**: Raw performance, multi-SSD
- **Special Features**: Dedicated GPU, RGB lighting
- **Power Management**: Performance profiles

```nix
{
  # Performance optimization
  powerManagement.cpuFreqGovernor = "performance";
  
  # GPU support
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  
  # RGB lighting control
  hardware.openrazer.enable = true;
  
  # Multiple SSD optimization
  services.btrfs.autoScrub.enable = true;
}
```

### Server Configuration

#### Hetzner VPS (Primary Server)
- **Purpose**: Primary codespace server
- **Optimization**: Server workloads, network services
- **Special Features**: Cloud integration, backup
- **Security**: Hardened configuration

```nix
{
  # Server optimization
  services.btrfs.autoScrub.enable = true;
  
  # Cloud integration
  services.cloud-init.enable = true;
  
  # Backup configuration
  services.borgbackup.jobs = {
    backup = {
      paths = "/home";
      repo = "backup@repo.server:pantherOS";
      encryption.mode = "repokey";
    };
  };
  
  # Hardening
  security.sudo.wheelNeedsPassword = false;
  services.fail2ban.enable = true;
}
```

#### OVH VPS (Secondary Server)
- **Purpose**: Secondary server (backup/mirror)
- **Optimization**: Same as Hetzner
- **Special Features**: Geographic redundancy
- **Security**: Mirror of Hetzner security

```nix
{
  # Mirror Hetzner configuration
  # Geographic redundancy
  # Backup services
  
  # Time synchronization with Hetzner
  services.ntp.enable = true;
  services.ntp.servers = [ "hetzner-vps" ];
}
```

## Testing and Deployment

### Build Testing Procedures
Always test before deployment:

```bash
# Build test (dry run)
nixos-rebuild build --flake .#<hostname>

# Check for errors
nixos-rebuild build --flake .#<hostname> --show-trace

# Test configuration
nixos-rebuild test --flake .#<hostname>
```

### Dry-Run Validation
Validate activation without changes:

```bash
# Dry-run activation
nixos-rebuild dry-activate --flake .#<hostname>

# Check what would change
nixos-rebuild dry-build --flake .#<hostname>
```

### Deployment Safety Measures
Safe deployment procedures:

```bash
# Create backup generation before switch
nixos-rebuild build --flake .#<hostname>
sudo nixos-rebuild switch --flake .#<hostname>

# Keep previous generation for rollback
nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### Rollback Procedures
Emergency recovery procedures:

```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Rollback to specific generation
sudo nixos-rebuild switch --profile-generation <number>

# Select from GRUB menu at boot
```

## Skills Integration

### Hardware Scanner Usage
Use hardware scanner for host discovery:

```bash
# Scan all hosts
for host in yoga zephyrus hetzner-vps ovh-vps; do
  ./skills/pantheros-hardware-scanner/scripts/scan-hardware.sh $host
done

# Generate hardware documentation
./skills/pantheros-hardware-scanner/scripts/generate-docs.sh
```

### Deployment Orchestrator Workflow
Use deployment orchestrator for safe deployment:

```bash
# Build all hosts
./skills/pantheros-deployment-orchestrator/scripts/build-all.sh

# Deploy to specific host
./skills/pantheros-deployment-orchestrator/scripts/deploy.sh yoga

# Rollback if needed
./skills/pantheros-deployment-orchestrator/scripts/rollback.sh yoga
```

### Host-Specific Optimization
Apply hardware-specific optimizations:

```bash
# Generate optimization profile
./skills/pantheros-hardware-scanner/scripts/optimize-profile.sh yoga

# Apply optimizations
./skills/pantheros-hardware-scanner/scripts/apply-optimizations.sh yoga
```

## Cross-Host Consistency

### Configuration Consistency
Maintain consistency across hosts:

```nix
# Shared base configuration
{
  imports = [
    ../../modules/nixos/core/base.nix
    ../../modules/nixos/security/firewall.nix
    ../../modules/nixos/services/tailscale.nix
  ];
}

# Host-specific additions
{
  # Host-specific modules and settings
}
```

### Module Version Consistency
Ensure same module versions across hosts:

```bash
# Check module versions
nix flake check

# Update all hosts together
nix flake update
nixos-rebuild build .#yoga
nixos-rebuild build .#zephyrus
nixos-rebuild build .#hetzner-vps
nixos-rebuild build .#ovh-vps
```

### Security Consistency
Maintain consistent security posture:

```nix
# Base security for all hosts
{
  services.tailscale.enable = true;
  services.fail2ban.enable = true;
  security.sudo.wheelNeedsPassword = false;
}

# Additional security for servers
lib.mkIf (lib.hasSuffix "-vps" config.networking.hostName) {
  services.openssh.passwordAuthentication = false;
  networking.firewall.allowedTCPPorts = [ 22 ];
}
```

## Emergency Procedures

### System Won't Boot
1. **Select Previous Generation**: Use GRUB menu
2. **Boot from USB**: Emergency system access
3. **Chroot and Fix**: Repair configuration
4. **Rollback**: Return to working state

### Locked Out of Server
1. **Tailscale Access**: Use from another device
2. **Web Console**: Use provider's web console
3. **Rescue Mode**: Boot into rescue environment
4. **Recovery**: Restore from backup

### Configuration Corruption
1. **Git Reset**: Revert to last working commit
2. **Generation Rollback**: Use previous system generation
3. **Configuration Repair**: Fix broken configuration
4. **Rebuild**: Rebuild and test

## Best Practices

### Configuration Management
- **Version Control**: Commit all changes
- **Testing**: Build before switch
- **Documentation**: Document all changes
- **Backup**: Keep working generations

### Security Management
- **Principle of Least Privilege**: Minimal access required
- **Regular Updates**: Keep system updated
- **Monitoring**: Monitor for issues
- **Backup**: Regular backups of critical data

### Performance Management
- **Monitoring**: Monitor system performance
- **Optimization**: Optimize based on usage patterns
- **Resource Management**: Manage resources efficiently
- **Capacity Planning**: Plan for future needs

## Related Documentation

- [Hardware Discovery Guide](../guides/hardware-discovery.md)
- [Module Development Guide](../guides/module-development.md)
- [Testing and Deployment](../guides/testing-deployment.md)
- [Phase 1 Tasks](../todos/phase1-hardware-discovery.md)
- [Phase 3 Tasks](../todos/phase3-host-configuration.md)

---

**Maintained by:** pantherOS Infrastructure Team
**Last Updated:** 2025-11-19
**Version:** 1.0