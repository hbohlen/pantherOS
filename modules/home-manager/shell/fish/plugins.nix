{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.fish;
in
{
  options.programs.fish = {
    enableStarship = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Starship prompt for fish";
    };

    enableZoxide = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Zoxide (smarter cd) for fish";
    };

    enableFzf = mkOption {
      type = types.bool;
      default = true;
      description = "Enable fzf integration for fish";
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional fish plugins to install";
    };
  };

  config = mkIf cfg.enable {
    programs.fish.plugins = cfg.plugins;

    # Starship prompt
    programs.starship = mkIf cfg.enableStarship {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };

    # Zoxide (smarter cd)
    programs.zoxide = mkIf cfg.enableZoxide {
      enable = true;
      enableFishIntegration = true;
    };

    # fzf (fuzzy finder)
    programs.fzf = mkIf cfg.enableFzf {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
