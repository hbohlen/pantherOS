{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.hardware.lenovo.yoga.audio;
in
{
  options.pantherOS.hardware.lenovo.yoga.audio = {
    enable = mkEnableOption "Lenovo Yoga audio configuration";
  };

  config = mkIf cfg.enable {
    # PipeWire audio configuration optimized for Yoga devices
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Hardware packages for audio
    environment.systemPackages = with pkgs; [
      pavucontrol
      pulseaudio  # For pactl
    ];
  };
}
