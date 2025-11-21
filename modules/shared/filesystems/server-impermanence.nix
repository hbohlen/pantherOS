{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.serverImpermanence;
in
{
  options.pantherOS.serverImpermanence = {
    enable = mkEnableOption "Server-optimized impermanence with Btrfs snapshots";
    
    excludePaths = mkOption {
      type = types.listOf types.str;
      default = [
        "/persist"
        "/nix"
        "/var/log"
        "/var/lib/services"
        "/var/lib/caddy"
        "/var/backup"
        "/var/lib/containers"
        "/btrfs_tmp"
      ];
      description = "Paths to preserve across reboots";
    };
    
    snapshotPolicy = mkOption {
      type = types.attrsOf types.str;
      default = {
        frequency = "6h";
        retention = "30d";
        scope = "critical";
      };
      description = "Automated snapshot policy";
    };
    
    performanceMode = mkOption {
      type = types.enum [ "balanced" "io-optimized" "space-optimized" ];
      default = "balanced";
      description = "Performance tuning mode for server workloads";
    };
  };
  
  config = mkIf cfg.enable {
    # Implementation will be completed in Task 1.2
  };
}