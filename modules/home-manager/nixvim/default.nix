# modules/home-manager/nixvim/default.nix
# Main nixvim configuration aggregator
# ADHD-friendly Neovim configuration using nixvim
# Optimized for beginners with productivity plugins

{ ... }:

{
  imports = [
    ./settings
    ./plugins
    ./keymaps
    ./lsp
  ];

  # Enable nixvim
  programs.nixvim.enable = true;
}