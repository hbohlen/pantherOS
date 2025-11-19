# Home-Manager Module Template
# Use for: User-level configuration (home-manager)

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

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          key = "value";
          option = true;
        }
      '';
      description = ''
        Configuration for MODULE_NAME.
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        Additional packages to install.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ] ++ cfg.extraPackages;

    # Configuration file
    xdg.configFile."MODULE_NAME/config".text = toJSON cfg.settings;

    # Desktop entry (for GUI apps)
    xdg.desktopEntries.MODULE_NAME = {
      name = "MODULE_NAME";
      genericName = "MODULE_NAME Application";
      categories = [ "Application" ];
      exec = "${cfg.package}/bin/MODULE_NAME";
      terminal = false;
    } // (optionalAttrs (cfg.settings ?icon) {
      icon = cfg.settings.icon;
    });

    # Shell integration
    programs.bash.initExtra = ''
      # MODULE_NAME configuration
      export MODULE_NAME_HOME="\${XDG_CONFIG_HOME:-\$HOME/.config}/MODULE_NAME"
    '';

    imports = [
      # Add module imports here
    ];
  };
}
