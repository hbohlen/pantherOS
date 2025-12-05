# modules/desktop-shells/dankmaterial/services.nix
# System services integration for DankMaterialShell - refactored to use modular service components

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  imports = [
    ./services
  ];
}
