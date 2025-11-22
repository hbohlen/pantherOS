# Troubleshooting Guide

Common issues and solutions for pantherOS.

## Quick Diagnosis

### System Won't Boot

**Steps**:
1. Select "Previous NixOS configuration" from GRUB menu
2. Once booted, investigate the issue:
   ```bash
   # Check recent logs
   journalctl -b -1

   # Check failed services
   systemctl --failed

   # Review configuration
   nixos-rebuild dry-activate --flake .#<hostname>
   ```

3. If emergency access needed:
   - Workstations: Physical access
   - Servers: VPS web console or Tailscale from another device

### Can't Access Server

**Steps**:
1. Check Tailscale status from another device:
   ```bash
   tailscale status
   ```

2. If Tailscale unreachable, access via VPS web console
3. Once access restored, check network configuration:
   ```bash
   systemctl status tailscaled
   journalctl -u tailscaled -n 50
   ```

### Build Fails

**Steps**:
1. Get full error output:
   ```bash
   nixos-rebuild build .#<hostname> 2>&1 | tee build-error.log
   ```

2. Common issues:
   - **Import errors**: Check file paths and syntax
   - **Option errors**: Verify option names and types
   - **Package not found**: Check if package exists in nixpkgs

## Common Issues by Category

### Configuration Issues

#### Error: "The option `X' is defined multiple times"

**Cause**: Duplicate option definition

**Solution**:
```bash
# Find duplicates
grep -r "X" hosts/<hostname>/

# Merge or remove duplicates
# Check both default.nix and imported modules
```

#### Error: "Cannot add property X, because the attribute set already contains the property"

**Cause**: Nested attribute conflict

**Solution**:
```nix
# Bad - nested attribute conflict
{
  services.myService = {
    enable = true;
  };
  services.myService.port = 8080;
}

# Good - define together
{
  services.myService = {
    enable = true;
    port = 8080;
  };
}
```

#### Error: "value is a string while a list was expected"

**Cause**: Type mismatch

**Solution**:
```nix
# Check option type in module
programs.myModule.settings = lib.mkOption {
  type = lib.types.attrs;  # or list, bool, etc.
  default = { };
};
```

### Hardware Issues

#### Hardware Not Detected

**Check**:
```bash
# List hardware
lshw
lspci
lsblk

# Check kernel modules
lsmod | grep <module>
```

**Fix**:
- Add module to `boot.kernelModules` in `hardware.nix`
- Check if firmware is needed
- Verify hardware compatibility

#### Disk Not Found

**Check**:
```bash
# List disks
lsblk
fdisk -l

# Check Disko configuration
disko --dry-run --arg device /dev/sda ./hosts/<hostname>/disko.nix
```

**Fix**:
- Verify device path in `disko.nix`
- Check if disk is recognized by BIOS
- Update hardware.nix with correct device

### Network Issues

#### Tailscale Not Connecting

**Check**:
```bash
# Service status
systemctl status tailscaled

# Tailscale status
tailscale status

# Logs
journalctl -u tailscaled -f
```

**Fix**:
```bash
# Restart service
sudo systemctl restart tailscaled

# Re-authenticate
sudo tailscale up

# Check auth key
sudo tailscale login --authkey <key>
```

#### SSH Connection Refused

**Check**:
```bash
# Service status
systemctl status sshd

# Port listening
ss -tlnp | grep :22

# Firewall
systemctl status nftables
```

**Fix**:
```bash
# Enable SSH service
services.openssh.enable = true

# Allow in firewall
networking.firewall.allowedTCPPorts = [ 22 ];

# Restart SSH
systemctl restart sshd
```

### Service Issues

#### Service Won't Start

**Check**:
```bash
# Service status
systemctl status <service>

# Logs
journalctl -u <service> -n 100

# Configuration
nixos-rebuild dry-activate --flake .#<hostname> | grep <service>
```

**Fix**:
- Check configuration syntax
- Verify dependencies are enabled
- Check port conflicts
- Review service-specific logs

#### Service Starts but Crashes

**Check**:
```bash
# Crash logs
journalctl -b -p err

# Core dumps
coredumpctl list
coredumpctl info <PID>
```

**Fix**:
- Update service configuration
- Check for known bugs
- Verify permissions
- Check resource limits

### Build Issues

#### Nix Store Full

**Check**:
```bash
# Disk space
df -h
du -sh /nix/store/* | sort -hr | head -20
```

**Fix**:
```bash
# Clean old generations
nix-collect-garbage --delete-older-than 30d

# Clean build cache
rm -rf /nix/var/nix/binary-cache/*

# Optimize store
nix-store --optimize
```

#### Derivations Fail to Build

**Check**:
```bash
# Build log
nix log /nix/store/<hash>-<name>

# Network access
ping cache.nixos.org
```

**Fix**:
```bash
# Update flake
nix flake update

# Try with different nixpkgs
nixos-rebuild build .#<hostname> --arg nixpkgs-repo nixos-unstable
```

#### Build Hangs

**Check**:
```bash
# Running builds
ps aux | grep nix

# Build logs
tail -f /tmp/nix-build-*.log
```

**Fix**:
```bash
# Cancel hanging build
Ctrl+C

# Clean build cache
rm -rf /nix/var/nix/binary-cache/*

# Retry with verbose output
nixos-rebuild build .#<hostname> --verbose
```

## Emergency Procedures

### Complete System Recovery

If system won't boot and GRUB rollback fails:

1. **Boot from NixOS installation media**
2. **Mount your root filesystem**:
   ```bash
   mount /dev/nvme0n1p2 /mnt
   mount /dev/nvme0n1p1 /mnt/boot
   mount --bind /dev /mnt/dev
   mount --bind /proc /mnt/proc
   mount --bind /sys /mnt/sys
   nixos-enter --root /mnt
   ```

3. **Investigate the issue**:
   ```bash
   # Check logs
   journalctl -b

   # Check configuration
   cat /etc/nixos/configuration.nix

   # Review recent changes
   git log --oneline
   ```

4. **Fix or revert changes**:
   ```bash
   # Edit configuration
   vim /etc/nixos/configuration.nix

   # Or revert from git
   git checkout HEAD~1
   ```

5. **Rebuild**:
   ```bash
   nixos-rebuild switch
   exit
   reboot
   ```

### Recover from Bad Flake Update

If `nix flake update` breaks everything:

```bash
# Check git
git log --oneline -10

# Revert to previous commit
git checkout <previous-commit-hash>

# Update flake.lock manually if needed
git checkout HEAD -- flake.lock

# Rebuild
nixos-rebuild build .#<hostname>
```

### Recover from Accidental Configuration Deletion

If configuration was deleted accidentally:

```bash
# Check git history
git log --all --full-history -- "hosts/<hostname>/*"

# Restore specific file
git checkout <commit-hash> -- hosts/<hostname>/default.nix

# Or restore directory
git checkout <commit-hash>^ -- hosts/<hostname>
```

## Debugging Commands

### System Information
```bash
# System details
hostnamectl
cat /etc/os-release

# Hardware
lscpu
lsmem
lsblk
lspci

# Services
systemctl list-units --type=service --state=failed
systemctl list-timers

# Network
ip addr
ip route
ss -tulnp

# Tailscale
tailscale status
tailscale netcheck
```

### NixOS Specific
```bash
# Configuration
nixos-rebuild show-config --flake .#<hostname>

# Generations
nixos-rebuild list-generations

# Build info
nixos-rebuild build .#<hostname> --dry-run 2>&1 | grep -i error

# Nix store
nix-store --query --roots /nix/store/<hash>
nix-store --verify
```

### Logs
```bash
# System journal
journalctl -b
journalctl -f
journalctl -u <service>

# Kernel messages
dmesg | tail -100

# Auth logs
tail -f /var/log/auth.log
```

## Prevention Tips

### Regular Maintenance
1. **Update regularly**: Don't let systems fall too far behind
2. **Test updates**: Build test before applying updates
3. **Monitor health**: Check disk space, service status
4. **Keep records**: Document hardware, configuration decisions

### Before Major Changes
1. **Backup configuration**: `git commit` before changes
2. **Test in VM**: Use test configurations first
3. **Plan rollback**: Know how to get back to working state
4. **Schedule time**: Don't rush critical changes

### Documentation
1. **Document issues**: Add to this guide when you solve something
2. **Keep hardware docs current**: Update when hardware changes
3. **Track dependencies**: Know what depends on what
4. **Note quirks**: Hardware or software specific issues

---

**Still need help?**
- Review [Testing and Deployment Guide](./testing-deployment.md)
- Check [Module Development Guide](./module-development.md)
- Search [Architecture Documentation](../architecture/)
- Review task tracking in [docs/todos/](../todos/)
