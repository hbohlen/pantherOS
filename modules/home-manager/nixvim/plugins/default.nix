# modules/home-manager/nixvim/plugins/default.nix
# Plugin aggregator for nixvim configuration

{ ... }:

{
  imports = [
    ./core.nix
    ./productivity.nix
    ./git.nix
    ./ui.nix
  ];
}