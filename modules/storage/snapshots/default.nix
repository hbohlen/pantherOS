# modules/storage/snapshots/default.nix
# Snapshot Automation Modules
# Manages snapper configuration and snapshot scheduling

{ ... }:

{
  imports = [
    # Snapshot modules added in Task Group 6
    ./policies.nix
    ./snapper.nix
    ./automation.nix
    ./hooks.nix
    ./manual-helper.nix
    # Task Group 8: Monitoring
    ./monitoring.nix
  ];
}
