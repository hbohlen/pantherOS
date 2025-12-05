{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf (cfg.enable && cfg.enableWidgets) {
    # Media control dependencies
    environment.systemPackages = with pkgs; [
      pavucontrol
      pamixer
    ];

    # Media Control Widget
    environment.etc."dankmaterial/widgets/volume.qml".text = ''
      import QtQuick
      import QtQuick.Controls
      import QtQuick.Layouts

      Rectangle {
          id: root
          width: 250
          height: 120
          color: "#2b2b2b"
          radius: 8

          ColumnLayout {
              anchors.fill: parent
              anchors.margins: 16
              spacing: 12

              // Volume slider
              Text {
                  text: "Volume"
                  color: "#ffffff"
                  font.weight: Font.Bold
              }

              Slider {
                  id: volumeSlider
                  Layout.fillWidth: true
                  from: 0
                  to: 100
                  value: currentVolume
                  onValueChanged: setVolume(value)
              }

              RowLayout {
                  Layout.fillWidth: true
                  spacing: 8

                  Text {
                      text: currentVolume + "%"
                      color: "#ffffff"
                  }

                  Rectangle {
                      Layout.fillWidth: true
                      height: 4
                      color: "#4a4a4a"
                      radius: 2

                      Rectangle {
                          width: parent.width * (currentVolume / 100)
                          height: parent.height
                          color: "#2196F3"
                          radius: 2
                      }
                  }
              }

              // Mute button
              Button {
                  Layout.fillWidth: true
                  text: isMuted ? "🔇 Unmute" : "🔊 Mute"
                  onClicked: toggleMute()
              }
          }

          // Properties
          property real currentVolume: 50
          property bool isMuted: false

          // Functions
          function setVolume(level) {
              currentVolume = level
              // Set system volume using pactl or wpctl
          }

          function toggleMute() {
              isMuted = !isMuted
              // Toggle system mute
          }
      }
    '';
  };
}
