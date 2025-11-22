{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.hardware.lenovo.yoga.touchpad;
in
{
  options.pantherOS.hardware.lenovo.yoga.touchpad = {
    enable = mkEnableOption "Lenovo Yoga touchpad configuration";

    enableTapToClick = mkOption {
      type = types.bool;
      default = true;
      description = "Enable tap to click";
    };

    enableNaturalScrolling = mkOption {
      type = types.bool;
      default = true;
      description = "Enable natural scrolling";
    };
  };

  config = mkIf cfg.enable {
    # Touchpad configuration
    services.libinput = {
      enable = true;
      touchpad = {
        tapping = cfg.enableTapToClick;
        naturalScrolling = cfg.enableNaturalScrolling;
        disableWhileTyping = true;
      };
    };

    # Required kernel modules
    boot.kernelModules = [ 
      "i2c_hid" 
      "i2c_designware_platform" 
      "i2c_designware_core"
    ];
  };
}
