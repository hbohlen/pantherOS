# modules/home-manager/nixvim/keymaps/navigation.nix
# Navigation and window management keymaps

{ ... }:

{
  programs.nixvim = {
    keymaps = [
      # Navigation and window management
      {
        key = "<leader>h";
        action = "<C-w>v";
        modes = [ "n" ];
        desc = "Split window horizontally";
      }
      {
        key = "<leader>v";
        action = "<C-w>s";
        modes = [ "n" ];
        desc = "Split window vertically";
      }
      {
        key = "<leader>w";
        action = "<C-w>q";
        modes = [ "n" ];
        desc = "Close current window";
      }

      # File explorer
      {
        key = "<leader>g";
        action = "<cmd>Neotree toggle<cr>";
        modes = [ "n" ];
        desc = "Toggle file explorer";
      }

      # Buffer management
      {
        key = "<leader>b";
        action = "<cmd>Telescope buffers<cr>";
        modes = [ "n" ];
        desc = "Find buffers";
      }
    ];
  };
}