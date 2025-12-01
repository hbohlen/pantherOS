# modules/home-manager/nixvim/plugins/ui.nix
# UI and visual enhancement plugins

{ ... }:

{
  programs.nixvim = {
    plugins = {
      lualine-nvim.enable = true; # Status line
      neotree-nvim.enable = true; # File explorer
      bufferline-nvim.enable = true; # Tab management
    };
  };
}