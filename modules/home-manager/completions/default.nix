{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.fish.completions;
in
{
  options.programs.fish.completions = {
    enable = mkEnableOption "Fish shell completions";

    # OpenCode completions
    opencode = {
      enable = mkEnableOption "OpenCode command completions";
    };

    # OpenAgent completions
    openagent = {
      enable = mkEnableOption "OpenAgent command completions";
    };

    # System management completions
    systemManagement = {
      enable = mkEnableOption "System management command completions";
      nix = mkEnableOption "Nix command completions";
      systemd = mkEnableOption "Systemd service completions";
      backup = mkEnableOption "Backup script completions";
      network = mkEnableOption "Network management completions";
    };

    # Container management completions
    container = {
      enable = mkEnableOption "Container management completions";
      podman = mkEnableOption "Podman completions";
      podmanCompose = mkEnableOption "Podman-compose completions";
    };

    # Development tool completions
    development = {
      enable = mkEnableOption "Development tool completions";
      git = mkEnableOption "Git completions";
      zellij = mkEnableOption "Zellij session completions";
      mutagen = mkEnableOption "Mutagen session completions";
      direnv = mkEnableOption "Direnv completions";
    };

    # Dynamic completion caching
    caching = {
      enable = mkEnableOption "Completion caching";
      cacheTimeout = mkOption {
        type = types.int;
        default = 300;  # 5 minutes
        description = "Cache timeout in seconds for dynamic completions";
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable Fish shell if completions are enabled
    programs.fish.enable = mkDefault true;

    # Create completions directory and install completion files
    xdg.configFile = {
      # Create directory structure
      # Removed reference to non-existent ./completions directory
    };

    # Add shellInit to configure completion behavior
    programs.fish.shellInit = mkAfter (
      ''
        # Configure Fish completion behavior
        set -g fish_completion_show_foreign 1  # Show completions for non-built-in commands
      ''
      + optionalString cfg.opencode.enable ''
        # OpenCode completions enabled
      ''
      + optionalString cfg.openagent.enable ''
        # OpenAgent completions enabled
      ''
      + optionalString cfg.systemManagement.enable ''
        # System management completions enabled
      ''
      + optionalString cfg.container.enable ''
        # Container management completions enabled
      ''
      + optionalString cfg.development.enable ''
        # Development tool completions enabled
      ''
      + optionalString cfg.caching.enable ''
        # Configure completion caching (timeout: ${toString cfg.caching.cacheTimeout}s)
        # Set up completion cache directory
        set -gx FISH_COMPLETION_CACHE_DIR "${config.xdg.cacheHome}/fish/completions"
        set -gx FISH_COMPLETION_CACHE_TIMEOUT "${toString cfg.caching.cacheTimeout}"
        if not test -d "$FISH_COMPLETION_CACHE_DIR"
          mkdir -p "$FISH_COMPLETION_CACHE_DIR"
        end
      ''
    );
  };
}