{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.hardware.lenovo.yoga.power;
in
{
  options.pantherOS.hardware.lenovo.yoga.power = {
    enable = mkEnableOption "Lenovo Yoga power management";

    batteryThreshold = {
      start = mkOption {
        type = types.int;
        default = 75;
        description = "Battery charge start threshold";
      };

      stop = mkOption {
        type = types.int;
        default = 80;
        description = "Battery charge stop threshold";
      };
    };
  };

  config = mkIf cfg.enable {
    # TLP power management
    services.tlp = {
      enable = true;
      settings = {
        "CPU_SCALING_GOVERNOR_ON_AC" = "powersave";
        "CPU_SCALING_GOVERNOR_ON_BAT" = "powersave";
        "CPU_ENERGY_PERF_POLICY_ON_BAT" = "power";
        "CPU_ENERGY_PERF_POLICY_ON_AC" = "power";
        "SCHED_POWERSAVE_ON_AC" = 1;
        "SCHED_POWERSAVE_ON_BAT" = 1;
        "START_CHARGE_THRESH_BAT0" = cfg.batteryThreshold.start;
        "STOP_CHARGE_THRESH_BAT0" = cfg.batteryThreshold.stop;
      };
    };

    # Power management packages
    environment.systemPackages = with pkgs; [
      powertop
      acpi
    ];
  };
}
