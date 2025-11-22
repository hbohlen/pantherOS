{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.security.firewall;
in
{
  options.pantherOS.security.firewall = {
    enable = mkEnableOption "PantherOS firewall configuration";

    allowedTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of allowed TCP ports";
    };

    allowedUDPPorts = mkOption {
      type = types.listOf types.port;
      default = [ ];
      description = "List of allowed UDP ports";
    };

    trustedInterfaces = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of network interfaces to trust";
    };

    enableLogging = mkOption {
      type = types.bool;
      default = false;
      description = "Enable firewall logging";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = cfg.allowedTCPPorts;
      allowedUDPPorts = cfg.allowedUDPPorts;
      trustedInterfaces = cfg.trustedInterfaces;
      logRefusedConnections = cfg.enableLogging;
    };
  };
}