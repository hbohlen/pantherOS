# Testing and Deployment Guide

This guide covers testing configurations and safely deploying changes.

## Overview

Testing prevents issues and ensures configuration works before deploying.

## Testing Levels

### 1. Build Test
**Purpose**: Verify configuration compiles

**Command**:
```bash
nixos-rebuild build .#<hostname>
```

**What it checks**:
- Syntax correctness
- Module imports
- Option validation
- Package availability

**When to use**:
- Before any deployment
- After configuration changes
- During development

### 2. Dry Run
**Purpose**: Test activation without making changes

**Command**:
```bash
nixos-rebuild dry-activate --flake .#<hostname>
```

**What it checks**:
- Service configuration
- File changes
- Activation scripts
- System state transitions

**When to use**:
- Before first switch
- After major changes
- When unsure about changes

### 3. Test Build (Advanced)
**Purpose**: Build in isolated environment

**Command**:
```bash
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

**What it checks**:
- Complete system build
- All derivations
- Dependency resolution

**When to use**:
- Before deploying to critical systems
- CI/CD pipelines
- Complex changes

### 4. Switch (Live Deployment)
**Purpose**: Actually apply changes

**Command**:
```bash
nixos-rebuild switch --flake .#<hostname>
```

**What it does**:
- Applies configuration
- Creates new generation
- Activates services
- Updates system

**When to use**:
- After thorough testing
- When ready to commit changes
- Workstations: safe to use directly
- Servers: use with caution, have rollback plan

## Workflow by Host Type

### Workstations (yoga, zephyrus)

**Development workflow**:
```bash
# Make changes
vim hosts/yoga/default.nix

# Test build
nixos-rebuild build .#yoga

# Test activation
nixos-rebuild dry-activate --flake .#yoga

# Deploy (safe on local workstation)
nixos-rebuild switch --flake .#yoga
```

**Verification after switch**:
```bash
# Verify services
systemctl status <service>

# Check configuration
nixos-rebuild show-config --flake .#yoga | grep <setting>

# Check Nix store
nix-store --verify --repair
```

### Servers (hetzner-vps, ovh-vps)

**CAUTION**: Remote servers require extra care!

**Deployment from another machine**:
```bash
# Ensure Tailscale connection
tailscale status

# Build first
nixos-rebuild build .#hetzner-vps

# Switch remotely
nixos-rebuild switch --flake .#hetzner-vps --use-remote-sudo

# Or SSH and switch
ssh root@hetzner-vps
nixos-rebuild switch --flake .#hetzner-vps
```

**Verification after remote switch**:
```bash
# SSH back and verify
ssh root@hetzner-vps

# Check system status
systemctl status
journalctl -b

# Verify services are running
systemctl status tailscale
systemctl status caddy

# Check network
tailscale status
```

## Pre-Deployment Checklist

### Before Building
- [ ] Configuration changes reviewed
- [ ] Dependencies identified
- [ ] Hardware requirements checked
- [ ] Module imports verified
- [ ] Tailscale connection stable (for remote hosts)

### Before Switching (Especially Servers)
- [ ] Build test passed
- [ ] Dry run completed successfully
- [ ] Rollback plan ready
- [ ] SSH access verified
- [ ] Tailscale access verified
- [ ] Web console access verified (for VPS)
- [ ] Time allocated for potential rollback

## Rollback Procedures

### Automatic Rollback
NixOS automatically keeps previous generations:

```bash
# List generations
nixos-rebuild list-generations

# Rollback to previous
nixos-rebuild switch --generation -1

# Rollback to specific generation
nixos-rebuild switch --generation <number>
```

### Emergency Rollback via GRUB

If system won't boot:
1. Reboot system
2. At GRUB menu, select "Advanced options"
3. Select previous NixOS configuration
4. System boots to previous working state
5. Access system and investigate

### Manual Rollback (Advanced)

If automatic rollback fails:
```bash
# Boot from NixOS installation media
# Mount filesystem
mount /dev/nvme0n1p2 /mnt
mount /dev/nvme0n1p1 /mnt/boot

# Enter chroot
nixos-enter --root /mnt

# Rollback manually
nixos-rebuild switch --generation <number>

# Exit and reboot
exit
reboot
```

## Testing Specific Configurations

### Test Specific Module

Create test configuration:
```nix
# test-module.nix
{ ... }:

{
  imports = [
    ./modules/nixos/services/my-service.nix
  ];

  services.my-service.enable = true;
  services.my-service.port = 8080;
}
```

Test it:
```bash
nixos-rebuild build -I nixos-config=test-module.nix
```

### Test Hardware Configuration

For hardware changes:
```bash
# Generate hardware config
nixos-generate-config --show-hardware-config

# Test build
nixos-rebuild build .#<hostname>

# Dry run to check hardware detection
nixos-rebuild dry-activate --flake .#<hostname> | grep -i hardware
```

### Test Disko Configuration

Test disk layout without installing:
```bash
# Disko dry run (check syntax)
disko --dry-run --arg device /dev/nvme0n1 --mode create ./hosts/<hostname>/disko.nix

# Create test VM
nix run .#vm -- -hda /dev/null ./hosts/<hostname>
```

## CI/CD Testing

### Local CI Script

Create `.github/test.yml` or use locally:
```yaml
name: Test Configurations

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v20
      - name: Build all hosts
        run: |
          nix build .#nixosConfigurations.yoga.config.system.build.toplevel
          nix build .#nixosConfigurations.zephyrus.config.system.build.toplevel
          nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel
          nix build .#nixosConfigurations.ovh-vps.config.system.build.toplevel
```

### Pre-Push Testing

Before pushing changes:
```bash
#!/bin/bash
# test-all.sh

set -e

HOSTS="yoga zephyrus hetzner-vps ovh-vps"

for host in $HOSTS; do
  echo "Testing $host..."
  nixos-rebuild build .#$host
  echo "$host: OK"
done

echo "All hosts tested successfully!"
```

## Common Issues and Solutions

### Build Fails with Import Error

**Problem**:
```
error: The option `services.myService.enable' is defined multiple times
```

**Solution**:
```bash
# Find duplicate imports
grep -r "my-service.nix" hosts/

# Remove duplicate or merge configurations
```

### Service Fails to Start

**Problem**:
```
service failed to start
```

**Solution**:
```bash
# Check service logs
journalctl -u my-service -f

# Test configuration
nixos-rebuild dry-activate --flake .#<hostname>

# Verify configuration
nixos-rebuild show-config --flake .#<hostname> | grep my-service
```

### Remote Switch Hangs

**Problem**:
Remote `nixos-rebuild switch` hangs or times out

**Solution**:
```bash
# Use build instead
nixos-rebuild build .#hetzner-vps

# Then SSH and switch
ssh root@hetzner-vps
nixos-rebuild switch --flake .#hetzner-vps

# Or use with timeout
timeout 300 nixos-rebuild switch --flake .#hetzner-vps
```

### Disk Space Issues

**Problem**:
`No space left on device` during build

**Solution**:
```bash
# Clean old generations
nix-collect-garbage --delete-older-than 30d

# Clean build cache
rm -rf /nix/var/nix/binary-cache/*

# Check space
df -h
```

## Best Practices

### General
1. **Always test before deploy**: Build, then dry-run, then switch
2. **One host at a time**: Don't try to deploy multiple hosts simultaneously
3. **Test critical changes twice**: Once in VM, once in staging
4. **Keep previous generation**: Default behavior, but don't manually delete
5. **Document changes**: Note what changed and why

### Servers
1. **Plan maintenance window**: Schedule time for potential issues
2. **Have console access**: VPS web console or IPMI
3. **Verify connectivity**: Tailscale and SSH before deploying
4. **Start with build only**: Never directly switch to unknown servers
5. **Monitor after deployment**: Check logs, services, connectivity

### Workstations
1. **Local testing is safe**: Can use switch directly after build
2. **Test when not critical**: Avoid testing during important work
3. **Keep Tailscale updated**: For accessing other devices
4. **Test new hardware configs carefully**: May affect boot

---

**See also:**
- [Module Development](./module-development.md)
- [Host Configuration](./host-configuration.md)
- [Troubleshooting](./troubleshooting.md)
- Recovery: Use previous generation from GRUB
