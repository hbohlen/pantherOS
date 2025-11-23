{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.pantherOS.hardware.asus.zephyrus.gpu;
in
{
  options.pantherOS.hardware.asus.zephyrus.gpu = {
    enable = mkEnableOption "Asus Zephyrus GPU configuration";

    enableNvidia = mkOption {
      type = types.bool;
      default = true;
      description = "Enable NVIDIA GPU support";
    };

    enableHybridGraphics = mkOption {
      type = types.bool;
      default = true;
      description = "Enable hybrid graphics (integrated + discrete)";
    };
  };

  config = mkIf cfg.enable {
    # Graphics drivers
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Kernel modules for GPU
    boot.kernelModules = mkIf cfg.enableHybridGraphics [ "nouveau" ];

    # GPU management tools
    environment.systemPackages =
      with pkgs;
      [
        nvidia-vaapi-driver
        nvtopPackages.nvidia
      ]
      ++ optionals cfg.enableNvidia [
        # NVIDIA-specific tools would go here
      ];
  };
}
