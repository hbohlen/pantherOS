# PantherOS Troubleshooting Guide

This guide covers common issues that may arise when using or developing PantherOS and how to resolve them.

## Boot and Installation Issues

### System Won't Boot After Installation

**Symptoms**:
- Boot hangs at early stages
- Kernel panic messages
- GRUB doesn't appear or shows errors

**Solutions**:
1. Check EFI/BIOS settings:
   - Ensure CSM/Legacy mode is properly configured
   - Verify boot order
   - Check if secure boot is interfering

2. Verify hardware configuration:
   - Ensure hardware-configuration.nix was properly generated
   - Check that all necessary kernel modules are included
   - Verify disk device identifiers are correct

3. Examine boot logs:
   - Boot with `nixos-verbose` kernel parameter for more details
   - Check `/var/log` if system partially boots

### Btrfs Mount Issues

**Symptoms**:
- System fails to mount root filesystem
- Btrfs errors during boot
- Subvolume mounting failures

**Solutions**:
1. Boot from recovery media and check filesystem:
   ```bash
   # Check Btrfs filesystem
   btrfs check /dev/sdX
   
   # Check subvolume structure
   btrfs subvolume list /dev/sdX
   ```

2. Verify mount options in configuration:
   - Ensure "subvol=" options are correct
   - Check for proper compress and noatime options

3. If corrupted, attempt to restore from snapshots:
   ```bash
   # List available snapshots
   btrfs subvolume list -r /.snapshots
   
   # Mount a snapshot as read-only to recover
   btrfs subvolume snapshot -r /.snapshots/backup /mnt/restore
   ```

## Configuration and Build Issues

### Nix Build Failures

**Symptoms**:
- `nixos-rebuild` fails with error messages
- Missing dependencies
- Circular dependency errors

**Solutions**:
1. Check flake inputs:
   ```bash
   # Update flake lock file
   nix flake update
   
   # Check flake status
   nix flake show
   ```

2. Verify module configurations:
   - Check for typos in option names
   - Ensure modules are properly imported
   - Validate option types match expected values

3. Increase resource limits temporarily:
   ```bash
   # Limit parallel jobs to reduce memory usage
   nixos-rebuild switch --flake .# --max-jobs 1
   ```

### Impermanence Issues

**Symptoms**:
- Files not persisting as expected
- System not resetting to clean state
- Snapshot creation failures

**Solutions**:
1. Check impermanence module configuration:
   ```bash
   # Verify module is enabled
   nixos-rebuild build --flake .# --show-trace
   ```

2. Verify Btrfs configuration:
   ```bash
   # Check subvolumes
   btrfs subvolume list /
   
   # Check mount points
   mount | grep btrfs
   ```

3. Review persistent vs ephemeral paths:
   - Ensure files that should persist are in appropriate directories
   - Verify impermanence script hasn't been disrupted

## Service and Network Issues

### Tailscale Connection Problems

**Symptoms**:
- Tailscale won't connect after reboot
- Network access issues through Tailscale
- Authentication required repeatedly

**Solutions**:
1. Check Tailscale service status:
   ```bash
   # Check service status
   systemctl status tailscaled
   
   # Check connection status
   tailscale status
   ```

2. Verify firewall integration:
   - Ensure PantherOS firewall settings are compatible
   - Check that Tailscale routes are properly configured

3. Re-authenticate if necessary:
   ```bash
   # Logout and back in
   sudo tailscale logout
   sudo tailscale up
   ```

### SSH Access Issues

**Symptoms**:
- Can't SSH to system
- SSH authentication failures
- Connection timeouts

**Solutions**:
1. Check SSH service status:
   ```bash
   # Check SSH status
   systemctl status sshd
   
   # Check SSH configuration
   sudo sshd -T
   ```

2. Verify SSH configuration:
   - Ensure your public key is in authorized_keys
   - Check that SSH hardening settings allow your connection method
   - Verify network connectivity

3. Check security modules:
   - Verify PantherOS SSH security module settings
   - Check if Fail2Ban has blocked your IP

## Security and Hardening Issues

### Service Access Problems After Hardening

**Symptoms**:
- Services not accessible after security module activation
- Unexpected permission denials
- Network services blocked incorrectly

**Solutions**:
1. Review firewall configuration:
   ```bash
   # Check active firewall rules
   sudo iptables -L
   
   # Review PantherOS firewall settings
   nixos-rebuild dry-build --flake .# | grep firewall
   ```

2. Check systemd hardening:
   - Verify services can still access necessary resources
   - Check if PrivateTmp, ProtectSystem, etc. are too restrictive

3. Review security module settings:
   - Ensure allowed ports are properly configured
   - Verify trusted interfaces are correctly set

## Development and Module Issues

### Module Testing Problems

**Symptoms**:
- Modules don't work as expected
- Configuration conflicts between modules
- Options not applying correctly

**Solutions**:
1. Test module in isolation:
   - Create a minimal configuration with just the module
   - Verify options and their default values
   - Check conditional application with mkIf

2. Check module dependencies:
   - Ensure all required modules are imported
   - Verify correct application order
   - Check for conflicting configurations

3. Use VM testing:
   ```bash
   # Test configuration in VM
   nixos-rebuild build-vm --flake .#
   ./result/bin/run-vm-vm
   ```

## Performance and Resource Issues

### High Memory or CPU Usage

**Symptoms**:
- System running slowly
- High resource consumption by system processes
- Services timing out

**Solutions**:
1. Check system resource usage:
   ```bash
   # Monitor system resources
   htop
   iotop  # for I/O
   ```

2. Review Btrfs operations:
   - Check if Btrfs scrub/autotrim is running
   - Consider adjusting Btrfs compression settings
   - Check snapshot management

3. Review security auditing:
   - Auditd can consume resources with verbose logging
   - Adjust log levels or retention if needed

### Storage Issues

**Symptoms**:
- Disk space filling up unexpectedly
- Slow filesystem operations
- Btrfs quota issues

**Solutions**:
1. Check disk usage:
   ```bash
   # Check storage usage
   df -h
   btrfs filesystem usage /
   
   # Find large files
   sudo find / -type f -size +1G
   ```

2. Btrfs-specific maintenance:
   ```bash
   # Check filesystem balance
   btrfs filesystem usage /
   
   # Defragment if needed
   btrfs filesystem defragment -r /path
   ```

3. Review snapshot retention:
   - Adjust snapshot retention policies
   - Clean up old snapshots if needed

## Recovery Procedures

### Complete System Recovery

If the system is in an unrecoverable state:

1. Boot from NixOS installation media
2. Mount your system:
   ```bash
   # Mount root filesystem
   mount /dev/sdX3 /mnt
   # Mount other subvolumes as needed
   mount /dev/sdX1 /mnt/boot
   # Mount necessary special filesystems
   mount --bind /dev /mnt/dev
   mount --bind /proc /mnt/proc
   mount --bind /sys /mnt/sys
   ```
   
3. Chroot and troubleshoot:
   ```bash
   # Chroot to your system
   chroot /mnt /nix/var/nix/profiles/default/bin/bash
   # Load Nix environment
   source /nix/var/nix/profiles/default/etc/profile.d/nix.sh
   ```

### Configuration Rollback

If a configuration change breaks the system:

1. Use previous generations:
   ```bash
   # List system generations
   sudo nix-env --list-generations -p /nix/var/nix/profiles/system
   
   # Switch back to a previous generation
   sudo nixos-rebuild switch --rollback
   ```

2. Or manually boot to a previous generation from GRUB menu by selecting an older entry.

## Getting More Help

If these troubleshooting steps don't resolve the issue:

1. Check system logs: `journalctl -xe`
2. Review the documentation in `docs/`
3. Examine OpenSpec proposals in `openspec/changes/` for implementation details
4. For development issues, add debug options to your configuration temporarily
5. Create a minimal reproduction case for complex issues

## Preventive Measures

### Regular Maintenance

1. Schedule regular system updates
2. Monitor disk space and Btrfs health
3. Review security logs regularly
4. Test backup and recovery procedures
5. Keep hardware discovery outputs updated