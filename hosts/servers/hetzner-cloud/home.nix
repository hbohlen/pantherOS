{ config, pkgs, ... }:

{
  home.stateVersion = "24.11";
  
  home = {
    username = "hbohlen";
    homeDirectory = "/home/hbohlen";
  };

  # Basic development packages
  # NOTE: Most packages commented out for initial deployment
  # Uncomment after successful deployment
  home.packages = with pkgs; [
    # starship
    # eza
    # ripgrep
    # gh
    # bottom
    # _1password-cli
    git
    neovim
    fish
    # zoxide
    # direnv
    # nix-direnv
  ];

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rerere.enabled = true;
    };
  };

  # Fish shell
  programs.fish = {
    enable = true;
    shellInit = ''
      set -gx PATH $PATH ~/.local/bin
      # NOTE: Shell integrations commented out for initial deployment
      # starship init fish | source
      # zoxide init fish | source
      # eval "$(op completion fish)"
      # eval "$(gh completion --shell fish)"
    '';
  };

  # NOTE: Starship and direnv commented out for initial deployment
  # Uncomment after successful deployment
  # Starship prompt
  # programs.starship = {
  #   enable = true;
  #   settings = {
  #     # Minimal prompt configuration
  #     format = "$all$character";
  #   };
  # };

  # Direnv
  # programs.direnv = {
  #   enable = true;
  #   nix-direnv.enable = true;
  # };
}