# modules/home-manager/nixvim.nix
# Home Manager nixvim configuration using modular setup

{ ... }:

{
  imports = [
    ../editor/nixvim
  ];
}