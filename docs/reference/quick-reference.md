# PantherOS Quick Reference

This document provides quick access to common commands and configurations in PantherOS.

## Common NixOS Commands

### Building and Switching Configurations
```bash
# Build the configuration without switching
nixos-rebuild build --flake .#hostname

# Test the configuration (temporary switch)
nixos-rebuild test --flake .#hostname

# Switch to the new configuration (permanent)
nixos-rebuild switch --flake .#hostname

# Build for a remote machine
nixos-rebuild build --flake .#hostname --target-host user@hostname
nixos-rebuild switch --flake .#hostname --target-host user@hostname --use-remote-sudo
```

### Managing the Flake
```bash
# Update flake inputs
nix flake update

# Check flake inputs
nix flake show

# Build specific packages from the flake
nix build .#packageName
```

### Nix Commands
```bash
# Search for packages
nix search nixpkgs packageName

# Run a package without installing
nix run nixpkgs#packageName

# Check what will be built/installed
nix-store --gc --print-dead

# Clean the Nix store
nix-collect-garbage
```

## PantherOS Module Options

### Core Modules
- `pantherOS.core.base.enable` - Enable basic system configuration
- `pantherOS.core.boot.enable` - Enable boot configuration
- `pantherOS.core.systemd.enable` - Enable systemd optimizations
- `pantherOS.core.networking.enable` - Enable networking configuration
- `pantherOS.core.users.defaultUser.name` - Set default user name

### Service Modules
- `pantherOS.services.tailscale.enable` - Enable Tailscale VPN
- `pantherOS.services.podman.enable` - Enable Podman container service
- `pantherOS.services.ssh.enable` - Enable SSH service

### Security Modules
- `pantherOS.security.firewall.enable` - Enable advanced firewall
- `pantherOS.security.ssh.enable` - Enable SSH hardening
- `pantherOS.security.systemdHardening.enable` - Enable systemd hardening

### Filesystem Modules
- `pantherOS.filesystems.btrfs.enable` - Enable Btrfs configuration
- `pantherOS.filesystems.impermanence.enable` - Enable impermanence
- `pantherOS.filesystems.snapshots.enable` - Enable snapshot management

### Hardware Modules
- `pantherOS.hardware.workstations.enable` - Enable workstation features
- `pantherOS.hardware.servers.enable` - Enable server features
- `pantherOS.hardware.yoga.enable` - Enable Yoga-specific features
- `pantherOS.hardware.zephyrus.enable` - Enable Zephyrus-specific features
- `pantherOS.hardware.vps.enable` - Enable VPS-specific features

## Hardware Discovery and Configuration

### Running Hardware Discovery
```bash
# For a specific machine
sudo nix run .#hardware-discovery -- --output-file hardware-config-$(hostname)-$(date +%Y%m%d_%H%M%S).nix
```

## Impermanence Management

### Btrfs Snapshots
```bash
# List Btrfs subvolumes
sudo btrfs subvolume list /

# Create a snapshot
sudo btrfs subvolume snapshot / /.snapshots/root-$(date +%Y%m%d-%H%M%S)

# List snapshots
sudo btrfs subvolume list -r /.snapshots

# Delete a snapshot
sudo btrfs subvolume delete /.snapshots/snapshot-name
```

## Troubleshooting Commands

### System Status
```bash
# Check systemd services
systemctl status

# View system logs
journalctl -xe

# Check disk usage
df -h

# Check memory usage
free -h
```

### Network Troubleshooting
```bash
# Test network connectivity
ping 8.8.8.8

# Check network interfaces
ip addr show

# Test DNS resolution
nslookup google.com
```

## Security Commands

### Firewall Management
```bash
# Check firewall status
sudo iptables -L

# Check nixos firewall settings
sudo nixos-rebuild dry-build
```

### SSH Management
```bash
# Check SSH status
systemctl status sshd

# Test SSH connection
ssh -T user@hostname
```

## Development Commands

### Using Development Environment
```bash
# Enter development shell
nix develop

# Run pre-commit checks
pre-commit run --all-files
```

## Version Control Commands

### Git Operations
```bash
# Common git operations for PantherOS contributions
git checkout -b feature-branch-name
git add .
git commit -m "Clear, descriptive commit message"
git push origin feature-branch-name
```

## OpenSpec Change Management

### Working with OpenSpec
```bash
# After implementing a change, update its status
# Edit the proposal and task files to mark completion
```