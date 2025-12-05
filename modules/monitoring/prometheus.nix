{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.monitoring;
in {
  config = mkIf (cfg.enable && cfg.provider == "prometheus" && cfg.prometheus.enable) {
    # Prometheus configuration
    services.prometheus = {
      enable = true;
      retentionTime = cfg.prometheus.retention;
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{ targets = [ "localhost:9100" ] }];
        }
      ];
    };

    # System packages
    environment.systemPackages = with pkgs; [
      prometheus
      node-exporter
      alertmanager
    ];
  };
}
