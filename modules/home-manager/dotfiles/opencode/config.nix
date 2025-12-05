{ config, lib, ... }:

with lib;

let
  cfg = config.dotfiles.opencode-ai;
in {
  options.dotfiles.opencode-ai = {
    enable = mkEnableOption "Enable OpenCode.ai and OpenAgent configuration management";

    theme = mkOption {
      type = types.enum [
        "light"
        "dark"
        "auto"
      ];
      default = "auto";
      description = ''
        Theme preference for OpenCode.ai interface
      '';
    };

    plugins = mkOption {
      type = types.listOf types.str;
      default = [ "@tarquinen/opencode-dcp" ];
      description = "List of OpenCode plugins to load";
    };

    additionalConfig = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional configuration files to add to OpenCode directory";
    };
  };
}
