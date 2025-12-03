{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.monitoring;
in {
  config = mkIf (cfg.enable && cfg.provider == "datadog") {
    # Datadog agent configuration
    services.datadog-agent = {
      enable = true;
      site = cfg.datadog.site;
    };

    # System packages for monitoring
    environment.systemPackages = with pkgs; [
      datadog-agent
      htop
      btop
      nvtop
    ];

    # Datadog agent environment variables
    environment.sessionVariables = {
      DD_API_KEY = cfg.datadog.apiKey;
      DD_SITE = cfg.datadog.site;
    };
  };
}
