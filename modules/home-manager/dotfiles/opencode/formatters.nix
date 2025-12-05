{ config, lib, ... }:

with lib;

let
  cfg = config.dotfiles.opencode-ai;
in {
  options.dotfiles.opencode-ai.formatter = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable formatters";
    };
    nix = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Nix formatter (nixpkgs-fmt)";
      };
    };
  };
}
