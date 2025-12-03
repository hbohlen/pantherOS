{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  imports = [
    ./system-services.nix
    ./systemd-services.nix
    ./packages.nix
  ];
}
