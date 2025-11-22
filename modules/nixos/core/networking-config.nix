{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.core.networking;
in
{
  options.pantherOS.core.networking = {
    enable = mkEnableOption "PantherOS core networking configuration";

    hostName = mkOption {
      type = types.str;
      default = "pantheros";
      description = "Hostname for the system";
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Domain name for the system";
    };

    useDHCP = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to use DHCP for all interfaces";
    };

    interfaces = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          ipAddress = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Static IP address for interface ${name}";
          };
        };
      }));
      default = {};
      description = "Configuration for network interfaces";
    };
  };

  config = mkIf cfg.enable {
    networking = {
      hostName = cfg.hostName;
      domain = cfg.domain;
      useDHCP = cfg.useDHCP;

      # Configure specific interfaces if provided
      interfaces = mkMerge (mapAttrsToList (name: interfaceCfg:
        mkIf (interfaceCfg.ipAddress != null) {
          ${name}.ipv4.addresses = [{
            address = interfaceCfg.ipAddress;
            prefixLength = 24;
          }];
        }
      ) cfg.interfaces);
    };
  };
}