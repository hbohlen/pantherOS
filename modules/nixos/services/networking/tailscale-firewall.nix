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

  config = mkIf (cfg.enable && config.pantherOS.services.tailscale.enable) {
    # Open the Tailscale port in the firewall
    networking.firewall.allowedUDPPorts = [ config.pantherOS.services.tailscale.port ];
  };
}