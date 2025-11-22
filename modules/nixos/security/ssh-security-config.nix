{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.security.ssh-security;
in
{
  options.pantherOS.security.ssh-security = {
    enable = mkEnableOption "PantherOS SSH security configuration";

    sshPort = mkOption {
      type = types.port;
      default = 22;
      description = "SSH port for security configurations";
    };

    fail2banEnabled = mkOption {
      type = types.bool;
      default = true;
      description = "Enable fail2ban for SSH protection";
    };
  };

  config = mkIf cfg.enable {
    # SSH security configurations
    services = mkIf cfg.fail2banEnabled {
      fail2ban = {
        enable = true;
        jails = {
          sshd = ''
            enabled = true
            port = ${toString cfg.sshPort}
          '';
        };
      };
    };
  };
}