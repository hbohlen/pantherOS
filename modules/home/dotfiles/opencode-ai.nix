{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home-manager.dotfiles.opencode-ai;
in
{
  options.home-manager.dotfiles.opencode-ai = {
    enable = mkEnableOption "Enable OpenCode.ai configuration management";

    theme = mkOption {
      type = types.enum [ "light" "dark" "auto" ];
      default = "auto";
      description = ''
        Theme preference for OpenCode.ai interface
      '';
    };
  };

  config = mkIf cfg.enable {
    # This module can be extended in the future for additional OpenCode configuration
    # Currently, OpenCode is configured via xdg.configFile in home-manager
  };
}