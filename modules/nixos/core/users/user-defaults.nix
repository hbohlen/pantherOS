{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.core.userDefaults;
in
{
  options.pantherOS.core.userDefaults = {
    enable = mkEnableOption "PantherOS user defaults configuration";

    shell = mkOption {
      type = types.package;
      default = pkgs.bashInteractive;
      description = "Default shell for all users";
    };
    homeDirectory = mkOption {
      type = types.str;
      default = "/home";
      description = "Default home directory path";
    };
  };

  config = mkIf cfg.enable {
    # Setting default values for user configurations
    # Add shell to systemPackages instead of replacing defaultPackages
    environment.systemPackages = [ cfg.shell ];
  };
}
