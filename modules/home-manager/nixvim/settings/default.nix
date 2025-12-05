# modules/home-manager/nixvim/settings/default.nix
# Core settings aggregator for nixvim configuration

{ ... }:

{
  imports = [
    ./options.nix
    ./colorscheme.nix
  ];
}