# modules/home-manager/nixvim/settings/options.nix
# Basic editor options and settings

{ ... }:

{
  programs.nixvim = {
    # Global editor settings
    viAlias = true; # Alias 'vi' to nvim
    vimAlias = true; # Alias 'vim' to nvim

    # Custom options for better user experience
    extraOptions = {
      # Enhanced editing experience
      backspace = "indent,eol,start"; # Normal backspace behavior
      clipboard = "unnamedplus"; # Use system clipboard
      mouse = "a"; # Enable mouse support
      number = true; # Show line numbers
      relativenumber = true; # Relative line numbers
      showmode = false; # Hide showmode (lualine shows it)
      wrap = false; # Don't wrap lines
      scrolloff = 8; # Keep cursor centered
      sidescrolloff = 8; # Keep cursor centered horizontally

      # Better default keybindings
      timeoutlen = 300;
      updatetime = 250;

      # Visual improvements
      signcolumn = "yes:2"; # Reserve space for signs
      tabstop = 2; # Standard indentation
      shiftwidth = 2; # Indentation width
      expandtab = true; # Use spaces instead of tabs

      # Searching
      ignorecase = true; # Case-insensitive search
      smartcase = true; # Case-sensitive if pattern has uppercase
      incsearch = true; # Show search matches as you type
    };
  };
}