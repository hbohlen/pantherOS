# modules/storage/backup/default.nix
# Backup Integration Modules
# Manages Backblaze B2 backup configuration and scheduling

{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.storage.backup;
in

{
  imports = [
    # Backup modules - Task Group 7
    ./backblaze.nix           # B2 credential integration with OpNix
    ./scope.nix               # Backup scope configuration per host
    ./service.nix             # Backup job systemd service
    ./timer.nix               # Backup schedule timer
    ./bucket-structure.nix    # B2 bucket organization
    ./validation.nix          # Backup validation service
    ./cost-monitoring.nix     # B2 cost tracking and monitoring
    # Task Group 8: Monitoring
    ./monitoring.nix
  ];

  # Unified backup configuration options
  options.storage.backup = {
    enable = mkEnableOption "Enable PantherOS backup infrastructure";

    # B2 configuration (backblaze.nix)
    b2 = {
      enable = mkEnableOption "Enable Backblaze B2 integration";
      accountId = mkOption {
        type = types.str;
        default = "";
        description = "Backblaze B2 account ID";
      };
      keyId = mkOption {
        type = types.str;
        default = "";
        description = "Backblaze B2 key ID";
      };
      bucket = mkOption {
        type = types.str;
        default = "pantherOS-backups";
        description = "Backblaze B2 bucket for backups";
      };
    };

    # Subvolume scope (scope.nix)
    subvolumes = {
      enable = mkEnableOption "Enable subvolume backup configuration";
      paths = mkOption {
        type = types.listOf types.str;
        default = [ "/" "/home" "/etc" ];
        description = "Subvolume paths to backup";
      };
    };

    # Service configuration (service.nix)
    service = {
      enable = mkEnableOption "Enable backup service";
      retryAttempts = mkOption {
        type = types.int;
        default = 3;
        description = "Number of retry attempts";
      };
    };

    # Timer configuration (timer.nix)
    timer = {
      enable = mkEnableOption "Enable backup timer";
      schedule = mkOption {
        type = types.str;
        default = "02:00";
        description = "Backup schedule (HH:MM)";
      };
      persistent = mkOption {
        type = types.bool;
        default = true;
        description = "Run missed backups on boot";
      };
    };

    # Validation configuration (validation.nix)
    validation = {
      enable = mkEnableOption "Enable backup validation";
      schedule = mkOption {
        type = types.enum [ "daily" "weekly" "monthly" ];
        default = "weekly";
        description = "Validation frequency";
      };
    };

    # Cost monitoring configuration (cost-monitoring.nix)
    costMonitoring = {
      enable = mkEnableOption "Enable B2 cost monitoring";
      warningThreshold = mkOption {
        type = types.int;
        default = 800;
        description = "Cost warning threshold (cents)";
      };
      criticalThreshold = mkOption {
        type = types.int;
        default = 1000;
        description = "Cost critical threshold (cents)";
      };
    };

    # B2 bucket lifecycle (bucket-structure.nix)
    bucket = {
      enable = mkEnableOption "Enable B2 bucket structure";
      lifecycle = {
        costWarning = mkOption {
          type = types.int;
          default = 800;
          description = "Cost warning in cents";
        };
        costCritical = mkOption {
          type = types.int;
          default = 1000;
          description = "Cost critical in cents";
        };
      };
    };

    # Monitoring configuration (monitoring.nix) - Task Group 8
    monitoring = {
      enable = mkEnableOption "Enable backup monitoring metrics";
    };
  };

  config = mkIf (cfg.enable || cfg.b2.enable || cfg.subvolumes.enable || cfg.service.enable || cfg.timer.enable || cfg.validation.enable || cfg.costMonitoring.enable || cfg.monitoring.enable) {
    # Comprehensive backup documentation
    environment.etc."backups/README".text = ''
      # PantherOS Backup Infrastructure

      Complete backup solution using btrbk and Backblaze B2.

      ## Components

      ### 7.1 Backblaze B2 Integration (backblaze.nix)
      - Secure credential management via OpNix/1Password
      - S3-compatible API integration
      - Environment configuration

      ### 7.2 Backup Scope (scope.nix)
      - Configurable subvolume backup lists
      - Database subvolumes auto-included
      - Host type-specific optimization

      ### 7.3 Backup Service (service.nix)
      - systemd service with retry logic
      - Resource limits (IO/CPU)
      - Comprehensive logging

      ### 7.4 Backup Timer (timer.nix)
      - Nightly scheduling (02:00 default)
      - Randomized delay (30min) to stagger hosts
      - Persistent (runs missed backups on boot)

      ### 7.5 B2 Bucket Structure (bucket-structure.nix)
      - Organized: hostname/subvolume/year/month/
      - Timestamp format: YYYYMMDD_HHMMSS
      - Lifecycle policy documentation

      ### 7.6 Backup Validation (validation.nix)
      - Weekly validation of backup integrity
      - Checks backup recency and size
      - Reports to monitoring systems

      ### 7.7 Cost Monitoring (cost-monitoring.nix)
      - Tracks B2 storage usage
      - Alerts at $8 (warning) and $10 (critical)
      - Monthly cost reports

      ## Task Group 8: Monitoring

      ### 8.3 Backup Metrics (monitoring.nix)
      - Emits Datadog metrics for backup operations
      - Tracks completion, failures, duration, size
      - Integrates with backup service and validation

      ## Quick Start

      1. Enable backup infrastructure:
         storage.backup.enable = true;
         storage.backup.b2.enable = true;
         storage.backup.b2.opnix.enable = true;

      2. Configure 1Password secret:
         op://pantherOS/backblaze-b2/backup-credentials

      3. Customize backup scope (optional):
         storage.backup.subvolumes.paths = [ "/" "/home" "/etc" "/var/lib/postgresql" ];

      4. Enable services:
         storage.backup.service.enable = true;
         storage.backup.timer.enable = true;
         storage.backup.validation.enable = true;
         storage.backup.costMonitoring.enable = true;
         storage.backup.monitoring.enable = true;

      5. Rebuild system:
         sudo nixos-rebuild switch

      ## Management Commands

      Check backup status:
        sudo systemctl status panther-backup-timer.timer
        sudo systemctl status panther-backup.service

      Run backup manually:
        sudo systemctl start panther-backup.service

      Run validation:
        sudo systemctl start panther-backup-validation.service

      Check costs:
        sudo systemctl start panther-backup-cost-monitor.service
        sudo tail /var/log/panther-backup/cost-report.log

      View logs:
        sudo journalctl -u panther-backup.service -f
        sudo tail -f /var/log/panther-backup/backup.log

      ## Security

      - Credentials managed via OpNix/1Password
      - No secrets in Nix store
      - HTTPS/TLS for all B2 communication
      - Encrypted backups at rest in B2

      ## Backup Strategy

      1. Local Btrfs snapshots (fast, instant)
      2. B2 cloud sync (disaster recovery)
      3. Retention: 7d/4w/12m local, 30d/12w/12m remote
      4. Validation: weekly integrity checks
      5. Cost control: $5-10/month budget

      For detailed documentation, see:
      - /etc/backups/b2/README
      - /etc/backups/bucket-structure/README
      - /etc/backups/validation/README
      - /etc/backups/cost-monitoring/README

      Project: https://github.com/digint/btrbk
    '';
  };
}
