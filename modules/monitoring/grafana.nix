{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.monitoring;
in {
  config = mkIf (cfg.enable && cfg.grafana.enable) {
    # Grafana configuration
    services.grafana = {
      enable = true;
      port = cfg.grafana.port;
      domain = "localhost";
    };

    # System packages
    environment.systemPackages = with pkgs; [
      grafana
    ];
  };
}
