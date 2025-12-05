# Snapshot & Restore Operations Runbook

## Overview

This runbook provides step-by-step procedures for managing Btrfs snapshots and performing restore operations in the PantherOS storage system.

**Emergency Contact**: [Add your contact information]
**Escalation**: [Add escalation procedures]

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [Manual Snapshot Operations](#manual-snapshot-operations)
3. [File Recovery from Snapshots](#file-recovery-from-snapshots)
4. [Subvolume Restore Procedures](#subvolume-restore-procedures)
5. [Emergency Recovery Procedures](#emergency-recovery-procedations)
6. [Monitoring & Validation](#monitoring--validation)
7. [Troubleshooting](#troubleshooting)

---

## Quick Reference

### Common Commands

```bash
# List snapshots
snapper list

# Create manual snapshot
snapper create --description "manual-backup-$(date +%Y%m%d-%H%M%S)"

# Compare snapshots
snapper diff <snapshot-number> <snapshot-number>

# Rollback to snapshot
snapper rollback <snapshot-number>

# List subvolumes
btrfs subvolume list /

# Find files in snapshot
snapper status <snapshot-number>
```

### Snapshot Locations

- **Timeline snapshots**: `/.snapshots/`
- **Config snapshots**: `/etc/snapper/configs/`
- **Manual snapshots**: Created in timeline with description

### Default Retention Policies

**Laptops (Zephyrus, Yoga)**:
- Daily: 7 snapshots
- Weekly: 4 snapshots
- Monthly: 12 snapshots

**Servers (Hetzner, Contabo, OVH)**:
- Daily: 30 snapshots
- Weekly: 12 snapshots
- Monthly: 12 snapshots

---

## Manual Snapshot Operations

### Creating a Manual Snapshot

**When to use**: Before system updates, major configuration changes, or risky operations.

#### Procedure

1. **Check current snapshots**
   ```bash
   snapper list
   ```

2. **Create snapshot with description**
   ```bash
   # For root filesystem
   snapper create --description "pre-update-$(date +%Y%m%d-%H%M%S)"

   # For specific subvolume
   snapper create --description "manual-$(date +%Y%m%d-%H%M%S)" --subvolume /home
   ```

3. **Verify snapshot creation**
   ```bash
   snapper list | tail -5
   ```

4. **Tag snapshot for tracking**
   ```bash
   snapper modify <snapshot-number> --userdata "tag=pre-update,owner=admin"
   ```

#### Pre-Update Snapshot (Recommended)

```bash
#!/bin/bash
# Create pre-update snapshot for all critical subvolumes

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
DESCRIPTION="pre-update-$TIMESTAMP"

# Root filesystem
snapper create --description "$DESCRIPTION-root" --type single

# Home directory
snapper create --description "$DESCRIPTION-home" --subvolume /home

# Configuration
snapper create --description "$DESCRIPTION-config" --subvolume /etc

# Databases (if applicable)
if [ -d /var/lib/postgresql ]; then
    snapper create --description "$DESCRIPTION-postgresql" --subvolume /var/lib/postgresql
fi

if [ -d /var/lib/redis ]; then
    snapper create --description "$DESCRIPTION-redis" --subvolume /var/lib/redis
fi

echo "Created pre-update snapshots with tag: $TIMESTAMP"
```

### Scheduled Snapshots

#### Enable/Disable Timeline Snapshots

```bash
# Enable timeline snapshots
systemctl enable --now snapper-timeline.timer

# Disable timeline snapshots
systemctl disable --now snapper-timeline.timer

# Check timer status
systemctl status snapper-timeline.timer
```

#### Modify Snapshot Schedule

Edit snapper configuration:
```bash
# Edit root config
snapper -c root modify-config "TIMELINE_CLEANUP=yes"
snapper -c root modify-config "TIMELINE_LIMIT_DAILY=7"
snapper -c root modify-config "TIMELINE_LIMIT_WEEKLY=4"
snapper -c root modify-config "TIMELINE_LIMIT_MONTHLY=12"
```

#### Manual Snapshot Cleanup

```bash
# Clean according to limits
snapper cleanup timeline

# Clean old snapshots (keep last 5)
snapper cleanup number

# Clean old snapshots by age (keep last 30 days)
snapper cleanup age
```

---

## File Recovery from Snapshots

### Finding and Recovering a Deleted File

**Scenario**: User accidentally deleted important files from `/home/user/Documents/`

#### Procedure

1. **Identify the file and approximate deletion time**
   ```bash
   # Example: /home/user/Documents/project/important.txt
   ```

2. **List relevant snapshots**
   ```bash
   snapper list | grep -E "(pre-|timeline)"
   ```

3. **Browse snapshot to find file**
   ```bash
   # Mount snapshot read-only
   mkdir -p /mnt/snapshot
   mount -o subvol=.snapshots/<snapshot-number>/snapshot /mnt/snapshot

   # Find the file
   find /mnt/snapshot/home/user/Documents -name "important.txt" -ls

   # Unmount when done
   umount /mnt/snapshot
   rmdir /mnt/snapshot
   ```

4. **Restore individual file**
   ```bash
   # Copy from snapshot to current filesystem
   cp /.snapshots/<snapshot-number>/snapshot/home/user/Documents/important.txt \
      /home/user/Documents/important.txt

   # Or use rsync for multiple files
   rsync -av /.snapshots/<snapshot-number>/snapshot/home/user/Documents/ \
         /home/user/Documents/
   ```

5. **Verify restoration**
   ```bash
   ls -lh /home/user/Documents/important.txt
   md5sum /home/user/Documents/important.txt
   ```

#### Automated File Recovery Script

```bash
#!/bin/bash
# recover-file.sh - Recover file from most recent snapshot

FILE_PATH="$1"
SNAPSHOT_NUM="$2"

if [ -z "$FILE_PATH" ] || [ -z "$SNAPSHOT_NUM" ]; then
    echo "Usage: $0 <file-path> <snapshot-number>"
    echo "Example: $0 /home/user/Documents/important.txt 45"
    exit 1
fi

# Create restore directory
RESTORE_DIR="/tmp/file-restore-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESTORE_DIR"

# Mount snapshot
MOUNT_POINT="$RESTORE_DIR/mnt"
mkdir -p "$MOUNT_POINT"
mount -o subvol=.snapshots/$SNAPSHOT_NUM/snapshot "$MOUNT_POINT"

if [ $? -eq 0 ]; then
    # Copy file
    if [ -f "$MOUNT_POINT$FILE_PATH" ]; then
        cp -v "$MOUNT_POINT$FILE_PATH" "$RESTORE_DIR/"
        echo "File recovered to: $RESTORE_DIR"
        echo "Review and move to desired location"
    else
        echo "File not found in snapshot"
    fi

    # Cleanup
    umount "$MOUNT_POINT"
else
    echo "Failed to mount snapshot"
fi

# Keep restore directory for 24 hours
echo "Restore directory will be cleaned up in 24 hours"
find "$RESTORE_DIR" -type d -empty -mtime +1 -exec rmdir {} \; 2>/dev/null
```

### Recovering from Accidental Configuration Changes

**Scenario**: Configuration file was edited incorrectly

#### Procedure

1. **Identify the configuration file**
   ```bash
   # Example: /etc/nginx/nginx.conf
   ```

2. **Find relevant snapshot**
   ```bash
   snapper list --all-configs | grep -E "(pre-|timeline)"
   ```

3. **Check differences**
   ```bash
   snapper diff <snapshot-number> /etc/nginx/nginx.conf
   ```

4. **Restore the file**
   ```bash
   # Copy from snapshot
   cp /.snapshots/<snapshot-number>/snapshot/etc/nginx/nginx.conf \
      /etc/nginx/nginx.conf

   # Test configuration
   nginx -t

   # Reload service if valid
   systemctl reload nginx
   ```

---

## Subvolume Restore Procedures

### Rolling Back an Entire Subvolume

**Scenario**: Subvolume corrupted or severely misconfigured, need to restore from snapshot

⚠️ **WARNING**: This procedure will replace the current subvolume content with snapshot content.

#### Procedure

1. **Identify the subvolume and snapshot**
   ```bash
   btrfs subvolume list /
   snapper list
   ```

2. **Create safety snapshot of current state**
   ```bash
   snapper create --description "pre-rollback-$(date +%Y%m%d-%H%M%S)"
   ```

3. **Unmount the subvolume**
   ```bash
   umount /subvolume/path
   ```

4. **Delete current subvolume**
   ```bash
   btrfs subvolume delete /subvolume/path
   ```

5. **Receive subvolume from snapshot**
   ```bash
   btrfs receive /mount/point < /.snapshots/<snapshot-number>/snapshot

   # Or use snapper rollback (simpler)
   snapper rollback <snapshot-number>
   ```

6. **Mount the restored subvolume**
   ```bash
   mount /dev/device /subvolume/path
   ```

7. **Verify restoration**
   ```bash
   # Check files
   ls -la /subvolume/path

   # Verify services (if applicable)
   systemctl status <service-name>
   ```

#### Snapper Rollback Method (Recommended)

```bash
#!/bin/bash
# rollback-subvolume.sh - Rollback subvolume using snapper

SNAPSHOT_NUM="$1"
SUBVOLUME="$2"

if [ -z "$SNAPSHOT_NUM" ] || [ -z "$SUBVOLUME" ]; then
    echo "Usage: $0 <snapshot-number> <subvolume>"
    echo "Example: $0 45 root"
    exit 1
fi

echo "This will replace the current $SUBVOLUME subvolume with snapshot $SNAPSHOT_NUM"
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted"
    exit 1
fi

# Create pre-rollback snapshot
snapper create --description "pre-rollback-$SUBVOLUME-$(date +%Y%m%d-%H%M%S)"

# Perform rollback
snapper -c "$SUBVOLUME" rollback "$SNAPSHOT_NUM"

if [ $? -eq 0 ]; then
    echo "Rollback successful"
    echo "You may need to reboot for changes to take effect"
else
    echo "Rollback failed - check logs"
    exit 1
fi
```

### Restoring Database Subvolumes

**Scenario**: PostgreSQL or Redis data corruption

#### PostgreSQL Restore

```bash
#!/bin/bash
# restore-postgresql.sh

SNAPSHOT_NUM="$1"

if [ -z "$SNAPSHOT_NUM" ]; then
    echo "Usage: $0 <snapshot-number>"
    exit 1
fi

echo "⚠️  This will stop PostgreSQL and restore from snapshot $SNAPSHOT_NUM"

# 1. Stop PostgreSQL
systemctl stop postgresql

# 2. Create backup of current state
btrfs subvolume snapshot /var/lib/postgresql \
    /var/lib/postgresql-backup-$(date +%Y%m%d-%H%M%S)

# 3. Delete current subvolume
btrfs subvolume delete /var/lib/postgresql

# 4. Restore from snapshot
btrfs subvolume create /var/lib/postgresql
mount -o subvol=@postgresql /dev/nvme0n1p2 /var/lib/postgresql

# Or using snapper (if configured)
# snapper -c postgresql rollback "$SNAPSHOT_NUM"

# 5. Set correct permissions
chown -R postgres:postgres /var/lib/postgresql
chmod 700 /var/lib/postgresql

# 6. Start PostgreSQL
systemctl start postgresql

# 7. Verify
systemctl status postgresql
ps aux | grep postgres

echo "PostgreSQL restore complete"
```

#### Redis Restore

```bash
#!/bin/bash
# restore-redis.sh

SNAPSHOT_NUM="$1"

if [ -z "$SNAPSHOT_NUM" ]; then
    echo "Usage: $0 <snapshot-number>"
    exit 1
fi

echo "⚠️  This will stop Redis and restore from snapshot $SNAPSHOT_NUM"

# 1. Stop Redis
systemctl stop redis

# 2. Create backup of current state
btrfs subvolume snapshot /var/lib/redis \
    /var/lib/redis-backup-$(date +%Y%m%d-%H%M%S)

# 3. Delete current subvolume
btrfs subvolume delete /var/lib/redis

# 4. Restore from snapshot
btrfs subvolume create /var/lib/redis
mount -o subvol=@redis /dev/nvme0n1p2 /var/lib/redis

# 5. Set correct permissions
chown -R redis:redis /var/lib/redis

# 6. Start Redis
systemctl start redis

# 7. Verify
systemctl status redis
redis-cli ping

echo "Redis restore complete"
```

---

## Emergency Recovery Procedures

### Recovering from Complete Disk Failure

**Scenario**: Primary disk failed, need to restore from B2 backup

#### Prerequisites
- Backup files available in Backblaze B2
- Replacement disk installed
- Bootable rescue media or NixOS installer

#### Procedure

1. **Boot from rescue media**
   - Use NixOS installer USB/DVD
   - Boot into rescue mode

2. **Set up B2 credentials**
   ```bash
   # Install B2 CLI
   nix-env -iA nixos.backblaze-b2

   # Configure credentials
   b2 authorize-account <key-id> <application-key>
   ```

3. **Create new Btrfs filesystem**
   ```bash
   # Create partition and filesystem
   cfdisk /dev/nvme0n1
   mkfs.btrfs -L "pantherOS" /dev/nvme0n1p2

   # Mount filesystem
   mkdir /mnt/root
   mount /dev/nvme0n1p2 /mnt/root
   ```

4. **Download and extract backup**
   ```bash
   # List available backups
   b2 ls pantherOS-backups/<hostname>/root/

   # Download latest backup
   cd /mnt/root
   b2 download-file-by-name pantherOS-backups/<hostname>/root/<path>/backup.tar.zst \
        backup.tar.zst

   # Extract backup
   tar -xzf backup.tar.zst

   # Receive Btrfs subvolumes
   btrfs receive . < /path/to/snapshots-stream
   ```

5. **Configure bootloader**
   ```bash
   # Install NixOS
   nixos-generate-config --root /mnt/root

   # Mount necessary filesystems
   mount --bind /dev /mnt/root/dev
   mount --bind /proc /mnt/root/proc
   mount --bind /sys /mnt/root/sys

   # Enter chroot
   chroot /mnt/root /bin/bash

   # Install bootloader
   nixos-install

   # Exit chroot
   exit
   ```

6. **Reboot and verify**
   ```bash
   umount -R /mnt/root
   reboot
   ```

### Failed Snapshot Recovery

**Scenario**: Snapshot creation failed, backup operation cannot proceed

#### Diagnosis

```bash
# Check snapper logs
journalctl -u snapper-cleanup
journalctl -u snapper-timeline

# Check disk space
df -h

# Check Btrfs status
btrfs filesystem show
btrfs scrub status /
```

#### Recovery Steps

1. **Fix disk space issues**
   ```bash
   # Clean old snapshots
   snapper cleanup timeline

   # Remove old log files
   journalctl --vacuum-time=7d

   # Clean package cache
   nix store gc
   ```

2. **Fix Btrfs issues**
   ```bash
   # Run filesystem check
   btrfs check --check-mode=lowmem /dev/nvme0n1p2

   # Scrub to verify data integrity
   btrfs scrub start /
   btrfs scrub status /
   ```

3. **Restart snapshot services**
   ```bash
   systemctl restart snapper-timeline
   systemctl restart snapper-cleanup

   # Verify
   systemctl status snapper-timeline
   ```

---

## Monitoring & Validation

### Verifying Snapshot Health

```bash
#!/bin/bash
# verify-snapshots.sh - Verify snapshot integrity

echo "=== Snapshot Health Check ==="

# Check timeline snapshots
echo "Timeline snapshots:"
snapper list | tail -10

# Check snapshot count
DAILY=$(snapper list | grep "timeline" | grep -c "^0")
WEEKLY=$(snapper list | grep "timeline" | grep -c "^1")
MONTHLY=$(snapper list | grep "timeline" | grep -c "^2")

echo "Daily snapshots: $DAILY"
echo "Weekly snapshots: $WEEKLY"
echo "Monthly snapshots: $MONTHLY"

# Check for failed snapshots
FAILED=$(snapper list | grep "failed" | wc -l)
if [ "$FAILED" -gt 0 ]; then
    echo "⚠️  WARNING: $FAILED failed snapshots detected"
    snapper list | grep "failed"
else
    echo "✓ No failed snapshots"
fi

# Check snapshot sizes
echo ""
echo "Snapshot sizes:"
du -sh /.snapshots/*/snapshot | head -10

# Check for old snapshots
OLDEST=$(snapper list | tail -1 | awk '{print $1}')
echo "Oldest snapshot: $OLDEST"

# Check disk usage
echo ""
echo "Disk usage:"
df -h / | tail -1

echo ""
echo "=== Snapshot Verification Complete ==="
```

### Checking Backup Status

```bash
#!/bin/bash
# check-backup-status.sh

echo "=== Backup Status Check ==="

# Check last backup
LAST_BACKUP=$(systemctl status panther-backup.service | grep "Active:" | tail -1)
echo "Last backup: $LAST_BACKUP"

# Check backup logs
echo ""
echo "Recent backup logs:"
journalctl -u panther-backup.service --since "24 hours ago" | tail -20

# Check backup validation
if [ -f /etc/backups/validation/status.json ]; then
    cat /etc/backups/validation/status.json
fi

# Check B2 connectivity
b2 ls pantherOS-backups/<hostname>/root/ | tail -5

echo ""
echo "=== Backup Check Complete ==="
```

---

## Troubleshooting

### Issue: "No space left on device" during snapshot

**Symptoms**:
- Snapshot creation fails
- Btrfs errors in logs
- Disk shows full

**Solution**:
```bash
# Check actual usage
btrfs filesystem show /
btrfs filesystem df /

# Clean old snapshots
snapper cleanup timeline
snapper cleanup number

# Balance if needed
btrfs balance start -dusage=10 /
btrfs balance start -musage=10 /

# Check fragmentation
btrfs filesystem defragment -rv /

# Emergency: manually delete oldest snapshots
snapper list
snapper delete <oldest-snapshot-numbers>
```

### Issue: "Btrfs check failed" errors

**Symptoms**:
- Snapshots fail to create
- Filesystem errors in dmesg
- Data corruption warnings

**Solution**:
```bash
# Run filesystem check (unmounted)
umount /
btrfs check --check-mode=lowmem /dev/nvme0n1p2

# If errors found, try repair
btrfs check --repair /dev/nvme0n1p2

# Scrub for errors
btrfs scrub start /
btrfs scrub status /  # Wait for completion

# If issues persist, restore from backup
```

### Issue: Snapper service not running

**Symptoms**:
- No timeline snapshots
- Timer shows inactive

**Solution**:
```bash
# Enable and start services
systemctl enable snapper-timeline.timer
systemctl start snapper-timeline.timer

systemctl enable snapper-cleanup.timer
systemctl start snapper-cleanup.timer

# Check status
systemctl status snapper-timeline.timer
systemctl status snapper-cleanup.timer

# View timer schedule
systemctl list-timers snapper-timeline
```

### Issue: Database snapshot corruption

**Symptoms**:
- Database won't start after snapshot
- Inconsistent data
- Checkpoint errors

**Solution**:
```bash
# Ensure databases are properly stopped
systemctl stop postgresql
systemctl stop redis

# Create consistent snapshot
snapper create --description "db-consistent" --command "systemctl stop postgresql redis; snapper create; systemctl start postgresql redis"

# Verify snapshot with database check
systemctl start postgresql
sudo -u postgres pg_verifybackup /var/lib/postgresql/<snapshot-path>
```

---

## Recovery Time Objectives (RTO)

| Scenario | Target RTO | Procedure |
|----------|-----------|-----------|
| File recovery | 5-15 minutes | [File Recovery](#file-recovery-from-snapshots) |
| Config rollback | 10-20 minutes | [Config Restore](#recovering-from-accidental-configuration-changes) |
| Subvolume rollback | 30-60 minutes | [Subvolume Restore](#subvolume-restore-procedures) |
| Database recovery | 45-90 minutes | [Database Restore](#restoring-database-subvolumes) |
| Complete disaster | 2-4 hours | [Disk Failure Recovery](#recovering-from-complete-disk-failure) |

## Contact Information

**Primary Contact**: [Name] - [Phone] - [Email]
**Backup Contact**: [Name] - [Phone] - [Email]
**Escalation**: [Contact details]

## Additional Resources

- [Snapper Manual](https://snapper.io/documentation.html)
- [Btrfs Wiki](https://btrfs.wiki.kernel.org/)
- [Storage Module README](../README.md)
- [Backup Testing Guide](../testing/backup-restore-testing.md)
- [Monitoring Setup](../monitoring/datadog-setup.md)

---

**Document Version**: 1.0
**Last Updated**: 2025-12-04
**Maintained By**: PantherOS Operations Team
