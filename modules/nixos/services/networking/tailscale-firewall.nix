{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.services.tailscale;
in
{
  options.pantherOS.services.tailscale.firewall = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable firewall configuration for Tailscale";
    };
  };

  config = mkIf (cfg.firewall.enable && cfg.enable) {
    # Open the Tailscale port in the firewall
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}
