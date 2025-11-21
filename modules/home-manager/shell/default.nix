{ config, lib, pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./fnm.nix
  ];

  # Shell configuration is handled by individual modules
  # This file serves as the shell module index
}