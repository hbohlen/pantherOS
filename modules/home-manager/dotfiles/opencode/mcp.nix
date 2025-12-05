{ config, lib, ... }:

with lib;

let
  cfg = config.dotfiles.opencode-ai;
in {
  options.dotfiles.opencode-ai.mcp = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable MCP (Model Context Protocol) servers";
    };
    nixos = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable NixOS MCP server";
      };
    };
  };
}
