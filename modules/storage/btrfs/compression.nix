# modules/storage/btrfs/compression.nix
# Btrfs Compression Configuration
# Documents compression settings for different workload types with rationale
#
# Compression Algorithms:
# - zstd:3: Good balance of compression ratio and speed for general files
# - zstd:1: Fast compression with low CPU overhead for frequently accessed data
# - zstd:15: Maximum compression (use selectively, high CPU cost)
# - no: No compression (best for databases, containers, and already-compressed data)

{ lib, config, ... }:

let
  inherit (lib) mkOption types;
  cfg = config.storage.btrfs;
in
{
  options = {
    storage.btrfs.compressionSettings = mkOption {
      description = ''
        Compression configuration for Btrfs subvolumes.
        Defines compression levels and rationale for different workload types.
      '';
      type = types.attrs;
      default = {
        # ===== ZSTD:3 FOR GENERAL FILES =====
        # Compression level 3 provides good balance:
        # - Compression ratio: ~2.5-3x for typical files
        # - CPU overhead: Moderate (acceptable for desktop/server)
        # - Decompression speed: Fast (good for reads)
        # Use for: @, @home, @log, general data
        general = {
          algorithm = "zstd";
          level = 3;
          rationale = ''
            Zstandard level 3 offers the best balance of compression ratio
            and performance for general filesystem operations. Provides
            significant space savings with acceptable CPU overhead for
            read/write operations on typical desktop and server workloads.
          '';
          useCases = [
            "Root filesystem (@)"
            "Home directories (@home)"
            "System logs (@log)"
            "User data directories"
          ];
        };

        # ===== ZSTD:1 FOR NIX STORE AND CACHES =====
        # Compression level 1 prioritizes speed:
        # - Compression ratio: ~2x for typical files
        # - CPU overhead: Low (minimal impact on nix operations)
        # - Decompression speed: Very fast (critical for package access)
        # Use for: @nix, @cache, @user-cache
        nixCaches = {
          algorithm = "zstd";
          level = 1;
          rationale = ''
            Zstandard level 1 provides light compression with minimal CPU
            overhead. Critical for Nix store operations where performance
            matters more than space savings. The Nix package manager
            frequently accesses files, so decompression speed is prioritized.
          '';
          useCases = [
            "Nix store (@nix)"
            "System cache (@cache)"
            "User cache directories"
            "Package manager caches"
          ];
        };

        # ===== NO COMPRESSION FOR DATABASES =====
        # Databases should never use compression:
        # - CoW (Copy-on-Write) + compression = performance degradation
        # - Database files are often already compressed
        # - nodatacow is preferred for databases (more important than compression)
        # Use for: @postgresql, @redis, database files
        database = {
          algorithm = "no";
          level = null;
          rationale = ''
            Databases (PostgreSQL, Redis, etc.) should use no compression
            and prefer nodatacow for optimal performance. Database systems
            manage their own storage and caching, and CoW with compression
            causes significant performance overhead. Modern database files
            are often already compressed, making filesystem compression redundant.
          '';
          useCases = [
            "PostgreSQL data (@postgresql)"
            "Redis data (@redis)"
            "Database files and WAL"
            "Already-compressed data (images, videos, archives)"
          ];
        };

        # ===== NO COMPRESSION FOR CONTAINERS =====
        # Container layers benefit more from nodatacow:
        # - Container filesystems are designed for performance
        # - Layer compression provides minimal benefit
        # - nodatacow significantly improves container I/O
        # Use for: @containers, @podman-cache
        containers = {
          algorithm = "no";
          level = null;
          rationale = ''
            Container storage benefits more from nodatacow than compression.
            Container image layers are typically already compressed at the
            image level, making filesystem-level compression redundant.
            The nodatacow option provides significantly better I/O performance
            for container workloads.
          '';
          useCases = [
            "Container storage (@containers)"
            "Podman cache (@podman-cache)"
            "Container layer directories"
          ];
        };

        # ===== NO COMPRESSION FOR TEMP FILES =====
        # Temporary files should avoid compression overhead:
        # - Short lifespan doesn't justify compression overhead
        # - Typically already temporary/disposable
        # - Speed is more important than size
        # Use for: @tmp, temporary directories
        temporary = {
          algorithm = "no";
          level = null;
          rationale = ''
            Temporary files have a short lifespan, making compression
            overhead unjustified. These files are typically created,
            used briefly, and deleted. The CPU overhead of compression
            provides no long-term benefit for temporary data.
          '';
          useCases = [
            "Temporary directories (@tmp)"
            "Build temporary files"
            "Download staging areas"
            "Scratch space"
          ];
        };
      };
      readOnly = true;
    };

    storage.btrfs.compressionPerSubvolumeOverride = mkOption {
      description = ''
        Allow per-subvolume compression overrides.
        When enabled, specific subvolumes can override the default compression
        settings defined in presets.
      '';
      type = types.bool;
      default = true;
      defaultText = "true";
    };
  };

  config = {
    # Documentation for host profiles:
    # - Reference compression settings via: config.storage.btrfs.compressionSettings.*
    # - Override per-subvolume by specifying "compress" in mount options
    # - Combine with mountPresets for complete option sets
  };
}
