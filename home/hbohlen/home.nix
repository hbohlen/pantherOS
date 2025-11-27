{ config, lib, pkgs, ... }:

{
  imports = [
    ../../../modules/home
  ];

  home = {
    username = "hbohlen";
    homeDirectory = "/home/hbohlen";
    stateVersion = "25.05";
  };

  # Enable XDG base directory specification
  xdg.enable = true;

  # OpenCode.ai configuration using xdg.configFile
  # This links the opencode directory to ~/.config/opencode
  xdg.configFile."opencode" = {
    source = ./opencode;
    recursive = true;
  };

  # Home Manager configuration
  programs = {
    home-manager.enable = true;
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    OPENCODE_CONFIG_PATH = "${config.home.homeDirectory}/.config/opencode";
    OPENCODE_DATA_PATH = "${config.home.homeDirectory}/.local/share/opencode";
    OPENCODE_CACHE_PATH = "${config.home.homeDirectory}/.cache/opencode";
  };

  # Packages managed by home-manager
  home.packages = with pkgs; [
    # Terminal tools
    fish
    fzf
    eza
    
    # Development tools  
    neovim
    git
    
    # AI coding assistant (from nixpkgs or nix-ai-tools)
    opencode
  ];

  # Fish shell configuration
  programs.fish = {
    enable = true;
    shellInit = ''
      # Set up OpenCode environment variables
      set -gx OPENCODE_CONFIG_PATH "$HOME/.config/opencode"
      set -gx OPENCODE_DATA_PATH "$HOME/.local/share/opencode"
      set -gx OPENCODE_CACHE_PATH "$HOME/.cache/opencode"
      
      # Add OpenCode completions to PATH if available
      if test -d "$HOME/.local/share/opencode/completions"
        set -gx fish_user_paths "$fish_user_paths" "$HOME/.local/share/opencode/completions"
      end
      
      # Aliases for common OpenCode commands
      alias oc="opencode"
      alias occ="opencode --config $OPENCODE_CONFIG_PATH"
    '';
  };

  # Optional: Enable OpenCode dotfiles module for additional configuration
  home-manager.dotfiles.opencode-ai = {
    enable = true;
    theme = "auto";
    # API key will be managed via opencode auth login or environment
  };
}