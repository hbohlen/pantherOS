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

  # OpenCode.ai configuration - managed via dotfiles module for structured config
  # Base OpenCode configuration from the opencode directory
  xdg.configFile."opencode" = {
    source = ./opencode;
    recursive = true;
  };

  # Note: OpenCode/OpenAgent enhanced dotfiles management module is available but not imported
  # To enable the structured dotfiles management, uncomment the following configuration:
  # dotfiles.opencode-ai = {
  #   enable = true;
  #   theme = "rosepine";
  #   openAgent = {
  #     enable = true;
  #     debug = true;
  #     dcp.enable = true;
  #   };
  #   plugins = [ "@tarquinen/opencode-dcp" "opencode-skills" ];
  # };

  # Home Manager configuration
  programs = {
    home-manager.enable = true;
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";

    # OpenCode/OpenAgent configuration paths
    OPENCODE_CONFIG_PATH = "${config.home.homeDirectory}/.config/opencode";
    OPENCODE_DATA_PATH = "${config.home.homeDirectory}/.local/share/opencode";
    OPENCODE_CACHE_PATH = "${config.home.homeDirectory}/.cache/opencode";

    # OpenAgent specific paths
    OPENAGENT_CONTEXT_PATH = "${config.home.homeDirectory}/.config/opencode/context";
    OPENAGENT_SESSIONS_PATH = "${config.home.homeDirectory}/.cache/opencode/sessions";
    OPENAGENT_AGENTS_PATH = "${config.home.homeDirectory}/.config/opencode/agents";
    OPENAGENT_COMMANDS_PATH = "${config.home.homeDirectory}/.config/opencode/commands";
    OPENAGENT_SKILLS_PATH = "${config.home.homeDirectory}/.config/opencode/skills";

    # OpenAgent operational modes
    OPENAGENT_DEBUG = "true";
    OPENAGENT_DCP_ENABLED = "true";
    OPENAGENT_AUTO_UPDATE = "true";
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

      # OpenAgent specific environment variables
      set -gx OPENAGENT_CONTEXT_PATH "$HOME/.config/opencode/context"
      set -gx OPENAGENT_SESSIONS_PATH "$HOME/.cache/opencode/sessions"
      set -gx OPENAGENT_AGENTS_PATH "$HOME/.config/opencode/agents"
      set -gx OPENAGENT_COMMANDS_PATH "$HOME/.config/opencode/commands"
      set -gx OPENAGENT_SKILLS_PATH "$HOME/.config/opencode/skills"

      # Add OpenCode completions to PATH if available
      if test -d "$HOME/.local/share/opencode/completions"
        set -gx fish_user_paths "$fish_user_paths" "$HOME/.local/share/opencode/completions"
      end

      # OpenAgent command aliases
      alias oc="opencode"
      alias occ="opencode --config $OPENCODE_CONFIG_PATH"
      alias oa="opencode --agents"
      alias ocmd="opencode --commands"
      alias oskill="opencode --skills"

      # OpenAgent agent management aliases
      alias oa-openagent="opencode agent openagent"
      alias oa-codeagent="opencode agent code-agent"
      alias oa-reviewer="opencode agent reviewer"
      alias oa-tester="opencode agent tester"

      # OpenAgent workflow aliases
      alias oa-workflow="opencode workflow"
      alias oa-validate="opencode validate"
      alias oa-optimize="opencode optimize"

      # OpenSpec integration aliases
      alias ospec="opencode openspec"
      alias ospec-proposal="opencode openspec-proposal"
      alias ospec-apply="opencode openspec-apply"
      alias ospec-archive="opencode openspec-archive"

      # Context management aliases
      alias octx="opencode context"
      alias octx-build="opencode build-context-system"
      alias octx-analyze="opencode gap-analyze"

      # Quick access to OpenAgent commands
      alias oa-test="opencode test"
      alias oa-build="opencode build"
      alias oa-clean="opencode clean"
      alias oa-commit="opencode commit"

      # Print OpenAgent status
      function oa-status
        echo "=== OpenAgent Status ==="
        echo "Config: $OPENCODE_CONFIG_PATH"
        echo "Data: $OPENCODE_DATA_PATH"
        echo "Agents: $(ls $OPENCODE_CONFIG_PATH/agents/*.md 2>/dev/null | wc -l)"
        echo "Commands: $(ls $OPENCODE_CONFIG_PATH/commands/*.md 2>/dev/null | wc -l)"
        echo "Skills: $(ls $OPENCODE_CONFIG_PATH/skills/ 2>/dev/null | wc -l)"
      end

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
