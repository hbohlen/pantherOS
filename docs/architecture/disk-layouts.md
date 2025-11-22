# Disk Layouts Architecture

This document defines the Btrfs sub-volume strategy and filesystem design across all pantherOS hosts, optimized for different workloads and host types.

## Filesystem Architecture Overview

All pantherOS hosts use Btrfs as the primary filesystem, chosen for its advanced features including:
- **Sub-volumes**: Flexible filesystem layout with independent snapshots
- **Compression**: Space-saving transparent compression
- **Snapshots**: Point-in-time backups for recovery
- **Checksums**: Data integrity verification
- **SSD Optimization**: Built-in SSD-specific optimizations

### Core Design Principles

1. **Performance Optimization**: Different compression levels per workload
2. **Snapshot Strategy**: Automated backups with retention policies  
3. **Host Type Specialization**: Optimized layouts per host classification
4. **Impermanence Integration**: Ephemeral root with persistent data separation
5. **Recovery Focus**: Multiple paths for system recovery

## Host-Specific Layouts

### Workstation Layouts

Workstations (yoga, zephyrus) use layouts optimized for user experience and development workflows.

#### yoga - Mobile Workstation Layout

```nix
# hosts/yoga/disko.nix
{ config, lib, ... }:

{
  disko.devices = {
    disk = {
      "nvme0n1" = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # ESP (1GB) - Multiple kernel support for mobility
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
            };
            
            # Btrfs root (remaining space)
            root = {
              size = "max";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                btrfsConfig = {
                  label = "yoga-nixos";
                  features = [ "block-group-tree" ];
                };
                
                subvolumes = [
                  # Ephemeral system root
                  {
                    name = "root";
                    mountpoint = "/";
                    compress = "zstd:3";
                  }
                  
                  # User data and development
                  {
                    name = "home";
                    mountpoint = "/home";
                    compress = "zstd:3";
                  }
                  
                  # Development projects with auto-activation
                  {
                    name = "dev";
                    mountpoint = "/home/hbohlen/dev";
                    compress = "zstd:2";
                  }
                  
                  # Nix store - fast access for frequent package operations
                  {
                    name = "nix";
                    mountpoint = "/nix";
                    compress = "zstd:1";
                    neededForBoot = true;
                  }
                  
                  # Application cache and temporary data
                  {
                    name = "cache";
                    mountpoint = "/var/cache";
                    compress = "zstd:3";
                  }
                  
                  # System logs
                  {
                    name = "logs";
                    mountpoint = "/var/log";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  # Container storage (minimal for mobility)
                  {
                    name = "containers";
                    mountpoint = "/var/lib/containers";
                    compress = "zstd:1";
                    mountOptions = [ "nodatacow" ];
                  }
                  
                  # Desktop-specific data
                  {
                    name = "desktop";
                    mountpoint = "/home/hbohlen/.local";
                    compress = "zstd:3";
                  }
                  
                  # Snapshots for recovery
                  {
                    name = "snapshots";
                    mountpoint = "/.snapshots";
                    compress = "zstd:3";
                  }
                ];
              };
            };
          };
        };
      };
    };
  };
  
  # Universal mount options for workstation
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/yoga-nixos";
      fsType = "btrfs";
      options = [
        "compress=zstd:3"
        "noatime"
        "ssd"
        "space_cache=v2"
        "discard=async"
        "subvol=root"
      ];
    };
    
    "/home" = {
      device = "/dev/disk/by-uuid/yoga-nixos";
      fsType = "btrfs";
      options = [
        "compress=zstd:3"
        "noatime"
        "subvol=home"
      ];
    };
  };
}
```

**Layout Rationale for yoga:**
- **Mobility Focus**: 1GB ESP sufficient for single-kernel configurations
- **User Data Priority**: Separate home and dev subvolumes for user workflow
- **Development Optimization**: Fast Nix access for frequent package operations
- **Container Efficiency**: Minimal container footprint for battery life
- **Snapshot Strategy**: Manual snapshots for development milestone tracking

#### zephyrus - Performance Workstation Layout

```nix
# hosts/zephyrus/disko.nix
{ config, lib, ... }:

{
  disko.devices = {
    disk = {
      "nvme0n1" = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # ESP (2GB) - Multiple kernels for development
            esp = {
              size = "2G";
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
            };
            
            # Secondary ESP for dual-boot compatibility
            esp2 = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = [ "noauto" ];
              };
            };
            
            # Btrfs primary (NVMe 1 - 1TB)
            primary = {
              size = "max";
              type = "8300";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                btrfsConfig = {
                  label = "zephyrus-nixos";
                  features = [ "block-group-tree" ];
                };
                
                subvolumes = [
                  # System subvolumes
                  {
                    name = "root";
                    mountpoint = "/";
                    compress = "zstd:3";
                  }
                  
                  {
                    name = "nix";
                    mountpoint = "/nix";
                    compress = "zstd:1";
                    neededForBoot = true;
                  }
                  
                  # Performance-focused user data
                  {
                    name = "home";
                    mountpoint = "/home";
                    compress = "zstd:1";  # Fast for frequent access
                  }
                  
                  # Large development projects
                  {
                    name = "projects";
                    mountpoint = "/home/hbohlen/dev";
                    compress = "zstd:1";  # Fast compilation
                  }
                  
                  # Container storage with performance optimization
                  {
                    name = "containers";
                    mountpoint = "/var/lib/containers";
                    compress = "zstd:1";
                    mountOptions = [ "nodatacow" ];
                  }
                  
                  # AI model storage
                  {
                    name = "ai-models";
                    mountpoint = "/home/hbohlen/.cache/ai-models";
                    compress = "zstd:2";
                    mountOptions = [ "nodatacow" ];  # Large model files
                  }
                  
                  {
                    name = "cache";
                    mountpoint = "/var/cache";
                    compress = "zstd:3";
                  }
                  
                  {
                    name = "logs";
                    mountpoint = "/var/log";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  # Temporary high-performance storage
                  {
                    name = "tmp";
                    mountpoint = "/tmp";
                    compress = "zstd:1";
                    mountOptions = [ "nodatacow" ];
                  }
                  
                  {
                    name = "snapshots";
                    mountpoint = "/.snapshots";
                    compress = "zstd:3";
                  }
                ];
              };
            };
          };
        };
      };
      
      # Secondary NVMe (1TB) - High-performance data
      "nvme1n1" = {
        type = "disk";
        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          btrfsConfig = {
            label = "zephyrus-data";
            features = [ "block-group-tree" ];
          };
          
          subvolumes = [
            {
              name = "databases";
              mountpoint = "/mnt/databases";
              compress = "zstd:1";
              mountOptions = [ "nodatacow" ];
            }
            
            {
              name = "container-data";
              mountpoint = "/mnt/container-data";
              compress = "zstd:1";
              mountOptions = [ "nodatacow" ];
            }
            
            {
              name = "backup";
              mountpoint = "/mnt/backup";
              compress = "zstd:3";
            }
          ];
        };
      };
    };
  };
}
```

**Layout Rationale for zephyrus:**
- **Performance Focus**: Multiple NVMe drives with optimized subvolumes
- **Large ESP**: 2GB for multiple kernel versions during development
- **Dual ESP**: Support for development environment testing
- **Container Priority**: Large, high-performance container storage
- **AI Workload Support**: Dedicated subvolume for large AI models
- **Database Optimization**: nodatacow for containerized databases

### Server Layouts

Servers use layouts optimized for network services, long-running workloads, and reliability.

#### hetzner-vps - Primary Server Layout

```nix
# hosts/hetzner-vps/disko.nix
{ config, lib, ... }:

{
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
            
            # Swap (32GB) - Hetzner CPX52 has 32GB RAM
            swap = {
              size = "32G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
              };
              priority = 3;
            };
            
            # Btrfs root (remaining ~447GB)
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
                  }
                  
                  # Persistent Nix store
                  {
                    name = "nix";
                    mountpoint = "/nix";
                    compress = "zstd:1";
                    neededForBoot = true;
                  }
                  
                  # Persistent application data
                  {
                    name = "persist";
                    mountpoint = "/persist";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  # System logs
                  {
                    name = "log";
                    mountpoint = "/var/log";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  # Container storage for services
                  {
                    name = "containers";
                    mountpoint = "/var/lib/containers";
                    compress = "zstd:1";
                    mountOptions = [ "nodatacow" ];
                  }
                  
                  # Caddy proxy data
                  {
                    name = "caddy";
                    mountpoint = "/var/lib/caddy";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  # Backup storage
                  {
                    name = "backup";
                    mountpoint = "/var/backup";
                    compress = "zstd:3";
                  }
                  
                  # Service-specific data
                  {
                    name = "services";
                    mountpoint = "/var/lib/services";
                    compress = "zstd:2";
                    neededForBoot = true;
                  }
                  
                  # Snapshots for system recovery
                  {
                    name = "snapshots";
                    mountpoint = "/.snapshots";
                    compress = "zstd:3";
                  }
                  
                  # Impermanence archive
                  {
                    name = "old_roots";
                    mountpoint = "/btrfs_tmp/old_roots";
                    compress = "zstd:3";
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

#### ovh-vps - Secondary Server Layout

```nix
# hosts/ovh-vps/disko.nix
{ config, lib, ... }:

{
  # Identical to hetzner-vps with different labels for redundancy
  disko.devices = {
    disk = {
      "sda" = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            bios-boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            
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
            
            swap = {
              size = "32G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
              };
              priority = 3;
            };
            
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
                  {
                    name = "root";
                    mountpoint = "/";
                    compress = "zstd:3";
                  }
                  
                  {
                    name = "nix";
                    mountpoint = "/nix";
                    compress = "zstd:1";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "persist";
                    mountpoint = "/persist";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "log";
                    mountpoint = "/var/log";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "containers";
                    mountpoint = "/var/lib/containers";
                    compress = "zstd:1";
                    mountOptions = [ "nodatacow" ];
                  }
                  
                  {
                    name = "caddy";
                    mountpoint = "/var/lib/caddy";
                    compress = "zstd:3";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "backup";
                    mountpoint = "/var/backup";
                    compress = "zstd:3";
                  }
                  
                  {
                    name = "services";
                    mountpoint = "/var/lib/services";
                    compress = "zstd:2";
                    neededForBoot = true;
                  }
                  
                  {
                    name = "snapshots";
                    mountpoint = "/.snapshots";
                    compress = "zstd:3";
                  }
                  
                  {
                    name = "old_roots";
                    mountpoint = "/btrfs_tmp/old_roots";
                    compress = "zstd:3";
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

## Sub-Volume Strategy

### Universal Sub-Volumes

All hosts implement these common subvolumes:

```nix
{
  universalSubvolumes = {
    # Root subvolume - Contains ephemeral system state
    root = {
      mountpoint = "/";
      purpose = "System files that change frequently";
      persistence = "Ephemeral (wiped on reboot)";
      compression = "zstd:3";
      neededForBoot = false;
    };
    
    # Nix store - Package database
    nix = {
      mountpoint = "/nix";
      purpose = "Nix packages, derivations, and profiles";
      persistence = "Critical for system function";
      compression = "zstd:1";  # Fast for frequent access
      neededForBoot = true;
    };
    
    # Logs - System and application logs
    log = {
      mountpoint = "/var/log";
      purpose = "System logs, application logs, and audit trails";
      persistence = "Important for debugging and monitoring";
      compression = "zstd:3";
      neededForBoot = true;
    };
    
    # Snapshots - Point-in-time backups
    snapshots = {
      mountpoint = "/.snapshots";
      purpose = "Btrfs snapshots for system recovery";
      persistence = "Backup-only, not mounted at runtime";
      compression = "zstd:3";
      neededForBoot = false;
    };
  };
}
```

### Workstation-Specific Sub-Volumes

```nix
{
  workstationSubvolumes = {
    # Home directory - User data
    home = {
      mountpoint = "/home";
      purpose = "User configurations and data";
      persistence = "Permanent user data";
      compression = "zstd:3";
      special = "Contains user-specific subvolumes";
    };
    
    # Development directory - Auto-activated devshell
    dev = {
      mountpoint = "/home/hbohlen/dev";
      purpose = "Development projects with auto-activation";
      persistence = "Permanent project data";
      compression = "zstd:2";
      special = "Triggers devShell activation";
    };
    
    # Desktop data - Application-specific user data
    desktop = {
      mountpoint = "/home/hbohlen/.local";
      purpose = "Desktop application data and caches";
      persistence = "User preference data";
      compression = "zstd:3";
    };
    
    # Cache - Application caches for performance
    cache = {
      mountpoint = "/var/cache";
      purpose = "Application caches and temporary data";
      persistence = "Optional (can be cleared)";
      compression = "zstd:3";
    };
  };
}
```

### Server-Specific Sub-Volumes

```nix
{
  serverSubvolumes = {
    # Persistent data - Survives impermanence
    persist = {
      mountpoint = "/persist";
      purpose = "Configuration and data that survives reboots";
      persistence = "Critical for service continuity";
      compression = "zstd:3";
      neededForBoot = true;
    };
    
    # Container storage - Podman/Podman data
    containers = {
      mountpoint = "/var/lib/containers";
      purpose = "Container images, volumes, and overlay data";
      persistence = "Container data persistence";
      compression = "zstd:1";  # Fast access
      mountOptions = [ "nodatacow" ];  # Database optimization
    };
    
    # Caddy data - Reverse proxy configuration and certificates
    caddy = {
      mountpoint = "/var/lib/caddy";
      purpose = "SSL certificates and proxy configuration";
      persistence = "Critical for HTTPS services";
      compression = "zstd:3";
      neededForBoot = true;
    };
    
    # Services data - Service-specific persistent data
    services = {
      mountpoint = "/var/lib/services";
      purpose = "Service data that needs to persist across reboots";
      persistence = "Service-specific persistence requirements";
      compression = "zstd:2";
      neededForBoot = true;
    };
    
    # Backup storage - Server backups and archives
    backup = {
      mountpoint = "/var/backup";
      purpose = "Server backups and data archives";
      persistence = "Long-term data retention";
      compression = "zstd:3";
    };
    
    # Old roots - Impermanence archives
    old_roots = {
      mountpoint = "/btrfs_tmp/old_roots";
      purpose = "Archive of old root subvolumes for rollback";
      persistence = "30-day retention policy";
      compression = "zstd:3";
    };
  };
}
```

## Compression Strategy

### Performance-Based Compression Levels

Different data types benefit from different compression approaches:

```nix
{
  compressionStrategy = {
    # zstd:1 - Fast compression/decompression for frequently accessed data
    fast = [
      "nix"          # Package database, accessed frequently
      "containers"   # Container images and layers
      "tmp"          # Temporary high-performance storage
    ];
    
    # zstd:2 - Balanced compression for mixed workloads
    balanced = [
      "dev"          # Development projects, mixed file types
      "ai-models"    # Large AI model files
      "services"     # Service data, moderate access patterns
    ];
    
    # zstd:3 - Maximum compression for space efficiency
    maximum = [
      "root"         # System files, less frequently accessed
      "home"         # User files and configurations
      "desktop"      # Desktop application data
      "cache"        # Application caches
      "logs"         # Log files
      "persist"      # Persistent application data
      "caddy"        # Certificate and proxy data
      "backup"       # Backup archives
      "snapshots"    # Snapshot metadata
      "old_roots"    # Old root archives
    ];
  };
}
```

## Mount Options Strategy

### Universal Mount Options

All Btrfs subvolumes include these universal optimizations:

```nix
{
  universalMountOptions = [
    "noatime",           # Reduce metadata writes (performance)
    "ssd",              # Btrfs SSD-specific optimizations
    "space_cache=v2",   # Efficient space management
    "discard=async"     # Non-blocking TRIM for SSDs
  ];
}
```

### Workload-Specific Mount Options

```nix
{
  workloadMountOptions = {
    # Database and container storage optimization
    nodatacow = [
      "containers"      # Podman storage, database workloads
      "tmp"             # High-performance temporary storage
      "databases"       # Database files (zephyrus secondary disk)
      "ai-models"       # Large AI model files
    ];
    
    # Standard compression options
    compressed = [
      "root", "home", "dev", "persist", "log", 
      "cache", "desktop", "caddy", "backup", 
      "snapshots", "old_roots"
    ];
    
    # Fast access options
    fast = [
      "nix", "containers", "tmp", "databases"
    ];
  };
}
```

## Snapshot Strategy

### Snapshot Schedule

```nix
{
  snapshotStrategy = {
    workstations = {
      # Manual snapshots for development milestones
      manual = [
        "Development project completion"
        "System configuration changes"
        "Before major updates"
      ];
      
      # Automatic snapshots (hourly during active use)
      automatic = {
        frequency = "Hourly when system is active";
        retention = "24 hours";
        scope = "Root subvolume only";
      };
    };
    
    servers = {
      # Automated snapshots for service continuity
      automatic = {
        frequency = "Every 6 hours";
        retention = "30 days";
        scope = ["Root", "Persist", "Services"];
      };
      
      # Pre-maintenance snapshots
      maintenance = {
        frequency = "Before system updates";
        retention = "90 days";
        scope = "All persistent subvolumes";
      };
    };
  };
}
```

### Snapshot Management

```nix
# modules/shared/filesystems/snapshots.nix
{ config, lib, ... }:

{
  options.pantherOS.snapshots = {
    enable = lib.mkEnableOption "Btrfs snapshot management";
    schedule = lib.mkOption {
      type = lib.types.enum [ "workstation" "server" "manual" ];
      default = "workstation";
    };
    retention = lib.mkOption {
      type = lib.types.str;
      default = "30d";
      description = "Snapshot retention period";
    };
  };
  
  config = lib.mkIf config.pantherOS.snapshots.enable {
    # Snapshot creation script
    environment.systemPackages = [ pkgs.btrfs-progs ];
    
    systemd.services."btrfs-snapshots" = {
      enable = true;
      serviceConfig = {
        ExecStart = "${config.lib.systemd.package}/lib/systemd/systemd-snapshot create";
        Type = "oneshot";
      };
      
      # Configure schedule based on host type
      timerConfig = lib.mkIf (config.pantherOS.snapshots.schedule == "server") {
        OnCalendar = "*-*-* 00,06,12,18:00:00";  # Every 6 hours
        Persistent = true;
      };
    };
    
    # Snapshot cleanup service
    systemd.services."btrfs-snapshot-cleanup" = {
      enable = true;
      after = [ "btrfs-snapshots.service" ];
      serviceConfig = {
        ExecStart = ''
          find /.snapshots -name "snap-*" -type d -mtime +${config.pantherOS.snapshots.retention} -exec btrfs subvolume delete {} \;
        '';
      };
    };
  };
}
```

## Impermanence Integration

### Ephemeral Root Configuration

Servers implement impermanence for clean system reboots:

```nix
# modules/shared/filesystems/impermanence.nix
{ config, lib, ... }:

{
  options.pantherOS.impermanence = {
    enable = lib.mkEnableOption "Impermanence - ephemeral root with persistent data";
    excludePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/persist"
        "/var/lib/services"
        "/var/lib/caddy"
        "/var/backup"
        "/btrfs_tmp"
      ];
      description = "Paths to preserve across reboots";
    };
  };
  
  config = lib.mkIf config.pantherOS.impermanence.enable {
    # Pre-boot script to setup root
    systemd.services."impermanence-setup" = {
      enable = true;
      before = [ "sysroot.mount" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          #!/bin/sh
          set -e
          
          # Backup current root
          btrfs subvolume snapshot / /btrfs_tmp/old_roots/root-$(date +%Y%m%d-%H%M%S)
          
          # Delete existing root
          btrfs subvolume delete / || true
          
          # Create new root
          btrfs subvolume create /root
          
          # Copy persistent data
          for path in ${config.pantherOS.impermanence.excludePaths}; do
            mkdir -p "/root$path"
            if [ -e "$path" ]; then
              cp -a "$path" "/root$path"
            fi
          done
        '';
      };
    };
  };
}
```

## Cross-Reference Implementation

### Disk Layout Module Integration

```nix
# modules/shared/filesystems/disk-layouts.nix
{ config, lib, ... }:

{
  options.pantherOS.disk = {
    hostType = lib.mkOption {
      type = lib.types.enum [ "workstation" "server" ];
      description = "Host type for disk layout selection";
    };
    compressionLevel = lib.mkOption {
      type = lib.types.enum [ "fast" "balanced" "maximum" ];
      default = "balanced";
      description = "Default compression level for this host";
    };
    enableImpermanence = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable impermanence for ephemeral root";
    };
  };
  
  config = lib.mkIf config.pantherOS.disk.hostType == "workstation" {
    imports = [
      <modules/shared/filesystems/workstation-layout.nix>
      <modules/shared/filesystems/snapshots.nix>
    ];
  };
  
  config = lib.mkIf config.pantherOS.disk.hostType == "server" {
    imports = [
      <modules/shared/filesystems/server-layout.nix>
      <modules/shared/filesystems/snapshots.nix>
      <modules/shared/filesystems/impermanence.nix>
    ];
  };
}
```

## Recovery Procedures

### Emergency Recovery Commands

```bash
# Boot from snapshot
btrfs subvolume set-default /.snapshots/<snapshot-name> /
reboot

# Manual snapshot creation
btrfs subvolume snapshot -r / /.snapshots/manual-$(date +%Y%m%d-%H%M%S)

# Recover from snapshot
btrfs subvolume snapshot /.snapshots/<snapshot-name> /

# Check disk space usage
btrfs filesystem df /

# List all subvolumes
btrfs subvolume list /

# Verify filesystem integrity
btrfs check --repair /dev/disk/by-uuid/<uuid>
```

## Related Documentation

- [System Architecture Overview](./overview.md)
- [Host Classification](./host-classification.md)
- [Security Model](./security-model.md)
- [Module Organization](./module-organization.md)
- [Impermanence Integration Specification](../../openspec/changes/btrfs-impermanence-layout/specs/)
- [Hardware Discovery Guide](../guides/hardware-discovery.md)
- [Host Configuration Guide](../guides/host-configuration.md)

---

**Maintained by:** hbohlen  
**Last Updated:** 2025-11-20  
**Version:** 1.0