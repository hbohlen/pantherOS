# Package Module Template
# Use for: Package installation and basic configuration

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.MODULE_NAME;
in
{
  options.programs.MODULE_NAME = {
    enable = mkEnableOption "MODULE_NAME";

    package = mkOption {
      type = types.package;
      default = pkgs.MODULE_NAME;
      defaultText = literalExpression "pkgs.MODULE_NAME";
      description = ''
        Package to install for MODULE_NAME.
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        Additional packages to install alongside MODULE_NAME.
      '';
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          theme = "dark";
          fontSize = 14;
        }
      '';
      description = ''
        Configuration for MODULE_NAME.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ] ++ cfg.extraPackages;

    # Write configuration file
    environment.etc."MODULE_NAME/config".source =
      pkgs.writeText "MODULE_NAME-config" (toJSON cfg.settings);

    # Set environment variables
    environment.sessionVariables = {
      MODULE_NAME_CONFIG = "/etc/MODULE_NAME/config";
    };

    imports = [
      # Add module imports here
    ];
  };
}
