{ config, lib, pkgs, ... }:

{
  imports = [
    ./config.nix
    ./plugins.nix
  ];
}
