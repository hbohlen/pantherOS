{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  imports = [
    ./system-monitoring.nix
    ./network-status.nix
    ./media-controls.nix
  ];

  config = mkIf (cfg.enable && cfg.enableWidgets) {
    # Widget autostart configuration
    systemd.user.services.dankmaterial-widgets = {
      description = "DankMaterialShell Widget Manager";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.quickshell}/bin/quickshell --widget-dir /etc/dankmaterial/widgets";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };
  };
}
