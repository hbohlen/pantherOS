{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.shell.completions;
in {
  options.shell.completions = {
    enable = mkEnableOption "Enable shell command completions";

    # Fish shell completion configuration
    fish = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Fish shell completions";
      };

      cache = mkOption {
        type = types.bool;
        default = true;
        description = "Enable completion caching";
      };
    };

    # Dynamic completions
    dynamic = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable dynamic completions for services and containers";
      };
    };

    # Alias completions
    aliases = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable completion for custom aliases";
      };
    };
  };

  config = mkIf cfg.enable {
    imports = [
      ./fish.nix
      ./dynamic.nix
    ];

    # System packages for completion tools
    environment.systemPackages = with pkgs; [
      fish
      bash-completion
      zsh-completions
    ];

    # Home Manager integration for Fish completions
    programs.fish = {
      enable = mkIf cfg.fish.enable true;
      completions = {
        enable = true;
        cache = cfg.fish.cache;
      };
    };
  };
}
