{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.services.tailscale;
in
{
  options.pantherOS.services.tailscale = {
    enable = mkEnableOption "PantherOS Tailscale VPN service";

    package = mkOption {
      type = types.package;
      default = pkgs.tailscale;
      defaultText = "pkgs.tailscale";
      description = "Tailscale package to use";
    };

    permitCertUid = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Allow specified user to use Tailscale Certificates";
    };

    authWait = mkOption {
      type = types.bool;
      default = true;
      description = "Wait for interactive authentication during startup";
    };

    useRoutingFeatures = mkOption {
      type = types.enum [ "both" "server" "client" "none" ];
      default = "client";
      description = "Configure Tailscale for exit node or subnet router capabilities";
    };

    port = mkOption {
      type = types.port;
      default = 41641;
      description = "Tailscale port";
    };

    extraUpFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "--accept-dns=false" "--accept-routes=false" ];
      description = "Additional flags to pass to 'tailscale up'";
    };
  };

  config = mkIf cfg.enable {
    # Enable the Tailscale service
    services.tailscale = {
      enable = true;
      package = cfg.package;
      permitCertUid = cfg.permitCertUid;
      authWait = cfg.authWait;
      useRoutingFeatures = cfg.useRoutingFeatures;
      port = cfg.port;
      extraUpFlags = cfg.extraUpFlags;
    };

    # Additional security configurations
    environment.systemPackages = [ cfg.package ];

    # Enable the Tailscale service to start on boot
    systemd.services.tailscale = mkIf cfg.enable {
      after = [ "network-pre.target" ];
      wants = [ "network-pre.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}