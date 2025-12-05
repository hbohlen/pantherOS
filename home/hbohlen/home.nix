{ config, pkgs, ... }:

{
  # imports = [
  #   ../../modules/home
  # ];

  home = {
    username = "hbohlen";
    homeDirectory = "/home/hbohlen";
    stateVersion = "25.05";
  };

  # Enable XDG base directory specification
  xdg.enable = true;

  # Home Manager configuration
  programs = {
    home-manager.enable = true;
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";
  };

  # Packages managed by home-manager
  home.packages = with pkgs; [
    # Terminal tools
    fish
    fzf
    eza
    zellij  # Terminal multiplexer

    # Development tools
    neovim
    git
    zed-editor
  ];

  # Fish shell configuration
  programs.fish = {
    enable = true;
    shellInit = ''
      # Zellij aliases for convenience
      alias zj="zellij"
      alias zja="zellij attach"
      alias zjl="zellij list-sessions"
      alias zjk="zellij kill-session"
    '';
  };

  # Zellij terminal multiplexer configuration
  programs.zellij = {
    enable = true;
    settings = {
      # Theme and appearance
      theme = "default";
      default_shell = "fish";

      # Simplified keybindings mode
      simplified_ui = true;

      # Pane frames
      pane_frames = true;

      # Copy on select
      copy_on_select = false;

      # Mouse mode
      mouse_mode = true;

      # Scroll buffer size
      scroll_buffer_size = 10000;

      # Layout configuration
      default_layout = "compact";

      # Session serialization
      session_serialization = true;

      # Automatically attach to existing session if one exists
      auto_layout = true;
    };
  };

  # Zellij layout files
  xdg.configFile."zellij/layouts/development.kdl".source = ./zellij/development.kdl;
  xdg.configFile."zellij/layouts/compact.kdl".source = ./zellij/compact.kdl;

}
