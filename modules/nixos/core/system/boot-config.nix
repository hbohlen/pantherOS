{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.core.boot;
in
{
  options.pantherOS.core.boot = {
    enable = mkEnableOption "PantherOS boot configuration";

    timeout = mkOption {
      type = types.int;
      default = 5;
      description = "Boot menu timeout in seconds";
    };

    enableFlakes = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Nix flakes support";
    };

    enableInitrd = mkOption {
      type = types.bool;
      default = true;
      description = "Enable initrd configuration";
    };
  };

  config = mkIf cfg.enable {
    # Boot loader configuration
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      loader.timeout = cfg.timeout;
    };

    # Nix flakes configuration
    nix.settings.experimental-features = mkIf cfg.enableFlakes [ "nix-command" "flakes" ];
  };
}