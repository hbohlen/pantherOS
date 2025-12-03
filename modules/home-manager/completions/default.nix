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
    xdg.configFile = mkMerge [
      # OpenCode completions
      (mkIf cfg.opencode.enable {
        "fish/completions/opencode.fish".source = ./files/opencode.fish;
      })

      # OpenAgent completions
      (mkIf cfg.openagent.enable {
        "fish/completions/openagent.fish".source = ./files/openagent.fish;
      })

      # System management completions
      (mkIf (cfg.systemManagement.enable || cfg.systemManagement.nix) {
        "fish/completions/nix.fish".source = ./files/nix.fish;
      })
      (mkIf (cfg.systemManagement.enable || cfg.systemManagement.systemd) {
        "fish/completions/systemd.fish".source = ./files/systemd.fish;
      })
      (mkIf (cfg.systemManagement.enable || cfg.systemManagement.backup) {
        "fish/completions/backup.fish".source = ./files/backup.fish;
      })
      (mkIf (cfg.systemManagement.enable || cfg.systemManagement.network) {
        "fish/completions/network.fish".source = ./files/network.fish;
      })

      # Container management completions
      (mkIf (cfg.container.enable || cfg.container.podman) {
        "fish/completions/podman.fish".source = ./files/podman.fish;
      })
      (mkIf (cfg.container.enable || cfg.container.podmanCompose) {
        "fish/completions/podman-compose.fish".source = ./files/podman-compose.fish;
      })

      # Development tool completions
      (mkIf (cfg.development.enable || cfg.development.git) {
        "fish/completions/git.fish".source = ./files/git.fish;
      })
      (mkIf (cfg.development.enable || cfg.development.zellij) {
        "fish/completions/zellij.fish".source = ./files/zellij.fish;
      })
      (mkIf (cfg.development.enable || cfg.development.mutagen) {
        "fish/completions/mutagen.fish".source = ./files/mutagen.fish;
      })
      (mkIf (cfg.development.enable || cfg.development.direnv) {
        "fish/completions/direnv.fish".source = ./files/direnv.fish;
      })
    ];

    # Add shellInit to configure completion behavior
    programs.fish.shellInit = mkAfter (
      ''
        # Configure Fish completion behavior
        set -g fish_completion_show_foreign 1  # Show completions for non-built-in commands
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

    # Ensure cache directory exists if caching is enabled
    home.activation = mkIf cfg.caching.enable {
      fishCompletionCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.cacheHome}/fish/completions"
      '';
    };
  };
}