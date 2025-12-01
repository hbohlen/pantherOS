# modules/home-manager/nixvim/keymaps/default.nix
# Keymap aggregator for nixvim configuration

{ ... }:

{
  imports = [
    ./navigation.nix
    ./search.nix
    ./git.nix
    ./lsp.nix
  ];
}