{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.core.base;
in
{
  options.pantherOS.core.base = {
    enable = mkEnableOption "PantherOS base configuration";

    systemPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ git vim wget curl htop ];
      description = "List of packages to install in the system environment";
    };

    stateVersion = mkOption {
      type = types.str;
      default = "23.11";
      description = "NixOS state version";
    };
  };

  config = mkIf cfg.enable {
    # Base system configuration
    environment.systemPackages = cfg.systemPackages;
    system.stateVersion = cfg.stateVersion;
  };
}