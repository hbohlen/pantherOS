{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf (cfg.enable && cfg.enableServices) {
    # Systemd user services for DankMaterialShell integration
    systemd.user = {
      # Audio control service
      services.dankmaterial-audio = {
        description = "DankMaterialShell Audio Service";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" "pipewire.service" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScript "dankmaterial-audio" ''
            # Initialize audio settings for DankMaterialShell
            export PULSE_RUNTIME_PATH="/run/user/$(id -u)/pulse"

            # Set default audio profile
            ${pkgs.pulseaudio}/bin/pactl set-default-sink @DEFAULT_SINK@

            # Initialize volume
            ${pkgs.pamixer}/bin/pamixer --set-volume 50

            # Start audio monitoring
            while true; do
              # Update audio status for widgets
              ${pkgs.pamixer}/bin/pamixer --get-volume > /tmp/dankmaterial_volume
              sleep 2
            done
          ''}";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };

      # Network monitoring service
      services.dankmaterial-network = {
        description = "DankMaterialShell Network Service";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" "NetworkManager.service" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScript "dankmaterial-network" ''
            # Network monitoring for DankMaterialShell
            while true; do
              # Get Wi-Fi status
              WIFI_STATUS=$(${pkgs.iw}/bin/iw dev wlan0 link | grep 'Connected to' | cut -d' ' -f2 | tr -d ',')
              WIFI_SIGNAL=$(${pkgs.iw}/bin/iw dev wlan0 link | grep 'signal' | awk '{print $2}' | tr -d 'dBm')

              # Get Ethernet status
              ETH_STATUS=$(${pkgs.networkmanager}/bin/nmcli -t -f TYPE,DEVICE,STATE connection show --active | grep ethernet | cut -d: -f3)
              ETH_IP=$(${pkgs.networkmanager}/bin/nmcli -t -f IP4.ADDRESS device show eth0 | head -1)

              # Write status for widgets
              echo "WIFI:$WIFI_STATUS:$WIFI_SIGNAL" > /tmp/dankmaterial_network
              echo "ETH:$ETH_STATUS:$ETH_IP" >> /tmp/dankmaterial_network

              sleep 5
            done
          ''}";
          Restart = "on-failure";
          RestartSec = 1;
        };
      };
    };
  };
}
