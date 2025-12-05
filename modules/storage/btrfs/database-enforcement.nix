# modules/storage/btrfs/database-enforcement.nix
# Database Nodatacow Enforcement
# Validates that database subvolumes use nodatacow mount option
#
# Databases (PostgreSQL, Redis, etc.) are incompatible with Copy-on-Write (CoW)
# because:
# 1. Performance: CoW adds overhead to every write operation
# 2. Integrity: Databases manage their own caching and consistency
# 3. fragmentation: Frequent CoW can cause excessive fragmentation
#
# This module ensures @postgresql, @redis, and @containers subvolumes
# cannot be configured without nodatacow.

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.btrfs;

  # Helper function to check if a list of mount options contains nodatacow
  hasNodatacow = mountOptions:
    if mountOptions == null then false
    else lib.elem "nodatacow" mountOptions;

  # Check laptop disk configuration
  laptopHasNodatacow = config.storage.disks.laptop.enable && config.storage.disks.laptop.enableDatabases;

  # Extract mount options from laptop disk subvolumes
  laptopPostgresMountOptions = if config.storage.disks.laptop.enable then
    (config.disko.devices.disk.${config.storage.disks.laptop.device}.content.partitions.root.content.subvolumes."@postgresql".mountOptions or null)
  else null;

  laptopRedisMountOptions = if config.storage.disks.laptop.enable then
    (config.disko.devices.disk.${config.storage.disks.laptop.device}.content.partitions.root.content.subvolumes."@redis".mountOptions or null)
  else null;

  laptopContainersMountOptions = if config.storage.disks.laptop.enable then
    (config.disko.devices.disk.${config.storage.disks.laptop.device}.content.partitions.root.content.subvolumes."@containers".mountOptions or null)
  else null;

in
{
  options = {
    storage.btrfs.enforceDatabaseNodatacow = mkOption {
      description = ''
        Enforce nodatacow mount option on database and container subvolumes.

        When enabled, this validation ensures that:
        - @postgresql subvolume has nodatacow
        - @redis subvolume has nodatacow
        - @containers subvolume has nodatacow

        Disabling this check allows override but is NOT recommended.
        Database performance will be severely degraded without nodatacow.
      '';
      type = types.bool;
      default = true;
      defaultText = "true (strongly recommended)";
    };
  };

  config = lib.mkIf cfg.enforceDatabaseNodatacow {
    # ===== DATABASE SUBNODACOW VALIDATION =====
    assertions = [
      # PostgreSQL subvolume validation
      {
        assertion = !laptopHasNodatacow || hasNodatacow laptopPostgresMountOptions;
        message = ''
          PostgreSQL subvolume (@postgresql) is configured without nodatacow.

          PostgreSQL databases are incompatible with Btrfs Copy-on-Write (CoW)
          due to performance and integrity concerns:

          1. Performance Impact:
             - CoW creates additional I/O overhead on every write
             - Database write patterns are frequent and regular
             - This can cause 10-50x slowdown in write-heavy workloads

          2. Data Integrity:
             - PostgreSQL manages its own caching and write-ahead logging
             - CoW can interfere with database consistency guarantees
             - Modern PostgreSQL versions work best without filesystem CoW

          3. Fragmentation:
             - Regular CoW operations can cause excessive fragmentation
             - Database files benefit from contiguous storage

          SOLUTION:
          Ensure @postgresql mount options include "nodatacow" and "compress=no"

          Example:
            "@postgresql" = {
              mountpoint = "/var/lib/postgresql";
              mountOptions = [
                "nodatacow"
                "compress=no"
                "noatime"
                "space_cache=v2"
              ];
            };

          If you must disable this check (NOT RECOMMENDED), set:
            storage.btrfs.enforceDatabaseNodatacow = false;
        '';
      }

      # Redis subvolume validation
      {
        assertion = !laptopHasNodatacow || hasNodatacow laptopRedisMountOptions;
        message = ''
          Redis subvolume (@redis) is configured without nodatacow.

          Redis is an in-memory database that persists to disk and requires
          consistent, low-latency writes. Copy-on-Write causes performance issues:

          1. Write Performance:
             - Redis uses append-only file (AOF) and snapshot (RDB) writes
             - CoW overhead degrades these critical write operations
             - Can cause latency spikes affecting entire database

          2. Memory-Mapped Files:
             - Redis uses memory-mapped files for persistence
             - CoW on memory-mapped files causes additional overhead
             - nodatacow provides better performance for this access pattern

          3. Fragmentation:
             - Redis files can become heavily fragmented with CoW
             - nodatacow ensures efficient storage allocation

          SOLUTION:
          Ensure @redis mount options include "nodatacow" and "compress=no"

          Example:
            "@redis" = {
              mountpoint = "/var/lib/redis";
              mountOptions = [
                "nodatacow"
                "compress=no"
                "noatime"
                "space_cache=v2"
              ];
            };

          If you must disable this check (NOT RECOMMENDED), set:
            storage.btrfs.enforceDatabaseNodatacow = false;
        '';
      }

      # Container subvolume validation
      {
        assertion = !config.storage.disks.laptop.enable || hasNodatacow laptopContainersMountOptions;
        message = ''
          Container subvolume (@containers) is configured without nodatacow.

          While containers don't strictly require nodatacow like databases,
          they perform significantly better without CoW:

          1. Layer Performance:
             - Container image layers are read-heavy workloads
             - nodatacow eliminates CoW overhead on layer access
             - Critical for fast container startup times

          2. Write Patterns:
             - Container writes (logs, temp files) are frequent
             - nodatacow provides better I/O performance
             - Especially important for database containers

          3. Already Compressed:
             - Container images are typically compressed at build time
             - Filesystem compression provides minimal benefit
             - nodatacow is more valuable than compression here

          SOLUTION:
          Ensure @containers mount options include "nodatacow" and "compress=no"

          Example:
            "@containers" = {
              mountpoint = "/var/lib/containers";
              mountOptions = [
                "nodatacow"
                "compress=no"
                "noatime"
                "space_cache=v2"
              ];
            };

          If container performance is not critical, you may disable the
          enforcement check with:
            storage.btrfs.enforceDatabaseNodatacow = false;

          However, this is NOT recommended for development workstations.
        '';
      }
    ];
  };
}
