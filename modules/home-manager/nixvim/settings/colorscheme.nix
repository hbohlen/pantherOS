# modules/home-manager/nixvim/settings/colorscheme.nix
# Colorscheme configuration for nixvim

{ ... }:

{
  programs.nixvim = {
    # Custom highlights for better visual feedback
    colorschemes = {
      default = "tokyonight"; # Modern, easy-on-eyes color scheme
    };
  };
}