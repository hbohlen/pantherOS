{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.core.users;
in
{
  options.pantherOS.core.users.sudo = {
    enable = mkEnableOption "Sudo configuration for PantherOS users";
  };

  config = mkIf cfg.enable {
    # Additional security configurations for users
    security.sudo = mkIf (elem "wheel" config.pantherOS.core.users.defaultUser.extraGroups) {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}