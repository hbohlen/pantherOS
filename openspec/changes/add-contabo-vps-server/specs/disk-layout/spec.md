# Disk Layout Specification - Contabo VPS

## ADDED Requirements

### Requirement: Btrfs Filesystem with Optimized Subvolumes
The system SHALL use Btrfs filesystem with multiple subvolumes optimized for different workload types on the Contabo 250GB NVMe drive.

#### Scenario: Root filesystem mounts successfully
- **WHEN** system boots
- **THEN** root filesystem is mounted with compression
- **AND** async TRIM is enabled for NVMe

#### Scenario: Nix store is on separate subvolume
- **WHEN** system is running
- **THEN** `/nix` is on dedicated `@nix` subvolume
- **AND** uses light compression (zstd:1)

### Requirement: Container-Optimized Storage
The system SHALL provide container storage with CoW disabled for optimal performance.

#### Scenario: Container subvolume is configured
- **WHEN** Podman runtime initializes
- **THEN** `/var/lib/containers` is on `@containers` subvolume
- **AND** nodatacow option is enabled
- **AND** no compression is applied

#### Scenario: Container operations are fast
- **WHEN** containers are deployed
- **THEN** image operations are not slowed by Btrfs CoW
- **AND** performance matches or exceeds Hetzner setup

### Requirement: Development Subvolume
The system SHALL provide optimized storage for development projects under `/home/hbohlen/dev`.

#### Scenario: Development directory is mounted
- **WHEN** user accesses `/home/hbohlen/dev`
- **THEN** it is on dedicated `@dev` subvolume
- **AND** source code benefits from compression

#### Scenario: Source code is compressed
- **WHEN** projects are stored in development directory
- **THEN** Btrfs compression (zstd:3) reduces space usage
- **AND** access times are not updated (noatime)

### Requirement: AI Tools Storage
The system SHALL provide dedicated storage for AI tools and models like Claude Code and OpenCode.AI.

#### Scenario: AI tools directory is accessible
- **WHEN** user accesses `/home/hbohlen/.ai-tools`
- **THEN** it is on dedicated `@ai-tools` subvolume
- **AND** storage is optimized for model files

#### Scenario: Large model files are stored efficiently
- **WHEN** AI models are downloaded and cached
- **THEN** light compression is applied to reduce space
- **AND** read performance is maintained for inference

### Requirement: Swap Space
The system SHALL provide 10GB swap space for heavy development workloads.

#### Scenario: Swap is configured
- **WHEN** system boots
- **THEN** 10GB swap file is available
- **AND** swap file is on dedicated `@swap` subvolume with nodatacow

#### Scenario: Swap does not cause slowdown
- **WHEN** memory pressure exceeds available RAM
- **THEN** swap is available without Btrfs CoW overhead

### Requirement: Journal and Log Storage
The system SHALL separate journal storage from general logs for retention policy management.

#### Scenario: Journal is persisted
- **WHEN** systemd-journal writes logs
- **THEN** journal is stored on dedicated `@journal` subvolume
- **AND** independent retention policies can be applied

#### Scenario: Logs are compressed
- **WHEN** system generates log files
- **THEN** system logs are on `@log` subvolume
- **AND** compression reduces storage usage

### Requirement: Cache and Temporary Storage
The system SHALL provide optimized storage for system caches and temporary files.

#### Scenario: System cache is stored efficiently
- **WHEN** package manager writes to `/var/cache`
- **THEN** it is on dedicated `@var-cache` subvolume
- **AND** light compression is applied

#### Scenario: Temporary files are fast
- **WHEN** applications write to `/tmp`
- **THEN** temporary storage is on `@tmp` subvolume
- **AND** no compression is applied for speed

### Requirement: User Cache Storage
The system SHALL optimize storage for user-level caches (npm, cargo, pip, etc.).

#### Scenario: Build tool caches are stored
- **WHEN** build tools cache downloads
- **THEN** cache is stored on `@user-cache` subvolume
- **AND** light compression saves space

#### Scenario: Cache cleanup is automated
- **WHEN** caches exceed retention period
- **THEN** old caches are automatically removed
- **AND** storage is reclaimed

### Requirement: Configuration Storage
The system SHALL provide dedicated storage for user configurations.

#### Scenario: Config directory is mounted
- **WHEN** user accesses `/home/hbohlen/.config`
- **THEN** it is on dedicated `@config` subvolume
- **AND** configurations benefit from compression

#### Scenario: Local user data is preserved
- **WHEN** applications store state in `.local`
- **THEN** data is on `@local` subvolume
- **AND** medium compression balances space and performance

### Requirement: GPT Partition Table
The system SHALL use GPT partitioning with appropriate boot configuration for Contabo platform.

#### Scenario: Disk is partitioned correctly
- **WHEN** NixOS is installed
- **THEN** GPT partition table is created
- **AND** appropriate boot partition is configured

#### Scenario: Boot configuration works
- **WHEN** server reboots
- **THEN** bootloader loads from correct partition
- **AND** NixOS kernel is executed

### Requirement: TRIM Support for NVMe
The system SHALL enable async TRIM for SSD/NVMe performance.

#### Scenario: TRIM is enabled
- **WHEN** Btrfs filesystem is mounted
- **THEN** async discard option is enabled
- **AND** NVMe wear leveling is optimized

#### Scenario: SSD performance is maintained
- **WHEN** files are deleted
- **THEN** TRIM is executed asynchronously
- **AND** performance degradation is minimal

### Requirement: Btrfs Features
The system SHALL enable modern Btrfs features for efficiency.

#### Scenario: Space cache v2 is enabled
- **WHEN** filesystem mounts
- **THEN** space_cache=v2 option is set
- **AND** filesystem performance is optimized

#### Scenario: Access times are not tracked
- **WHEN** files are accessed
- **THEN** noatime option prevents unnecessary writes
- **AND** SSD write wear is reduced
