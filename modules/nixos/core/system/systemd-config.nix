{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.core.systemd;
in
{
  options.pantherOS.core.systemd = {
    enable = mkEnableOption "PantherOS systemd configuration";

    enableCoredump = mkOption {
      type = types.bool;
      default = true;
      description = "Enable systemd core dumps";
    };

    services = {
      enableEmergencyMode = mkOption {
        type = types.bool;
        default = false;
        description = "Enable emergency mode services";
      };
    };
  };

  config = mkIf cfg.enable {
    # Systemd configuration
    systemd = {
      enableCoredump = cfg.enableCoredump;
    };
  };
}