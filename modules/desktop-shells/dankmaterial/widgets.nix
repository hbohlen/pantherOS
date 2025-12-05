# modules/desktop-shells/dankmaterial/widgets.nix
# Widget configurations for DankMaterialShell - refactored to use modular widget components

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  imports = [
    ./widgets
  ];
}
