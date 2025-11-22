# Server Btrfs Impermanence Implementation Proposal

**Change ID**: server-btrfs-impermanence  
**Type**: Architecture (Storage System)  
**Status**: Draft  
**Created**: 2025-11-21  
**Author**: hbohlen  

## Executive Summary

This proposal outlines the implementation of a research-backed Btrfs subvolume layout with impermanence specifically optimized for server environments, targeting the Hetzner VPS deployment. The solution provides clean state management, atomic snapshots, and optimized storage for production server workloads while maintaining data persistence and service continuity.

## Problem Statement

### Current State
- Documentation exists for Btrfs layouts and Hetzner VPS hardware specifications
- Detailed disk layout planned but no impermanence implementation
- Server-specific optimization needs are not fully addressed
- No automated snapshot management for production workloads

### Challenges to Address
1. **Server Workload Optimization**: Current layouts are workstation-focused
2. **State Management**: No clean separation between ephemeral and persistent data
3. **Snapshot Strategy**: No automated backup/retention for production
4. **Container Performance**: Suboptimal Btrfs settings for containerized databases
5. **Recovery Procedures**: Limited rollback capabilities for server emergencies

## Research Findings

### Btrfs Best Practices for Servers (2024)

Based on community research and production deployments:

#### Subvolume Strategy
- **Flat Layout Preferred**: Avoid nested subvolumes for atomic snapshots
- **Separation of Concerns**: Different subvolumes for different data lifecycles
- **Performance Optimization**: `nodatacow` for high-write workloads (databases, containers)
- **Compression Strategy**: Balanced approach based on access patterns

#### Mount Options Research
```bash
# Server-optimized universal options
"compress=zstd:1"          # Fast compression for frequently accessed data
"compress=zstd:3"          # Maximum compression for infrequently accessed data
"noatime"                   # Reduce metadata writes
"ssd"                       # SSD optimizations
"space_cache=v2"             # Efficient space management
"discard=async"               # Non-blocking TRIM
"nodatacow"                  # For databases and containers
```

#### Impermanence Patterns
- **Btrfs Snapshots**: More efficient than tmpfs for servers with ample storage
- **Clean State Recovery**: Snapshot-based rollback vs bind mounts
- **Persistent Data Isolation**: Separate subvolumes for critical data
- **Automated Cleanup**: Retention policies for old root snapshots

### Production Server Requirements
1. **Service Continuity**: Zero-downtime snapshot operations
2. **Data Integrity**: Checksums and atomic operations
3. **Performance**: Optimized for I/O-bound workloads
4. **Recovery**: Quick rollback from service failures
5. **Monitoring**: Integration with existing observability

## Proposed Solution

### Architecture Overview

```
┌─────────────────────────────────────────┐
│           BTRFS ROOT (800GB)        │
├─────────────────────────────────────────┤
│  IMPERMANENT SUBVOLUMES             │
│  ├─ /nix           (Package Store)    │
│  ├─ /persist       (Persistent Data)   │
│  ├─ /var/log       (System Logs)      │
│  ├─ /var/lib/services (Service Data)   │
│  ├─ /var/lib/caddy   (SSL/Certs)     │
│  ├─ /var/backup     (Backup Storage)   │
│  └─ /var/lib/containers (Container Data)│
├─────────────────────────────────────────┤
│  EPHEMERAL SUBVOLUMES              │
│  ├─ /root          (System Root)     │
│  ├─ /var/cache      (App Caches)     │
│  ├─ /var/tmp        (Temp Storage)    │
│  └─ /btrfs_tmp/old_roots (Archive)   │
└─────────────────────────────────────────┘
```

### Implementation Components

#### 1. Enhanced Disko Configuration

**File**: `hosts/servers/hetzner-vps/disko.nix`

```nix
{ config, lib, ... }:

{
  disko.devices = {
    disk = {
      "sda" = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition
            bios-boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            
            # ESP for UEFI boot
            esp = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077" "fmask=0077" "dmask=0077"
                ];
              };
              priority = 2;
            };
            
            # Encrypted swap (32GB)
            swap = {
              size = "32G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
              };
              priority = 3;
            };
            
            # Btrfs root with server-optimized subvolumes
            root = {
              size = "max";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                btrfsConfig = {
                  label = "hetzner-nixos";
                  features = [ "block-group-tree" ];
                };
                
                subvolumes = [
                  # ===== PERMANENT SUBVOLUMES =====
                  # Critical system data that survives reboots
                  {
                    name = "nix";
                    mountpoint = "/nix";
                    compress = "zstd:1";  # Fast access for packages
                    neededForBoot = true;
                    persistence = "critical";
                  }
                  
                  {
                    name = "persist";
                    mountpoint = "/persist";
                    compress = "zstd:3";  # Max compression for config
                    neededForBoot = true;
                    persistence = "critical";
                  }
                  
                  {
                    name = "log";
                    mountpoint = "/var/log";
                    compress = "zstd:3";  # Compress logs well
                    neededForBoot = true;
                    persistence = "important";
                  }
                  
                  {
                    name = "services";
                    mountpoint = "/var/lib/services";
                    compress = "zstd:2";  # Balanced for service data
                    neededForBoot = true;
                    persistence = "service-critical";
                  }
                  
                  {
                    name = "caddy";
                    mountpoint = "/var/lib/caddy";
                    compress = "zstd:3";  # SSL certs compress well
                    neededForBoot = true;
                    persistence = "critical";
                  }
                  
                  {
                    name = "backup";
                    mountpoint = "/var/backup";
                    compress = "zstd:3";  # Max compression for backups
                    persistence = "backup";
                  }
                  
                  {
                    name = "containers";
                    mountpoint = "/var/lib/containers";
                    compress = "zstd:1";  # Fast for container I/O
                    mountOptions = [ "nodatacow" ];  # Critical for DBs
                    persistence = "service-data";
                  }
                  
                  # ===== EPHEMERAL SUBVOLUMES =====
                  # Reset on each boot via impermanence
                  {
                    name = "root";
                    mountpoint = "/";
                    compress = "zstd:3";
                    persistence = "ephemeral";
                  }
                  
                  {
                    name = "cache";
                    mountpoint = "/var/cache";
                    compress = "zstd:3";
                    persistence = "temporary";
                  }
                  
                  {
                    name = "tmp";
                    mountpoint = "/var/tmp";
                    compress = "zstd:1";
                    mountOptions = [ "nodatacow" ];
                    persistence = "temporary";
                  }
                  
                  # ===== ARCHIVE SUBVOLUMES =====
                  {
                    name = "snapshots";
                    mountpoint = "/.snapshots";
                    compress = "zstd:3";
                    persistence = "backup-only";
                  }
                  
                  {
                    name = "old_roots";
                    mountpoint = "/btrfs_tmp/old_roots";
                    compress = "zstd:3";
                    persistence = "archive";
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
}
```

#### 2. Advanced Impermanence Module

**File**: `modules/shared/filesystems/server-impermanence.nix`

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.serverImpermanence;
in
{
  options.pantherOS.serverImpermanence = {
    enable = mkEnableOption "Server-optimized impermanence with Btrfs snapshots";
    
    excludePaths = mkOption {
      type = types.listOf types.str;
      default = [
        "/persist"
        "/nix"
        "/var/log"
        "/var/lib/services"
        "/var/lib/caddy"
        "/var/backup"
        "/var/lib/containers"
        "/btrfs_tmp"
      ];
      description = "Paths to preserve across reboots";
    };
    
    snapshotPolicy = mkOption {
      type = types.attrsOf types.str;
      default = {
        frequency = "6h";     # Every 6 hours
        retention = "30d";    # 30 days retention
        scope = "critical";   # Only critical subvolumes
      };
      description = "Automated snapshot policy";
    };
    
    performanceMode = mkOption {
      type = types.enum [ "balanced" "io-optimized" "space-optimized" ];
      default = "balanced";
      description = "Performance tuning mode for server workloads";
    };
  };
  
  config = mkIf cfg.enable {
    # Pre-boot impermanence setup
    systemd.services."server-impermanence-setup" = {
      enable = true;
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      
      script = let
        timestamp = "date +%Y%m%d-%H%M%S";
        excludePaths = concatStringsSep " " cfg.excludePaths;
      in ''
        #!/bin/sh
        set -e
        
        echo "Starting server impermanence setup"
        echo "Performance mode: ${cfg.performanceMode}"
        
        # Backup current root if it exists and isn't empty
        if [ -d "/root" ] && [ "$(ls -A /root 2>/dev/null)" ]; then
          echo "Creating backup snapshot: root-$(date +%Y%m%d-%H%M%S)"
          btrfs subvolume snapshot / /btrfs_tmp/old_roots/root-$(date +%Y%m%d-%H%M%S)
        fi
        
        # Delete existing root (will be recreated)
        btrfs subvolume delete / || true
        
        # Create new clean root
        btrfs subvolume create /root
        
        # Restore persistent data
        for path in ${excludePaths}; do
          if [ -e "$path" ]; then
            echo "Preserving $path"
            mkdir -p "/root$path"
            cp -a "$path" "/root$path"
          fi
        done
        
        # Apply performance optimizations
        case "${cfg.performanceMode}" in
          "io-optimized")
            echo "Applying I/O optimizations"
            # Tune for database/container workloads
            echo 8192 > /proc/sys/vm/dirty_background_ratio
            echo 160 > /proc/sys/vm/dirty_ratio
            echo 5 > /proc/sys/vm/vfs_cache_pressure
            ;;
          "space-optimized")
            echo "Applying space optimizations"
            # Aggressive compression settings
            btrfs property set /root compression=zstd:3
            ;;
          "balanced"|*)
            echo "Applying balanced optimizations"
            # Default balanced settings
            ;;
        esac
        
        echo "Server impermanence setup completed"
      '';
    };
    
    # Automated snapshot service
    systemd.services."server-snapshots" = {
      enable = true;
      serviceConfig = {
        Type = "oneshot";
      };
      
      script = ''
        #!/bin/sh
        set -e
        
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        SNAPDIR="/.snapshots"
        
        # Create snapshots directory
        mkdir -p $SNAPDIR
        
        # Snapshot critical subvolumes
        echo "Creating server snapshots at $TIMESTAMP"
        
        # Root snapshot (for rollback)
        btrfs subvolume snapshot -r / $SNAPDIR/root-$TIMESTAMP
        
        # Persistent data snapshots
        if [ "${cfg.snapshotPolicy.scope}" = "critical" ] || [ "${cfg.snapshotPolicy.scope}" = "all" ]; then
          btrfs subvolume snapshot -r /persist $SNAPDIR/persist-$TIMESTAMP
          btrfs subvolume snapshot -r /var/lib/services $SNAPDIR/services-$TIMESTAMP
          btrfs subvolume snapshot -r /var/lib/caddy $SNAPDIR/caddy-$TIMESTAMP
        fi
        
        echo "Snapshots created: $TIMESTAMP"
      '';
    };
    
    # Snapshot timer based on policy
    systemd.timers."server-snapshots" = {
      enable = true;
      timerConfig = {
        OnCalendar = cfg.snapshotPolicy.frequency;
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    
    # Snapshot cleanup service
    systemd.services."server-snapshots-cleanup" = {
      enable = true;
      after = [ "server-snapshots.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
      
      script = let
        retentionDays = cfg.snapshotPolicy.retention;
      in ''
        #!/bin/sh
        set -e
        
        echo "Cleaning old snapshots (retention: ${retentionDays})"
        
        # Clean root snapshots
        find /.snapshots -name "root-*" -type d -mtime +${retentionDays} -exec btrfs subvolume delete {} \; 2>/dev/null || true
        
        # Clean persistent snapshots
        if [ "${cfg.snapshotPolicy.scope}" = "critical" ] || [ "${cfg.snapshotPolicy.scope}" = "all" ]; then
          find /.snapshots -name "persist-*" -type d -mtime +${retentionDays} -exec btrfs subvolume delete {} \; 2>/dev/null || true
          find /.snapshots -name "services-*" -type d -mtime +${retentionDays} -exec btrfs subvolume delete {} \; 2>/dev/null || true
          find /.snapshots -name "caddy-*" -type d -mtime +${retentionDays} -exec btrfs subvolume delete {} \; 2>/dev/null || true
        fi
        
        # Clean old root archives
        find /btrfs_tmp/old_roots -name "root-*" -type d -mtime +30 -exec btrfs subvolume delete {} \; 2>/dev/null || true
        
        echo "Snapshot cleanup completed"
      '';
    };
    
    # Cleanup timer (daily)
    systemd.timers."server-snapshots-cleanup" = {
      enable = true;
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    
    # Btrfs maintenance service
    systemd.services."btrfs-maintenance" = {
      enable = true;
      serviceConfig = {
        Type = "oneshot";
      };
      
      script = ''
        #!/bin/sh
        set -e
        
        echo "Running Btrfs maintenance"
        
        # Balance filesystem (monthly)
        if [ $(date +%d) = "01" ]; then
          echo "Balancing Btrfs filesystem"
          btrfs balance start /
        fi
        
        # Scrub for data integrity (weekly)
        if [ $(date +%u) = "0" ]; then
          echo "Scrubbing Btrfs filesystem for data integrity"
          btrfs scrub start /
        fi
        
        echo "Btrfs maintenance completed"
      '';
    };
    
    # Maintenance timer
    systemd.timers."btrfs-maintenance" = {
      enable = true;
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    
    # Required packages
    environment.systemPackages = with pkgs; [
      btrfs-progs
      coreutils
      findutils
    ];
    
    # Kernel parameters for server optimization
    boot.kernel.sysctl = {
      # Btrfs performance tuning
      "vm.vfs_cache_pressure" = mkIf (cfg.performanceMode == "io-optimized") 50;
      "vm.dirty_ratio" = mkIf (cfg.performanceMode == "io-optimized") 80;
      "vm.dirty_background_ratio" = mkIf (cfg.performanceMode == "io-optimized") 15;
      
      # General server optimizations
      "vm.swappiness" = 1;
      "vm.overcommit_memory" = 1;
    };
  };
}
```

#### 3. Integration Module

**File**: `modules/shared/filesystems/server-btrfs.nix`

```nix
{ config, lib, ... }:

{
  imports = [
    ./server-impermanence.nix
  ];
  
  config = {
    # Universal Btrfs mount options for servers
    fileSystems = {
      "/" = {
        options = [
          "compress=zstd:3"
          "noatime"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=root"
        ];
      };
      
      "/nix" = {
        options = [
          "compress=zstd:1"
          "noatime"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=nix"
        ];
      };
      
      "/persist" = {
        options = [
          "compress=zstd:3"
          "noatime"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=persist"
        ];
      };
      
      "/var/log" = {
        options = [
          "compress=zstd:3"
          "noatime"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=log"
        ];
      };
      
      "/var/lib/containers" = {
        options = [
          "compress=zstd:1"
          "noatime"
          "nodatacow"
          "nodatasum"
          "ssd"
          "space_cache=v2"
          "discard=async"
          "subvol=containers"
        ];
      };
    };
    
    # Enable Btrfs quota support for multi-tenant isolation
    services.btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/" ];
    };
  };
}
```

#### 4. Host Configuration Integration

**File**: `hosts/servers/hetzner-vps/default.nix` (additions)

```nix
{ config, lib, ... }:

{
  imports = [
    ./disko.nix
    ./hardware.nix
    ../../modules/shared/filesystems/server-btrfs.nix
    inputs.opnix.nixosModules.default
  ];
  
  # Enable server-optimized impermanence
  pantherOS.serverImpermanence = {
    enable = true;
    performanceMode = "io-optimized";  # Optimized for container/database workloads
    snapshotPolicy = {
      frequency = "6h";      # Every 6 hours
      retention = "30d";     # 30-day retention
      scope = "critical";     # Critical subvolumes only
    };
  };
  
  # Additional server-specific configurations
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    
    # Enable Btrfs in initrd for early boot
    initrd = {
      enable = true;
      supportedFilesystems = [ "btrfs" ];
    };
  };
  
  # Container optimization
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    
    # Server-optimized settings
    defaultMemory = "4G";
    defaultCpuPeriod = 100000;
    defaultCpuQuota = 400;  # 4 cores per container
    
    storage = {
      driver = "overlay";
      runRoot = "/var/lib/containers/run";
      graphRoot = "/var/lib/containers/storage";
      options = [
        "overlay.mountopt=nodev,metacopy=on"
      ];
    };
  };
  
  # System monitoring integration
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" "diskstats" "filesystem" ];
      };
    };
  };
  
  # Alert integration for snapshot failures
  services.alertmanager = {
    enable = true;
    configuration = {
      route = {
        group_by = [ "alertname" ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "12h";
        receiver = "web.hook";
      };
    };
  };
}
```

## Implementation Plan

### Phase 1: Foundation (Week 1)
1. **Create server-impermanence module**
   - Implement Btrfs snapshot-based impermanence
   - Add performance tuning options
   - Create automated snapshot services

2. **Enhance disko configuration**
   - Update Hetzner VPS disko.nix with server-optimized subvolumes
   - Add proper mount options for each workload type
   - Implement persistent/ephemeral separation

3. **Integration testing**
   - Build configuration validation
   - Test impermanence setup in isolated environment
   - Verify snapshot creation and cleanup

### Phase 2: Automation (Week 2)
1. **Snapshot automation**
   - Implement systemd timers for automated snapshots
   - Add retention policy enforcement
   - Create cleanup procedures for old snapshots

2. **Performance optimization**
   - Add I/O-optimized kernel parameters
   - Implement Btrfs maintenance (balance, scrub)
   - Tune for container/database workloads

3. **Monitoring integration**
   - Add metrics for snapshot operations
   - Create alerts for impermanence failures
   - Integrate with existing observability stack

### Phase 3: Production Deployment (Week 3)
1. **Staging deployment**
   - Deploy to test environment
   - Validate all functionality
   - Performance benchmarking

2. **Production deployment**
   - Deploy to Hetzner VPS
   - Monitor initial operations
   - Validate rollback procedures

3. **Documentation and training**
   - Update operational procedures
   - Create troubleshooting guides
   - Team training on new system

## Benefits Analysis

### Operational Benefits
1. **Clean State Management**: Eliminates configuration drift
2. **Fast Recovery**: Atomic snapshots for quick rollback
3. **Automated Maintenance**: Self-managing snapshot lifecycle
4. **Performance Optimization**: Tuned for server workloads
5. **Data Integrity**: Btrfs checksums and scrubbing

### Business Benefits
1. **Reduced Downtime**: Faster recovery from failures
2. **Operational Efficiency**: Automated state management
3. **Risk Mitigation**: Multiple recovery paths
4. **Scalability**: Pattern applies to additional servers
5. **Cost Optimization**: Efficient storage utilization

### Technical Benefits
1. **I/O Performance**: Optimized for database/container workloads
2. **Storage Efficiency**: Intelligent compression strategies
3. **Reliability**: Automated integrity checking
4. **Maintainability**: Declarative, reproducible setup
5. **Observability**: Integrated monitoring and alerting

## Risk Assessment

### Technical Risks
| Risk | Impact | Probability | Mitigation |
|-------|---------|------------|------------|
| Snapshot corruption | High | Low | Regular integrity checks, multiple snapshots |
| Performance overhead | Medium | Low | Performance tuning, monitoring |
| Complexity increase | Medium | Medium | Documentation, training |
| Storage consumption | Medium | High | Automated cleanup, retention policies |

### Operational Risks
| Risk | Impact | Probability | Mitigation |
|-------|---------|------------|------------|
| Deployment failure | High | Low | Staging testing, rollback plan |
| Data loss | Critical | Very Low | Multiple backup layers, testing |
| Service disruption | Medium | Low | Maintenance windows, communication |
| Learning curve | Medium | Medium | Documentation, training |

## Success Metrics

### Technical Metrics
- [ ] Snapshot creation time < 30 seconds
- [ ] Rollback time < 2 minutes
- [ ] Storage overhead < 15%
- [ ] I/O performance improvement > 20%
- [ ] System uptime > 99.9%

### Operational Metrics
- [ ] Zero data loss incidents
- [ ] Mean time to recovery < 5 minutes
- [ ] Automated maintenance coverage > 95%
- [ ] Documentation completeness > 90%
- [ ] Team proficiency > 80%

### Business Metrics
- [ ] Reduced downtime costs > 50%
- [ ] Operational efficiency gain > 30%
- [ ] Risk mitigation effectiveness > 90%
- [ ] Scalability to additional servers
- [ ] Positive user feedback > 85%

## Testing Strategy

### Unit Testing
1. **Module testing**: Individual module validation
2. **Configuration testing**: Syntax and logic verification
3. **Snapshot testing**: Creation, restoration, cleanup
4. **Performance testing**: I/O benchmarks and optimization

### Integration Testing
1. **End-to-end workflows**: Complete impermanence cycle
2. **Service integration**: Container, database, application compatibility
3. **Monitoring integration**: Metrics and alert validation
4. **Recovery testing**: Rollback and emergency procedures

### Production Testing
1. **Staging environment**: Full production simulation
2. **Load testing**: Performance under realistic workloads
3. **Failover testing**: Recovery from various failure scenarios
4. **Long-term testing**: Extended operation validation

## Documentation Plan

### Technical Documentation
1. **Architecture diagrams**: System design and data flow
2. **Configuration guides**: Setup and customization
3. **Operational procedures**: Daily and maintenance tasks
4. **Troubleshooting guides**: Common issues and solutions

### User Documentation
1. **Quick start guide**: Initial deployment steps
2. **Best practices**: Optimization and usage tips
3. **FAQ**: Common questions and answers
4. **Training materials**: Team education resources

## Maintenance Plan

### Regular Maintenance
1. **Daily**: Snapshot monitoring and log review
2. **Weekly**: Performance analysis and optimization
3. **Monthly**: Btrfs maintenance and cleanup
4. **Quarterly**: System review and updates

### Continuous Improvement
1. **Performance tuning**: Ongoing optimization based on metrics
2. **Feature enhancement**: New capabilities based on needs
3. **Documentation updates**: Keep current with system changes
4. **Training updates**: Maintain team proficiency

## Conclusion

This proposal delivers a comprehensive, research-backed Btrfs impermanence solution specifically optimized for server environments. The implementation provides:

- **Production-ready reliability** with automated snapshot management
- **Performance optimization** for I/O-bound server workloads
- **Operational efficiency** through automated state management
- **Risk mitigation** via multiple recovery paths
- **Scalability** for additional server deployments

The solution addresses current limitations while establishing a foundation for future growth. With proper implementation and monitoring, this system will significantly improve server reliability, reduce operational overhead, and provide a robust platform for production services.

## Next Steps

1. **Review and approve** this proposal with stakeholders
2. **Allocate resources** for implementation phases
3. **Establish timeline** with specific milestones
4. **Begin Phase 1** foundation implementation
5. **Regular progress reviews** and course corrections

---

**Proposal Status**: Draft - Pending Review  
**Estimated Implementation**: 3 weeks  
**Required Resources**: 1 senior developer, 1 DevOps engineer  
**Budget Impact**: Minimal (uses existing infrastructure)  

**Contact**: hbohlen  
**Last Updated**: 2025-11-21