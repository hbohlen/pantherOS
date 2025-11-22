# Btrfs Sub-Volume Layouts for pantherOS

## Overview

This document outlines the optimal Btrfs sub-volume layouts for each host in the pantherOS configuration, based on hardware specifications and use cases.

## General Principles

### Sub-Volume Strategy
1. **Root sub-volumes** for system directories that benefit from snapshotting
2. **Separate sub-volumes** for user data and development projects
3. **Container storage** dedicated sub-volumes for Podman
4. **SSD optimizations** following Btrfs best practices for flash storage

### Btrfs Best Practices for SSDs
- Enable TRIM support: `discard=async`
- Use compression: `compress=zstd` for better SSD longevity
- Enable SSD allocation hints: `ssd`
- Avoid excessive snapshots on heavily used directories

## Host-Specific Layouts

### 1. yoga (Lenovo Yoga 7 2-in-1)
**Purpose**: Lightweight programming, web browsing, battery-efficient

**Hardware**:
- CPU: AMD Ryzen AI 7 350 (16 cores)
- RAM: 14GB
- Storage: 1x NVMe SSD (~1TB)
- GPU: Integrated Radeon 860M

**Sub-Volume Layout**:
```
/
├── @ (root sub-volume)
├── @home (user data)
├── @dev (development projects - auto-activation for devShell)
├── @var-cache (package cache - can be cleared)
├── @var-log (logs - frequently rotated)
├── @var-tmp (temporary files)
├── @snapshots (Btrfs snapshots for rollback)
├── @containers (Podman storage - separate for easy management)
└── @nix (Nix store - read-only, special handling)
```

**Rationale**:
- Small footprint (14GB RAM) - keep /var/cache separate for easy cleanup
- Battery-focused - minimize background writes, use compression
- Single NVMe - simple layout, no RAID
- Development - dedicated @dev sub-volume with auto-activation

### 2. zephyrus (ASUS ROG Zephyrus M16)
**Purpose**: Heavy development, Podman containers, performance-focused

**Hardware**:
- CPU: Intel i9-12900H (20 cores)
- RAM: 38GB
- Storage: 2x NVMe SSDs (~2.7TB each)
- GPU: NVIDIA RTX 3070 Ti Laptop

**Sub-Volume Layout**:
```
/
├── @ (root sub-volume)
├── @home (user data)
├── @dev (development projects)
├── @var-cache (package cache)
├── @var-log (logs)
├── @var-tmp (temporary files)
├── @snapshots (Btrfs snapshots)
├── @containers (Podman storage)
├── @containers-root (Podman rootless storage)
├── @nix (Nix store)
├── @data (large datasets, media)
└── @games (gaming/projects if needed)
```

**Rationale**:
- High-performance workstation (38GB RAM, 2x NVMe)
- Heavy Podman usage - separate containers and containers-root
- Dual NVMe - consider Btrfs RAID1 or separate mount points
- Plenty of space - dedicated @data for large projects
- Development + Gaming - can accommodate both use cases

### 3. hetzner-vps (Hetzner Cloud VPS)
**Purpose**: Personal codespace server, headless

**Hardware**:
- CPU: AMD EPYC Genoa (12 cores)
- RAM: 24GB
- Storage: 1x SSD (~440GB)
- Virtualized: KVM

**Sub-Volume Layout**:
```
/
├── @ (root sub-volume)
├── @home (user data - minimal)
├── @dev (development projects - mounted from storage)
├── @var-cache (package cache)
├── @var-log (logs)
├── @var-tmp (temporary files)
├── @snapshots (Btrfs snapshots - for rollback)
├── @containers (Podman storage - main use case)
├── @containers-root (Podman rootless)
├── @nix (Nix store)
└── @backup (backup location for other hosts)
```

**Rationale**:
- Headless server - minimal user data
- Small storage (440GB) - efficient layout critical
- Podman hosting - dedicated large sub-volumes for containers
- Codespace server - @dev mounted from network or larger storage
- Backup target - @backup for cross-host backup operations

### 4. ovh-vps (OVH Cloud VPS)
**Purpose**: Secondary server, mirrors hetzner-vps

**Hardware**:
- CPU: Intel Haswell (8 cores)
- RAM: 22GB
- Storage: 1x SSD (~195GB)
- Virtualized: KVM

**Sub-Volume Layout**:
```
/
├── @ (root sub-volume)
├── @home (user data - minimal)
├── @dev (development projects - minimal)
├── @var-cache (package cache)
├── @var-log (logs)
├── @var-tmp (temporary files)
├── @snapshots (Btrfs snapshots)
├── @containers (Podman storage)
├── @containers-root (Podman rootless)
└── @nix (Nix store)
```

**Rationale**:
- Smallest storage (195GB) - very efficient layout
- Secondary server - mirror hetzner but smaller
- Podman hosting - but less intensive than hetzner
- Minimal user data - mostly infrastructure
- Cost-effective - minimal overhead

## Implementation with Disko

### Example Disko Configuration Structure

```nix
{
  disko.devices = {
    disk = {
      hp = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = [
            {
              name = "ESP";
              start = "0%";
              end = "256MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                fsformat = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "main";
              start = "256MiB";
              end = "100%";
              content = {
                type = "btrfs";
                extraSubvolumes = [
                  {
                    name = "@";
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "ssd" "discard=async" ];
                  }
                  {
                    name = "@home";
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "ssd" "discard=async" ];
                  }
                  {
                    name = "@dev";
                    mountpoint = "/dev";
                    mountOptions = [ "compress=zstd" "ssd" "discard=async" ];
                  }
                  {
                    name = "@var-cache";
                    mountpoint = "/var/cache";
                    mountOptions = [ "compress=zstd" "ssd" "discard=async" ];
                  }
                  {
                    name = "@containers";
                    mountpoint = "/var/lib/containers";
                    mountOptions = [ "compress=zstd" "ssd" "discard=async" ];
                  }
                ];
              };
            }
          ];
        };
      };
    };
  };
}
```

## Migration Plan for VPS Hosts

### Current State
- **hetzner-vps**: ext4 (needs migration)
- **ovh-vps**: ext4 (needs migration)

### Migration Strategy
1. **Backup existing data** (critical)
2. **Install pantherOS with Btrfs** using Disko
3. **Restore data** to appropriate sub-volumes
4. **Test functionality** before production use

### Migration Commands (Reference)
```bash
# Backup
sudo rsync -avz --progress /home/ /mnt/backup/home/

# During NixOS install
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@dev
# ... create other sub-volumes

# Restore
sudo rsync -avz --progress /mnt/backup/home/ /mnt/home/
```

## NixOS Integration

### Root Sub-Volume Configuration
```nix
{
  boot.supportedFilesystems = [ "btrfs" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/<uuid>";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" "ssd" "discard=async" ];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/<uuid>";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "ssd" "discard=async" ];
    };
    "/dev" = {
      device = "/dev/disk/by-uuid/<uuid>";
      fsType = "btrfs";
      options = [ "subvol=@dev" "compress=zstd" "ssd" "discard=async" ];
    };
    # ... other sub-volumes
  };
}
```

### Snapshot Management
```nix
{
  # Enable automatic snapshots
  services.btrfs.autoSnapshot.enable = true;
  services.btrfs.autoSnapshot.flags = [ "-r" ];  # read-only snapshots
}
```

## Development Directory Setup

### Auto-Activation in ~/dev
```bash
# In fish shell configuration (home-manager)
if test -d ~/dev
  cd ~/dev
end
```

Or using direnv:
```nix
{
  programs.direnv.enable = true;
  programs.direnv.config = {
    nix-direnv = {
      enable = true;
    };
  };
}
```

## Container Storage Optimization

### Podman with Btrfs
```nix
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    # Use Btrfs storage driver
    storageDriver = "btrfs";
    storage = {
      # Point to dedicated sub-volume
      runDir = "/var/lib/containers";
      dataDir = "/var/lib/containers";
    };
  };
}
```

## Next Steps

1. ✅ Document optimal sub-volume layouts per host
2. ⏳ Create disko.nix configuration files for each host
3. ⏳ Test layouts on non-production systems first
4. ⏳ Implement migration plan for VPS hosts (ext4 → Btrfs)
5. ⏳ Configure snapshot automation
6. ⏳ Document backup/restore procedures

## References

- [Btrfs Wiki](https://btrfs.wiki.kernel.org/)
- [NixOS Btrfs Guide](https://nixos.org/manual/nixos/stable/#sec-file-systems)
- [Disko Documentation](https://github.com/nix-community/disko)
- [Podman Storage Configuration](https://docs.podman.io/en/latest/markdown/podman-storage.conf.5.html)
