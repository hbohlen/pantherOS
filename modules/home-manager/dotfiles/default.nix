{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.dotfiles;
in
{
  options.dotfiles = {
    enable = mkEnableOption "Enable basic dotfiles management";

    files = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = ''
        Simple file management for dotfiles (prefer xdg.configFile for complex setups)
      '';
    };
  };

  config = mkIf cfg.enable {
    # Simple file creation using home.file
    home.file = mapAttrs' (name: value: nameValuePair name { text = value; }) cfg.files;
  };
}