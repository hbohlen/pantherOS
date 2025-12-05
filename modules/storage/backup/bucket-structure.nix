# B2 Bucket Structure Module
# Defines and documents the Backblaze B2 bucket directory organization
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.storage.backup;
in
{
  options.storage.backup.bucket = {
    enable = mkEnableOption "Enable B2 bucket structure organization";

    # Base structure organization
    structure = {
      hostnameBased = mkOption {
        type = types.bool;
        default = true;
        description = "Organize backups by hostname";
      };

      temporalSubdirs = mkOption {
        type = types.bool;
        default = true;
        description = "Create year/month subdirectories";
      };
    };

    # Backup naming convention
    naming = {
      timestampFormat = mkOption {
        type = types.str;
        default = "%Y%m%d_%H%M%S";
        description = "Timestamp format for backup files";
        example = "%Y%m%d_%H%M%S";
      };

      separator = mkOption {
        type = types.str;
        default = "_";
        description = "Separator used in backup file names";
      };
    };

    # Lifecycle and retention (documented for B2 console configuration)
    lifecycle = {
      # Note: These are documented for manual B2 console configuration
      # B2 doesn't have automatic lifecycle rules in API, so we document the policy

      defaultRetention = mkOption {
        type = types.str;
        default = "keep_all";
        description = ''
          Default retention policy for backups.
          Note: This must be configured manually in B2 console or via API.
          Recommended: Archive old backups after 1 year, delete after 3 years.
        '';
      };

      # Document the cost implications
      costWarning = mkOption {
        type = types.int;
        default = 8000; # $8.00 in cents
        description = "Warning threshold in cents ($8.00 = 800 cents)";
      };

      costCritical = mkOption {
        type = types.int;
        default = 10000; # $10.00 in cents
        description = "Critical threshold in cents ($10.00 = 1000 cents)";
      };
    };
  };

  config = mkIf cfg.bucket.enable {
    # Documentation for bucket structure
    environment.etc."backups/bucket-structure/README".text = ''
      # Backblaze B2 Bucket Structure

      This document describes the backup organization structure in the B2 bucket: ${cfg.b2.bucket}

      ## Directory Structure

      ### Base Structure

      Backups are organized hierarchically:

      ```
      ${cfg.b2.bucket}/
      ├── <hostname>/
      │   ├── <subvolume>/
      │   │   ├── 2024/
      │   │   │   └── 12/
      │   │   │       ├── <timestamp>_root_snapshots.tar.zst
      │   │   │       ├── <timestamp>_home_snapshots.tar.zst
      │   │   │       └── <timestamp>_etc_snapshots.tar.zst
      │   │   └── (archived or deleted per retention policy)
      │   └── ...
      └── (other hosts)
      ```

      ### Hostname-Based Organization

      ${if cfg.bucket.structure.hostnameBased then ''
      Backups are organized by hostname to support:
      - Multi-host deployments with centralized backup bucket
      - Easy identification of backup sources
      - Simplified cross-host restore operations

      Each host gets its own directory with backups organized by subvolume.
      '' else ''
      Backups are stored directly in bucket root (not recommended for multi-host).
      ''}

      ### Temporal Organization

      ${if cfg.bucket.structure.temporalSubdirs then ''
      Year/month subdirectories provide:
      - Easier navigation and browsing in B2 console
      - Simplified retention policy application
      - Clear backup history at a glance
      - Efficient lifecycle management

      Example: 2024/12/ contains all backups from December 2024
      '' else ''}
      Backups stored without temporal directories (flat structure).

      ## Backup File Naming

      ### Format: `<timestamp>_<subvolume>_snapshots.tar.zst`

      Examples:
      - `20241204_020000_root_snapshots.tar.zst`
      - `20241204_020000_home_snapshots.tar.zst`
      - `20241204_020000_etc_snapshots.tar.zst`
      - `20241204_020000_postgresql_snapshots.tar.zst`

      ### Naming Components

      - **Timestamp**: ${cfg.bucket.naming.timestampFormat}
        - YYYYMMDD_HHMMSS format for sorting and readability
        - Matches backup execution time

      - **Subvolume**: Source subvolume path
        - Replaced spaces with underscores
        - Removed leading slashes for filesystem safety
        - Examples: `root`, `home`, `etc`, `var_lib_postgresql`

      - **Suffix**: `_snapshots.tar.zst`
        - Indicates this is a snapshot archive
        - .zst compression for efficiency

      ## Subvolume Organization

      Each subvolume gets its own directory for:

      1. **Isolation**: Problems in one subvolume don't affect others
      2. **Parallel Uploads**: btrbk can upload subvolumes in parallel
      3. **Selective Restore**: Easier to restore specific subvolumes
      4. **Incremental Efficiency**: Only changed subvolumes are synced

      Example for a server with databases:

      ```
      ${cfg.b2.bucket}/${config.networking.hostName}/
      ├── root/
      │   └── 2024/
      │       └── 12/
      │           └── 20241204_020000_root_snapshots.tar.zst
      ├── home/
      │   └── 2024/
      │       └── 12/
      │           └── 20241204_020000_home_snapshots.tar.zst
      ├── etc/
      │   └── 2024/
      │       └── 12/
      │           └── 20241204_020000_etc_snapshots.tar.zst
      ├── var_lib_postgresql/
      │   └── 2024/
      │       └── 12/
      │           └── 20241204_020000_var_lib_postgresql_snapshots.tar.zst
      └── var_lib_redis/
          └── 2024/
              └── 12/
                  └── 20241204_020000_var_lib_redis_snapshots.tar.zst
      ```

      ## Retention Policy

      ### Local Snapshots (Btrfs)
      - 7 daily snapshots
      - 4 weekly snapshots
      - 12 monthly snapshots
      - Automatically cleaned by btrbk

      ### Remote Backups (B2)
      - 30 daily backups
      - 12 weekly backups
      - 12 monthly backups
      - Configured in btrbk.conf

      ### Lifecycle Management

      Recommended B2 lifecycle rules (configure in B2 console):

      1. **Keep all backups for 30 days**
         - Ensures recent backups are always available
         - Covers daily operational recovery needs

      2. **Archive backups older than 30 days**
         - Move to B2's "Archive" tier for cost savings
         - Still retrievable for disaster recovery

      3. **Delete backups older than 3 years (1095 days)**
         - Long-term retention in B2 "Deep Archive" or delete
         - Balances disaster recovery needs with cost

      **Cost Warning**: Monitor storage usage regularly
      - Current configuration typically costs $${cfg.bucket.lifecycle.costWarning / 100}/month
      - Critical threshold: $${cfg.bucket.lifecycle.costCritical / 100}/month
      - Pricing: $0.005/GB/month for standard storage

      ## Backup Types

      ### Snapshot Backups
      - Btrfs read-only snapshots
      - Created locally before upload
      - Efficient with Btrfs copy-on-write
      - Fast to create, minimal space overhead

      ### Archive Files
      - Snapshots compressed with zstd
      - Single-file archives for easy restore
      - Checksum verification for integrity
      - Universal format (tar.zst)

      ## Restoration

      To restore from B2 backups:

      1. **List available backups**:
         ```bash
         b2 list-file-names ${cfg.b2.bucket}/${config.networking.hostName}/root/2024/12/
         ```

      2. **Download backup**:
         ```bash
         b2 download-file-by-name ${cfg.b2.bucket}/${config.networking.hostName}/root/2024/12/ \
           20241204_020000_root_snapshots.tar.zst /tmp/restore.tar.zst
         ```

      3. **Extract snapshot**:
         ```bash
         tar -xf /tmp/restore.tar.zst -C /
         ```

      4. **Apply snapshot**:
         ```bash
         btrfs subvolume snapshot /.snapshots/<snapshot-name> /
         ```

      For detailed restore procedures, see the backup validation service documentation.

      ## Security

      - All backups are encrypted at rest in B2
      - S3-compatible API uses HTTPS (TLS 1.2+)
      - Credentials managed via OpNix/1Password
      - No credentials stored in Nix store or config files

      ## Monitoring

      Use the backup validation service to:
      - Verify backups exist and are recent
      - Check backup sizes for reasonableness
      - Monitor B2 storage costs
      - Alert on failures

      For more information:
      - btrbk documentation: https://github.com/digint/btrbk
      - B2 API documentation: https://www.backblaze.com/b2/docs/
    '';

    # Example B2 commands for bucket management
    environment.etc."backups/bucket-structure/examples.sh".text = ''
      #!/bin/bash
      # B2 Bucket Management Examples

      # List all backups for this host
      b2 list-file-names ${cfg.b2.bucket}/${config.networking.hostName}/ | head -50

      # List backups for specific subvolume
      b2 list-file-names ${cfg.b2.bucket}/${config.networking.hostName}/root/2024/12/

      # Get backup size
      b2 get-file-info <file-id> | grep contentLength

      # Calculate total storage used
      b2 ls -r ${cfg.b2.bucket}/${config.networking.hostName}/ | \\
        awk '{sum += $1} END {print "Total: " sum/1024/1024 " GB"}'

      # Download latest backup
      LATEST=$(b2 list-file-names ${cfg.b2.bucket}/${config.networking.hostName}/root/2024/12/ | \\
        tail -1 | awk '{print $4}')
      b2 download-file-by-name ${cfg.b2.bucket}/${config.networking.hostName}/root/2024/12/ "$LATEST" backup.tar.zst

      # Delete old backups (use with caution)
      # b2 delete-file-version <file-id>

      echo "Bucket: ${cfg.b2.bucket}"
      echo "Host: ${config.networking.hostName}"
      echo "Structure: hostname/subvolume/year/month/backup.tar.zst"
    '';
  };
}
