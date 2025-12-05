# PantherOS Storage Module

Comprehensive storage management for NixOS with Btrfs subvolumes, automated snapshots, and Backblaze B2 backup integration.

## Overview

The PantherOS storage module provides a declarative, hardware-aware storage configuration system that supports multiple host profiles:

- **Zephyrus**: Dual-NVMe development laptop (2TB + 1TB)
- **Yoga**: Single-NVMe travel laptop (1TB)
- **Hetzner**: Production database VPS (458GB)
- **Contabo**: Staging VPS (536GB)
- **OVH**: Utility VPS (200GB)

## Quick Start

### Minimal Configuration

Enable the storage module in your system configuration:

```nix
{ inputs, outputs, ... }: {
  imports = [
    inputs.pantherOS.packages.x86_64-linux.storage
  ];

  # Enable storage module
  storage = {
    enable = true;

    # Select host profile (auto-detected by default)
    profile = "zephyrus"; # or "yoga", "hetzner", "contabo", "ovh"

    # Enable backups (requires B2 credentials)
    backup = {
      enable = true;
      b2 = {
        bucket = "your-bucket-name";
      };
    };
  };
}
```

### Complete Zephyrus Configuration

```nix
{ config, lib, ... }: {
  imports = [
    inputs.pantherOS.packages.x86_64-linux.storage
  ];

  storage = {
    enable = true;
    profile = "zephyrus";

    # Btrfs configuration
    btrfs = {
      ssdOptimization = true;

      # Customize mount options
      subvolumes = {
        "@dev-projects" = {
          mountOptions = [ "nodatacow" ];
        };
      };
    };

    # Snapshot policy (laptop default: 7/4/12)
    snapshots = {
      enable = true;
      retention = {
        daily = 7;
        weekly = 4;
        monthly = 12;
      };
    };

    # Backup configuration
    backup = {
      enable = true;

      # OpNix/1Password integration
      # Store credentials at: op://pantherOS/backblaze-b2/backup-credentials
      b2 = {
        bucket = "pantherOS-backups";
      };

      # Backup scope
      subvolumes = [ "/" "/home" "/etc" ];
      includeDatabases = true;
      includeContainers = false; # Set to true if using containers

      # Schedule (default: 02:00 daily)
      schedule = "02:00";
    };
  };
}
```

### Hetzner Production Configuration

```nix
{ config, ... }: {
  imports = [
    inputs.pantherOS.packages.x86_64-linux.storage
  ];

  storage = {
    enable = true;
    profile = "hetzner";

    # Aggressive snapshot retention for production
    snapshots = {
      enable = true;
      retention = {
        daily = 30;    # Keep 30 days
        weekly = 12;   # Keep 12 weeks
        monthly = 12;  # Keep 12 months
      };
    };

    # Enable database subvolumes
    btrfs = {
      subvolumes = {
        "@postgresql" = {
          enable = true;
        };
        "@redis" = {
          enable = true;
        };
      };
    };

    # Critical data backup
    backup = {
      enable = true;
      b2 = {
        bucket = "pantherOS-backups";
      };
      subvolumes = [ "/" "/home" "/etc" "/var/lib/postgresql" "/var/lib/redis" ];
      includeDatabases = true;
    };
  };
}
```

## Architecture

### Module Hierarchy

```
modules/storage/
├── default.nix              # Entry point
├── core.nix                 # Core configuration
├── btrfs/                   # Btrfs management
│   ├── mount-options.nix    # Mount option presets
│   ├── compression.nix      # Compression settings
│   ├── database-enforcement.nix # Nodatacow enforcement
│   └── ssd-optimization.nix # SSD optimizations
├── profiles/                # Host profiles
│   ├── zephyrus.nix         # Dual-NVMe laptop
│   ├── yoga.nix             # Single-NVMe laptop
│   ├── hetzner.nix          # Production VPS
│   ├── contabo.nix          # Staging VPS
│   └── ovh.nix              # Utility VPS
├── disko/                   # Disk layouts
│   ├── laptop-disk.nix      # Single NVMe
│   ├── dual-nvme-disk.nix   # Dual NVMe
│   └── server-disk.nix      # VPS disk
├── snapshots/               # Snapshot automation
│   ├── default.nix
│   ├── policies.nix
│   └── automation.nix
├── backup/                  # Backup integration
│   ├── backblaze.nix        # B2 credentials
│   ├── scope.nix            # Backup scope
│   ├── service.nix          # Backup service
│   ├── timer.nix            # Backup schedule
│   ├── bucket-structure.nix # B2 organization
│   ├── validation.nix       # Backup validation
│   └── cost-monitoring.nix  # Cost tracking
└── monitoring/              # Monitoring integration
    └── datadog.nix          # Metrics and alerts
```

### Visual Architecture

See [Storage Architecture Diagram](../../planning/visuals/storage-architecture.mmd)

See [Subvolume Layout Diagrams](../../planning/visuals/storage-layout/)
- [Zephyrus Layout](storage-layout/zephyrus.mmd)
- [Yoga Layout](storage-layout/yoga.mmd)
- [Server Layout](storage-layout/server.mmm)

See [Backup Flow Diagram](../../planning/visuals/backup-flow.mmd)

## Configuration Reference

### Core Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `storage.enable` | boolean | `false` | Enable storage module |
| `storage.profile` | enum | `"auto"` | Host profile: `zephyrus`, `yoga`, `hetzner`, `contabo`, `ovh`, `auto` |
| `storage.hostname` | string | auto | Hostname for backup organization |

### Btrfs Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `storage.btrfs.ssdOptimization` | boolean | `false` | Enable SSD-specific optimizations |
| `storage.btrfs.subvolumes` | attribute set | see profiles | Subvolume configuration |
| `storage.btrfs.enforceDatabaseNodatacow` | boolean | `true` | Enforce nodatacow on database subvolumes |

### Snapshot Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `storage.snapshots.enable` | boolean | `false` | Enable automatic snapshots |
| `storage.snapshots.retention.daily` | integer | profile default | Daily snapshots to keep |
| `storage.snapshots.retention.weekly` | integer | profile default | Weekly snapshots to keep |
| `storage.snapshots.retention.monthly` | integer | profile default | Monthly snapshots to keep |
| `storage.snapshots.schedule` | string | `"02:00"` | Daily snapshot time |

### Backup Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `storage.backup.enable` | boolean | `false` | Enable backup to B2 |
| `storage.backup.schedule` | string | `"02:00"` | Backup schedule |
| `storage.backup.subvolumes` | list | `["/" "/home" "/etc"]` | Subvolumes to backup |
| `storage.backup.includeDatabases` | boolean | `true` | Auto-include database subvolumes |
| `storage.backup.includeContainers` | boolean | host default | Auto-include container subvolumes |

### B2 Options

| Option | Type | Description |
|--------|------|-------------|
| `storage.backup.b2.bucket` | string | **Required** B2 bucket name |
| `storage.backup.b2.accountId` | string | From OpNix secret |
| `storage.backup.b2.keyId` | string | From OpNix secret |

## Subvolume Reference

### Standard Subvolumes

All hosts include these subvolumes:

- `@` (root) - System root filesystem
- `@home` - User home directories
- `@nix` - Nix store (nodatacow)
- `@log` - System logs (servers)
- `@tmp` - Temporary files
- `@swap` - Swap file (if enabled)

### Database Subvolumes

When databases are enabled:

- `@postgresql` - PostgreSQL data (nodatacow)
- `@redis` - Redis data (nodatacow)

### Container Subvolumes

- `@containers` - Podman/container storage (nodatacow)

### Host-Specific Subvolumes

**Zephyrus (Dual-NVMe):**
- `@dev-projects` - Development projects (nodatacow on primary pool)
- Secondary pool: `@cache`, `@podman-cache`, `@snapshots`, `@user-cache`

**Servers:**
- `@dev` - Development data
- `@config` - System configuration
- `@local` - Local software
- `@user-cache` - User cache
- `@ai-tools` - AI/ML tools
- `@var-cache` - Variable cache

## Mount Options

### Presets

#### Standard
- `noatime` - Don't update access times
- `space_cache=v2` - Modern space allocation
- `compress=zstd:3` - Good compression

#### Database
- `noatime`
- `nodatacow` - **Required** for database integrity
- `compress=no` - No compression

#### Container
- `noatime`
- `nodatacow` - **Required** for I/O performance
- `compress=no` - Images already compressed

#### Cache
- `noatime`
- `compress=zstd:1` - Light compression

#### Temporary
- `noatime`
- `compress=no` - Speed over space

### SSD Optimizations (Laptops)

When `storage.btrfs.ssdOptimization = true`:
- `ssd` flag - Btrfs SSD hints
- `discard=async` - Asynchronous TRIM
- `autodefrag` - Background defragmentation (optional)
- Weekly `fstrim` systemd timer

## Snapshot Retention

### Laptop Default (Zephyrus, Yoga)
- **Daily**: 7 snapshots (1 per day)
- **Weekly**: 4 snapshots (1 per week, keep 1 month)
- **Monthly**: 12 snapshots (1 per month, keep 1 year)
- **Total**: 23 snapshots maximum

### Server Default (Hetzner, Contabo, OVH)
- **Daily**: 30 snapshots (1 per day, keep 1 month)
- **Weekly**: 12 snapshots (1 per week, keep 3 months)
- **Monthly**: 12 snapshots (1 per month, keep 1 year)
- **Total**: 54 snapshots maximum

## Backup Organization

### B2 Bucket Structure

```
b2://pantherOS-backups/
├── zephyrus-laptop/
│   ├── root/
│   │   └── 2024/
│   │       └── 12/
│   │           └── 20241204_020000_root_snapshots.tar.zst
│   ├── home/
│   │   └── 2024/
│   └── etc/
├── hetzner-vps/
│   ├── root/
│   ├── home/
│   ├── postgresql/
│   └── redis/
```

### File Naming Convention

`<timestamp>_<subvolume>_snapshots.tar.zst`

Example: `20241204_020000_root_snapshots.tar.zst`

## Hardware Detection

The module auto-detects hardware profiles:

### Zephyrus
- Detects: `nvme0n1` AND `nvme1n1` devices
- Triggers: Dual-NVMe profile

### Yoga
- Detects: `nvme0n1` only
- Triggers: Single-NVMe profile

### Hetzner
- Detects: ~458GB disk
- Triggers: Production VPS profile

### Contabo
- Detects: ~536GB disk
- Triggers: Staging VPS profile

### OVH
- Detects: ~200GB disk
- Triggers: Utility VPS profile

## Troubleshooting

### Disk Space Issues

**Problem**: Disk full, snapshots failing

**Solution**:
```bash
# Check disk usage
df -h

# Check snapshot count
snapper list

# Clean old snapshots
snapper cleanup timeline

# Manual balance (if needed)
btrfs balance start -dusage=10 /
```

### Backup Failures

**Problem**: Backup to B2 failing

**Diagnosis**:
```bash
# Check backup logs
journalctl -u panther-backup.service

# Check B2 credentials
cat /var/lib/panther-backups/b2-credentials.env

# Manual backup test
systemctl start panther-backup.service
```

**Solution**:
1. Verify B2 credentials in 1Password
2. Check network connectivity
3. Verify bucket exists and is accessible
4. Check available B2 storage (capacity limits)

### Nodatacow Issues

**Problem**: Database performance degradation

**Diagnosis**:
```bash
# Check CoW status
find /var/lib/postgresql -print0 | xargs -0 chattr +C

# Verify mount options
mount | grep postgresql
```

**Solution**:
Ensure database subvolumes have `nodatacow` mount option.

### Snapshot Creation Failures

**Problem**: Snapshots not being created

**Diagnosis**:
```bash
# Check snapper service
systemctl status snapper-timeline.timer

# Check logs
journalctl -u snapper-cleanup
```

**Solution**:
```bash
# Enable and start timer
systemctl enable --now snapper-timeline.timer

# Manual snapshot
snapper create --description "manual snapshot"
```

### Mount Option Issues

**Problem**: Subvolume not mounting with correct options

**Diagnosis**:
```bash
# Check current mount options
mount | grep btrfs

# Check subvolume list
btrfs subvolume list /
```

**Solution**:
Update `storage.btrfs.subvolumes` configuration and rebuild.

## Common Configurations

### Development Laptop (Zephyrus)

```nix
storage = {
  profile = "zephyrus";
  btrfs = {
    ssdOptimization = true;
    subvolumes."@dev-projects".mountOptions = [ "nodatacow" ];
  };
  snapshots.enable = true;
  backup.enable = true;
  backup.includeContainers = true;
};
```

### Production Database Server (Hetzner)

```nix
storage = {
  profile = "hetzner";
  snapshots = {
    enable = true;
    retention.daily = 30;
    retention.weekly = 12;
    retention.monthly = 12;
  };
  backup.enable = true;
  backup.includeDatabases = true;
};
```

### Light Travel Laptop (Yoga)

```nix
storage = {
  profile = "yoga";
  btrfs.ssdOptimization = true;
  snapshots.enable = true;
  backup.enable = true;
};
```

### Staging Environment (Contabo)

```nix
storage = {
  profile = "contabo";
  snapshots.enable = true;
  backup.enable = true;
};
```

### Utility Server (OVH)

```nix
storage = {
  profile = "ovh";
  btrfs.subvolumes."@postgresql".enable = false;
  btrfs.subvolumes."@redis".enable = false;
  snapshots.enable = true;
  backup.enable = true;
};
```

## Integration

### With OpNix (1Password)

Store B2 credentials at: `op://pantherOS/backblaze-b2/backup-credentials`

Format:
```json
{
  "accountId": "your_account_id",
  "keyId": "your_key_id",
  "key": "your_application_key"
}
```

### With NixOS

Add to your `configuration.nix`:
```nix
{ config, ... }: {
  imports = [
    /path/to/pantherOS-storage/modules
  ];
  # ... storage configuration
}
```

### With Monitoring

Enable Datadog integration:
```nix
storage.monitoring = {
  datadog.enable = true;
  datadog.apiKey = "your_api_key";
};
```

## Testing

### Unit Tests

```bash
# Run unit tests
nix flake check

# Test specific profile
nix eval .#checks.x86_64-linux.storage-unit-tests.zephyrus
```

### Integration Tests

```bash
# Run VM tests
nix build .#checks.x86_64-linux.storage-integration-tests.zephyrus
```

## Additional Resources

### Visual Documentation
- [Architecture Diagram](../../planning/visuals/storage-architecture.mmd)
- [Subvolume Layouts](../../planning/visuals/storage-layout/)
- [Backup Flow](../../planning/visuals/backup-flow.mmd)

### Operational Guides
- [Snapshot & Restore Runbook](../../docs/operational/runbook-snapshot-restore.md)
- [Backup Restore Testing Guide](../../docs/testing/backup-restore-testing.md)
- [Monitoring Setup](../../docs/monitoring/datadog-setup.md)
- [Cost Analysis](../../docs/budget/b2-cost-analysis.md)

### Related Documentation
- [Btrfs Wiki](https://btrfs.wiki.kernel.org/)
- [Backblaze B2 Documentation](https://www.backblaze.com/b2/docs/)
- [Snapper Manual](https://snapper.io/documentation.html)

## Support

For issues and questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review logs: `journalctl -u panther-backup.service`
3. Consult operational runbooks
4. Open an issue in the project repository

## License

Part of PantherOS project - see project license for details.
