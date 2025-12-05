# modules/home-manager/default.nix
# Home Manager module configuration

{ 
  pkgs, 
  lib, 
  config, 
  ...
}:

{
imports = [
    ./dotfiles
    ./nixvim.nix
    ./completions
  ];

  # Terminal tools packages
  home.packages = with pkgs; [
    # Hardware monitoring
    nvtopPackages.full
    pciutils
    usbutils

    # ASUS ROG tools - temporarily disabled due to CUDA dependency
    # asusctl

    # Performance monitoring
    powertop
    # linuxPackages.perf  # TODO: May have unfree dependencies

    # Network tools
    iwd
    wirelesstools

    # Zed IDE - high-performance code editor
    # TODO: Check if zed-editor has unfree dependencies
    # zed-editor
  ];

  # Fish shell configuration
  programs.fish = {
    enable = true;
    shellInit = ''
      # Terminal shortcuts and enhancements
      alias ll="eza -la --group-directories-first"
      alias ls="eza --group-directories-first"
      alias la="eza -la"
      alias tree="eza -Ta"

      # Git shortcuts
      alias gs="git status"
      alias ga="git add"
      alias gc="git commit"
      alias gp="git push"
      alias gl="git log --oneline"

      # Development shortcuts
      alias ..="cd .."
      alias ...="cd ../.."
      alias ....="cd ../../.."

      # Set up environment variables
      set -gx EDITOR "nvim"
      set -gx VISUAL "nvim"
    '';
  };

  # Shell environment variables
  home.sessionVariables = {
    # Editor configuration
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Additional home-manager configuration
  programs = {
    home-manager.enable = true;
  };
}
