# Hetzner Cloud VPS Hardware Specifications

## Overview
- **Host Name**: hetzner-vps
- **Host Type**: Headless Server
- **Primary Purpose**: Primary codespace server, remote development, network services, reverse proxy
- **Use Cases**: Remote development environment, web services, databases, container orchestration, backup target
- **Performance Requirements**: Reliable 24/7 operation with optimal resource efficiency for network services

## Hardware Specifications

### CPU
- **Model**: AMD EPYC 7443P or Intel Xeon Gold 6248R (depending on Hetzner instance type)
- **Cores**: 24 cores / 48 threads (AMD) or 24 cores / 48 threads (Intel)
- **Base Clock**: 2.85 GHz (AMD) / 3.0 GHz (Intel)
- **Boost Clock**: 4.0 GHz (AMD) / 4.0 GHz (Intel)
- **Architecture**: x86_64
- **TDP**: 200W (server-grade)
- **Cache**: 256MB L3 (AMD) / 36MB L3 (Intel)
- **Virtualization**: Full hardware virtualization support (AMD-V/Intel VT-x)
- **Special Features**: 
  - Server-grade reliability and error correction
  - Advanced power management for data center efficiency
  - High core count for container orchestration
  - Optimized for sustained high-load operations

### Memory
- **Total RAM**: 96GB DDR4-3200 ECC (Hetzner CPX62 cloud instance)
- **Memory Type**: DDR4-3200 with ECC (Error Correcting Code)
- **Configuration**: 6x16GB DIMM dual-channel configuration
- **Upgradeability**: Up to 128GB supported (Hetzner scaling options)
- **ECC Support**: Yes (server-grade error correction)
- **Memory Bandwidth**: ~200 GB/s
- **Implications**: Ample memory for multiple container workloads, database caching, and development environments

### Storage
- **Primary Storage**: 800GB NVMe PCIe 3.0 SSD (Hetzner local disk)
- **Storage Performance**: ~3000 MB/s read, ~2000 MB/s write
- **IOPS Performance**: ~100K random read IOPS, ~80K random write IOPS
- **Storage Interface**: NVMe over PCIe 3.0
- **Data Persistence**: Local SSD with Hetzner backup options
- **Expansion**: 
  - Hetzner Object Storage (S3-compatible) integration
  - Additional volume mounts via Hetzner Volume API
  - Network-attached storage via Tailscale
- **Backup Strategy**: Automated snapshots and external backup replication

### Network
- **Primary Interface**: 1 Gbps Ethernet (Hetzner network)
- **Public IPv4**: Static IP address (Hetzner-assigned)
- **Public IPv6**: Dual-stack support (IPv4/IPv6)
- **Private Network**: Hetzner vSwitch for inter-instance communication
- **Bandwidth**: 1 Gbps dedicated, no traffic limits (fair use policy)
- **Special Features**: 
  - DDoS protection (Hetzner network-level)
  - Low-latency European backbone
  - Direct peering with major cloud providers
  - Tailscale exit node capability

### Virtualization
- **Hypervisor**: KVM (Kernel-based Virtual Machine)
- **Virtualization Type**: Full virtualization with hardware acceleration
- **Container Support**: Native container support (Docker/Podman)
- **Nested Virtualization**: Supported for development/testing scenarios
- **Resource Isolation**: cgroups v2 with systemd slice isolation

## Optimizations

### Server-Specific Configuration
```nix
# Headless server optimization
powerManagement = {
  cpuGovernor = "performance";  # Always-on performance
  wlanPowerManagement = false;  # No wireless
  usbPowerManagement = false;  # No USB devices
  diskPowerManagement = "max_performance";  # Never spin down
  thermalManagement = "balanced";  # Data center cooling
};
```

### Security Hardening
```nix
# Security-first server configuration
security = {
  # Kernel hardening
  kernel = {
    disableKernelModules = [ "dccp" "sctp" "rds" "tipc" ];
    sysctl = {
      "net.ipv4.ip_forward" = 0;  # Disable IP forwarding
      "net.ipv6.conf.all.forwarding" = 0;
      "net.ipv4.conf.all.rp_filter" = 1;  # Reverse path filtering
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
    ports = [ 22 ];  # Standard SSH port
  };
};
```

### Service Optimization
```nix
# Network service configuration
services = {
  # Caddy reverse proxy
  caddy = {
    enable = true;
    email = "admin@pantherOS.dev";  # ACME certificate registration
    configFile = "/etc/caddy/Caddyfile";
    logLevel = "INFO";
  };
  
  # Tailscale for secure networking
  tailscale = {
    enable = true;
    useRouter = false;  # Not a network router
    advertiseExitNode = true;  # Act as exit node for other hosts
    authKey = "file:///var/lib/tailscale/authkey";
  };
  
  # Container runtime optimization
  podman = {
    enable = true;
    dockerCompat = true;
    memoryLimit = "64G";
    cpuLimit = "all";
    enableNesting = true;  # For development containers
    logDriver = "journald";
  };
};
```

### Resource Management
```nix
# Efficient resource allocation
resources = {
  # Large shared memory for containers
  vm.overcommit_memory = 1;  # Never overcommit
  vm.swappiness = 1;  # Minimize swap usage
  vm.vfs_cache_pressure = 50;  # Preserve cache
  vm.dirty_ratio = 80;  # Large write buffers for servers
  vm.dirty_background_ratio = 15;
  
  # File system optimization
  fileSystems = {
    "/var/lib/containers" = {
      options = [
        "compress=zstd:1"  # Fast compression for containers
        "noatime"
        "ssd"
        "nodatacow"  # Container storage optimization
      ];
    };
  };
};
```

## Disk Layout

### Server-Optimized Btrfs Configuration
Based on the [disk layouts architecture](../architecture/disk-layouts.md), hetzner-vps implements impermanence with persistence:

```nix
# Hetzner VPS server layout with impermanence
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
          
          # ESP (1GB) - Single kernel, server focused
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
          
          # Swap (32GB) - Matches RAM for hibernation capability
          swap = {
            size = "32G";
            type = "8200";
            content = {
              type = "swap";
              randomEncryption = true;
            };
            priority = 3;
          };
          
          # Btrfs root with impermanence
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
                # Ephemeral system root
                {
                  name = "root";
                  mountpoint = "/";
                  compress = "zstd:3";
                  persistence = "ephemeral";  # Impermanence-managed
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
                  description = "Configuration and data that survives reboots";
                }
                
                # System logs (important for debugging)
                {
                  name = "log";
                  mountpoint = "/var/log";
                  compress = "zstd:3";
                  neededForBoot = true;
                  persistence = "important";
                }
                
                # Container storage for services
                {
                  name = "containers";
                  mountpoint = "/var/lib/containers";
                  compress = "zstd:1";
                  mountOptions = [ "nodatacow" ];
                  persistence = "service-data";
                  description = "Container images and overlay data";
                }
                
                # Caddy reverse proxy data
                {
                  name = "caddy";
                  mountpoint = "/var/lib/caddy";
                  compress = "zstd:3";
                  neededForBoot = true;
                  persistence = "critical";
                  description = "SSL certificates and proxy configuration";
                }
                
                # Backup storage
                {
                  name = "backup";
                  mountpoint = "/var/backup";
                  compress = "zstd:3";
                  persistence = "backup";
                  description = "Server backups and data archives";
                }
                
                # Service-specific data
                {
                  name = "services";
                  mountpoint = "/var/lib/services";
                  compress = "zstd:2";
                  neededForBoot = true;
                  persistence = "service-critical";
                  description = "Service data that needs to persist across reboots";
                }
                
                # Snapshots for system recovery
                {
                  name = "snapshots";
                  mountpoint = "/.snapshots";
                  compress = "zstd:3";
                  persistence = "backup-only";
                  description = "Btrfs snapshots for system recovery";
                }
                
                # Impermanence archive
                {
                  name = "old_roots";
                  mountpoint = "/btrfs_tmp/old_roots";
                  compress = "zstd:3";
                  persistence = "temporary";
                  description = "Archive of old root subvolumes for rollback";
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

### Impermanence Configuration
```nix
# Impermanence setup for clean system reboots
impermanence = {
  enable = true;
  excludePaths = [
    "/persist"
    "/var/lib/services"
    "/var/lib/caddy"
    "/var/backup"
    "/btrfs_tmp"
    "/nix"
  ];
  
  # Pre-boot cleanup script
  preBootScript = ''
    #!/bin/sh
    set -e
    
    echo "Starting impermanence setup for hetzner-vps"
    
    # Backup current root before cleanup
    if [ -d "/root" ]; then
      btrfs subvolume snapshot / /btrfs_tmp/old_roots/root-$(date +%Y%m%d-%H%M%S)
    fi
    
    # Create new clean root
    btrfs subvolume create /root
    
    # Setup persistent data
    for path in ${config.pantherOS.impermanence.excludePaths}; do
      if [ -e "$path" ]; then
        mkdir -p "/root$path"
        cp -a "$path" "/root$path"
        echo "Preserved $path"
      fi
    done
    
    echo "Impermanence setup completed"
  '';
};
```

### Snapshot Strategy
```nix
# Automated snapshot management for servers
snapshots = {
  enable = true;
  schedule = "server";
  retention = "30d";
  
  # Server-specific snapshot policy
  serverPolicy = {
    frequency = "every-6-hours";  # Every 6 hours
    retention = "30 days";  # 30-day retention
    scope = [ "root" "persist" "services" ];  # Critical subvolumes
  };
  
  # Pre-maintenance snapshots
  maintenancePolicy = {
    frequency = "before-updates";  # Before system updates
    retention = "90 days";  # Extended retention
    scope = "all-persistent";  # All persistent subvolumes
  };
};
```

## Network Services

### Reverse Proxy Configuration
```nix
# Caddy reverse proxy for web services
services.caddy = {
  enable = true;
  email = "admin@pantherOS.dev";
  configFile = "/etc/caddy/Caddyfile";
  
  # ACME CloudFlare integration
  acmeEmail = "admin@pantherOS.dev";
  acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  
  # Default reverse proxy configuration
  defaultConfig = ''
    {
      admin localhost:2019
      log {
        output file /var/log/caddy/access.log {
          roll_size 100mb
          roll_keep 10
        }
        level INFO
      }
    }
    
    # Tailscale subnet access
    100.100.100.100 {
      reverse_proxy localhost:8080
    }
    
    # Default service proxy
    :80 {
      reverse_proxy localhost:8080
    }
    
    # HTTPS with automatic certificates
    *.pantherOS.dev {
      tls internal  # Development certificates
      reverse_proxy localhost:8080
    }
  '';
};
```

### Tailscale Integration
```nix
# Secure networking and exit node
services.tailscale = {
  enable = true;
  
  # Exit node configuration
  advertiseExitNode = true;
  exitNodePolicy = "userspace";  # Userspace networking
  
  # Authentication
  authKey = "/var/lib/tailscale/authkey";
  stateFile = "/var/lib/tailscale/state";
  
  # Logging
  logFile = "/var/log/tailscale.log";
  logLevel = "info";
  
  # Network configuration
  meshNetwork = "pantherOS";  # Network name
  subnetRoutes = [];  # No additional subnet routing
};
```

### Container Orchestration
```nix
# Podman for container services
virtualisation.podman = {
  enable = true;
  dockerCompat = true;  # Docker API compatibility
  
  # Resource limits for services
  defaultMemory = "4G";
  defaultCpuPeriod = 100000;
  defaultCpuQuota = 400;  # 4 CPU cores per container
  
  # Storage optimization
  storage = {
    driver = "overlay";
    runRoot = "/var/lib/containers/run";
    graphRoot = "/var/lib/containers/storage";
    options = [
      "overlay.mountopt=nodev,metacopy=on"
    ];
  };
  
  # Network configuration
  network = {
    defaultNetworkName = "podman";
    dnsEnabled = true;
  };
};
```

## Backup and Monitoring

### Backup Strategy
```nix
# Multi-tier backup approach
backup = {
  # Local snapshots
  local = {
    enable = true;
    frequency = "daily";
    retention = "30 days";
    scope = [ "persist" "services" "backup" ];
  };
  
  # Remote backup to OVH VPS
  remote = {
    enable = true;
    target = "hetzner-vps";
    protocol = "rsync";
    frequency = "daily";
    compression = "zstd";
    encryption = true;
  };
  
  # Hetzner backup service
  hetzner = {
    enable = true;
    schedule = "weekly";
    retention = "4 weeks";
  };
};
```

### Monitoring
```nix
# System monitoring for server health
monitoring = {
  # System health monitoring
  system = {
    enable = true;
    metrics = [ "cpu" "memory" "disk" "network" ];
    alerts = [ "high-memory" "disk-space" "service-down" ];
  };
  
  # Service monitoring
  services = {
    enable = true;
    checks = [ "caddy" "tailscale" "podman" "ssh" ];
    interval = "30s";
  };
  
  # Log monitoring
  logging = {
    enable = true;
    logFiles = [ "/var/log/syslog" "/var/log/caddy/*.log" ];
    alertOnErrors = true;
  };
};
```

## Known Issues

### Virtualization-Specific Issues
- **KVM Performance**: Some CPU features may not be fully exposed to guests
  - **Impact**: Slight performance overhead in some workloads
  - **Mitigation**: Use containerization when possible for development
- **I/O Performance**: NVMe performance may be limited by virtualization overhead
  - **Impact**: 10-20% I/O performance reduction
  - **Optimization**: Use fast compression to reduce I/O requirements

### Network Issues
- **Bandwidth Limitations**: 1 Gbps may be limiting for large data transfers
  - **Mitigation**: Use compression, schedule large transfers during off-peak
- **DDoS Protection**: Hetzner DDoS protection may affect legitimate high-traffic scenarios
  - **Monitoring**: Monitor for false positives and adjust thresholds
- **Geographical Latency**: EU-based hosting may have higher latency for US-based users
  - **Solution**: Consider multi-region deployment if needed

### Security Considerations
- **Public Exposure**: Internet-facing server requires constant security monitoring
  - **Mitigation**: Regular security updates, intrusion detection, fail2ban
- **Tailscale Exit Node**: Acting as exit node increases attack surface
  - **Security**: Strict access controls, network segmentation
- **Container Security**: Running containers from internet poses security risks
  - **Isolation**: Use user namespaces, read-only containers, resource limits

### Storage Considerations
- **Single Point of Failure**: Local SSD represents single storage device
  - **Backup Strategy**: Regular backups to external storage and OVH VPS
- **Disk Space**: 800GB may become limiting with growing container images
  - **Management**: Regular cleanup of old images, external storage integration
- **Snapshot Impact**: Frequent snapshots may consume significant disk space
  - **Monitoring**: Monitor snapshot size and implement cleanup policies

### Maintenance Windows
- **Hetzner Maintenance**: Regular maintenance windows (typically 2-4 hours monthly)
  - **Planning**: Schedule maintenance during off-peak hours
- **Reboot Requirements**: Kernel updates require reboot
  - **Coordination**: Coordinate with development work and notify users
- **SSL Certificate Renewal**: Let's Encrypt renewals happen automatically but require HTTP reachability
  - **Monitoring**: Monitor certificate expiration dates

## Performance Characteristics

### Expected Server Performance
```bash
# CPU Performance (EPYC 7443P)
Geekbench 6 Single-Core: ~1500-1700 points
Geekbench 6 Multi-Core: ~18000-22000 points
CPU Mark: ~20000-25000

# Memory Performance (96GB DDR4-3200 ECC)
Memory Bandwidth: ~200 GB/s
Memory Latency: 70-80ns
ECC Error Rate: <1 error per 10^18 bits

# Storage Performance (800GB NVMe)
Sequential Read: 3000 MB/s
Sequential Write: 2000 MB/s
Random Read IOPS: 100K
Random Write IOPS: 80K

# Network Performance (1 Gbps)
Network Throughput: ~940 Mbps sustained
Latency to EU: 1-5ms
Latency to US: 80-120ms
Latency to Asia: 150-200ms

# Container Performance
Concurrent Containers: 50+ containers
Memory per Container: 1-8GB typical
Container Startup Time: 2-5 seconds
Network Throughput: 800+ Mbps per container
```

### Service Benchmarks
```bash
# Reverse Proxy Performance (Caddy)
HTTPS Requests: 10,000+ RPS
HTTP Requests: 50,000+ RPS
Latency: <1ms proxy overhead
SSL Handshake: ~50ms

# Database Performance (PostgreSQL)
Concurrent Connections: 1000+
Queries Per Second: 100K+ simple queries
Latency: <1ms for cached queries
Throughput: Limited by 96GB RAM for caching

# Development Environment
Concurrent SSH Sessions: 50+
Git Operations: <100ms for typical operations
Build Performance: Depends on container/compilation requirements
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
- **Disk Layout**: `../../hosts/servers/hetzner-cloud/disko.nix`
- **System Configuration**: `../../hosts/servers/hetzner-cloud/default.nix`
- **Hardware Configuration**: `../../hosts/servers/hetzner-cloud/hardware.nix`

### OpenSpec Specifications
- [NixOS Base Hetzner VPS Configuration](../../openspec/changes/nixos-base-hetzner-vps/specs/)
- [Impermanence Layout Specification](../../openspec/changes/btrfs-impermanence-layout/specs/)

---

**Maintained by:** hbohlen  
**Last Updated:** 2025-11-20  
**Version:** 1.0