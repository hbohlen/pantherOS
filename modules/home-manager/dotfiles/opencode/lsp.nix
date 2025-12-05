{ config, lib, ... }:

with lib;

let
  cfg = config.dotfiles.opencode-ai;
in {
  options.dotfiles.opencode-ai.lsp = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable LSP servers";
    };
    nix = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Nix LSP (nixd)";
      };
    };
  };
}
