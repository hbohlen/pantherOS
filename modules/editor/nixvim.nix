# modules/editor/nixvim.nix
# ADHD-friendly Neovim configuration using nixvim
# Optimized for beginners with productivity plugins

{ lib, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    
    # Global editor settings
    viAlias = true;  # Alias 'vi' to nvim
    vimAlias = true; # Alias 'vim' to nvim
    
    # Enable plugins with ADHD-friendly features
    plugins = {
      # Essential utilities
      nvim-web-devicons.enable = true;      # File icons
      cmp-nvim-lsp.enable = true;           # LSP completion
      nvim-cmp.enable = true;               # Completion engine
      luasnip.enable = true;                # Snippet engine
      nvim-ts-rainbow2.enable = true;       # Rainbow parentheses
      
      # ADHD-friendly productivity plugins
      hardtime-nvim = {                     # Enforces good habits
        enable = true;
        setting = {
          mode = "normal";
          repeat_only_moves = true;
          maxrepeat = 10;
        };
      };
      
      precognition-nvim = {                 # Motion hints
        enable = true;
        setting = {
          startVisiChars = [ "f" "F" "t" "T" "s" "S" ];
          endVisiChars = [ "F" "T" "a" "A" "i" "I" "l" "L" ];
          maxVisiChars = 50;
        };
      };
      
      which-key-nvim = {                    # Key binding suggestions
        enable = true;
        setting = {
          timeout = 3000;
          notify = false;
          hideOnRelease = true;
        };
      };
      
      flash-nvim = {                        # Enhanced search
        enable = true;
        setting = {
          search = {
            mode = "search";
            multi_window = true;
            priority = 2;
            incremental = true;
          };
        };
      };
      
      gitsigns-nvim = {                     # Git integration
        enable = true;
        setting = {
          signs = {
            add = { hl = "GitSignsAdd"; text = "│"; numhl = "GitSignsAddNr"; linehl = "GitSignsAddLn"; };
            change = { hl = "GitSignsChange"; text = "│"; numhl = "GitSignsChangeNr"; linehl = "GitSignsChangeLn"; };
            delete = { hl = "GitSignsDelete"; text = "│"; numhl = "GitSignsDeleteNr"; linehl = "GitSignsDeleteLn"; };
          };
        };
      };
      
      todo-comments-nvim = {                # TODO highlighting
        enable = true;
        setting = {
          keywords = {
            FIX = { icon = "f"; color = "error"; alt = [ "FIXME" "BUG" "HACK" ]; };
            TODO = { icon = "t"; color = "info"; };
            NOTE = { icon = "n"; color = "hint"; alt = [ "INFO" "IDEA" ]; };
            WARNING = { icon = "w"; color = "warning"; alt = [ "WARN" ]; };
            PERF = { icon = "p"; alt = [ "PERFORMANCE" "OPTIMIZE" ]; };
          };
        };
      };
      
      trouble-nvim = {                      # Better diagnostics
        enable = true;
        setting = {
          position = "bottom";
          height = 10;
        };
      };
      
      # Additional helpful plugins
      telescope-nvim.enable = true;         # Fuzzy finder
      treesitter-nvim.enable = true;        # Syntax highlighting
      fidget-nvim.enable = true;            # LSP progress
      lualine-nvim.enable = true;           # Status line
      neotree-nvim.enable = true;           # File explorer
      bufferline-nvim.enable = true;        # Tab management
    };

    # Key bindings optimized for productivity
    keymaps = [
      # Navigation and window management
      { key = "leader>h"; action = "<C-w>v"; modes = [ "n" ]; desc = "Split window horizontally"; }
      { key = "leader>v"; action = "<C-w>s"; modes = [ "n" ]; desc = "Split window vertically"; }
      { key = "leader>;w"; action = "<C-w>q"; modes = [ "n" ]; desc = "Close current window"; }
      
      # Telescope (fuzzy finder)
      { key = "leader>f"; action = "<cmd>Telescope find_files<cr>"; modes = [ "n" ]; desc = "Find files"; }
      { key = "leader>r"; action = "<cmd>Telescope live_grep<cr>"; modes = [ "n" ]; desc = "Live grep"; }
      { key = "leader>b"; action = "<cmd>Telescope buffers<cr>"; modes = [ "n" ]; desc = "Find buffers"; }
      
      # Flash (enhanced search)
      { key = "s"; action = "<cmd>lua require('flash').jump()<cr>"; modes = [ "n" "x" "o" ]; desc = "Flash search"; }
      { key = "S"; action = "<cmd>lua require('flash').treesitter()<cr>"; modes = [ "n" "x" "o" ]; desc = "Flash treesitter"; }
      
      # Trouble (diagnostics)
      { key = "<leader>d"; action = "<cmd>Trouble diagnostics toggle<cr>"; modes = [ "n" ]; desc = "Toggle diagnostics"; }
      { key = "<leader>tr"; action = "<cmd>Trouble lsp toggle<cr>"; modes = [ "n" ]; desc = "Toggle LSP"; }
      
      # Git integration
      { key = "<leader>g"; action = "<cmd>Neotree toggle<cr>"; modes = [ "n" ]; desc = "Toggle file explorer"; }
      
      # Comment toggle
      { key = "<leader>/"; action = "<Plug>NERDCommenterToggle<cr>"; modes = [ "n" "v" ]; desc = "Toggle comment"; }
    ];

    # LSP configuration for better development experience
    lspServers = {
      bashls.enable = true;     # Bash
      jsonls.enable = true;     # JSON
      yamlls.enable = true;     # YAML
      nixvim-lsp-setup.enable = true; # Nix
    };

    # Custom options for better user experience
    extraOptions = {
      # Enhanced editing experience
      backspace = "indent,eol,start"; # Normal backspace behavior
      clipboard = "unnamedplus";      # Use system clipboard
      mouse = "a";                    # Enable mouse support
      number = true;                  # Show line numbers
      relativenumber = true;          # Relative line numbers
      showmode = false;               # Hide showmode (lualine shows it)
      wrap = false;                   # Don't wrap lines
      scrolloff = 8;                  # Keep cursor centered
      sidescrolloff = 8;              # Keep cursor centered horizontally
      
      # Better default keybindings
      timeoutlen = 300;
      updatetime = 250;
      
      # Visual improvements
      signcolumn = "yes:2";           # Reserve space for signs
      tabstop = 2;                    # Standard indentation
      shiftwidth = 2;                 # Indentation width
      expandtab = true;               # Use spaces instead of tabs
      
      # Searching
      ignorecase = true;              # Case-insensitive search
      smartcase = true;               # Case-sensitive if pattern has uppercase
      incsearch = true;               # Show search matches as you type
    };

    # Custom highlights for better visual feedback
    colorschemes = {
      default = "tokyonight";         # Modern, easy-on-eyes color scheme
    };
  };
}
