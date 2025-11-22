{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.hardware.asus.zephyrus.performance;
in
{
  options.pantherOS.hardware.asus.zephyrus.performance = {
    enable = mkEnableOption "Asus Zephyrus performance configuration";

    mode = mkOption {
      type = types.enum [ "powersave" "balanced" "performance" ];
      default = "balanced";
      description = "Performance mode for the system";
    };

    enableAsusWmi = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ASUS WMI support for function keys";
    };

    enableRgbControl = mkOption {
      type = types.bool;
      default = true;
      description = "Enable RGB keyboard control";
    };
  };

  config = mkIf cfg.enable {
    # Power management based on mode
    services.tlp = {
      enable = true;
      settings = {
        "CPU_SCALING_GOVERNOR_ON_AC" = if cfg.mode == "performance" then "performance" else "powersave";
        "CPU_SCALING_GOVERNOR_ON_BAT" = "powersave";
        "CPU_ENERGY_PERF_POLICY_ON_AC" = if cfg.mode == "performance" then "performance" else "balance_performance";
        "CPU_ENERGY_PERF_POLICY_ON_BAT" = "power";
        "START_CHARGE_THRESH_BAT0" = 75;
        "STOP_CHARGE_THRESH_BAT0" = 80;
      };
    };

    # ASUS-specific kernel modules
    boot.kernelModules = mkIf cfg.enableAsusWmi [
      "asus-nb-wmi"
      "asus-wmi"
      "sparse-keymap"
    ];

    # Performance and RGB control tools
    environment.systemPackages = with pkgs; [
      openrgb
    ] ++ optionals cfg.enableRgbControl [
      # RGB control tools
    ];
  };
}
