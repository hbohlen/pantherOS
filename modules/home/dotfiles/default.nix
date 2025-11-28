{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home-manager.dotfiles;
in
{
  options.home-manager.dotfiles = {
    enable = mkEnableOption "Enable basic dotfiles management";

    files = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = ''
        Simple file management for dotfiles (prefer xdg.configFile for complex setups)
      '';
    };
    
    opencode-ai = import ./opencode-ai.nix;
  };

  config = mkIf cfg.enable {
    # Simple file creation using home.file
    home.file = mapAttrs' (name: value: 
      nameValuePair name { text = value; })
      cfg.files;
  };
}