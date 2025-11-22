{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.services.monitoring;
in
{
  options.pantherOS.services.monitoring = {
    enable = mkEnableOption "PantherOS system monitoring services";
    
    enablePrometheus = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Prometheus monitoring stack";
      };
      
      port = mkOption {
        type = types.port;
        default = 9090;
        description = "Prometheus web interface port";
      };
    };
    
    enableNodeExporter = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable node_exporter for system metrics";
      };
      
      port = mkOption {
        type = types.port;
        default = 9100;
        description = "Node exporter port";
      };
    };
    
    enableGrafana = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Grafana for dashboard visualization";
      };
      
      port = mkOption {
        type = types.port;
        default = 3000;
        description = "Grafana web interface port";
      };
    };
    
    enableAlertManager = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable AlertManager for alert handling";
      };
      
      port = mkOption {
        type = types.port;
        default = 9093;
        description = "AlertManager web interface port";
      };
    };
  };

  config = mkIf cfg.enable {
    # Prometheus configuration
    services.prometheus = mkIf cfg.enablePrometheus.enable {
      enable = cfg.enablePrometheus.enable;
      port = cfg.enablePrometheus.port;
      
      # Exporters to be enabled based on system requirements
      exporters = {};
    };
    
    # Node exporter configuration
    services.prometheus = mkIf cfg.enableNodeExporter.enable {
      exporters = mkIf cfg.enableNodeExporter.enable {
        node = {
          enable = cfg.enableNodeExporter.enable;
          port = cfg.enableNodeExporter.port;
          enabledCollectors = [ "systemd" "diskstats" "filesystem" "loadavg" "meminfo" "netdev" "time" "vmstat" ];
        };
      };
    };
    
    # Grafana configuration
    services.grafana = mkIf cfg.enableGrafana.enable {
      enable = cfg.enableGrafana.enable;
      port = cfg.enableGrafana.port;
      settings = {
        "auth.anonymous" = {
          enabled = true;
          org_role = "Viewer";
        };
        "server" = {
          serve_from_sub_path = true;
        };
      };
    };
    
    # AlertManager configuration
    services.alertmanager = mkIf cfg.enableAlertManager.enable {
      enable = cfg.enableAlertManager.enable;
      configFile = pkgs.writeText "alertmanager.yml" ''
        global:
          smtp_smarthost: 'localhost:587'
          smtp_from: 'alertmanager@localhost'
          smtp_auth_username: 'alertmanager'
          smtp_auth_password: 'password'
        
        route:
          group_by: ['alertname']
          group_wait: 10s
          group_interval: 10s
          repeat_interval: 1h
          receiver: 'web.hook'
        
        receivers:
        - name: 'web.hook'
          webhook_configs:
          - url: 'http://localhost:5001/webhook'
        
        inhibit_rules:
        - source_match:
            severity: 'critical'
          target_match:
            severity: 'warning'
          equal: ['alertname', 'dev', 'instance']
      '';
    };
    
    # System packages for monitoring
    environment.systemPackages = with pkgs; []
      ++ (mkIf cfg.enablePrometheus.enable [ prometheus ])
      ++ (mkIf cfg.enableGrafana.enable [ grafana ])
      ++ (mkIf cfg.enableNodeExporter.enable [ node_exporter ]);
    
    # Firewall configuration for monitoring services
    networking.firewall = {
      allowedTCPPorts = 
        (mkIf cfg.enablePrometheus.enable [ cfg.enablePrometheus.port ])
        ++ (mkIf cfg.enableNodeExporter.enable [ cfg.enableNodeExporter.port ])
        ++ (mkIf cfg.enableGrafana.enable [ cfg.enableGrafana.port ])
        ++ (mkIf cfg.enableAlertManager.enable [ cfg.enableAlertManager.port ]);
    };
  };
}