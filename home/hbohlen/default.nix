{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/shell/fish.nix
    ../../modules/home-manager/shell/fnm.nix
  ];

  # Enable Fish shell with fnm integration
  programs.fish.enable = true;
  programs.fnm.enable = true;

  # Home-manager configuration for hbohlen user
  home.stateVersion = "24.11";
  
  # Basic user configuration
  home.username = "hbohlen";
  home.homeDirectory = "/home/hbohlen";
}