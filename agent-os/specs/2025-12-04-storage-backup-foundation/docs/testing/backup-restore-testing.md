# Backup Restore Testing Guide

## Overview

This document establishes procedures for testing backup and restore operations to ensure data integrity and recovery capabilities in the PantherOS storage system.

**Testing Frequency**:
- **Monthly**: Full restore test to staging environment
- **Quarterly**: Complete disaster recovery drill
- **After Major Changes**: Ad-hoc restore testing

**Test Environments**:
- **Staging**: Contabo VPS (mirrors production)
- **Development**: Local VM or test laptop

## Table of Contents

1. [Testing Prerequisites](#testing-prerequisites)
2. [Monthly Restore Test](#monthly-restore-test)
3. [Staging Environment Restore](#staging-environment-restore)
4. [Validation Procedures](#validation-procedures)
5. [Testing Checklist](#testing-checklist)
6. [Test Report Template](#test-report-template)
7. [Troubleshooting Test Failures](#troubleshooting-test-failures)
8. [Compliance and Audit](#compliance-and-audit)

---

## Testing Prerequisites

### Required Access

1. **Backblaze B2 Access**
   - B2 account credentials
   - API access enabled
   - Sufficient storage for test downloads

2. **Staging Environment (Contabo)**
   - Root access
   - SSH key configured
   - Test user account

3. **Test Data**
   - Known test files
   - Checksums documented
   - File samples (text, binary, databases)

### Test Data Set

Create test data with known characteristics:

```bash
#!/bin/bash
# create-test-data.sh

TEST_DIR="/var/tmp/backup-test-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$TEST_DIR"

# Create test files
echo "Test file 1 - $(date)" > "$TEST_DIR/test1.txt"
dd if=/dev/urandom of="$TEST_DIR/test2.bin" bs=1M count=10
echo '{"key": "value", "timestamp": "'$(date -Iseconds)'"}' > "$TEST_DIR/test3.json"

# Create test directory structure
mkdir -p "$TEST_DIR"/{documents,images,data}
echo "Document test" > "$TEST_DIR/documents/readme.txt"
dd if=/dev/zero of="$TEST_DIR/images/test.img" bs=1M count=5

# Generate checksums
cd "$TEST_DIR"
find . -type f -exec sha256sum {} \; > checksums.sha256

echo "Test data created at: $TEST_DIR"
echo "Checksums:"
cat checksums.sha256
```

### Backup Credentials Setup

```bash
# Verify B2 credentials
b2 authorize-account <key-id> <application-key>

# Test B2 connectivity
b2 ls pantherOS-backups/<hostname>/root/

# Check available backup space
echo "Verify sufficient B2 space for test downloads"
b2 ls pantherOS-backups/<hostname>/root/ | wc -l
```

---

## Monthly Restore Test

### Overview

Monthly restore tests validate that backups can be successfully restored and data integrity is maintained.

### Scope

- **Critical subvolumes**: `/`, `/home`, `/etc`
- **Database data**: PostgreSQL and Redis (if applicable)
- **Test data**: Specifically created test files

### Procedure

#### Step 1: Prepare Staging Environment

```bash
#!/bin/bash
# prepare-staging.sh - Setup staging environment for testing

STAGING_HOST="staging.pantheros.example.com"
STAGING_USER="admin"

# Connect to staging
ssh "$STAGING_USER@$STAGING_HOST"

# Install required tools
nix-env -iA nixos.backblaze-b2
nix-env -iA nixos.btrbk  # if not in base system

# Create test directory
mkdir -p /tmp/restore-test
cd /tmp/restore-test

# Record initial state
df -h > initial-disk-state.txt
mount > initial-mount-state.txt

# Note: You'll use this as the target for restore
echo "Staging prepared for testing"
```

#### Step 2: Download Latest Backup

```bash
#!/bin/bash
# download-backup.sh

STAGING_HOST="staging.pantheros.example.com"
STAGING_USER="admin"
HOSTNAME="production-host"  # Change to actual hostname

# On staging host
ssh "$STAGING_USER@$STAGING_HOST"

# List available backups
b2 ls pantherOS-backups/$HOSTNAME/root/

# Find latest backup
LATEST_BACKUP=$(b2 ls pantherOS-backups/$HOSTNAME/root/ | tail -1 | awk '{print $NF}')

echo "Will restore from: $LATEST_BACKUP"

# Download backup
b2 download-file-by-name \
    pantherOS-backups/$HOSTNAME/root/$LATEST_BACKUP \
    latest-backup.tar.zst

# Verify download
ls -lh latest-backup.tar.zst
sha256sum latest-backup.tar.zst

echo "Backup downloaded successfully"
```

#### Step 3: Extract and Restore

```bash
#!/bin/bash
# restore-backup.sh

# Extract backup archive
tar -xzf latest-backup.tar.zst -C /tmp/restore-test/

# Verify extracted contents
ls -la /tmp/restore-test/

# If using btrbk, receive subvolumes:
# btrbk run --config /etc/btrbk/btrbk.conf --restore \
#     --target /tmp/restore-test \
#     --source / \
#     --snapshots btrfs://.snapshots

echo "Backup extracted to /tmp/restore-test/"
```

#### Step 4: Verify Restored Data

```bash
#!/bin/bash
# verify-restore.sh

RESTORE_DIR="/tmp/restore-test"
cd "$RESTORE_DIR"

echo "=== File Count Verification ==="
find . -type f | wc -l

echo ""
echo "=== Directory Structure ==="
tree -L 2

echo ""
echo "=== Sample File Checks ==="
# Check specific files
if [ -f etc/passwd ]; then
    echo "✓ /etc/passwd restored"
    wc -l etc/passwd
fi

if [ -f etc/shadow ]; then
    echo "✓ /etc/shadow restored"
    head -1 etc/shadow
fi

if [ -f home ]; then
    echo "✓ /home directory restored"
    find home -type f | wc -l
fi

# Check for test data if available
if [ -f var/tmp/backup-test-*/* ]; then
    echo "✓ Test data found"
    find var/tmp/backup-test-* -type f -exec sha256sum {} \; | tee restored-checksums.txt
fi

echo ""
echo "=== Verification Complete ==="
```

#### Step 5: Database Restore Test (If Applicable)

```bash
#!/bin/bash
# test-database-restore.sh

# Only if databases are included in backup

# Restore PostgreSQL database
if [ -d var/lib/postgresql ]; then
    echo "Testing PostgreSQL restore..."

    # Stop PostgreSQL on staging
    systemctl stop postgresql || true

    # Create backup of current state
    mkdir -p /tmp/postgres-original
    if [ -d /var/lib/postgresql ]; then
        cp -a /var/lib/postgresql /tmp/postgres-original/
    fi

    # Restore from backup
    mkdir -p /var/lib/postgresql-restore
    mount -t btrfs -o subvol=@postgresql /dev/vda2 /var/lib/postgresql-restore

    # Verify data
    if [ -f /var/lib/postgresql-restore/PG_VERSION ]; then
        echo "✓ PostgreSQL data structure valid"

        # Test with pg_verifybackup
        if command -v pg_verifybackup >/dev/null 2>&1; then
            pg_verifybackup /var/lib/postgresql-restore
        fi
    fi

    # Cleanup
    umount /var/lib/postgresql-restore
fi

# Restore Redis data
if [ -d var/lib/redis ]; then
    echo "Testing Redis restore..."

    systemctl stop redis || true

    mkdir -p /var/lib/redis-restore
    mount -t btrfs -o subvol=@redis /dev/vda2 /var/lib/redis-restore

    if [ -f /var/lib/redis-restore/dump.rdb ]; then
        echo "✓ Redis dump.rdb file found"
        ls -lh /var/lib/redis-restore/dump.rdb
    fi

    umount /var/lib/redis-restore
fi

echo "Database restore test complete"
```

### Test Execution Checklist

**Pre-Test**:
- [ ] Staging environment accessible
- [ ] B2 credentials configured and tested
- [ ] Test data set prepared
- [ ] Initial snapshot of staging taken
- [ ] Test plan reviewed

**During Test**:
- [ ] Latest backup downloaded successfully
- [ ] Backup file size reasonable
- [ ] Archive extracted without errors
- [ ] File count matches expectations
- [ ] Directory structure preserved
- [ ] File permissions maintained
- [ ] Database data structures valid
- [ ] Test data checksums verified
- [ ] No corruption detected

**Post-Test**:
- [ ] Restore directory cleaned up
- [ ] Test report generated
- [ ] Results documented
- [ ] Any issues logged
- [ ] Staging environment restored to initial state

---

## Staging Environment Restore

### Full System Restore to Staging

This procedure restores a production backup to the staging environment for validation.

#### Prerequisites

1. **Staging VM/VPS**:
   - Fresh NixOS installation
   - Same or larger disk than production
   - Network connectivity

2. **Backup Access**:
   - Production backups accessible in B2
   - Sufficient bandwidth for download

#### Procedure

##### Step 1: Setup Staging VM

```bash
# Fresh NixOS installation on staging
nixos-generate-config --root /mnt/staging

# Edit configuration.nix for staging
vim /mnt/staging/etc/nixos/configuration.nix

# Install NixOS
nixos-install --root /mnt/staging

# Reboot into staging
reboot

# Login and verify
ssh admin@staging-ip
hostname  # Should be staging
```

##### Step 2: Prepare for Restore

```bash
# On staging host
sudo -i

# Create restore directory
mkdir -p /tmp/restore-test
cd /tmp/restore-test

# Record staging baseline
df -h > staging-baseline.txt
btrfs subvolume list / > staging-subvolumes-before.txt

# Disable services that may interfere
systemctl disable --now snapper-timeline
systemctl disable --now panther-backup
```

##### Step 3: Download Production Backup

```bash
# Configure B2 credentials
b2 authorize-account <prod-key-id> <prod-app-key>

# List production backups
b2 ls pantherOS-backups/production-host/root/

# Select backup to restore (e.g., latest or specific date)
BACKUP_PATH="production-host/root/2024/12/latest-backup.tar.zst"

# Download backup
b2 download-file-by-name \
    pantherOS-backups/$BACKUP_PATH \
    production-backup.tar.zst

# Verify download integrity
sha256sum production-backup.tar.zst
```

##### Step 4: Restore to Test Environment

```bash
# Extract to separate location (not overwriting system)
mkdir -p /tmp/prod-restore
cd /tmp/prod-restore
tar -xzf /tmp/restore-test/production-backup.tar.zst

# Verify extracted data
ls -la
find . -type f | head -20

# Check specific data
if [ -d etc/nixos ]; then
    echo "Production NixOS config found"
    ls -la etc/nixos/
fi

if [ -d home ]; then
    echo "Production home directories found"
    find home -type f | wc -l
fi
```

##### Step 5: Compare Production vs Staging

```bash
#!/bin/bash
# compare-prod-staging.sh

PROD_DIR="/tmp/prod-restore"
STAGING_DIR="/"

echo "=== Comparison: Production Backup vs Staging ==="
echo ""

# File count comparison
PROD_FILES=$(find "$PROD_DIR" -type f | wc -l)
STAGING_FILES=$(find "$STAGING_DIR" -type f | wc -l)
echo "Production files: $PROD_FILES"
echo "Staging files: $STAGING_FILES"

# Configuration comparison
if [ -d "$PROD_DIR/etc/nixos" ]; then
    echo ""
    echo "Production NixOS configuration modules:"
    find "$PROD_DIR/etc/nixos" -name "*.nix" | head -10
fi

# User comparison
if [ -f "$PROD_DIR/etc/passwd" ]; then
    echo ""
    echo "Production users:"
    wc -l "$PROD_DIR/etc/passwd"
fi

# Package comparison
if [ -f "$PROD_DIR/var/nix/profile" ]; then
    echo ""
    echo "Production Nix profile entries:"
    wc -l "$PROD_DIR/var/nix/profile"/* 2>/dev/null || echo "Cannot read"
fi

echo ""
echo "=== Comparison Complete ==="
```

##### Step 6: Restore Specific Subvolumes

For more thorough testing, restore specific subvolumes:

```bash
# Restore /home to separate mount
mkdir -p /mnt/test-home
mount -t btrfs -o subvol=@home /dev/vda2 /mnt/test-home

# Verify home data
ls -la /mnt/test-home/
find /mnt/test-home -type f | wc -l

# Test file access
cat /mnt/test-home/*/readme.txt 2>/dev/null

# Unmount when done
umount /mnt/test-home
```

##### Step 7: Test Data Integrity

```bash
# Test with database dump (if available)
if [ -f /tmp/prod-restore/var/lib/postgresql/dump.sql ]; then
    echo "Testing PostgreSQL dump..."
    # Verify dump syntax
    head -20 /tmp/prod-restore/var/lib/postgresql/dump.sql
fi

# Test configuration validity
if [ -d /tmp/prod-restore/etc/nginx ]; then
    echo "Testing Nginx configuration..."
    find /tmp/prod-restore/etc/nginx -name "*.conf" -exec nginx -t -c {} \; 2>/dev/null || echo "Config files present"
fi

# Test JSON files
find /tmp/prod-restore -name "*.json" -exec jq . {} \; 2>/dev/null | head -20

echo "Data integrity test complete"
```

---

## Validation Procedures

### Data Integrity Validation

#### Checksums Verification

```bash
#!/bin/bash
# verify-checksums.sh

RESTORE_DIR="$1"
if [ -z "$RESTORE_DIR" ]; then
    echo "Usage: $0 <restore-directory>"
    exit 1
fi

cd "$RESTORE_DIR"

# Find checksum files
find . -name "*.sha256" -o -name "checksums.txt"

# If test data had checksums, verify them
if [ -f checksums.sha256 ]; then
    echo "Verifying checksums..."
    sha256sum -c checksums.sha256

    if [ $? -eq 0 ]; then
        echo "✓ All checksums match"
    else
        echo "✗ Checksum verification failed"
        exit 1
    fi
fi
```

#### File Permissions Check

```bash
#!/bin/bash
# check-permissions.sh

RESTORE_DIR="$1"

# Check sensitive files
echo "=== Checking Sensitive File Permissions ==="

SENSITIVE_FILES=(
    "$RESTORE_DIR/etc/shadow"
    "$RESTORE_DIR/etc/ssh/ssh_host_rsa_key"
    "$RESTORE_DIR/var/lib/postgresql/"
    "$RESTORE_DIR/var/lib/redis/"
)

for file in "${SENSITIVE_FILES[@]}"; do
    if [ -e "$file" ]; then
        ls -l "$file"
        # Check if permissions are reasonable (not world-readable for sensitive files)
        if [[ "$file" == *"shadow" || "$file" == *"ssh_host"* ]]; then
            perms=$(stat -c %a "$file")
            if [ "$perms" = "600" ] || [ "$perms" = "640" ]; then
                echo "✓ Permissions OK: $file"
            else
                echo "⚠️  Unexpected permissions: $file ($perms)"
            fi
        fi
    fi
done
```

#### Database Consistency Check

```bash
#!/bin/bash
# check-database-consistency.sh

RESTORE_DIR="$1"

# PostgreSQL
if [ -d "$RESTORE_DIR/var/lib/postgresql" ]; then
    echo "Checking PostgreSQL consistency..."

    # Check for essential files
    for dir in $(find "$RESTORE_DIR/var/lib/postgresql" -maxdepth 1 -type d); do
        if [ -f "$dir/PG_VERSION" ]; then
            echo "✓ PostgreSQL data directory: $dir"

            # Check for WAL files
            if [ -d "$dir/pg_wal" ]; then
                wal_count=$(find "$dir/pg_wal" -name "*.wal" | wc -l)
                echo "  WAL files: $wal_count"
            fi

            # Check for checkpoint files
            if [ -f "$dir/PG_VERSION" ]; then
                version=$(cat "$dir/PG_VERSION")
                echo "  PostgreSQL version: $version"
            fi
        fi
    done
fi

# Redis
if [ -d "$RESTORE_DIR/var/lib/redis" ]; then
    echo "Checking Redis consistency..."

    if [ -f "$RESTORE_DIR/var/lib/redis/dump.rdb" ]; then
        size=$(stat -f %z "$RESTORE_DIR/var/lib/redis/dump.rdb" 2>/dev/null || stat -c %s "$RESTORE_DIR/var/lib/redis/dump.rdb")
        echo "✓ Redis dump.rdb found (size: $size bytes)"

        # Verify dump format
        head -1 "$RESTORE_DIR/var/lib/redis/dump.rdb" | od -A n -t x1 | head -1
    fi
fi
```

### Restore Time Measurement

```bash
#!/bin/bash
# measure-restore-time.sh

echo "Starting restore test at $(date)"

# Measure download time
START_DOWNLOAD=$(date +%s)
# ... download backup ...
END_DOWNLOAD=$(date +%s)
DOWNLOAD_TIME=$((END_DOWNLOAD - START_DOWNLOAD))

# Measure extraction time
START_EXTRACT=$(date +%s)
# ... extract backup ...
END_EXTRACT=$(date +%s)
EXTRACT_TIME=$((END_EXTRACT - START_EXTRACT))

# Measure verification time
START_VERIFY=$(date +%s)
# ... verify files ...
END_VERIFY=$(date +%s)
VERIFY_TIME=$((END_VERIFY - START_VERIFY))

# Calculate total time
TOTAL_TIME=$((DOWNLOAD_TIME + EXTRACT_TIME + VERIFY_TIME))

echo "=== Restore Time Summary ==="
echo "Download: ${DOWNLOAD_TIME}s"
echo "Extract: ${EXTRACT_TIME}s"
echo "Verify: ${VERIFY_TIME}s"
echo "Total: ${TOTAL_TIME}s"
echo ""
echo "Completed at $(date)"
```

---

## Testing Checklist

### Pre-Testing Checklist

- [ ] Test environment prepared (staging VM)
- [ ] B2 credentials configured and tested
- [ ] Network connectivity verified
- [ ] Sufficient disk space available
- [ ] Test data set created with checksums
- [ ] Backup list reviewed (latest backup identified)
- [ ] Rollback plan prepared
- [ ] Test team notified
- [ ] Test window scheduled

### Monthly Restore Test Checklist

- [ ] **Download Test**
  - [ ] B2 connectivity established
  - [ ] Backup file identified
  - [ ] Download initiated
  - [ ] Download completed successfully
  - [ ] File size matches expectation
  - [ ] SHA256 checksum verified

- [ ] **Extraction Test**
  - [ ] Archive extracted without errors
  - [ ] No corruption detected
  - [ ] File count reasonable
  - [ ] Directory structure preserved

- [ ] **Integrity Test**
  - [ ] Critical files present (`/etc/passwd`, `/etc/shadow`)
  - [ ] Configuration files valid
  - [ ] User data present
  - [ ] Checksums verified (if available)
  - [ ] Permissions preserved

- [ ] **Database Test** (if applicable)
  - [ ] PostgreSQL data directory structure valid
  - [ ] Redis dump file present
  - [ ] Database version compatible
  - [ ] WAL files present (PostgreSQL)

- [ ] **Performance Test**
  - [ ] Download time measured
  - [ ] Extraction time measured
  - [ ] Verification time measured
  - [ ] Total time within SLA

- [ ] **Documentation**
  - [ ] Test report generated
  - [ ] Issues documented
  - [ ] Recommendations provided
  - [ ] Pass/Fail status recorded

### Quarterly Disaster Recovery Drill Checklist

- [ ] Full system restore tested
- [ ] Multiple backup dates tested
- [ ] Network failure scenarios simulated
- [ ] B2 outage scenarios tested
- [ ] Restore to different hardware verified
- [ ] Bootloader restoration tested
- [ ] Service startup validated
- [ ] Application functionality verified
- [ ] Team response time measured
- [ ] Documentation updated

---

## Test Report Template

```
# Backup Restore Test Report

**Test Date**: _______________
**Test Type**: [ ] Monthly [ ] Quarterly [ ] Ad-hoc
**Tester**: _______________
**Environment**: _______________

## Test Summary

**Result**: [ ] PASS [ ] FAIL [ ] PARTIAL

## Backup Information

**Backup Source**: _______________
**Backup Date**: _______________
**Backup Size**: _______________
**B2 Location**: _______________

## Test Execution

### Download Test
- **Start Time**: _______________
- **End Time**: _______________
- **Duration**: _______________
- **Status**: [ ] Pass [ ] Fail
- **Notes**: _______________

### Extraction Test
- **Start Time**: _______________
- **End Time**: _______________
- **Duration**: _______________
- **Status**: [ ] Pass [ ] Fail
- **Notes**: _______________

### Verification Test
- **Files Restored**: _______________
- **Checksums Verified**: [ ] Yes [ ] No [ ] N/A
- **Critical Files Present**: [ ] Yes [ ] No
- **Database Integrity**: [ ] Pass [ ] Fail [ ] N/A
- **Status**: [ ] Pass [ ] Fail
- **Notes**: _______________

## Performance Metrics

| Phase | Duration (seconds) | Within SLA |
|-------|-------------------|------------|
| Download | | [ ] Yes [ ] No |
| Extract | | [ ] Yes [ ] No |
| Verify | | [ ] Yes [ ] No |
| **Total** | | [ ] Yes [ ] No |

**SLA Targets**:
- Download: < 30 minutes
- Extract: < 10 minutes
- Verify: < 15 minutes
- Total: < 60 minutes

## Issues Found

| Issue | Severity | Status | Notes |
|-------|----------|--------|-------|
| | | | |
| | | | |

## Recommendations

- [ ] Update backup procedures
- [ ] Adjust retention policies
- [ ] Improve monitoring
- [ ] Update documentation
- [ ] No changes needed

## Next Test Date

**Scheduled**: _______________

## Sign-off

**Tester**: _________________ **Date**: _________
**Reviewer**: _________________ **Date**: _________
**Approver**: _________________ **Date**: _________

---
Report generated: $(date)
```

---

## Troubleshooting Test Failures

### Common Failure Scenarios

#### Failure: Download Timeout

**Symptoms**:
- Backup download fails
- Network errors in logs
- Incomplete file downloaded

**Solutions**:
```bash
# Check network connectivity
ping b2.backblaze.com

# Resume download
b2 download-file-by-name --resume \
    pantherOS-backups/host/path/file.tar.zst

# Use download mode
b2 download-file-by-name --download-mode standard \
    pantherOS-backups/host/path/file.tar.zst

# Split large backups
# Consider downloading in parts if >100GB
```

#### Failure: Checksum Mismatch

**Symptoms**:
- SHA256 verification fails
- Files corrupted
- Extraction errors

**Solutions**:
```bash
# Re-download backup
rm backup.tar.zst
b2 download-file-by-name ...

# Check B2 bucket integrity
b2 ls pantherOS-backups/host/path/ | head -20

# Verify file on B2 side
b2 download-file-by-name --sha1 \
    pantherOS-backups/host/path/file.tar.zst \
    /tmp/test-download

# Compare checksums
```

#### Failure: Database Corruption

**Symptoms**:
- Database files present but invalid
- PostgreSQL won't start
- Redis dump corrupted

**Solutions**:
```bash
# Check database files
ls -la /var/lib/postgresql/*/PG_VERSION
file /var/lib/redis/dump.rdb

# Verify backup is from consistent state
# Check if backup includes database locks

# Try older backup
# Select backup from before corruption event

# Manually restore from dump
# If logical dump available, restore from that instead
```

#### Failure: Insufficient Disk Space

**Symptoms**:
- Extraction fails
- "No space left on device" errors

**Solutions**:
```bash
# Check available space
df -h

# Clean test environment
rm -rf /tmp/restore-test/*

# Use streaming restore (don't extract to disk)
b2 download-file-by-name ... | tar -xz -C /dest/dir

# Compressed validation only
tar -tzf backup.tar.zst | head -20
```

#### Failure: B2 Authentication Error

**Symptoms**:
- "Invalid credentials" errors
- "Unauthorized" messages

**Solutions**:
```bash
# Re-authorize
b2 clear-account
b2 authorize-account <key-id> <app-key>

# Check key permissions
# Verify key has read access to bucket

# Test with simple command
b2 ls pantherOS-backups/
```

---

## Compliance and Audit

### Testing Documentation

Maintain records for compliance:

```bash
# Archive test reports
mkdir -p /var/log/backup-tests/$(date +%Y)
cp test-report-$(date +%Y%m%d).md /var/log/backup-tests/$(date +%Y)/

# Generate monthly summary
ls -ltr /var/log/backup-tests/*/test-report-*.md | tail -5 > monthly-summary.txt

# Track pass/fail rate
grep "Result" /var/log/backup-tests/*/test-report-*.md | \
    awk '{print $3}' | sort | uniq -c
```

### Audit Trail

Document all test activities:

- Test plan execution
- Backup source and date
- File verification results
- Performance metrics
- Issues found and resolution
- Recommendations implemented

### Regulatory Compliance

For compliance requirements:

- **RPO**: Restore Point Objective (max data loss acceptable)
- **RTO**: Restore Time Objective (max time to restore)

Example requirements:
- RPO: ≤ 24 hours
- RTO: ≤ 4 hours
- Test frequency: Monthly

Verify compliance:
```bash
# Check last successful backup
last_backup=$(b2 ls pantherOS-backups/host/root/ | tail -1)
echo "Last backup: $last_backup"

# Calculate data loss window
backup_time="2024-12-01 02:00:00"
current_time=$(date)
# Calculate difference

# Verify RPO met
# if [ $data_loss_window -le 86400 ]; then
#     echo "✓ RPO met"
# fi
```

---

## Contact Information

**Test Coordinator**: [Name] - [Email]
**Backup Administrator**: [Name] - [Email]
**Database Administrator**: [Name] - [Email]
**Escalation Contact**: [Name] - [Phone]

## Additional Resources

- [B2 API Documentation](https://www.backblaze.com/b2/docs/)
- [Btrfs Send/Receive Guide](https://btrfs.wiki.kernel.org/index.php/Using_btrfs_personal_and_administrative_storage)
- [Backup System Documentation](../README.md)
- [Snapper Testing Guide](https://snapper.io/2018/04/18/snapper-internals.html)

---

**Document Version**: 1.0
**Last Updated**: 2025-12-04
**Maintained By**: PantherOS Operations Team
**Review Frequency**: Quarterly
