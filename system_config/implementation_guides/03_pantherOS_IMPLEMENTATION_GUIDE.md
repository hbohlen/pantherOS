# pantherOS Implementation Guide

**Last Updated**: 2025-11-15 10:47:11  
**Author**: MiniMax Agent  
**Purpose**: Step-by-step implementation guide for pantherOS NixOS configurations

## Overview

This guide provides comprehensive instructions for deploying, configuring, and maintaining pantherOS systems. It covers initial installation, configuration customization, service integration, and ongoing maintenance.

### What You'll Achieve
- Complete pantherOS deployment from scratch
- Hardware-specific optimization for your system
- Security hardening and secrets management integration
- Desktop environment configuration
- Service integration and monitoring setup

---

## Prerequisites

### System Requirements

#### Minimum Hardware
- **CPU**: 64-bit processor (x86_64 or aarch64)
- **RAM**: 4GB (8GB recommended)
- **Storage**: 20GB available space (50GB recommended)
- **Network**: Internet connection for initial setup

#### Recommended Hardware
- **Workstation**: Modern CPU, 16GB+ RAM, SSD storage
- **Laptop**: Battery optimization features, WiFi 6 support
- **Server**: 2+ vCPU, 4GB+ RAM, stable network

### Software Requirements
- **Host OS**: Linux, macOS, or Windows (for remote deployment)
- **Tools**: Git, SSH client, text editor
- **Access**: 1Password service account with appropriate permissions

---

## Installation Methods

### Method 1: Fresh NixOS Installation

#### 1.1 Boot NixOS Installation Media

```bash
# Download NixOS installation ISO
wget https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso

# Create bootable USB
sudo dd if=latest-nixos-minimal-x86_64-linux.iso of=/dev/sdX bs=1M status=progress

# Boot from USB and select "NixOS installer"
```

#### 1.2 Partition and Format Disks

```bash
# Launch disk management
sudo cfdisk /dev/sda

# Create partitions:
# - EFI System (512MB) - /dev/sda1
# - Linux File System (remaining space) - /dev/sda2

# Format EFI partition
sudo mkfs.vfat -F32 /dev/sda1

# Format root partition
sudo mkfs.ext4 /dev/sda2

# Create swap file (optional)
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### 1.3 Mount and Begin Installation

```bash
# Mount partitions
sudo mount /dev/sda2 /mnt
sudo mkdir /mnt/boot
sudo mount /dev/sda1 /mnt/boot

# Enable flakes
sudo mkdir -p /etc/nixos
echo 'experimental-features = ["nix-command" "flakes"]' | sudo tee /etc/nixos/nix.conf

# Install pantherOS
git clone https://github.com/yourusername/pantherOS.git
cd pantherOS
```

#### 1.4 Generate and Install Configuration

```bash
# Generate hardware configuration
sudo nixos-generate-config --root /mnt

# Copy hardware configuration
cp /mnt/etc/nixos/hardware-configuration.nix hosts/$(hostname)/hardware-configuration.nix

# Edit system configuration
nano hosts/$(hostname)/configuration.nix

# Build and install
sudo nixos-install --flake .#$(hostname)

# Set root password
sudo passwd

# Reboot
sudo reboot
```

### Method 2: In-Place Migration from Existing System

#### 2.1 Backup Current Configuration

```bash
# Backup existing configurations
tar -czf ~/system-backup-$(date +%Y%m%d).tar.gz /etc /home

# Document current services and configurations
systemctl list-units --type=service > ~/services-backup.txt
```

#### 2.2 Install NixOS Alongside Existing System

```bash
# Install NixOS in user space (optional)
curl -L https://nixos.org/nix/install | sh

# Or install NixOS proper
git clone https://github.com/NixOS/nixpkgs
cd nixpkgs
nix-env -f . -iA nix

# Configure dual-boot or migration
```

#### 2.3 Configure pantherOS

```bash
# Clone pantherOS configuration
git clone https://github.com/yourusername/pantherOS.git
cd pantherOS

# Test configuration build
nixos-rebuild build --flake .#$(hostname)

# Test in current environment (without switching)
nixos-rebuild test --flake .#$(hostname)

# Apply configuration when ready
sudo nixos-rebuild switch --flake .#$(hostname)
```

### Method 3: Remote Deployment via SSH

#### 3.1 Prepare Remote System

```bash
# SSH into remote system
ssh user@remote-host

# Install Nix (if not present)
curl -L https://nixos.org/nix/install | sh
source ~/.nix-profile/etc/profile.d/nix.sh

# Enable flakes
mkdir -p ~/.config/nix
echo 'experimental-features = ["nix-command" "flakes"]' >> ~/.config/nix/nix.conf

# Install git if needed
nix-env -iA nixpkgs.git
```

#### 3.2 Deploy Configuration

```bash
# Clone configuration
git clone https://github.com/yourusername/pantherOS.git
cd pantherOS

# Test build first
nix build .#nixosConfigurations.remote-host.config.system.build.toplevel

# Build and switch
sudo nixos-rebuild switch --flake .#remote-host
```

---

## Hardware-Specific Configuration

### Lenovo Yoga Laptop Setup

#### 1. Hardware Profile Configuration

```bash
# Edit yoga-specific configuration
cat > hosts/yoga/configuration.nix << 'EOF'
{ config, lib, pkgs, ... }:

{
  imports = [
    <pantherOS/profiles/workstation/base.nix>
    <pantherOS/modules/hardware/laptop/battery.nix>
    <pantherOS/modules/hardware/gpu/nvidia.nix>
    <pantherOS/modules/security/hardening/system.nix>
  ];
  
  # System identification
  system.stateVersion = "25.05";
  system.nixos.label = "pantherOS-yoga";
  
  # Hardware-specific options
  hardware.nvidia.prime.offload.enable = true;
  hardware.nvidia.prime.offload.enableOffloadCmd = true;
  
  # Battery optimization
  pantherOS.hardware.laptop.battery = {
    enable = true;
    mode = "balanced";
    features = {
      tlp = true;
      autoCpufreq = true;
      batteryThresholds = true;
    };
    thresholds = {
      startCharging = 30;
      stopCharging = 80;
    };
  };
  
  # Touch and display configuration
  services.xserver.wlr.enable = true;
  
  # Security hardening
  pantherOS.security.hardening = {
    enable = true;
    level = "standard";
    kernel.enable = true;
  };
}
EOF
```

#### 2. Yoga-Specific Optimizations

```bash
# Battery management for Yoga series
sudo tlp stat

# Touchscreen calibration
xinput list
xinput set-prop "ELAN Touchscreen" "Device Enabled" 1

# 2-in-1 mode detection
cat /sys/devices/platform/thinkpad_acpi/hotkey和平

# Yoga-specific power management
echo 'S3' | sudo tee /sys/power/mem_sleep
```

### ASUS ROG Zephyrus M16 GU603ZW Setup (2022)
**Target Hardware:** 
- 12th Gen Intel Core i9-12900H (14-core, up to 5.0GHz)
- NVIDIA RTX 3070 Ti Laptop GPU (8GB GDDR6, 120W)
- 16GB DDR5 (8GB onboard + 8GB SO-DIMM, up to 40GB)
- 1TB M.2 NVMe PCIe 4.0 SSD
- 16" WQXGA (2560x1600) 165Hz Display with DCI-P3 100%

#### 1. Gaming Laptop Configuration

```bash
cat > hosts/zephyrus/configuration.nix << 'EOF'
{ config, lib, pkgs, ... }:

{
  imports = [
    <pantherOS/profiles/workstation/base.nix>
    <pantherOS/modules/hardware/laptop/battery.nix>
    <pantherOS/modules/hardware/gpu/nvidia.nix>
    <pantherOS/modules/hardware/laptop/thermal.nix>
    <pantherOS/modules/services/monitoring/datadog.nix>
  ];
  
  # Gaming-specific configuration
  hardware.nvidia.prime.offload.enable = true;
  hardware.nvidia.prime.offload.enableOffloadCmd = true;
  
  # High-performance battery settings
  pantherOS.hardware.laptop.battery = {
    enable = true;
    mode = "performance";
    features = {
      tlp = true;
      thermal = true;
      deepSleep = true;
    };
    thresholds = {
      startCharging = 40;
      stopCharging = 85;
    };
  };
  
  # Thermal management
  pantherOS.hardware.laptop.thermal = {
    enable = true;
    profiles = {
      gaming = {
        governor = "performance";
        fan_curve = "aggressive";
      };
      balanced = {
        governor = "schedutil";
        fan_curve = "normal";
      };
    };
  };
}
EOF
```

#### 2. Gaming Performance Optimization

```bash
# NVIDIA performance mode
sudo nvidia-smi -pm 1
sudo nvidia-smi -pl 250

# Thermal optimization
sudo modprobe nct6683
sensors | grep -E "(temp|fan)"

# RGB keyboard configuration (if applicable)
echo "RGB keyboard support via kernel module"
```

### Desktop Workstation Setup

#### 1. Multi-Monitor Configuration

```bash
cat > hosts/desktop/configuration.nix << 'EOF'
{ config, lib, pkgs, ... }:

{
  imports = [
    <pantherOS/profiles/workstation/devtools.nix>
    <pantherOS/modules/hardware/gpu/amd.nix>
    <pantherOS/modules/hardware/display/multi-monitor.nix>
    <pantherOS/modules/services/containers/podman.nix>
    <pantherOS/modules/security/hardening/system.nix>
  ];
  
  # AMD GPU configuration
  hardware.amdgpu.powerProfile = "high";
  hardware.amdgpu.dynamicPowerManagement = "auto";
  
  # Multi-monitor setup
  services.xserver.displayManager.autoDetectPrimaryDevice = true;
  
  # Development environment
  pantherOS.hardware.laptop.battery.enable = false;
  
  # Security hardening
  pantherOS.security.hardening = {
    enable = true;
    level = "paranoid";
    audit.enable = true;
    audit.level = "comprehensive";
  };
}
EOF
```

#### 2. Professional Development Setup

```bash
# Multi-monitor detection and setup
arandr &

# Professional applications
flatpak install flathub com.jetbrains.IntelliJ IDEA
flatpak install flathub com.getpostman.Postman

# Development tools installation
nix-env -iA nixpkgs.vscode
nix-env -iA nixpkgs.neovim
nix-env -iA nixpkgs.docker
```

---

## Security Hardening

### Basic Security Implementation

#### 1. Enable Security Modules

```bash
# Add to configuration.nix
pantherOS.security.hardening = {
  enable = true;
  level = "basic";
  kernel.enable = true;
  audit.enable = true;
};
```

#### 2. Configure Firewall

```bash
# Basic firewall rules
nixos-rebuild switch --flake .#yoga

# Check firewall status
sudo nft list ruleset

# Monitor firewall logs
sudo journalctl -u nftables
```

#### 3. Audit Configuration

```bash
# Verify audit is running
sudo systemctl status auditd

# Check audit rules
sudo auditctl -l

# Monitor audit logs
sudo tail -f /var/log/audit/audit.log
```

### Advanced Security Setup

#### 1. Paranoid Mode Configuration

```bash
# Maximum security configuration
pantherOS.security.hardening = {
  enable = true;
  level = "paranoid";
  kernel.enable = true;
  services = {
    enable = true;
    disableInsecure = true;
    restrictPrivileges = true;
  };
  filesystem = {
    enable = true;
    mountSecurity = true;
    permissionHardening = true;
  };
  audit = {
    enable = true;
    level = "comprehensive";
  };
  network = {
    enable = true;
    restrictPublic = true;
  };
};
```

#### 2. Security Monitoring

```bash
# Enable fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Configure intrusion detection
sudo rkhunter --update
sudo rkhunter --propupd

# System integrity checking
sudo aide --init
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

---

## Secrets Management Integration

### OpNix Setup

#### 1. Initialize 1Password Integration

```bash
# Install OpNix (if not in flake)
nix-env -iA nixpkgs.opnix

# Initialize OpNix
opnix init --vault pantherOS

# Authenticate with service account
opnix token set --vault pantherOS
```

#### 2. Configure Secret Mappings

```bash
# In secrets/map.nix
{
  "tailscale-auth-key" = {
    path = "authentication/tailscale/authKey";
    mode = "0400";
    owner = "root";
    group = "tailscale";
  };
  
  "ssh-host-key" = {
    path = "authentication/ssh/workstation/privateKey";
    mode = "0600";
    owner = "root";
    group = "root";
  };
  
  "datadog-api-key" = {
    path = "services/datadog/apiKey";
    mode = "0400";
    owner = "dd-agent";
    group = "dd-agent";
  };
}
```

#### 3. Test Secret Integration

```bash
# Verify OpNix is working
opnix status

# Test secret access
opnix get pantherOS authentication/tailscale/authKey

# Rebuild with secrets
nixos-rebuild switch --flake .#yoga
```

---

## Desktop Environment Setup

### Niri + DankMaterialShell Configuration

#### 1. Desktop Environment Module

```bash
# In configuration.nix
imports = [
  <pantherOS/modules/desktop/compositor/niri.nix>
  <pantherOS/modules/desktop/theming/dankmaterialshell.nix>
  <pantherOS/modules/desktop/applications/>
  <pantherOS/modules/desktop/system/>
];

# Niri compositor setup
services.niri = {
  enable = true;
  package = pkgs.niri;
  
  # Wayland configuration
  settings = {
    startup_commands = [
      "exec_wayland_app terminal"
      "exec_wayland_app waybar"
    ];
    
    # Keybindings
    keybindings = {
      "Mod4+Return" = "spawn wayland-app terminal";
      "Mod4+w" = "spawn wayland-app browser";
      "Mod4+Space" = "spawn wofi --show drun";
    };
  };
};
```

#### 2. Theme Configuration

```bash
# DankMaterialShell theme setup
pantherOS.desktop.theming = {
  enable = true;
  theme = {
    name = "dank-dark";
    colors = {
      primary = "#1a1a1a";
      secondary = "#2d2d2d";
      accent = "#00d4aa";
    };
  };
  icons = {
    package = "Adwaita";
    theme = "Adwaita";
  };
  fonts = {
    primary = "Inter";
    terminal = "JetBrains Mono";
  };
};
```

#### 3. Application Setup

```bash
# Essential Wayland applications
environment.systemPackages = with pkgs; [
  # Terminal
  alacritty
  
  # File manager
  pcmanfm
  
  # Web browser
  firefox
  
  # Text editor
  neovim
  
  # Development tools
  gedit
  typora
  
  # System tools
  wofi
  waybar
  grim
  slurp
];

# Home Manager configuration for user
home-manager.users.hayden = {
  imports = [
    <pantherOS/home/common/shells/fish.nix>
    <pantherOS/home/common/editors/neovim.nix>
    <pantherOS/home/common/git/git.nix>
  ];
  
  programs.fish = {
    enable = true;
    plugins = [
      { name = "oh-my-fish/plugin-bobthefish"; }
    ];
  };
};
```

---

## Service Integration

### Monitoring Setup

#### 1. Datadog Integration

```bash
# In configuration.nix
services.datadog.agent = {
  enable = true;
  apiKeyFile = config.services.opnix.secrets."datadog-api-key".path;
  hostname = config.networking.hostName;
  tags = [
    "role:workstation"
    "os:nixos"
    "owner:hayden"
    "environment:${config.networking.hostName}"
  ];
  
  # Custom metrics
  extraConf = ''
    # System metrics
    load:
      - match: '*'
        tags:
          host: ${config.networking.hostName}
    
    # Process monitoring
    processes:
      - match: 'niri'
        tags:
          service: compositor
  '';
};
```

#### 2. Tailscale VPN Setup

```bash
# Tailscale configuration
services.tailscale = {
  enable = true;
  useRoutingFeatures = false; # Workstation mode
  
  # Get auth key from OpNix
  authKeyFile = config.services.opnix.secrets."tailscale-auth-key".path;
  
  # Custom routes (if needed)
  routes = [ "10.0.0.0/8" ];
};

# Configure post-install hook
systemd.services.tailscale-setup = {
  description = "Tailscale Post-Setup";
  after = [ "tailscale.service" ];
  wantedBy = [ "multi-user.target" ];
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "${pkgs.tailscale}/bin/tailscale set --accept-dns=false";
  };
};
```

#### 3. Container Runtime Setup

```bash
# Podman configuration
virtualisation.podman = {
  enable = true;
  dockerCompat = true;
  
  # Rootless containers
  enableNvidia = true;
  
  # Default registry
  registries = [
    "docker.io"
    "registry.fedoraproject.org"
    "quay.io"
  ];
};

# User namespaces
users.users.hayden.subUidRanges = [
  { startUid = 100000; count = 65536; }
];
```

---

## Testing and Validation

### Build Validation

#### 1. Configuration Syntax Check

```bash
# Check flake configuration
nix flake check

# Validate specific host
nix eval --impure .#nixosConfigurations.yoga.config.system.build.toplevel

# Test build without switching
nixos-rebuild build --flake .#yoga
```

#### 2. Security Validation

```bash
# Check kernel security parameters
sysctl kernel.kptr_restrict kernel.yama.ptrace_scope

# Verify firewall rules
sudo nft list ruleset

# Test audit configuration
sudo auditctl -l
```

#### 3. Service Validation

```bash
# Check all services are enabled
systemctl list-unit-files --type=service | grep enabled

# Validate secrets are accessible
opnix status
opnix get pantherOS services/datadog/apiKey

# Test monitoring integration
curl -X GET "http://localhost:6062/api/v1/metrics" -H "DD-API-KEY: $(opnix get pantherOS services/datadog/apiKey)"
```

### Runtime Testing

#### 1. System Functionality

```bash
# Test desktop environment
systemctl status greetd
systemctl status niri

# Verify hardware functionality
acpi -V  # Battery status
nvidia-smi  # GPU status
lspci | grep -i audio  # Audio devices
```

#### 2. Network Connectivity

```bash
# Test Tailscale connection
tailscale status

# Test DNS resolution
dig @100.100.100.100 google.com

# Test monitoring
curl -H "DD-API-KEY: $(opnix get pantherOS services/datadog/apiKey)" \
     "https://api.datadoghq.com/api/v1/validate"
```

#### 3. Container Functionality

```bash
# Test Podman
podman run --rm hello-world

# Test with GPU (if applicable)
podman run --rm --device nvidia.com/gpu alladin/busybox:latest nvidia-smi
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Build Failures

**Issue**: Configuration fails to build
```bash
# Debug: Check configuration errors
nix eval --impure .#nixosConfigurations.yoga.config

# Debug: Check specific module
nix eval --impure .#nixosConfigurations.yoga.config.pantherOS.hardware.laptop.battery

# Debug: Check dependencies
nix show-derivation .#nixosConfigurations.yoga.config.system.build.toplevel
```

#### 2. Desktop Environment Issues

**Issue**: Niri fails to start
```bash
# Check compositor logs
journalctl -u greetd -f

# Check hardware support
lsmod | grep -i drm

# Fallback to X11
services.xserver.enable = true;
```

#### 3. Secrets Management Issues

**Issue**: OpNix cannot access secrets
```bash
# Check OpNix status
opnix status

# Re-authenticate
opnix token refresh

# Test vault access
op vault list pantherOS
```

#### 4. Performance Issues

**Issue**: System performance problems
```bash
# Check resource usage
top
iotop

# Check systemd services
systemctl status

# Monitor GPU usage
nvidia-smi -l 1

# Check thermal management
sensors | grep -E "(temp|fan)"
```

### Emergency Recovery

#### 1. Rollback Configuration

```bash
# Rollback to previous generation
sudo nixos-rebuild switch --flake .#yoga --rollback

# List available generations
sudo nix-env -p /nix/var/nix/profiles/system list

# Boot into specific generation
sudo bootctl set-default one-shot
sudo bootctl set-default default
```

#### 2. Safe Mode Boot

```bash
# Add to kernel parameters at boot time
# kernel rescue boot to disable problematic modules

# Once booted, remove problematic module from configuration
```

#### 3. Fresh Installation

```bash
# If system is completely broken, fresh installation may be fastest
# Backup user data first
rsync -av ~/ /mnt/backup/

# Fresh NixOS installation
# Follow fresh installation method above
```

---

## Maintenance Procedures

### Regular Maintenance Tasks

#### Daily Tasks (Automated)

```bash
# Check system health
systemctl is-active --quiet niri || echo "Desktop environment issue"
systemctl is-active --quiet tailscale || echo "VPN connection issue"
systemctl is-active --quiet datadog-agent || echo "Monitoring issue"

# Check battery status (laptops only)
acpi -a | grep -q "on-line" || echo "Running on battery"

# Check available disk space
df -h | awk '$5 > 85 {print "Disk space warning: " $1 " is " $5 " full"}'
```

#### Weekly Tasks

```bash
# Update system
nix flake update
nix build .#nixosConfigurations.yoga.config.system.build.toplevel
sudo nixos-rebuild switch --flake .#yoga

# Update secrets
opnix sync

# Run system health checks
sudo systemctl status
sudo tlp stat  # For laptops
sudo auditctl -l
```

#### Monthly Tasks

```bash
# Full system audit
sudo rkhunter --check-all --skip-keypress
sudo chkrootkit

# Performance review
sudo powertop --auto-tune

# Configuration backup
git add . && git commit -m "Monthly configuration update"
git push origin main
```

### Performance Optimization

#### 1. System Performance

```bash
# Check system performance
systemd-analyze
systemd-analyze blame

# Optimize boot time
sudo systemctl disable unnecessary-services

# Clean up system
sudo nix-collect-garbage -d
```

#### 2. Hardware Optimization

```bash
# GPU optimization
sudo nvidia-smi -pm 1

# CPU optimization
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Battery optimization
sudo tlp start
```

---

## Next Steps

### Immediate Actions

1. **Complete Initial Deployment** - Follow installation method appropriate for your situation
2. **Configure Hardware-Specific Settings** - Optimize for your specific hardware
3. **Enable Security Hardening** - Choose appropriate security level
4. **Integrate Secrets Management** - Set up OpNix with 1Password
5. **Test Desktop Environment** - Verify Wayland compositor is working

### Advanced Configuration

1. **Customize Desktop Experience** - Adjust themes, applications, and workflows
2. **Optimize Performance** - Fine-tune for your specific use case
3. **Expand Service Integration** - Add additional monitoring and management tools
4. **Create Development Environment** - Set up IDEs and development tools
5. **Implement Backup Strategy** - Regular configuration and data backups

### Community Integration

1. **Document Customizations** - Share improvements back to pantherOS
2. **Test Hardware Configurations** - Contribute hardware-specific modules
3. **Report Issues** - Help improve pantherOS for everyone
4. **Contribute Code** - Submit improvements and new modules

---

**Implementation Guide Status**: Complete  
**Next Review**: 2025-11-22 10:47:11  
**Priority**: Critical for successful pantherOS deployment