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

    openAgent = {
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

    plugins = mkOption {
      type = types.listOf types.str;
      default = [ "@tarquinen/opencode-dcp" ];
      description = "List of OpenCode plugins to load";
    };

    mcp = {
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

    lsp = {
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

    formatter = {
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

    additionalConfig = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional configuration files to add to OpenCode directory";
    };
  };
}
