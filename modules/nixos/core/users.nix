{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.core.users;
in
{
  options.pantherOS.core.users = {
    enable = mkEnableOption "PantherOS user management configuration";
    
    defaultUser = {
      name = mkOption {
        type = types.str;
        default = "user";
        description = "Default user name";
      };
      description = mkOption {
        type = types.str;
        default = "Default User";
        description = "Description for the default user";
      };
      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [ "networkmanager" "wheel" ];
        description = "Extra groups for the default user";
      };
      isNormalUser = mkOption {
        type = types.bool;
        default = true;
        description = "Whether this is a normal user account";
      };
      shell = mkOption {
        type = types.package;
        default = pkgs.bashInteractive;
        description = "Default shell for the user";
      };
      openssh = {
        authorizedKeys = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "SSH public keys for the user";
        };
      };
    };
    
    enableUserActivation = mkOption {
      type = types.bool;
      default = true;
      description = "Enable user activation service";
    };
  };

  config = mkIf cfg.enable {
    # User management configuration
    users = {
      # Enable user activation service
      enableUserActivation = cfg.enableUserActivation;
      
      # Default user configuration
      users = mkIf (cfg.defaultUser.name != "") {
        ${cfg.defaultUser.name} = {
          name = cfg.defaultUser.name;
          description = cfg.defaultUser.description;
          extraGroups = cfg.defaultUser.extraGroups;
          isNormalUser = cfg.defaultUser.isNormalUser;
          shell = cfg.defaultUser.shell;
          openssh.authorizedKeys.keys = cfg.defaultUser.openssh.authorizedKeys;
        };
      };
      
      # Set default group for users
      groups = mkIf (cfg.defaultUser.name != "") {
        ${cfg.defaultUser.name} = {
          name = cfg.defaultUser.name;
        };
      };
    };
    
    # Additional security configurations for users
    security.sudo = mkIf (elem "wheel" cfg.defaultUser.extraGroups) {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}