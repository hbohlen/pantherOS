# modules/storage/monitoring/default.nix
# Monitoring Integration Modules
# Manages Datadog metrics and alerting for storage operations

{ ... }:

{
  imports = [
    # Task Group 8: Monitoring Options
    ./options.nix
    # Task Group 8: Monitoring Implementation
    ./datadog.nix              # Task 8.1: Datadog custom metrics
    ./alerts.nix               # Task 8.4: Alert definitions
    ./disk-monitoring.nix      # Task 8.5: Disk space monitoring
  ];
}
