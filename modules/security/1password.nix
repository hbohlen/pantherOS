# modules/security/1password.nix
# 1Password integration wrapper module for personal devices
#
# This module provides a simplified interface for configuring both 1Password CLI
# and GUI together, following the pattern from 1Password developer documentation:
# https://developer.1password.com/docs/cli/get-started/#install
#
# Why a wrapper?
# - Simplifies configuration: one option instead of configuring two separate modules
# - Ensures polkit is always enabled (required for GUI authentication)
# - Enforces polkitPolicyOwners requirement (often forgotten)
# - Provides consistent configuration pattern across hosts
#
# Internally configures:
# - programs._1password (NixOS built-in module for CLI)
# - programs._1password-gui (NixOS built-in module for GUI)
# - security.polkit.enable (required for GUI to work)

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.onepassword-desktop;
in {
  options.programs.onepassword-desktop = {
    enable = mkEnableOption "1Password CLI and desktop application integration";
    
    polkitPolicyOwners = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of users for polkit policy ownership (required for system auth)";
      example = [ "username" ];
    };
  };

  config = mkIf cfg.enable {
    # Enable 1Password CLI using NixOS built-in module
    # This provides the base CLI package and basic configuration
    programs._1password = {
      enable = true;
    };

    # Enable 1Password desktop app using NixOS built-in module
    # This provides the GUI application package
    programs._1password-gui = {
      enable = true;
      # polkitPolicyOwners is required for system authentication to work
      # This allows 1Password to integrate with the system's authentication dialogs
      polkitPolicyOwners = cfg.polkitPolicyOwners;
    };

    # Ensure polkit is enabled for 1Password GUI authentication
    security.polkit.enable = true;
  };
}
