# modules/storage/monitoring/options.nix
# Storage Monitoring Options
# Centralized configuration options for all storage monitoring modules

{ lib, ... }:

with lib;

{
  options.storage.monitoring = {
    enable = mkEnableOption "Enable storage monitoring infrastructure";

    # Datadog configuration
    datadog = {
      enable = mkEnableOption "Enable Datadog custom metrics for storage";

      statsdPort = mkOption {
        type = types.port;
        default = 8125;
        description = "Datadog StatsD port (agent listens on localhost)";
      };

      statsdHost = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Datadog StatsD host";
      };

      namespace = mkOption {
        type = types.str;
        default = "pantheros";
        description = "Metric namespace prefix";
      };
    };

    # Alert configuration
    alerts = {
      enable = mkEnableOption "Enable storage monitoring alert rules";
    };

    # Disk monitoring configuration
    disk = {
      enable = mkEnableOption "Enable disk space and Btrfs monitoring";
    };
  };
}
