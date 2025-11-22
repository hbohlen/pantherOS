{ config, lib, pkgs, ... }:

with lib;

{
  options.pantherOS.core.userDefaults = {
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

  config = {
    # Setting default values for user configurations
    environment.defaultPackages = [ pkgs.bashInteractive ];
  };
}