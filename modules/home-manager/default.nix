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
    linuxPackages.perf

    # Network tools
    iwd
    wirelesstools

    # Zed IDE - high-performance code editor
    zed-editor
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

      # OpenCode integration (if available)
      if type -q opencode
        alias oc="opencode"
        alias occ="opencode --config ~/.config/opencode"
      end

      # Set up environment variables
      set -gx EDITOR "nvim"
      set -gx VISUAL "nvim"

      # Add OpenCode to PATH if it's installed via nix
      if test -d "$HOME/.local/share/opencode/completions"
        set -gx fish_user_paths "$fish_user_paths" "$HOME/.local/share/opencode/completions"
      end

      # Set up OpenCode environment variables
      if test -n "$HOME"
        set -gx OPENCODE_CONFIG_PATH "$HOME/.config/opencode"
        set -gx OPENCODE_DATA_PATH "$HOME/.local/share/opencode"
        set -gx OPENCODE_CACHE_PATH "$HOME/.cache/opencode"
      end
    '';
  };

  # Shell environment variables
  home.sessionVariables = {
    # Editor configuration
    EDITOR = "nvim";
    VISUAL = "nvim";

    # OpenCode environment variables
    OPENCODE_CONFIG_PATH = "$HOME/.config/opencode";
    OPENCODE_DATA_PATH = "$HOME/.local/share/opencode";
    OPENCODE_CACHE_PATH = "$HOME/.cache/opencode";
  };

  # Additional home-manager configuration
  programs = {
    home-manager.enable = true;
  };
}
