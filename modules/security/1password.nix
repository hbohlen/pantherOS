# modules/security/1password.nix
# 1Password integration module for personal devices
# Based on 1Password developer documentation:
# https://developer.1password.com/docs/cli/get-started/#install

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
    # Enable 1Password CLI
    # NixOS has built-in modules to enable 1Password along with
    # pre-packaged configuration to make it work properly
    programs._1password = {
      enable = true;
    };

    # Enable 1Password desktop app
    programs._1password-gui = {
      enable = true;
      # This makes system auth etc. work properly
      polkitPolicyOwners = cfg.polkitPolicyOwners;
    };

    # Ensure polkit is enabled for authentication
    security.polkit.enable = true;
  };
}
