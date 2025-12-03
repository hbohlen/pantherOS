# Hetzner VPS Disko Configuration Technical Specification

## Hardware Analysis

Based on facter.json from hosts/servers/hetzner-vps/facter.json:

- **Primary Disk**: `/dev/vda` (458GB)
- **Controller**: virtio_scsi
- **Virtualization**: KVM/QEMU
- **Filesystem Strategy**: BTRFS with subvolumes

## Disko Configuration Rationale

### Single Disk Strategy

- No RAID or fancy partitioning (KVM environment limitation)
- Focus on optimal BTRFS subvolume layout
- Use snapshots instead of traditional backup strategies

### BTRFS Subvolume Design

```
/dev/vda1: EFI System Partition (512MB) - Optional, depends on UEFI
/dev/vda2: BTRFS main partition (remaining space)

BTRFS Subvolumes:
├── /@root         → / (root filesystem)
├── /@home         → /home (user data)
├── /@nix          → /nix (Nix store - separate for atomic updates)
├── /@var          → /var (system variables)
├── /@cache        → /var/cache (package caches, etc.)
├── /@log          → /var/log (log files)
├── /@tmp          → /var/tmp (temporary files)
├── /@persist      → /persist (persistent configuration)
└── /@postgresql   → /var/lib/postgresql (database - nodatacow)
```

### Mount Options Justification

- **zstd compression**: Space efficiency in VPS environment
- **noatime**: Reduces unnecessary disk writes
- **discard=async**: SSD TRIM support for virtio_scsi
- **nodatacow for @postgresql**: Critical for database performance (prevents copy-on-write overhead)

## Environment-Specific Optimizations

- **KVM/virtio_scsi**: Use discard=async for optimal SSD performance
- **Memory constraints**: Compression reduces disk I/O pressure
- **Single disk**: Subvolume isolation for backup/snapshot granularity
