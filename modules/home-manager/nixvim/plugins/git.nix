# modules/home-manager/nixvim/plugins/git.nix
# Git integration plugins

{ ... }:

{
  programs.nixvim = {
    plugins = {
      gitsigns-nvim = {
        # Git integration
        enable = true;
        setting = {
          signs = {
            add = {
              hl = "GitSignsAdd";
              text = "│";
              numhl = "GitSignsAddNr";
              linehl = "GitSignsAddLn";
            };
            change = {
              hl = "GitSignsChange";
              text = "│";
              numhl = "GitSignsChangeNr";
              linehl = "GitSignsChangeLn";
            };
            delete = {
              hl = "GitSignsDelete";
              text = "│";
              numhl = "GitSignsDeleteNr";
              linehl = "GitSignsDeleteLn";
            };
          };
        };
      };
    };
  };
}