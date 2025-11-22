{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.fish;
in
{
  options.programs.fish = {
    enable = mkEnableOption "Fish shell with pantherOS configuration";

    shellAliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        # System management
        "rebuild" = "sudo nixos-rebuild switch --flake .#";
        "update" = "nix flake update";
        "clean" = "sudo nix-collect-garbage -d";
        
        # Common shortcuts
        "ll" = "ls -lah";
        "la" = "ls -A";
        "l" = "ls -CF";
        "grep" = "grep --color=auto";
        
        # Git shortcuts
        "gs" = "git status";
        "ga" = "git add";
        "gc" = "git commit";
        "gp" = "git push";
        "gl" = "git log --oneline --graph";
        
        # Safety aliases
        "rm" = "rm -i";
        "cp" = "cp -i";
        "mv" = "mv -i";
      };
      description = "Shell aliases for fish";
    };

    interactiveShellInit = mkOption {
      type = types.lines;
      default = ''
        # Disable greeting
        set fish_greeting
        
        # Set vi keybindings
        fish_vi_key_bindings
      '';
      description = "Shell commands to run for interactive fish shells";
    };
  };

  config = mkIf cfg.enable {
    programs.fish = {
      shellAliases = cfg.shellAliases;
      interactiveShellInit = cfg.interactiveShellInit;
    };
  };
}
