{ config, lib, pkgs, ... }:

{
  imports = [
    ./nixos
    ./home-manager
    ./shared
  ];

  # Module system for pantherOS
  # Each category contains focused, single-concern modules
}