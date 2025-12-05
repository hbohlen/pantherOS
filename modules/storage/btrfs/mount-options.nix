# modules/storage/btrfs/mount-options.nix
# Btrfs Mount Option Presets
# Defines reusable mount option configurations for different workload types
#
# Workload Types:
# - standard: General filesystem use (balanced performance/compression)
# - database: Database workloads (nodatacow for integrity)
# - container: Container storage (nodatacow for performance)
# - cache: Temporary cache data (light compression)
# - temp: Temporary files (no compression, nodatacow recommended)

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.btrfs;
in
{
  options = {
    storage.btrfs.mountPresets = mkOption {
      description = ''
        Preset mount option configurations for different workload types.
        These presets can be referenced when defining subvolume mount options.
      '';
      type = types.attrs;
      default = {
        # ===== STANDARD WORKLOAD =====
        # Balanced configuration for general filesystem operations
        # - noatime: Prevents inode access time updates (performance)
        # - space_cache=v2: Enable space cache v2 (performance)
        # - compress=zstd:3: Good compression ratio for general files
        standard = [
          "noatime"
          "space_cache=v2"
          "compress=zstd:3"
        ];

        # ===== DATABASE WORKLOAD =====
        # Optimized for database storage (PostgreSQL, Redis, etc.)
        # - nodatacow: Required for database integrity and performance
        # - compress=no: Databases should not use compression
        database = [
          "noatime"
          "nodatacow"
          "compress=no"
        ];

        # ===== CONTAINER WORKLOAD =====
        # Optimized for container storage (Podman, Docker)
        # - nodatacow: Better performance for container layers
        # - compress=no: Container layers benefit from nodatacow over compression
        container = [
          "noatime"
          "nodatacow"
          "compress=no"
        ];

        # ===== CACHE WORKLOAD =====
        # Light compression for cache data (speed over size)
        # - compress=zstd:1: Fast compression, minimal CPU overhead
        # - No nodatacow: Compression is beneficial for cache
        cache = [
          "noatime"
          "compress=zstd:1"
        ];

        # ===== TEMP WORKLOAD =====
        # Minimal overhead for temporary files
        # - compress=no: No point compressing temporary data
        # - Can use nodatacow if temporary files are accessed frequently
        temp = [
          "noatime"
          "compress=no"
        ];
      };
      readOnly = true;
    };
  };

  config = {
    # Export presets for use by disko modules and profile configurations
    # These can be referenced as: config.storage.btrfs.mountPresets.standard
  };
}
