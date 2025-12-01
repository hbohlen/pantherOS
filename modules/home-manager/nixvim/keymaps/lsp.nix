# modules/home-manager/nixvim/keymaps/lsp.nix
# LSP-related keymaps

{ ... }:

{
  programs.nixvim = {
    keymaps = [
      # Trouble (diagnostics)
      {
        key = "<leader>d";
        action = "<cmd>Trouble diagnostics toggle<cr>";
        modes = [ "n" ];
        desc = "Toggle diagnostics";
      }
      {
        key = "<leader>tr";
        action = "<cmd>Trouble lsp toggle<cr>";
        modes = [ "n" ];
        desc = "Toggle LSP";
      }

      # Comment toggle
      {
        key = "<leader>/";
        action = "<Plug>NERDCommenterToggle<cr>";
        modes = [
          "n"
          "v"
        ];
        desc = "Toggle comment";
      }
    ];
  };
}