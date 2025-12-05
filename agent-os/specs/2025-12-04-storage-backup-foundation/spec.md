# PantherOS Storage, Snapshots & Backup Foundation - Implementation Specification

## Overview

This specification defines the comprehensive storage, snapshot, and backup foundation for PantherOS across five heterogeneous hosts (2 laptops, 3 VPS servers). The design emphasizes hardware-aware storage layouts, optimized Btrfs subvolume strategies, automated snapshot policies with different retention tiers, and cost-effective offsite backups to Backblaze B2.

This implementation aligns with PantherOS's mission to provide 100% reproducible, declarative infrastructure for individual power users managing multiple machines, supporting Phase 2 (Configuration Cleanup), Phase 3 (Testing Framework), Phase 4 (Backup & Disaster Recovery), and Phase 5 (Btrfs Optimization) from the roadmap.

## Goals & Non-Goals

### Goals

**MUST:**
- Design hardware-aware storage profiles for 5 distinct host types (Zephyrus dual-NVMe, Yoga single-NVMe, Hetzner production VPS, Contabo staging VPS, OVH utility VPS)
- Create modular NixOS storage modules using flake-parts architecture for reusability
- Implement Btrfs subvolume strategy with proper CoW vs nodatacow handling per workload type
- Provide automated snapshot management with different retention policies per host profile (laptops: 7/4/12, servers: 30/12/12)
- Integrate Backblaze B2 offsite backup with $5-10/month budget constraint
- Build comprehensive testing framework using nix-unit (unit tests) and NixOS VM tests (integration)
- Enable Datadog monitoring for snapshot/backup health and alerting
- Support database workloads (PostgreSQL, Redis) with nodatacow requirements
- Optimize container workloads (Podman) with Btrfs-friendly mount options

**SHOULD:**
- Support periodic restore testing for backup validation
- Provide hardware detection via facter.json integration
- Enable snapper/btrbk integration for snapshot automation
- Support manual snapshot operations for development workflows
- Integrate with existing OpNix/1Password for credential management

### Non-Goals (Explicitly Out of Scope)

- Container orchestration beyond basic Podman storage optimization
- Application-level database backup logic (handled at snapshot layer)
- Full disaster recovery runbook and procedures (future phase)
- Binary cache management (separate feature)
- Multi-cloud backup targets beyond Backblaze B2 (single target only)
- Performance benchmarking or tuning beyond initial mount option optimization
- Real-time replication or synchronous backup strategies
- Automated bare-metal recovery procedures
- Database-specific backup tools (pg_dump, redis-cli) - snapshots only

## User Stories / Scenarios

### Laptop Scenario: Zephyrus Development Day

**As a developer working on Zephyrus (dual-NVMe laptop), I want to:**
- Automatically create Btrfs snapshots before and after major development operations
- Have my /home/dev subvolume (with nodatacow) optimized for fast Nix builds
- Store Podman containers on secondary NVMe for isolation from primary development work
- Recover deleted files from daily snapshots without system downtime
- Push critical snapshots to Backblaze B2 overnight within budget constraints
- Monitor snapshot health through Datadog with alerts for failures

### Production VPS Scenario: Hetzner Database Recovery

**As a system administrator managing Hetzner (production VPS), I want to:**
- Create 30 daily snapshots with aggressive retention for point-in-time recovery
- Ensure PostgreSQL and Redis databases use nodatacow subvolumes for data integrity
- Validate backup integrity through automated restore testing
- Receive immediate alerts when snapshots fail or disk space is low
- Restore to a specific point in time within 15-30 minute RTO window
- Verify backups are replicated to Backblaze B2 before morning business hours

### Staging VPS Scenario: Contabo Development Testing

**As a developer testing on Contabo (staging VPS), I want to:**
- Mirror Hetzner storage layout for realistic staging environment
- Run with relaxed snapshot/backup policies (few hours RPO, 1-2h RTO)
- Test backup/restore procedures without impacting production
- Maintain compatibility with production profiles for easier promotion

## Host Profiles & Hardware Awareness

### Host Profile Matrix

| Profile | Hardware | Disk Layout | Workloads | RPO/RTO | Priority |
|---------|----------|-------------|-----------|---------|----------|
| **Zephyrus** | Dual NVMe (2TB + 1TB) | Separate pools | Dev, Podman, Nix builds | 1h / 30-60m | Safety ≈ DevEx > Performance |
| **Yoga** | Single NVMe | Single pool | Travel, light dev | 1h / 30-60m | Safety ≈ DevEx > Performance |
| **Hetzner** | 458GB VPS | Single pool | PostgreSQL, Redis, web | 15-30m / aggressive | Reliability > Performance |
| **Contabo** | 536GB VPS | Single pool | Staging, mirroring prod | Few hours / 1-2h | Reliability > Performance |
| **OVH** | 200GB VPS | Single pool | Utility, experimental | Few hours / 1-2h | Reliability > Performance |

### Hardware Detection Strategy

The storage foundation MUST use facter.json for hardware detection and profile selection:

```nix
# Hardware detection from existing facter.json
{
  "hardware": {
    "disk": [
      {
        # Zephyrus: 2 NVMe drives
        # Yoga: 1 NVMe drive
        # VPS: virtio_scsi single disk
      }
    ]
  }
}
```

**Profile Selection Logic:**
1. **Zephyrus Detection**: Check for `nvme0n1` AND `nvme1n1` devices
2. **Yoga Detection**: Check for `nvme0n1` only (single NVMe)
3. **VPS Detection**: Check for `scsi-*` or `virtio` disk controllers
4. **Hetzner Detection**: Check disk size ~458GB
5. **Contabo Detection**: Check disk size ~536GB
6. **OVH Detection**: Check disk size ~200GB

### Subvolume Layout by Host

#### Zephyrus (Dual NVMe)
```
Primary Pool (/dev/nvme0n1):
  - @ (/)
  - @home
  - @dev-projects
  - @nix (nodatacow)

Secondary Pool (/dev/nvme1n1):
  - @containers (nodatacow)
  - @cache
  - @podman-cache
  - @snapshots
  - @tmp
  - @user-cache

Database Subvolumes (when running locally):
  - @postgresql (nodatacow)
  - @redis (nodatacow)
  - @backups
```

#### Yoga (Single NVMe)
```
Single Pool (/dev/nvme0n1):
  - @ (/)
  - @home
  - @nix (nodatacow)
  - @containers (nodatacow)
  - @backups
  - Optional: @postgresql, @redis
```

#### Servers (Hetzner/Contabo/OVH)
```
Single Pool:
  - @ (/)
  - @home
  - @dev
  - @config
  - @local
  - @user-cache
  - @ai-tools
  - @nix (nodatacow)
  - @log
  - @var-cache
  - @tmp
  - @containers (nodatacow)
  - @postgresql (nodatacow) - Hetzner only
  - @redis (nodatacow) - Hetzner only
  - @swap (nodatacow)
```

## Disko +

### Disko Configuration Structure Btrfs Design

The implementation MUST organize Disko configurations into reusable modules:

```nix
modules/storage/disko/
├── laptop-disk.nix         # Base laptop layout (single NVMe)
├── dual-nvme-disk.nix      # Zephyrus dual NVMe
├── server-disk.nix         # Base server layout (single VPS disk)
└── profiles/
    ├── zephyrus.nix        # Host-specific composition
    ├── yoga.nix
    ├── hetzner.nix
    ├── contabo.nix
    └── ovh.nix
```

### Btrfs Subvolume Design Patterns

**System Subvolumes (all hosts):**
- `@` - Root filesystem (compress=zstd:3, noatime)
- `@home` - User data (compress=zstd:3, noatime)
- `@nix` - Nix store (compress=zstd:1, nodatacow)
- `@log` - System logs (compress=zstd:3, noatime)

**Database Subvolumes (where databases run):**
- `@postgresql` - PostgreSQL data (nodatacow, compress=no)
- `@redis` - Redis data (nodatacow, compress=no)
- Rationale: Copy-on-write breaks database performance and fsync semantics

**Container Subvolumes (all hosts):**
- `@containers` - Podman storage (nodatacow, compress=no)
- Rationale: Container I/O is high; CoW overhead is significant; images are already compressed

**Development Subvolumes:**
- `@dev` - Development projects (compress=zstd:3, noatime)
- `@dev-projects` - Zephyrus specific (compress=zstd:3, noatime, ssd flag)
- Rationale: Source code compresses well; fast access needed

**Cache Subvolumes:**
- `@cache` - System caches (compress=zstd:1, noatime)
- `@user-cache` - User caches (compress=zstd:1, noatime)
- `@tmp` - Temporary files (compress=no, noatime)
- Rationale: Frequently rewritten data needs light compression or none

### CoW vs Nodatacow Decision Matrix

| Subvolume | CoW Setting | Rationale |
|-----------|-------------|-----------|
| `/` (root) | CoW enabled | General system files benefit from compression |
| `/home` | CoW enabled | User files compress well, snapshots useful |
| `/home/dev` | CoW enabled (Zephyrus: nodatacow) | Fast builds require nodatacow on dev laptop |
| `/nix` | **nodatacow** | Hard links and atomic updates require nodatacow |
| `/var/lib/postgresql` | **nodatacow** | Database integrity requires nodatacow |
| `/var/lib/redis` | **nodatacow** | Cache integrity requires nodatacow |
| `/var/lib/containers` | **nodatacow** | Container I/O performance requires nodatacow |
| `/var/log` | CoW enabled | Logs compress well, snapshots for debugging |
| `/var/cache` | CoW enabled (light) | Frequently rewritten, light compression |
| `/tmp` | CoW disabled | Speed over space, temp data |
| `/swap` | **nodatacow** | Required for swap files |

## Mount Options & Performance Tuning

### Mount Option Standards

**Base mount options (all Btrfs subvolumes):**
- `noatime` - MUST: Prevent unnecessary access time updates
- `space_cache=v2` - MUST: Modern space allocation cache
- `discard=async` - SHOULD: Async TRIM for SSDs

**Compression levels:**
- `compress=zstd:3` - Standard compression (good balance)
- `compress=zstd:2` - Medium compression (for mixed content)
- `compress=zstd:1` - Light compression (frequently rewritten data)
- `compress=no` - No compression (databases, containers, temp)

### Mount Option Comparison Matrix

| Workload Type | Compression | Special Options | Justification |
|---------------|-------------|-----------------|---------------|
| System files | zstd:3 | noatime, discard=async | Good compression, performance |
| User data | zstd:3 | noatime, discard=async | Compresses well, typical use case |
| Dev projects | zstd:3 | noatime, ssd (Zephyrus) | Source code compresses 3-5x |
| Nix store | zstd:1, nodatacow | nodatacow critical | Hard links can't use CoW |
| Databases | no, nodatacow | nodatacow critical | Database performance, integrity |
| Containers | no, nodatacow | nodatacow critical | High I/O workload, images pre-compressed |
| Logs | zstd:3 | noatime | Logs compress 5-10x |
| Caches | zstd:1 | noatime | Frequently updated |
| Temp | no | noatime | Speed over space |

### SSD Optimization

For NVMe SSDs (Zephyrus, Yoga):
- Enable `ssd` mount flag for auto-defragmentation hints
- Use `autodefrag` for background defragmentation
- Schedule weekly `fstrim` via systemd.timer
- Balance data chunks when >10% unused space

For VPS SSDs:
- Enable `discard=async` for TRIM support
- Use `space_cache=v2` for efficient space management
- Monitor balance operations to prevent fragmentation

## Snapshots Strategy

### Snapshot Retention Policies

**Laptops (Zephyrus, Yoga):**
```
Daily:   7 snapshots  (1 per day)
Weekly:  4 snapshots  (1 per week, keep for 1 month)
Monthly: 12 snapshots (1 per month, keep for 1 year)
Total:   23 snapshots maximum
```

**VPS Servers (Hetzner, Contabo, OVH):**
```
Daily:   30 snapshots (1 per day, keep for 1 month)
Weekly:  12 snapshots (1 per week, keep for 3 months)
Monthly: 12 snapshots (1 per month, keep for 1 year)
Total:   54 snapshots maximum
```

### Snapshot Automation

**Implementation using snapper:**
- Use snapper for timeline-based snapshots
- Create config per subvolume requiring snapshots
- Use systemd timers for automated snapshot creation

**Snapshot Schedule:**
- **Hourly**: Not used (too frequent)
- **Daily**: At 02:00 (off-peak hours)
- **Weekly**: Sunday at 03:00
- **Monthly**: 1st of month at 04:00

**Pre/post snapshot hooks:**
- **Pre-snapshot**: Flush database caches, stop containers if needed
- **Post-snapshot**: Update monitoring metrics, trigger backup jobs
- **Database snapshots**: Use consistent snapshot points (postgreSQL checkpoint, Redis SAVE)

### Snapshot Tools

**Snapper (primary):**
```nix
services.snapper = {
  enable = true;
  configs."root" = {
    SUBVOLUME = "/";
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_DAILY = 7;  # Or 30 for servers
    TIMELINE_LIMIT_WEEKLY = 4; # Or 12 for servers
    TIMELINE_LIMIT_MONTHLY = 12;
  };
};
```

**btrbk (alternative):**
- Can snapshot multiple subvolumes atomically
- Better for database-consistent snapshots
- Integrates well with backup tools

### Snapshot Monitoring

Monitor via Datadog:
- **Snapshot creation success/failure** - Custom metric
- **Snapshot age** - Alert if >24h old
- **Retention policy compliance** - Verify counts match expectations
- **Snapshot size** - Track space usage
- **Subvolume health** - Btrfs check results

## Offsite Backup Design

### Backup Architecture

**Primary Tool:** Backblaze B2 Cloud Storage
- Cost: $5-10/month budget
- No egress fees (ideal for read-heavy recovery)
- S3-compatible API
- Lifecycle rules for cost optimization

**Backup Method:** Snapshot replication
- Replicate selected Btrfs snapshots to B2
- Use btrbk for atomic snapshot + send operations
- Compress snapshots with zstd before upload
- Encrypt backups at rest using B2 SSE or client-side encryption

### Backup Scope

**Critical subvolumes (always backup):**
- `/` (root) - System configuration
- `/home` - User data
- `/home/dev` - Development projects
- `/var/lib/postgresql` - Database data (if exists)
- `/var/lib/redis` - Database data (if exists)
- `/etc` - Configuration (separate or subvolume)

**Optional subvolumes (based on host type):**
- `/var/lib/containers` - Container data (laptops only)
- `/var/cache` - System caches (servers only)
- `/var/log` - Logs (servers only)

### Backup Schedule

**Nightly off-peak schedule:**
- **Weekdays**: 02:00-05:00 (off-peak)
- **Weekends**: 02:00-06:00 (more time for full backup)
- **Monthly**: 1st weekend - full verification backup

**Backup frequency by subvolume:**
- Databases: Daily (most critical)
- User data: Daily
- System config: Weekly (changes infrequently)
- Container data: Weekly (laptops only)
- Logs: Monthly (servers only)

### Backup Validation

**Periodic restore testing:**
- Weekly: Verify backup list integrity
- Monthly: Test restore to staging environment
- Quarterly: Full disaster recovery drill

**Validation checks:**
- Verify backup completion timestamp
- Check backup size vs source
- Test backup encryption
- Validate restore path access

### Backblaze B2 Integration

**Authentication:**
```nix
{ config, ... }:
let
  b2-credentials = config.secrets.b2-backup-keyId or "b2-key";
in
{
  services.backblaze-b2.enable = true;
  services.backblaze-b2.accounts = {
    backup = {
      accountId = config.secrets.b2-backup-accountId;
      keyId = config.secrets.b2-backup-keyId;
      key = config.secrets.b2-backup-key;
    };
  };
}
```

**Backup directory structure:**
```
b2://pantheros-backups/
├── zephyrus/
│   ├── 2024/
│   │   ├── 01/
│   │   │   ├── root_20240115_020000.tar.zst
│   │   │   └── home_20240115_020000.tar.zst
│   └── snapshots/
│       └── root/
└── hetzner/
    ├── 2024/
    └── snapshots/
```

**Budget monitoring:**
- Alert at 80% of monthly budget
- Track storage growth trend
- Adjust retention if approaching limit
- Estimate costs based on current growth

## Monitoring & Alerting Integration Points

### Datadog Metrics

**Custom metrics to track:**
```python
# Snapshot metrics
pantheros.snapshot.created{host}       # Counter: snapshots created
pantheros.snapshot.failed{host}        # Counter: snapshot failures
pantheros.snapshot.age{host}           # Gauge: age in hours
pantheros.snapshot.count{host,type}    # Gauge: count by retention type

# Backup metrics
pantheros.backup.completed{host}       # Counter: successful backups
pantheros.backup.failed{host}          # Counter: backup failures
pantheros.backup.duration{host}        # Gauge: backup duration (seconds)
pantheros.backup.size{host,target}     # Gauge: backup size (bytes)
pantheros.backup.b2.cost{host}         # Gauge: estimated B2 cost

# Storage metrics
pantheros.disk.usage{host,device}      # Gauge: disk usage %
pantheros.btrfs.balance{host,device}   # Gauge: balance status
pantheros.snapshot.size{host,subvol}   # Gauge: snapshot size
```

### Alerting Rules

**Critical alerts:**
- Snapshot creation failure (immediately)
- Backup failure (within 1 hour)
- Database subvolume snapshot failure (immediately)
- Disk usage >85% (within 2 hours)
- Last successful backup >36h ago

**Warning alerts:**
- Snapshot age >24h
- Retention policy violation (wrong count)
- Backup duration >expected threshold
- B2 cost >90% of monthly budget

### Integration Points

**Datadog Agent configuration:**
- Enable Btrfs plugin (if available)
- Configure custom check scripts for snapshot/backup status
- Set up log collection for snapshot/backup services
- Configure service checks for snapshot/backup systemd services

**Alert channels:**
- Email for all alerts
- Slack/Discord for critical alerts
- PagerDuty for production incidents (Hetzner only)

**Dashboard requirements:**
- Host overview with snapshot/backup status
- Backup cost tracking
- Storage utilization over time
- Failure trend analysis

## Testing Strategy

### Unit Tests (nix-unit)

**Test suites:**

1. **Hardware Detection Tests**
   ```nix
   test "zephyrus dual-nvme detection" {
     let facter = readJSON ./facter/zephyrus.json;
     assert profile == "dev-laptop";
   }

   test "yoga single-nvme detection" {
     let facter = readJSON ./facter/yoga.json;
     assert profile == "light-laptop";
   }

   test "hetzner vps detection" {
     let facter = readJSON ./facter/hetzner.json;
     assert profile == "production-vps";
   }
   ```

2. **Subvolume Layout Tests**
   ```nix
   test "required subvolumes exist" {
     let config = import ./disko/laptop-disk.nix;
     assert config.disko.devices.disk.nvme0n1.content.subvolumes ? "@";
     assert config.disko.devices.disk.nvme0n1.content.subvolumes ? "@home";
     assert config.disko.devices.disk.nvme0n1.content.subvolumes ? "@nix";
   }

   test "database subvolumes have nodatacow" {
     let config = import ./disko/server-disk.nix;
     assert hasOption "nodatacow" config.disko.devices.disk.main.content.subvolumes."@postgresql".mountOptions;
   }
   ```

3. **Mount Options Tests**
   ```nix
   test "databases use nodatacow" {
     let options = getMountOptions "postgresql";
     assert elem "nodatacow" options;
     assert not (elem "compress" options);
   }

   test "containers use nodatacow" {
     let options = getMountOptions "containers";
     assert elem "nodatacow" options;
   }

   test "nix uses nodatacow" {
     let options = getMountOptions "nix";
     assert elem "nodatacow" options;
   }
   ```

4. **Snapshot Policy Tests**
   ```nix
   test "laptop retention matches 7/4/12" {
     let policy = getSnapshotPolicy "laptop";
     assert policy.daily == 7;
     assert policy.weekly == 4;
     assert policy.monthly == 12;
   }

   test "server retention matches 30/12/12" {
     let policy = getSnapshotPolicy "server";
     assert policy.daily == 30;
     assert policy.weekly == 12;
     assert policy.monthly == 12;
   }
   ```

5. **Backup Configuration Tests**
   ```nix
   test "backblaze b2 configured" {
     let config = import ./backup/backblaze.nix;
     assert config.services.backblaze-b2.enable == true;
   }

   test "backup schedule is off-peak" {
     let schedule = getBackupSchedule "hetzner";
     assert startsWith "02" schedule.time;
   }
   ```

### Integration Tests (NixOS VM Tests)

**Test suites:**

1. **Laptop Profile Tests** (Zephyrus, Yoga)
   ```nix
   machine:
     { config, pkgs, ... }:
     {
       imports = [
         ./modules/storage/profiles/laptop.nix
         ./hosts/${host}/disko.nix
       ];
     }

   test "zephyrus dual-disk boot" =
     let machine = makeTest {
       machine = import ./machines/zephyrus.nix;
       testScript = ''
         machine.wait_for_unit("multi-user.target")
         assert "/dev/nvme0n1" in machine.succeed("lsblk")
         assert "/dev/nvme1n1" in machine.succeed("lsblk")
         machine.succeed("btrfs subvolume list /" | grep -q "@home")
       '';
     };
   ```

2. **Server Profile Tests** (Hetzner, Contabo, OVH)
   ```nix
   test "hetzner database subvolumes mounted" {
     machine.wait_for_unit("multi-user.target")
     machine.succeed("mountpoint /var/lib/postgresql")
     machine.succeed("mountpoint /var/lib/redis")
     machine.succeed("cat /proc/mounts" | grep -q "/dev.* /var/lib/postgresql")
   }

   test "container storage functional" {
     machine.succeed("podman info")
     machine.succeed("test -f /var/lib/containers/storage.toml")
   }
   ```

3. **Snapshot & Backup Workflow Tests**
   ```nix
   test "snapshots created on schedule" {
     machine.wait_for_unit("snapper-timeline.timer")
     machine.succeed("systemctl start snapper-timeline")
     machine.succeed("snapper list | grep -q 'timeline'")
   }

   test "backblaze backup runs" {
     machine.wait_for_unit("backblaze-backup.service")
     machine.succeed("systemctl start backblaze-backup")
     machine.succeed("systemctl is-active backblaze-backup" == "active")
   }
   ```

### CI Integration

**GitHub Actions workflow:**
```yaml
name: Storage Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        host: [zephyrus, yoga, hetzner, contabo, ovh]
    steps:
      - uses: actions/checkout@v4
      - uses: cachix/install-nix-action@v25
      - name: Run unit tests
        run: nix flake check --accept-flake-config
      - name: Run integration tests
        run: nix build .#checks.x86_64-linux.storage-integration-tests.${{ matrix.host }}
      - name: Archive logs
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: test-logs-${{ matrix.host }}
          path: result/logs/
```

## Module & Flake-parts Integration

### Directory Structure

```
flake.nix
├── inputs
├── outputs
│   ├── packages.x86_64-linux.storage.laptop
│   ├── packages.x86_64-linux.storage.server
│   ├── packages.x86_64-linux.storage.profiles.zephyrus
│   ├── checks.x86_64-linux.storage-unit-tests
│   ├── checks.x86_64-linux.storage-integration-tests.zephyrus
│   └── devShells.x86_64-linux.default

modules/
└── storage/
    ├── default.nix              # Entry point, imports all
    ├── profiles/                # Base profiles
    │   ├── laptop.nix           # Laptop base configuration
    │   ├── server.nix           # Server base configuration
    │   ├── with-databases.nix   # PostgreSQL/Redis profile
    │   └── with-containers.nix  # Container profile
    ├── disko/                   # Disk layouts
    │   ├── laptop-disk.nix
    │   ├── dual-nvme-disk.nix
    │   └── server-disk.nix
    ├── btrfs/                   # Btrfs management
    │   ├── subvolumes.nix
    │   ├── mount-options.nix
    │   └── compression.nix
    ├── snapshots/               # Snapshot automation
    │   ├── default.nix
    │   ├── policies.nix
    │   └── automation.nix
    ├── backup/                  # Backup integration
    │   ├── default.nix
    │   ├── backblaze.nix
    │   └── validation.nix
    └── monitoring/              # Monitoring
        ├── datadog.nix
        └── alerts.nix

lib/
└── storage/
    ├── default.nix              # Helper library
    ├── hardware-profiles.nix    # Hardware detection
    ├── snapshot-helpers.nix     # Snapshot utilities
    └── backup-helpers.nix       # Backup utilities
```

### Module Composition

**Base laptop profile:**
```nix
# modules/storage/profiles/laptop.nix
{ config, lib, profile, ... }:
{
  options.storage.profile = lib.mkOption {
    type = lib.types.enum ["laptop" "server"];
    default = "laptop";
  };

  config = {
    imports = [
      ./disko/laptop-disk.nix
      ./snapshots/default.nix
      ./backup/default.nix
    ];

    storage = {
      snapshots.retention.daily = 7;
      snapshots.retention.weekly = 4;
      snapshots.retention.monthly = 12;
    };
  };
}
```

**Host-specific composition:**
```nix
# hosts/zephyrus/default.nix
{ config, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/hardware/bare-metal.nix")
    ../../modules/storage/profiles/laptop.nix
    ../../modules/storage/profiles/with-databases.nix
    ./disko-complete.nix
    ./nixos-snippets.nix
  ];

  # Override database subvolumes to nodatacow
  storage.btrfs.subvolumes = {
    "@dev-projects".mountOptions = ["nodatacow"];
  };
}
```

**flake-parts integration:**
```nix
# flake-parts integration
{
  imports = [
    ./modules/storage
    ./lib/storage
  ];

  perSystem = { system, ... }: {
    packages.storage-profiles = import ./lib/storage/profiles.nix { inherit system; };

    checks = {
      "storage-unit-tests" = import ./tests/storage-unit-tests.nix { inherit system; };
      "storage-integration-tests" = import ./tests/storage-integration-tests.nix { inherit system; };
    };
  };
}
```

## Domain & Networking Tie-ins

### hbohlen.systems Integration

**Backup status endpoints:**
- `backup-status.hbohlen.systems` - REST API for backup status
- `snapshots.hbohlen.systems` - Web UI for snapshot management
- `storage.hbohlen.systems` - Storage metrics dashboard

**DNS and SSL:**
- Use existing Caddy reverse proxy with wildcard *.hbohlen.systems
- Implement DNS-01 challenge via Cloudflare
- Certbot integration for SSL certificates

### Monitoring Infrastructure

**Datadog integration:**
- Use existing Datadog Pro subscription
- Integrate with monitoring.monitoring.hbohlen.systems
- Forward alerts to alerts.hbohlen.systems

**Self-hosted monitoring (optional):**
- Grafana dashboard at monitoring.hbohlen.systems/grafana
- Prometheus metrics at monitoring.hbohlen.systems/prometheus
- Loki logs at monitoring.hbohlen.systems/loki

### Backup Transfer Network

**Off-peak scheduling:**
- Schedule backups during 02:00-05:00 local time
- Stagger backup windows across hosts to avoid bandwidth contention
- Use compression to reduce transfer times
- Monitor bandwidth usage to avoid ISP throttling

**VPN integration:**
- Backup transfers occur over existing VPN tunnels
- B2 endpoints accessed through VPN for security
- Bandwidth shaped to 10Mbps per host during backup windows

## Visual References

**Where to find visual documentation:**

1. **Storage Layout Diagrams** - `planning/visuals/storage-layout/`
   - Mermaid diagrams showing subvolume hierarchy per host
   - Btrfs subvolume tree visualization
   - Disk pool allocation charts (Zephyrus dual-NVMe)

2. **Backup Architecture** - `planning/visuals/backup-architecture/`
   - Flow diagram showing snapshot → backup → B2 → restore path
   - Retention policy timeline visualization
   - Cost analysis charts

3. **Monitoring Dashboards** - `planning/visuals/monitoring/`
   - Datadog dashboard mockups
   - Alert flow diagrams
   - KPI tracking visualizations

4. **Testing Strategy** - `planning/visuals/testing/`
   - Test coverage matrix
   - CI/CD pipeline flow
   - Integration test architecture

**What visuals should show:**
- Snapshot timeline and retention visualization
- Storage subvolume hierarchy and mount points
- Backup data flow and validation checkpoints
- Alert escalation and response workflows

## Risks, Tradeoffs & Open Questions

### Risks

**High Priority:**
1. **Backup cost overruns** - B2 costs could exceed $5-10/month if retention too aggressive
   - *Mitigation*: Implement cost monitoring and automatic retention adjustment
2. **Database corruption during snapshot** - Nodatacow mitigates but doesn't eliminate risk
   - *Mitigation*: Use database-aware snapshots with pre-flush hooks
3. **Zephyrus dual-disk complexity** - Two pools add operational complexity
   - *Mitigation*: Extensive integration testing and clear documentation

**Medium Priority:**
4. **Snapshot performance impact** - High-frequency snapshots could impact I/O
   - *Mitigation*: Off-peak scheduling and monitoring
5. **Backup transfer failures** - Network issues during off-peak hours
   - *Mitigation*: Retry logic and health checks

**Low Priority:**
6. **Btrfs stability concerns** - Btrfs generally stable but edge cases exist
   - *Mitigation*: Regular filesystem checks and monitoring

### Tradeoffs

1. **Compression vs Performance**
   - *Choice*: Use zstd:3 for most data, nodatacow for databases
   - *Impact*: 30-50% space savings, minimal performance impact on modern CPUs
   - *Alternative*: Could use no compression for maximum performance

2. **Retention Aggressiveness**
   - *Choice*: 7/4/12 (laptops), 30/12/12 (servers)
   - *Impact*: Balances recovery needs vs storage costs
   - *Alternative*: Could use more aggressive retention for servers

3. **Separate Storage Pools (Zephyrus)**
   - *Choice*: Dual NVMe as separate pools, not RAID1
   - *Impact*: Better isolation but requires manual management
   - *Alternative*: Could use RAID1 for redundancy

4. **Snapshot Tool Selection**
   - *Choice*: Snapper for simplicity, btrbk for advanced features
   - *Impact*: Snapper easier to manage, btrbk better for complex scenarios
   - *Alternative*: Could use bare btrfs commands

### Open Questions

1. **What is actual B2 storage growth rate?** Need monitoring data to validate $5-10/month budget
2. **Should we snapshot container volumes?** Currently not including, but may need for stateful containers
3. **Database snapshot consistency** - Best approach for PostgreSQL/Redis point-in-time recovery?
4. **Cross-host snapshot replication** - Should laptops replicate to servers directly?
5. **Backup encryption** - Use B2 SSE or client-side encryption? Client-side adds complexity but more control
6. **Multi-architecture support** - Currently x86_64 only, need ARM64 for future Mac laptops?
7. **Bare-metal recovery** - How to handle complete disk failure recovery?

## Out-of-Scope / Future Work

### Explicitly Deferred

1. **Disaster Recovery Runbook**
   - Complete bare-metal recovery procedures
   - Network boot and PXE recovery setup
   - Automated bare-metal provisioning
   - *Timeline*: Future phase after storage foundation is stable

2. **Multi-Cloud Backup Strategy**
   - AWS S3 / Google Cloud / Azure backup targets
   - Cross-cloud replication and geo-redundancy
   - *Timeline*: Future phase if single-cloud strategy proves insufficient

3. **Application-Level Backups**
   - PostgreSQL logical backups (pg_dump)
   - Redis RDB/AOF optimization
   - MySQL/MariaDB support (not in current environment)
   - *Timeline*: Separate database backup feature

4. **Performance Benchmarking**
   - Btrfs performance testing
   - Compression ratio analysis
   - I/O latency measurements
   - *Timeline*: Future optimization phase

5. **Binary Cache Management**
   - Nix binary cache setup
   - Cachix integration
   - Hydra CI integration
   - *Timeline*: Separate build infrastructure feature

6. **Real-Time Replication**
   - DRBD integration
   - Syncthing for home directory
   - Continuous replication vs scheduled snapshots
   - *Timeline*: High availability feature

### Future Enhancements

7. **AI-Assisted Storage Optimization**
   - Automatic compression level tuning based on data patterns
   - Smart snapshot timing based on user activity
   - Predictive storage growth modeling
   - *Timeline*: Phase 6+ (AI features)

8. **Advanced Monitoring**
   - Predictive failure analysis
   - Capacity planning recommendations
   - Cost optimization suggestions
   - *Timeline*: Monitoring enhancement phase

9. **Container Volume Snapshots**
   - Podman volume snapshot integration
   - Container state management
   - Application-consistent snapshots
   - *Timeline*: Container orchestration feature

10. **GitOps for Storage Configuration**
    - Storage config in Git
    - Automated testing and validation
    - Rollback procedures
    - *Timeline*: Configuration management phase

### Research Topics

- **Btrfs send/receive optimization** - Incremental backup strategies
- **Zstd dictionary compression** - Better compression for repetitive data
- **Copy-on-write performance tuning** - Optimal chunk sizes and profiles
- **SSD over-provisioning** - Reserved space for performance
- **ZRAM integration** - Compressed RAM for temporary data
