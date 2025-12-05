# Example configuration for Fish shell completions
# This file demonstrates how to enable and configure the completions module

{ config, pkgs, ... }:

{
  # Enable Fish shell completions with all features
  programs.fish.completions = {
    enable = true;
    
    # Enable all system management completions
    systemManagement = {
      enable = true;  # This enables all sub-options
      # Or enable individually:
      # nix = true;
      # systemd = true;
      # backup = true;
      # network = true;
    };
    
    # Enable all container management completions
    container = {
      enable = true;  # This enables all sub-options
      # Or enable individually:
      # podman = true;
      # podmanCompose = true;
    };
    
    # Enable all development tool completions
    development = {
      enable = true;  # This enables all sub-options
      # Or enable individually:
      # git = true;
      # zellij = true;
      # mutagen = true;
      # direnv = true;
    };
    
    # Enable caching for better performance
    caching = {
      enable = true;
      cacheTimeout = 300;  # 5 minutes (default)
    };
  };
}
