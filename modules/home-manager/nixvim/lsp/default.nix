# modules/home-manager/nixvim/lsp/default.nix
# LSP configuration aggregator for nixvim

{ ... }:

{
  imports = [
    ./servers.nix
    ./settings.nix
  ];
}