# modules/home-manager/nixvim/plugins/core.nix
# Core essential plugins for nixvim

{ ... }:

{
  programs.nixvim = {
    plugins = {
      # Essential utilities
      nvim-web-devicons.enable = true; # File icons
      cmp-nvim-lsp.enable = true; # LSP completion
      nvim-cmp.enable = true; # Completion engine
      luasnip.enable = true; # Snippet engine
      nvim-ts-rainbow2.enable = true; # Rainbow parentheses

      # Core functionality
      telescope-nvim.enable = true; # Fuzzy finder
      treesitter-nvim.enable = true; # Syntax highlighting
      fidget-nvim.enable = true; # LSP progress
    };
  };
}