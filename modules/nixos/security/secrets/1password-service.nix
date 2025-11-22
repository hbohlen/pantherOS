{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.security.onepassword;
in
{
  options.pantherOS.security.onepassword = {
    enable = mkEnableOption "1Password integration for pantherOS";

    enableGui = mkOption {
      type = types.bool;
      default = false;
      description = "Enable 1Password GUI application";
    };

    enableCli = mkOption {
      type = types.bool;
      default = true;
      description = "Enable 1Password CLI";
    };

    enableSshAgent = mkOption {
      type = types.bool;
      default = false;
      description = "Enable 1Password SSH agent";
    };
  };

  config = mkIf cfg.enable {
    # 1Password GUI
    programs._1password-gui = mkIf cfg.enableGui {
      enable = true;
      polkitPolicyOwners = [ "hbohlen" ];
    };

    # 1Password CLI
    programs._1password = mkIf cfg.enableCli {
      enable = true;
    };

    # Environment packages
    environment.systemPackages = with pkgs; [
      _1password
    ] ++ optionals cfg.enableGui [
      _1password-gui
    ];
  };
}
