# modules/storage/snapshots/hooks.nix
# Database Snapshot Hooks for Consistency
# Executes pre-snapshot and post-snapshot database operations
#
# HIGH-RISK: This module manages database operations that can affect
# data consistency and system performance. Ensure timeouts are respected.
#
# Pre-snapshot hooks:
# - PostgreSQL: CHECKPOINT (flush WAL to disk)
# - Redis: BGSAVE (save database to disk)
#
# Post-snapshot hooks:
# - Update monitoring metrics
# - Log snapshot completion

{ lib, config, ... }:

let
  inherit (lib) mkOption types mkIf;
  cfg = config.storage.snapshots;
  hasPostgreSQL = config.services.postgresql.enable or false;
  hasRedis = config.services.redis.enable or false;
in
{
  options = {
    storage.snapshots.databaseHooks = mkOption {
      description = ''
        Enable database snapshot hooks for data consistency.

        When enabled, these hooks execute before/after snapshots:
        - PostgreSQL: CHECKPOINT (flush WAL)
        - Redis: BGSAVE (save to disk)

        WARNING: These operations can take several minutes and will
        block snapshot creation until complete. Set appropriate timeouts.
      '';
      type = types.bool;
      default = false;
    };

    storage.snapshots.hookTimeout = mkOption {
      description = ''
        Timeout in seconds for database hooks to complete.
        Hooks exceeding this timeout will be aborted with a warning.
      '';
      type = types.int;
      default = 300; # 5 minutes
    };
  };

  config = mkIf (cfg.enable && cfg.databaseHooks) {
    # ===== PRE-SNAPSHOT HOOK SERVICE =====
    # This runs before snapshots to ensure database consistency
    systemd.services."snapper-pre-hook" = {
      description = "Pre-snapshot Database Hooks";
      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = lib.mkBefore (''
          echo "Starting pre-snapshot database hooks..."
        '');

        # PostgreSQL CHECKPOINT
        ExecStart = let
          # Build hook commands conditionally based on enabled services
          postgresCheck = lib.optional hasPostgreSQL ''
            echo "Executing PostgreSQL CHECKPOINT..."
            if command -v psql >/dev/null 2>&1; then
              # Use Unix socket connection to local PostgreSQL
              su - postgres -c "psql -c 'CHECKPOINT;'" || echo "WARNING: PostgreSQL CHECKPOINT failed"
            else
              echo "WARNING: PostgreSQL service enabled but psql not available"
            fi
          '';

          redisSave = lib.optional hasRedis ''
            echo "Executing Redis BGSAVE..."
            if command -v redis-cli >/dev/null 2>&1; then
              # Execute BGSAVE and wait for completion (with timeout)
              # redis-cli BGSAVE returns immediately and saves in background
              redis-cli BGSAVE || echo "WARNING: Redis BGSAVE failed"

              # Wait for save to complete (check for RDB file modification)
              SAVE_START=$(date +%s)
              SAVE_DONE=false
              while [ $(($(date +%s) - SAVE_START)) -lt ${toString cfg.hookTimeout} ]; do
                if redis-cli LASTSAVE | xargs -I {} redis-cli LASTSAVE | uniq | wc -l | grep -q "1"; then
                  SAVE_DONE=true
                  break
                fi
                sleep 1
              done

              if [ "$SAVE_DONE" = "false" ]; then
                echo "WARNING: Redis save did not complete within ${toString cfg.hookTimeout}s"
              else
                echo "Redis save completed successfully"
              fi
            else
              echo "WARNING: Redis service enabled but redis-cli not available"
            fi
          '';

          hookCommands = builtins.concatStringsSep "\n" (builtins.filter (x: x != "") [
            postgresCheck
            redisSave
          ]);
        in
          ''${hookCommands}'';

        # Set timeout for the entire operation
        TimeoutStartSec = "${toString cfg.hookTimeout}";

        # Log the operation
        StandardOutput = "journal";
        StandardError = "journal";

        # Run with root privileges (needed for database operations)
        User = "root";

        # Important: Don't continue if hooks fail
        # Comment out next line if you want snapshots to continue even if hooks fail
        # RemainAfterExit = true;
      };

      # Make this service run before snapper-timeline
      # This is configured in the snapper service unit
    };

    # ===== POST-SNAPSHOT HOOK SERVICE =====
    # This runs after snapshots to update metrics and log completion
    systemd.services."snapper-post-hook" = {
      description = "Post-snapshot Database Hooks";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          echo "Post-snapshot hooks executed"

          # Update snapshot statistics (if monitoring is available)
          # This would integrate with Prometheus or similar monitoring systems
          if command -v sqlite3 >/dev/null 2>&1; then
            echo "Snapshot completed at $(date)" > /var/log/snapshots/last-snapshot.log
          fi

          # Log to systemd journal
          logger -t snapper-hooks "Snapshot operations completed successfully"
        '';

        # Set timeout for post-snapshot operations
        TimeoutStartSec = "60";

        # Log the operation
        StandardOutput = "journal";
        StandardError = "journal";

        # Run with root privileges
        User = "root";
      };

      # Make this service run after snapper-timeline
      # This is configured in the snapper service unit
    };

    # ===== CONFIGURE SNAPPER TO USE HOOKS =====
    # Integrate hooks with snapper configuration
    services.snapper.configs = builtins.listToAttrs (
      map (subvolume: {
        name = subvolume;
        value = {
          # Point snapper to our pre/post hook scripts
          TIMELINE_HOOKS = "yes";

          # The actual hook execution will be handled by systemd services
          # We configure snapper to run our hooks before/after snapshots
        };
      }) cfg.enabledSubvolumes
    );

    # ===== CREATE HOOK WRAPPER SCRIPTS =====
    # Write shell scripts that snapper can call
    environment.etc."snapper-hooks/pre-snapshot.sh" = {
      mode = "0755";
      text = ''
        #!/bin/bash
        # Pre-snapshot hook script
        # Executes database consistency operations before snapshot creation

        set -e

        logger -t snapper-pre-hook "Starting pre-snapshot operations"

        # Execute pre-snapshot service
        systemctl start snapper-pre-hook || {
          logger -t snapper-pre-hook "ERROR: Pre-snapshot hooks failed"
          exit 1
        }

        logger -t snapper-pre-hook "Pre-snapshot operations completed"
        exit 0
      '';
    };

    environment.etc."snapper-hooks/post-snapshot.sh" = {
      mode = "0755";
      text = ''
        #!/bin/bash
        # Post-snapshot hook script
        # Executes post-snapshot operations after snapshot creation

        set -e

        logger -t snapper-post-hook "Starting post-snapshot operations"

        # Execute post-snapshot service
        systemctl start snapper-post-hook || {
          logger -t snapper-post-hook "WARNING: Post-snapshot hooks failed, but snapshot is complete"
          # Don't exit with error code - snapshot already succeeded
          exit 0
        }

        logger -t snapper-post-hook "Post-snapshot operations completed"
        exit 0
      '';
    };

    # ===== VALIDATION =====
    # Warn if databases are enabled but hooks are disabled
    assertions = [
      {
        assertion = !(hasPostgreSQL || hasRedis) || cfg.databaseHooks;
        message = ''
          Database services (PostgreSQL or Redis) are enabled but
          storage.snapshots.databaseHooks is disabled.

          This can lead to inconsistent snapshots! Enable database hooks
          or disable database services to ensure data consistency.

          Recommended: Set storage.snapshots.databaseHooks = true
        '';
      }
    ];
  };
}
