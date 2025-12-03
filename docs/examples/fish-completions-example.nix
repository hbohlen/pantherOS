# Example Fish Completions Configuration
# This file demonstrates various ways to configure the Fish completions module
#
# NOTE: This file contains multiple example configurations.
# Uncomment ONLY ONE example at a time in your actual configuration.
# The examples are mutually exclusive and should not all be enabled simultaneously.

{ config, pkgs, ... }:

{
  # Example 1: Minimal configuration
  # Just enable completions with defaults
  programs.fish.completions.enable = true;

  # Example 2: OpenCode/OpenAgent developer setup
  # programs.fish.completions = {
  #   enable = true;
  #   opencode.enable = true;
  #   openagent.enable = true;
  #   development = {
  #     enable = true;
  #     git = true;
  #   };
  # };

  # Example 3: System administrator setup
  # programs.fish.completions = {
  #   enable = true;
  #   systemManagement = {
  #     enable = true;
  #     nix = true;
  #     systemd = true;
  #     network = true;
  #   };
  # };

  # Example 4: Container-focused setup
  # programs.fish.completions = {
  #   enable = true;
  #   container = {
  #     enable = true;
  #     podman = true;
  #     podmanCompose = true;
  #   };
  #   caching = {
  #     enable = true;
  #     cacheTimeout = 600;  # 10 minutes for container completions
  #   };
  # };

  # Example 5: Full-featured development environment
  # programs.fish.completions = {
  #   enable = true;
  #   
  #   # AI tools
  #   opencode.enable = true;
  #   openagent.enable = true;
  #   
  #   # System management
  #   systemManagement = {
  #     enable = true;
  #     nix = true;
  #     systemd = true;
  #     backup = true;
  #     network = true;
  #   };
  #   
  #   # Container tools
  #   container = {
  #     enable = true;
  #     podman = true;
  #     podmanCompose = true;
  #   };
  #   
  #   # Development tools
  #   development = {
  #     enable = true;
  #     git = true;
  #     zellij = true;
  #     mutagen = true;
  #     direnv = true;
  #   };
  #   
  #   # Performance optimization
  #   caching = {
  #     enable = true;
  #     cacheTimeout = 300;  # 5 minutes default
  #   };
  # };

  # Example 6: Performance-optimized with longer cache
  # programs.fish.completions = {
  #   enable = true;
  #   opencode.enable = true;
  #   development = {
  #     enable = true;
  #     git = true;
  #     zellij = true;
  #   };
  #   caching = {
  #     enable = true;
  #     cacheTimeout = 1800;  # 30 minutes for better performance
  #   };
  # };

  # Example 7: Selective enablement for minimal overhead
  # programs.fish.completions = {
  #   enable = true;
  #   opencode.enable = true;
  #   development = {
  #     enable = true;
  #     git = true;
  #   };
  #   # No caching for minimal system impact
  # };
}
