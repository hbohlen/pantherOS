{ config, lib, ... }:

with lib;

let
  cfg = config.dotfiles.opencode-ai;
in {
  options.dotfiles.opencode-ai.openAgent = {
    enable = mkEnableOption "Enable OpenAgent system integration";
    debug = mkOption {
      type = types.bool;
      default = true;
      description = "Enable OpenAgent debug mode";
    };
    dcp = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable DCP (Distributed Computing Protocol) for OpenAgent";
      };
    };
  };
}
