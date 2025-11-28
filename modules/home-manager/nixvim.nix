# modules/home-manager/nixvim.nix
# Basic nixvim configuration for home-manager
# ADHD-friendly Neovim configuration

{ lib, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    
    # Global editor settings
    viAlias = true;  # Alias 'vi' to nvim
    vimAlias = true; # Alias 'vim' to nvim
    
    # Enable core plugins for ADHD-friendly features
    plugins = {
      # ADHD-friendly productivity plugins
      hardtime-nvim.enable = true;           # Enforces good habits
      precognition-nvim.enable = true;       # Motion hints
      which-key-nvim.enable = true;          # Key binding suggestions
      flash-nvim.enable = true;              # Enhanced search
      gitsigns-nvim.enable = true;           # Git integration
      todo-comments-nvim.enable = true;      # TODO highlighting
      trouble-nvim.enable = true;            # Better diagnostics
      
      # Additional helpful plugins
      telescope-nvim.enable = true;          # Fuzzy finder
      treesitter-nvim.enable = true;         # Syntax highlighting
      fidget-nvim.enable = true;             # LSP progress
      lualine-nvim.enable = true;            # Status line
      neotree-nvim.enable = true;            # File explorer
    };

    # Key bindings optimized for productivity
    keymaps = [
      # Navigation and window management
      { key = "<C-w>v"; action = "<C-w>v"; modes = [ "n" ]; desc = "Split window horizontally"; }
      { key = "<C-w>s"; action = "<C-w>s"; modes = [ "n" ]; desc = "Split window vertically"; }
      { key = "<C-w>q"; action = "<C-w>q"; modes = [ "n" ]; desc = "Close current window"; }
      
      # Telescope (fuzzy finder)
      { key = "<leader>f"; action = "<cmd>Telescope find_files<cr>"; modes = [ "n" ]; desc = "Find files"; }
      { key = "<leader>r"; action = "<cmd>Telescope live_grep<cr>"; modes = [ "n" ]; desc = "Live grep"; }
      { key = "<leader>b"; action = "<cmd>Telescope buffers<cr>"; modes = [ "n" ]; desc = "Find buffers"; }
      
      # Flash (enhanced search)
      { key = "s"; action = "<cmd>lua require('flash').jump()<cr>"; modes = [ "n" "x" "o" ]; desc = "Flash search"; }
      
      # Trouble (diagnostics)
      { key = "<leader>d"; action = "<cmd>Trouble diagnostics toggle<cr>"; modes = [ "n" ]; desc = "Toggle diagnostics"; }
      
      # File explorer
      { key = "<leader>g"; action = "<cmd>Neotree toggle<cr>"; modes = [ "n" ]; desc = "Toggle file explorer"; }
    ];

    # Basic options for better user experience
    extraOptions = {
      # Enhanced editing experience
      number = true;                  # Show line numbers
      relativenumber = true;          # Relative line numbers
      tabstop = 2;                    # Standard indentation
      shiftwidth = 2;                 # Indentation width
      expandtab = true;               # Use spaces instead of tabs
      clipboard = "unnamedplus";      # Use system clipboard
      mouse = "a";                    # Enable mouse support
    };
  };
}
