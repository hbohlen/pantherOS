# OVH Cloud VPS Hardware Specifications

## Overview
- **Host Name**: ovh-vps
- **Host Type**: Redundant Server
- **Primary Purpose**: Secondary server for redundancy, backup services, load distribution, geographic distribution
- **Use Cases**: Backup target, redundant services, additional development capacity, disaster recovery, mirror services
- **Performance Requirements**: High availability with optimized resource utilization for backup and redundancy workloads

## Hardware Specifications

### CPU
- **Model**: Intel Xeon Gold 6142 or AMD EPYC 7302P (depending on OVH instance type)
- **Cores**: 16 cores / 32 threads (Intel) or 16 cores / 32 threads (AMD)
- **Base Clock**: 3.2 GHz (Intel) / 3.0 GHz (AMD)
- **Boost Clock**: 3.7 GHz (Intel) / 3.4 GHz (AMD)
- **Architecture**: x86_64
- **TDP**: 150W (server-grade)
- **Cache**: 22MB L3 (Intel) / 128MB L3 (AMD)
- **Virtualization**: Full hardware virtualization support (Intel VT-x/AMD-V)
- **Special Features**: 
  - Enterprise-grade reliability and uptime
  - Advanced power management for 24/7 operation
  - Sufficient cores for container orchestration and backup tasks
  - Optimized for sustained multi-threaded workloads

### Memory
- **Total RAM**: 64GB DDR4-2933 ECC (OVH VPS)
- **Memory Type**: DDR4-2933 with ECC (Error Correcting Code)
- **Configuration**: 4x16GB DIMM dual-channel configuration
- **Upgradeability**: Up to 128GB supported (OVH scaling options)
- **ECC Support**: Yes (server-grade error correction)
- **Memory Bandwidth**: ~150 GB/s
- **Implications**: Adequate memory for backup services, redundant containers, and disaster recovery workloads

### Storage
- **Primary Storage**: 600GB NVMe PCIe 3.0 SSD (OVH local disk)
- **Storage Performance**: ~2500 MB/s read, ~1800 MB/s write
- **IOPS Performance**: ~80K random read IOPS, ~65K random write IOPS
- **Storage Interface**: NVMe over PCIe 3.0
- **Data Persistence**: Local SSD with OVH Cloud Archive integration
- **Expansion**: 
  - OVH Object Storage (S3-compatible) integration
  - Additional volume mounts via OVH Cloud API
  - Network-attached storage via Tailscale
  - Cross-region replication with Hetzner VPS
- **Backup Strategy**: Primary backup target with cross-provider replication

### Network
- **Primary Interface**: 1 Gbps Ethernet (OVH network)
- **Public IPv4**: Static IP address (OVH-assigned)
- **Public IPv6**: Dual-stack support (IPv4/IPv6)
- **Private Network**: OVH vRack for inter-instance communication
- **Bandwidth**: 1 Gbps dedicated, unlimited traffic
- **Geographic Location**: Canada (BHS-3) or France (RBX/UL/GRA) datacenter
- **Special Features**: 
  - Anti-DDoS protection (OVH network-level)
  - Global backbone with strong North American presence
  - Direct peering with major cloud providers and content networks
  - Tailscale mesh integration for secure inter-provider connectivity

### Virtualization
- **Hypervisor**: VMware vSphere or KVM (depending on OVH instance type)
- **Virtualization Type**: Full virtualization with hardware acceleration
- **Container Support**: Native container support (Docker/Podman)
- **Nested Virtualization**: Supported for testing scenarios
- **Resource Isolation**: cgroups v2 with systemd slice isolation
- **Network Virtualization**: OVH SDN integration for network isolation

## Optimizations

### Redundancy-Focused Configuration
```nix
# Backup and redundancy optimization
powerManagement = {
  cpuGovernor = "performance";  # Reliable performance
  wlanPowerManagement = false;  # No wireless
  usbPowerManagement = false;  # No USB devices
  diskPowerManagement = "max_performance";  # Never spin down
  thermalManagement = "balanced";  # Data center cooling
};
```

### Backup Service Optimization
```nix
# Backup-specific service configuration
backupServices = {
  # Primary backup target
  rsync = {
    enable = true;
    targetPath = "/var/backup/hetzner-sync";
    sourceHosts = [ "hetzner-vps" ];
    compression = "zstd";
    bandwidthLimit = "800M";  # Leave headroom for other services
    schedule = "0 2 * * *";  # Daily at 2 AM
  };
  
  # Object storage integration
  objectStorage = {
    enable = true;
    provider = "ovh";
    endpoint = "ca.bhs.cloud.ovh.net";
    bucket = "pantheros-backups";
    syncInterval = "weekly";
    encryption = true;
  };
  
  # Cross-region replication
  replication = {
    enable = true;
    source = "hetzner-vps";
    protocol = "rsync-ssh";
    verifyIntegrity = true;
    alertOnFailure = true;
  };
};
```

### Security Hardening
```nix
# Enhanced security for backup server
security = {
  # Kernel hardening
  kernel = {
    disableKernelModules = [ "dccp" "sctp" "rds" "tipc" ];
    sysctl = {
      "net.ipv4.ip_forward" = 0;  # Disable IP forwarding
      "net.ipv6.conf.all.forwarding" = 0;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      "net.ipv4.conf.all.log_martians" = 1;
      "net.ipv6.conf.all.accept_source_route" = 0;
      "kernel.yama.ptrace_scope" = 1;
      "kernel.dmesg_restrict" = 1;
      "kernel.kptr_restrict" = 2;
    };
  };
  
  # SSH hardening
  ssh = {
    permitRootLogin = "no";
    passwordAuthentication = false;
    publicKeyAuthentication = true;
    kbdInteractiveAuthentication = false;
    allowUsers = [ "hbohlen" ];
    ports = [ 22 ];
  };
  
  # Backup-specific security
  backupSecurity = {
    encryptionInTransit = true;
    encryptionAtRest = true;
    keyRotation = "quarterly";
    accessLogging = true;
  };
};
```

### Resource Management
```nix
# Backup and redundancy resource allocation
resources = {
  # Large shared memory for backup operations
  vm.overcommit_memory = 1;
  vm.swappiness = 1;
  vm.vfs_cache_pressure = 25;
  vm.dirty_ratio = 90;
  vm.dirty_background_ratio = 20;
  
  # File system optimization for backup storage
  fileSystems = {
    "/var/backup" = {
      options = [
        "compress=zstd:2"  # Balanced compression for storage
        "noatime"
        "ssd"
        "space_cache=v2"
      ];
    };
    
    "/var/lib/containers" = {
      options = [
        "compress=zstd:1"  # Fast compression for containers
        "noatime"
        "ssd"
        "nodatacow"  # Backup container storage optimization
      ];
    };
  };
};
```

## Disk Layout

### Mirror Server Btrfs Configuration
Based on the [disk layouts architecture](../architecture/disk-layouts.md), ovh-vps mirrors hetzner-vps with redundancy features:

```nix
# OVH VPS mirror layout
disko.devices = {
  disk = {
    "sda" = {
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # BIOS boot partition for compatibility
          bios-boot = {
            size = "1M";
            type = "EF02";
            priority = 1;
          };
          
          # ESP (1GB) - Mirror configuration
          esp = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "umask=0077"
                "fmask=0077"
                "dmask=0077"
              ];
            };
            priority = 2;
          };
          
          # Swap (16GB) - Balanced for backup operations
          swap = {
            size = "16G";
            type = "8200";
            content = {
              type = "swap";
              randomEncryption = true;
            };
            priority = 3;
          };
          
          # Btrfs root with impermanence (mirror)
          root = {
            size = "max";
            type = "8300";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              btrfsConfig = {
                label = "ovh-nixos";
                features = [ "block-group-tree" ];
              };
              
              # Same subvolume structure as hetzner-vps
              subvolumes = [
                # Ephemeral system root
                {
                  name = "root";
                  mountpoint = "/";
                  compress = "zstd:3";
                  persistence = "ephemeral";
                }
                
                # Persistent Nix store
                {
                  name = "nix";
                  mountpoint = "/nix";
                  compress = "zstd:1";
                  neededForBoot = true;
                  persistence = "persistent";
                }
                
                # Persistent application data
                {
                  name = "persist";
                  mountpoint = "/persist";
                  compress = "zstd:3";
                  neededForBoot = true;
                  persistence = "persistent";
                }
                
                # System logs
                {
                  name = "log";
                  mountpoint = "/var/log";
                  compress = "zstd:3";
                  neededForBoot = true;
                  persistence = "important";
                }
                
                # Container storage for backup services
                {
                  name = "containers";
                  mountpoint = "/var/lib/containers";
                  compress = "zstd:1";
                  mountOptions = [ "nodatacow" ];
                  persistence = "service-data";
                }
                
                # Mirror backup storage (primary function)
                {
                  name = "backup";
                  mountpoint = "/var/backup";
                  compress = "zstd:2";
                  neededForBoot = true;
                  persistence = "backup";
                  description = "Primary backup target from hetzner-vps";
                }
                
                # Replication data
                {
                  name = "replication";
                  mountpoint = "/var/lib/replication";
                  compress = "zstd:1";
                  persistence = "replication-data";
                  description = "Cross-region replication and sync data";
                }
                
                # Service-specific data
                {
                  name = "services";
                  mountpoint = "/var/lib/services";
                  compress = "zstd:2";
                  neededForBoot = true;
                  persistence = "service-critical";
                }
                
                # Snapshots for backup recovery
                {
                  name = "snapshots";
                  mountpoint = "/.snapshots";
                  compress = "zstd:3";
                  persistence = "backup-only";
                }
                
                # Impermanence archive
                {
                  name = "old_roots";
                  mountpoint = "/btrfs_tmp/old_roots";
                  compress = "zstd:3";
                  persistence = "temporary";
                  retentionPolicy = "30-days";
                }
              ];
            };
            priority = 4;
          };
        };
      };
    };
  };
};
```

### Backup and Replication Configuration
```nix
# Cross-provider backup and synchronization
crossProviderSync = {
  # Primary sync with Hetzner VPS
  primarySync = {
    enable = true;
    sourceHost = "hetzner-vps";
    sourceProtocol = "rsync-ssh";
    bandwidthLimit = "800M";  # Leave headroom
    compression = "zstd";
    encryption = true;
    schedule = "0 2 * * *";  # Daily sync at 2 AM
    integrityCheck = true;
  };
  
  # Incremental backup strategy
  incremental = {
    enable = true;
    fullBackup = "weekly";  # Full backup weekly
    incremental = "daily";  # Incremental daily
    retention = "30 days";  # 30-day retention
    compression = "zstd:2";  # Balanced compression
  };
  
  # Object storage sync
  objectStorage = {
    enable = true;
    provider = "ovh";
    bucket = "pantheros-disaster-recovery";
    syncInterval = "weekly";
    encryption = true;
    crossRegion = true;
  };
};
```

### Monitoring and Alerting
```nix
# Backup-focused monitoring
backupMonitoring = {
  # Sync status monitoring
  syncStatus = {
    enable = true;
    checkInterval = "5min";
    alertThreshold = "30min";
    notifyEmail = "admin@pantherOS.dev";
  };
  
  # Storage health monitoring
  storage = {
    enable = true;
    diskUsageAlert = 80;  # Alert at 80% capacity
    ioPerformanceCheck = true;
    smartHealthCheck = true;
  };
  
  # Cross-provider connectivity
  connectivity = {
    enable = true;
    targetHost = "hetzner-vps";
    checkInterval = "1min";
    failoverAlert = true;
  };
};
```

## Backup Services

### Primary Backup Services
```nix
# Cross-provider backup orchestration
services.backupOrchestrator = {
  enable = true;
  
  # Backup configuration
  backupJobs = [
    {
      name = "hetzner-daily";
      source = "hetzner-vps:/var/backup";
      target = "/var/backup/hetzner-sync";
      schedule = "0 2 * * *";  # Daily at 2 AM
      compression = "zstd";
      verifyIntegrity = true;
    }
    
    {
      name = "persistent-data-sync";
      source = "hetzner-vps:/persist";
      target = "/var/backup/hetzner-persist";
      schedule = "0 3 * * *";  # Daily at 3 AM
      compression = "zstd:3";
      encryption = true;
    }
    
    {
      name = "weekly-full-backup";
      source = "hetzner-vps:/";
      target = "/var/backup/hetzner-full";
      schedule = "0 1 * * 0";  # Weekly Sunday at 1 AM
      compression = "zstd:2";
      excludePaths = [
        "/proc"
        "/sys"
        "/dev"
        "/tmp"
        "/run"
      ];
    }
  ];
  
  # Retention policies
  retention = {
    daily = "7 days";
    weekly = "4 weeks";
    monthly = "12 months";
    yearly = "7 years";
  };
};
```

### Disaster Recovery Services
```nix
# Disaster recovery capabilities
disasterRecovery = {
  enable = true;
  
  # Service replication
  servicesReplication = {
    enable = true;
    replicatedServices = [
      "caddy"
      "tailscale"
      "ssh"
      "backup-services"
    ];
    
    # Health checks
    healthCheck = {
      interval = "30s";
      timeout = "10s";
      retries = 3;
    };
    
    # Failover configuration
    failover = {
      automatic = true;
      threshold = "3 consecutive failures";
      notification = true;
    };
  };
  
  # Emergency restore procedures
  emergencyRestore = {
    procedures = [
      {
        name = "service-migration";
        trigger = "hetzner-vps-unavailable";
        action = "migrate-services-to-ovh";
      }
      {
        name = "data-restore";
        trigger = "data-corruption-detected";
        action = "restore-from-backup";
      }
    ];
  };
};
```

## Known Issues

### Geographic and Network Issues
- **Cross-Provider Latency**: Network latency between OVH and Hetzner datacenters
  - **Impact**: Slower backup sync, potential timeouts on large transfers
  - **Mitigation**: Incremental transfers, compression, retry logic
- **Bandwidth Limitations**: 1 Gbps may limit backup window completion
  - **Solution**: Schedule backups during off-peak hours, use compression
- **DDoS Protection**: OVH DDoS protection may interfere with backup traffic
  - **Monitoring**: Monitor backup success rates and adjust if needed

### Storage Considerations
- **Storage Capacity**: 600GB may limit retention periods for large backups
  - **Management**: Regular cleanup, compression, external storage integration
- **IOPS Limitations**: Shared storage environment may have IOPS contention
  - **Optimization**: Use compression to reduce I/O requirements
- **Single Drive**: No RAID redundancy for backup storage
  - **Solution**: External backup replication, regular backup verification

### Virtualization Platform Issues
- **Hypervisor Differences**: OVH may use VMware while Hetzner uses KVM
  - **Impact**: Minor performance differences, potential compatibility issues
  - **Mitigation**: Container-based workloads to minimize platform differences
- **Resource Contention**: Shared hypervisor resources may affect performance
  - **Monitoring**: Monitor resource usage and adjust if needed

### Backup-Specific Challenges
- **Backup Window**: Limited time window for daily backups
  - **Solution**: Incremental backups, compression, bandwidth optimization
- **Data Verification**: Ensuring backup integrity across providers
  - **Solution**: Checksums, regular restore testing, automated verification
- **Cost Management**: Cross-provider data transfer costs
  - **Optimization**: Minimize unnecessary transfers, local caching

### Security Considerations
- **Cross-Provider Encryption**: Secure data transfer between providers
  - **Implementation**: SSH tunnel encryption, AES-256 at rest
- **Access Control**: Managing access across multiple providers
  - **Solution**: Tailscale authentication, key rotation policies
- **Compliance**: Data residency and compliance requirements
  - **Monitoring**: Track data locations and compliance status

## Performance Characteristics

### Expected Server Performance
```bash
# CPU Performance (Xeon Gold 6142)
Geekbench 6 Single-Core: ~1400-1600 points
Geekbench 6 Multi-Core: ~15000-18000 points
CPU Mark: ~18000-22000

# Memory Performance (64GB DDR4-2933 ECC)
Memory Bandwidth: ~150 GB/s
Memory Latency: 80-90ns
ECC Error Rate: <1 error per 10^18 bits

# Storage Performance (600GB NVMe)
Sequential Read: 2500 MB/s
Sequential Write: 1800 MB/s
Random Read IOPS: 80K
Random Write IOPS: 65K

# Network Performance (1 Gbps)
Network Throughput: ~940 Mbps sustained
Latency to EU: 80-120ms (OVH EU to Hetzner EU)
Latency to US: 1-5ms (OVH US to continental US)
Latency to Hetzner: 100-150ms (depending on regions)

# Backup Performance
Daily Backup Throughput: 200-400 GB/day
Full Backup Time: 6-12 hours (depending on data volume)
Incremental Sync: 1-3 hours typical
Compression Ratio: 40-60% (depends on data type)
```

### Backup and Sync Benchmarks
```bash
# Cross-provider synchronization
rsync Performance: 300-600 Mbps sustained
Compressed Transfer: 400-800 Mbps
SSH Encryption Overhead: 10-20%
Sync Success Rate: 99.5%+

# Storage efficiency
Compression Efficiency: 40-60% space savings
Deduplication: 10-30% for similar data
Storage Retention: 30 days daily, 12 months weekly
```

### Service Performance (as backup target)
```bash
# When serving as primary server
SSH Sessions: 100+ concurrent
HTTP Proxy: 5,000+ RPS
Database Queries: 50,000+ QPS
Container Startup: 3-8 seconds
```

## Configuration References

### Related Architecture Documents
- [System Architecture Overview](../architecture/overview.md)
- [Host Classification System](../architecture/host-classification.md)
- [Disk Layouts Strategy](../architecture/disk-layouts.md)
- [Security Model](../architecture/security-model.md)
- [Impermanence Integration Specification](../../openspec/changes/btrfs-impermanence-layout/specs/)

### Hardware Discovery Guide
- [Hardware Discovery Process](../guides/hardware-discovery.md)
- [Host Configuration Guide](../guides/host-configuration.md)
- [Testing and Deployment](../guides/testing-deployment.md)

### Configuration Files
- **Disk Layout**: `../../hosts/servers/ovh-cloud/disko.nix`
- **System Configuration**: `../../hosts/servers/ovh-cloud/default.nix`
- **Hardware Configuration**: `../../hosts/servers/ovh-cloud/hardware.nix`

### OpenSpec Specifications
- [Impermanence Layout Specification](../../openspec/changes/btrfs-impermanence-layout/specs/)
- [NixOS Base Configuration for Redundant Servers](../../openspec/changes/nixos-base-hetzner-vps/specs/)

### Cross-Provider Integration
- [Backup Orchestrator Design](../../openspec/changes/backup-orchestrator/specs/)
- [Disaster Recovery Procedures](../guides/troubleshooting.md#disaster-recovery)

---

**Maintained by:** hbohlen  
**Last Updated:** 2025-11-20  
**Version:** 1.0