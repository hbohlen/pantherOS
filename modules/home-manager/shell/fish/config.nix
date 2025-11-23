{ config, lib, ... }:

with lib;

let
  cfg = config.programs.fish;
  defaultAliases = {
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

  defaultInit = ''
    # Disable greeting
    set fish_greeting

    # Set vi keybindings
    fish_vi_key_bindings
  '';
in
{
  config = mkIf cfg.enable {
    programs.fish.shellAliases = mkOptionDefault defaultAliases;
    programs.fish.interactiveShellInit = mkDefault defaultInit;
  };
}
