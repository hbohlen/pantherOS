# modules/environment/default.nix
{ ... }:

{
  # Environment variables for XDG base directories and dev tools
  environment.sessionVariables = {
    # XDG Base Directory specification
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # Language-specific cache locations (use ~/.cache subvolume)
    NPM_CONFIG_CACHE = "$HOME/.cache/npm";
    CARGO_HOME = "$HOME/.cache/cargo";
    RUSTUP_HOME = "$HOME/.cache/rustup";
    GOPATH = "$HOME/.cache/go";
    GOCACHE = "$HOME/.cache/go-build";
    PIP_CACHE_DIR = "$HOME/.cache/pip";

    # Development directory
    PROJECTS_DIR = "$HOME/dev";

    # Editor - nixvim provides full Neovim configuration
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}