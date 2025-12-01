# modules/home-manager/nixvim/keymaps/search.nix
# Search and find functionality keymaps

{ ... }:

{
  programs.nixvim = {
    keymaps = [
      # Telescope (fuzzy finder)
      {
        key = "<leader>f";
        action = "<cmd>Telescope find_files<cr>";
        modes = [ "n" ];
        desc = "Find files";
      }
      {
        key = "<leader>r";
        action = "<cmd>Telescope live_grep<cr>";
        modes = [ "n" ];
        desc = "Live grep";
      }

      # Flash (enhanced search)
      {
        key = "s";
        action = "<cmd>lua require('flash').jump()<cr>";
        modes = [
          "n"
          "x"
          "o"
        ];
        desc = "Flash search";
      }
      {
        key = "S";
        action = "<cmd>lua require('flash').treesitter()<cr>";
        modes = [
          "n"
          "x"
          "o"
        ];
        desc = "Flash treesitter";
      }
    ];
  };
}