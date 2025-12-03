{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.monitoring;
in {
  options.services.monitoring = {
    enable = mkEnableOption "Enable system monitoring infrastructure";

    provider = mkOption {
      type = types.enum [ "datadog" "prometheus" "none" ];
      default = "datadog";
      description = "Monitoring provider to use";
    };

    datadog = {
      apiKey = mkOption {
        type = types.str;
        default = "";
        description = "Datadog API key for agent configuration";
      };
      site = mkOption {
        type = types.enum [ "datadoghq.com" "datadoghq.eu" "us3.datadoghq.com" "us5.datadoghq.com" "ap1.datadoghq.com" ];
        default = "datadoghq.com";
        description = "Datadog site endpoint";
      };
    };

    prometheus = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Prometheus monitoring stack";
      };
      retention = mkOption {
        type = types.str;
        default = "15d";
        description = "Time series retention period";
      };
    };

    grafana = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Grafana visualization";
      };
      port = mkOption {
        type = types.port;
        default = 3000;
        description = "Grafana web interface port";
      };
    };

    enableExporters = mkOption {
      type = types.bool;
      default = true;
      description = "Enable node_exporter and other system exporters";
    };

    enableAlerts = mkOption {
      type = types.bool;
      default = true;
      description = "Enable alert rules and notifications";
    };
  };

  config = mkIf cfg.enable {
    imports = [
      ./datadog.nix
      ./prometheus.nix
      ./grafana.nix
      ./exporters.nix
    ];
  };
}
