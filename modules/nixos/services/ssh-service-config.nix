{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.services.ssh-service;
in
{
  options.pantherOS.services.ssh-service = {
    enable = mkEnableOption "PantherOS SSH service configuration";

    enablePasswordAuthentication = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow password authentication";
    };

    enableRootLogin = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow root login";
    };

    ports = mkOption {
      type = types.listOf types.port;
      default = [ 22 ];
      description = "Ports on which SSH server will listen";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional SSH daemon configuration";
    };
  };

  config = mkIf cfg.enable {
    services = {
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = cfg.enablePasswordAuthentication;
          PermitRootLogin = mkIf cfg.enableRootLogin (mkOverride 10 "yes");
          Ports = cfg.ports;
        };
        extraConfig = cfg.extraConfig;
      };
    };
  };
}