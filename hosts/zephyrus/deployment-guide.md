# Deployment and Verification Guide - Zephyrus Complete Disko.nix

## Overview

Complete deployment guide for the dual-disk Zephyrus configuration with validation procedures and rollback options.

## Deployment Steps

### Phase 1: Pre-Deployment Preparation

1. **Backup Current Configuration**

   ```bash
   # Backup existing disko.nix
   cp /home/hbohlen/dev/pantherOS/hosts/zephyrus/disko.nix ~/disko.nix.backup

   # Backup current system
   sudo snapper create --description "Pre-disko-upgrade"
   ```

2. **Test Configuration Syntax**

   ```bash
   # Test Nix syntax for both files
   nix-instantiate --eval-only /home/hbohlen/dev/pantherOS/hosts/zephyrus/disko-complete.nix
   nix-instantiate --eval-only /home/hbohlen/dev/pantherOS/hosts/zephyrus/nixos-snippets.nix
   ```

3. **Verify Hardware Detection**

   ```bash
   # Confirm both NVMe drives are detected
   lsblk -f | grep nvme

   # Verify device names match facter.json
   cat /home/hbohlen/dev/pantherOS/hosts/zephyrus/facter.json | jq '.blockdevices[] | select(.name | startswith("nvme"))'
   ```

### Phase 2: Disko Testing (Safe Mode)

4. **Test Disko Configuration**

   ```bash
   # Test disko configuration without making changes
   sudo nix run github:nix-community/disko/latest -- --mode test --dry-run /home/hbohlen/dev/pantherOS/hosts/zephyrus/disko-complete.nix

   # This will show:
   # - Device detection and mapping
   # - Partition layout preview
   # - Mount point verification
   # - Filesystem creation plans
   ```

5. **Validate Btrfs Subvolume Structure**

   ```bash
   # Verify the proposed subvolume layout
   sudo nix run github:nix-community/disko/latest -- --mode test /home/hbohlen/dev/pantherOS/hosts/zephyrus/disko-complete.nix

   # Expected output should show:
   # - nvme0n1: ESP + btrfs (5 subvolumes: @, @home, @dev-projects, @nix, @var)
   # - nvme1n1: btrfs (6 subvolumes: @containers, @cache, @podman-cache, @snapshots, @tmp, @user-cache)
   ```

### Phase 3: Actual Deployment

6. **Execute Disko Configuration**

   ```bash
   # Apply disko configuration (destructive operation!)
   sudo nix run github:nix-community/disko/latest -- --mode create /home/hbohlen/dev/pantherOS/hosts/zephyrus/disko-complete.nix

   # This will:
   # - Create GPT partition tables on both disks
   # - Create ESP partition (512MB) on nvme0n1
   # - Create btrfs partitions and subvolumes
   # - Format filesystems with optimized options
   ```

7. **Install NixOS**

   ```bash
   # Install NixOS with the new configuration
   sudo nixos-install --flake /home/hbohlen/dev/pantherOS#zephyrus

   # This will install the system using the new disk layout
   ```

### Phase 4: Post-Deployment Verification

8. **Verify Disk Configuration**

   ```bash
   # Check disk layout
   lsblk -f

   # Verify btrfs subvolumes
   sudo btrfs subvolume list /
   sudo btrfs subvolume list /var/lib/containers

   # Check mount points
   mount | grep btrfs

   # Verify filesystem labels
   sudo btrfs filesystem show
   ```

9. **Validate Btrfs Mount Options**

   ```bash
   # Check mount options for each subvolume
   findmnt -D  # Show all mount options
   findmnt /home/hbohlen/dev  # Verify dev-projects mount options
   findmnt /var/lib/containers  # Verify containers mount options
   ```

10. **Test SSD Maintenance Services**

    ```bash
    # Verify fstrim timer is active
    sudo systemctl status fstrim.timer

    # Manual fstrim test
    sudo fstrim --all --verbose

    # Check smartd status for both NVMe drives
    sudo systemctl status smartd
    sudo smartctl -a /dev/nvme0n1
    sudo smartctl -a /dev/nvme1n1
    ```

### Phase 5: Application Testing

11. **Verify Development Environment**

    ```bash
    # Test Zed IDE functionality
    zed --version

    # Verify Fish shell
    fish --version

    # Check Ghostty
    ghostty --version

    # Test Niri window manager
    niri --version
    ```

12. **Validate Podman Configuration**

    ```bash
    # Test Podman functionality
    podman info

    # Verify container storage location
    podman info --format '{{.Store.GraphRoot}}'

    # Create test container
    podman run --rm hello-world

    # Check Podman cache location
    ls -la /var/cache/podman
    ```

13. **Test Snapper Configuration**

    ```bash
    # Verify snapper configs
    sudo snapper list-configs

    # Create test snapshot
    sudo snapper create --description "Post-deployment test"
    sudo snapper list

    # Test timeline snapshots
    sudo systemctl status snapper-timeline.timer
    ```

### Phase 6: Performance Validation

14. **Disk Performance Testing**

    ```bash
    # Test write performance on primary disk
    sudo dd if=/dev/zero of=/home/test-write bs=1M count=1000 oflag=direct

    # Test read performance on primary disk
    sudo dd if=/home/test-write of=/dev/null bs=1M count=1000 iflag=direct

    # Test container storage performance
    sudo dd if=/dev/zero of=/var/lib/containers/test-write bs=1M count=1000 oflag=direct

    # Cleanup test files
    sudo rm /home/test-write /var/lib/containers/test-write
    ```

15. **Btrfs Balance and Maintenance**

    ```bash
    # Check filesystem usage
    sudo btrfs filesystem df /dev/nvme0n1p2
    sudo btrfs filesystem df /dev/nvme1n1p1

    # Manual balance if needed
    sudo btrfs balance start -dusage=10 /dev/nvme0n1p2
    sudo btrfs balance start -dusage=10 /dev/nvme1n1p1
    ```

## Expected Results

### Successful Deployment Indicators

**Disk Layout:**

- `/dev/nvme0n1p1`: 512MB ESP (vfat)
- `/dev/nvme0n1p2`: Remaining space (btrfs) with 5 subvolumes
- `/dev/nvme1n1p1`: 100% (btrfs) with 6 subvolumes

**Mount Points:**

- `/boot`: ESP partition
- `/`: @ subvolume (root)
- `/home`: @home subvolume
- `/home/hbohlen/dev`: @dev-projects subvolume
- `/nix`: @nix subvolume (noatime + nodatacow)
- `/var`: @var subvolume
- `/var/lib/containers`: @containers subvolume
- `/var/cache`: @cache subvolume
- `/var/cache/podman`: @podman-cache subvolume
- `/var/lib/snapper`: @snapshots subvolume
- `/tmp`: @tmp subvolume
- `/home/hbohlen/.cache`: @user-cache subvolume

**Services:**

- `fstrim.timer` active and scheduled
- `smartd` monitoring both NVMe drives
- `snapper-timeline.timer` creating periodic snapshots
- `podman` using secondary disk for storage

## Rollback Procedure

If issues arise, rollback to the single-disk configuration:

1. **Boot from Previous Installation**
   - Select previous boot entry in GRUB
   - Use snapper snapshots if available

2. **Restore Single Disk Configuration**

   ```bash
   # Backup current (failed) configuration
   mv /home/hbohlen/dev/pantherOS/hosts/zephyrus/disko.nix /home/hbohlen/dev/pantherOS/hosts/zephyrus/disko-dual.failed

   # Restore original single-disk configuration
   cp ~/disko.nix.backup /home/hbohlen/dev/pantherOS/hosts/zephyrus/disko.nix

   # Rebuild configuration
   sudo nixos-rebuild switch --flake /home/hbohlen/dev/pantherOS#zephyrus
   ```

3. **Data Recovery**
   - If dual-disk setup partially worked, data may be recoverable from individual partitions
   - Use btrfs tools to mount subvolumes individually if needed

## Troubleshooting

### Common Issues

**1. Device Not Found**

- Verify device names with `lsblk`
- Check that facter.json reflects current hardware
- Ensure both NVMe drives are properly connected

**2. Btrfs Subvolume Creation Failed**

- Check disk space availability
- Verify mount point permissions
- Review disko logs for specific error messages

**3. Podman Storage Issues**

- Verify secondary disk mounting
- Check `/var/lib/containers` permissions
- Confirm podman configuration points to correct storage

**4. Performance Issues**

- Verify compression is working: `sudo btrfs filesystem df`
- Check mount options: `findmnt -D`
- Monitor SMART data for disk health

### Emergency Recovery

**Single-User Mode Boot:**

- Reboot and select previous kernel version
- If boot fails, use NixOS installation media
- Mount disks and restore from backup

**Data Recovery:**

```bash
# Mount btrfs partitions manually for data recovery
sudo mount -o subvol=@ /dev/nvme0n1p2 /mnt/recovery
sudo mount -o subvol=@home /dev/nvme0n1p2 /mnt/recovery/home
# Access data from /mnt/recovery
```
