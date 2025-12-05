# Backup Scope Configuration Module
# Defines which subvolumes should be backed up for different host types
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.storage.backup;
in
{
  options.storage.backup.subvolumes = {
    enable = mkEnableOption "Enable subvolume-based backup configuration";

    # List of subvolume paths to backup
    paths = mkOption {
      type = types.listOf types.str;
      default = [ "/" "/home" "/etc" ];
      description = ''
        List of subvolume paths to include in backups.
        Default includes critical system paths:
        - / (root filesystem)
        - /home (user data)
        - /etc (system configuration)
      '';
      example = [ "/" "/home" "/etc" "/var/lib/postgresql" ];
    };

    # Include database subvolumes automatically
    includeDatabases = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically add database subvolumes when databases are enabled";
    };

    # Include container data
    includeContainers = mkOption {
      type = types.bool;
      default = false;
      description = "Include /var/lib/containers subvolume (useful for laptops with Docker/Podman)";
    };

    # Exclude paths (patterns to skip)
    excludePatterns = mkOption {
      type = types.listOf types.str;
      default = [
        "/var/lib/atticd"     # Binary cache storage
        "/.snapshots"         # Local snapshots (don't backup backups)
        "/tmp/*"              # Temporary files
        "/var/cache/*"        # Cache directories
        "/var/lib/nix/*"      # Nix build cache
      ];
      description = "Patterns to exclude from backups";
    };

    # Host type-specific presets
    hostType = mkOption {
      type = types.enum [ "server" "laptop" "workstation" "utility" ];
      default = "server";
      description = "Host type for optimizing backup scope";
    };
  };

  config = mkIf cfg.subvolumes.enable {
    # Calculate final backup scope based on configuration
    # This merges defaults with host-specific additions
    storage.backup.finalSubvolumes = {
      paths = mkIf (cfg.subvolumes.includeDatabases && config.services.databases.enable) (
        # Database subvolumes are auto-added when databases are enabled
        # These paths are determined by the database modules
        cfg.subvolumes.paths ++ [
          "/var/lib/postgresql"
          "/var/lib/redis"
        ]
      ) (cfg.subvolumes.paths ++ mkIf cfg.subvolumes.includeContainers [
        # Optionally include containers subvolume for laptops
        "/var/lib/containers"
      ]);
    };

    # Documentation explaining backup scope decisions
    environment.etc."backup-scope/README".text = ''
      # Backup Scope Configuration

      This system is configured as a ${cfg.subvolumes.hostType} with the following backup scope:

      ## Included Subvolumes

      ${concatStringsSep "\n" (map (p: "  - ${p}") cfg.subvolumes.paths)}

      ${if cfg.subvolumes.includeDatabases && config.services.databases.enable then ''
      ### Database Subvolumes (Auto-Added)

      Databases are enabled on this system, so database subvolumes are automatically included:
      ${if config.services.postgresql.enable then "  - /var/lib/postgresql (PostgreSQL data)" else ""}
      ${if config.services.redis.enable then "      - /var/lib/redis (Redis data)" else ""}
      '' else ""}

      ${if cfg.subvolumes.includeContainers then ''
      ### Container Data

      Container subvolumes are included:
      - /var/lib/containers
      '' else ""}

      ## Excluded Patterns

      The following patterns are excluded from backups:
      ${concatStringsSep "\n" (map (p: "  - ${p}") cfg.subvolumes.excludePatterns)}

      ## Backup Scope Rationale

      ### Default Scope (/, /home, /etc)

      - **Root (/)**: System files, applications, and critical data
      - **/home**: User data, documents, and personal configurations
      - **/etc**: System configuration files (essential for recovery)

      ### Database Subvolumes

      Automatically included when databases are enabled:
      - PostgreSQL: Transactional database with critical application data
      - Redis: In-memory database often used for caching and session storage

      These are high-priority because they contain:
      - Application state and data
      - User-generated content
      - System configuration that changes frequently

      ### Laptop-Specific (Containers)

      Optional for laptops that run containers:
      - /var/lib/containers: Container images and runtime data
      - Useful for development environments with Docker/Podman
      - Can consume significant space, so optional for space-constrained laptops

      ### Excluded for Good Reason

      - **/.snapshots**: Local Btrfs snapshots (redundant to backup locally)
      - **/tmp**: Temporary files that don't need backing up
      - **/var/cache**: Cache data that can be recreated
      - **/var/lib/nix**: Nix build cache (can be regenerated)
      - **/var/lib/atticd**: Binary cache storage (managed separately)

      ## Backup Strategy

      Backups are created using btrbk with the following approach:
      1. Create read-only Btrfs snapshots of included subvolumes
      2. Synchronize snapshots to Backblaze B2 cloud storage
      3. Maintain retention policy: 7 daily, 4 weekly, 12 monthly

      This provides both local (fast restore) and remote (disaster recovery) protection.

      For more information: https://github.com/digint/btrbk
    '';
  };
}
