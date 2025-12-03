{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.monitoring;
in {
  config = mkIf (cfg.enable && cfg.enableExporters) {
    # System exporters configuration
    services.node-exporter = {
      enable = true;
      port = 9100;
    };

    # Additional monitoring packages
    environment.systemPackages = with pkgs; [
      node-exporter
      htop
      btop
      iotop
      nethogs
    ];
  };
}
