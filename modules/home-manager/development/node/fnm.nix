{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.fnm;
in
{
  options.programs.fnm = {
    enable = mkEnableOption "Fast Node Manager (fnm) for Node.js version management";

    package = mkOption {
      type = types.package;
      default = pkgs.fnm;
      defaultText = "pkgs.fnm";
      description = "The fnm package to use";
    };

    enableFishIntegration = mkOption {
      type = types.bool;
      default = config.programs.fish.enable or false;
      description = "Enable fish shell integration for fnm";
    };

    enableBashIntegration = mkOption {
      type = types.bool;
      default = config.programs.bash.enable or false;
      description = "Enable bash shell integration for fnm";
    };

    enableZshIntegration = mkOption {
      type = types.bool;
      default = config.programs.zsh.enable or false;
      description = "Enable zsh shell integration for fnm";
    };

    defaultNodeVersion = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "lts-latest";
      description = "Default Node.js version to install and use";
    };

    nodePackages = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "yarn" "pnpm" "typescript" ];
      description = "Global npm packages to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Fish integration
    programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
      fnm env --use-on-cd | source
    '';

    # Bash integration
    programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
      eval "$(fnm env --use-on-cd)"
    '';

    # Zsh integration
    programs.zsh.initExtra = mkIf cfg.enableZshIntegration ''
      eval "$(fnm env --use-on-cd)"
    '';

    # Environment variables
    home.sessionVariables = {
      FNM_DIR = "$HOME/.local/share/fnm";
    };
  };
}
