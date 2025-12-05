{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf (cfg.enable && cfg.enableWidgets) {
    # System monitoring dependencies
    environment.systemPackages = with pkgs; [
      lm_sensors
      acpi
      pciutils
      usbutils
      neofetch
    ];

    # System Monitor Widget
    environment.etc."dankmaterial/widgets/system-monitor.qml".text = ''
      import QtQuick
      import QtQuick.Controls
      import QtQuick.Layouts

      Rectangle {
          id: root
          width: 300
          height: 200
          color: "#2b2b2b"
          radius: 8

          ColumnLayout {
              anchors.fill: parent
              anchors.margins: 16
              spacing: 12

              // CPU usage
              Rectangle {
                  Layout.fillWidth: true
                  height: 40
                  color: "#3c3c3c"
                  radius: 4

                  RowLayout {
                      anchors.fill: parent
                      anchors.leftMargin: 12
                      anchors.rightMargin: 12
                      spacing: 8

                      Text {
                          text: "CPU"
                          color: "#ffffff"
                          font.weight: Font.Bold
                      }

                      Rectangle {
                          Layout.fillWidth: true
                          height: 4
                          color: "#4a4a4a"
                          radius: 2

                          Rectangle {
                              width: parent.width * (cpuUsage / 100)
                              height: parent.height
                              color: "#4CAF50"
                              radius: 2
                          }
                      }

                      Text {
                          text: cpuUsage + "%"
                          color: "#ffffff"
                      }
                  }
              }

              // Memory usage
              Rectangle {
                  Layout.fillWidth: true
                  height: 40
                  color: "#3c3c3c"
                  radius: 4

                  RowLayout {
                      anchors.fill: parent
                      anchors.leftMargin: 12
                      anchors.rightMargin: 12
                      spacing: 8

                      Text {
                          text: "RAM"
                          color: "#ffffff"
                          font.weight: Font.Bold
                      }

                      Rectangle {
                          Layout.fillWidth: true
                          height: 4
                          color: "#4a4a4a"
                          radius: 2

                          Rectangle {
                              width: parent.width * (memoryUsage / 100)
                              height: parent.height
                              color: "#2196F3"
                              radius: 2
                          }
                      }

                      Text {
                          text: memoryUsage + "%"
                          color: "#ffffff"
                      }
                  }
              }

              // Temperature
              Rectangle {
                  Layout.fillWidth: true
                  height: 40
                  color: "#3c3c3c"
                  radius: 4

                  RowLayout {
                      anchors.fill: parent
                      anchors.leftMargin: 12
                      anchors.rightMargin: 12
                      spacing: 8

                      Text {
                          text: "TEMP"
                          color: "#ffffff"
                          font.weight: Font.Bold
                      }

                      Rectangle {
                          Layout.fillWidth: true
                          height: 4
                          color: "#4a4a4a"
                          radius: 2

                          Rectangle {
                              width: parent.width * Math.min(temperature / 100, 1)
                              height: parent.height
                              color: temperature > 80 ? "#F44336" : "#FF9800"
                              radius: 2
                          }
                      }

                      Text {
                          text: temperature + "°C"
                          color: temperature > 80 ? "#F44336" : "#ffffff"
                      }
                  }
              }
          }

          // Properties
          property real cpuUsage: 0
          property real memoryUsage: 0
          property real temperature: 0

          // Update timer
          Timer {
              interval: 1000
              running: true
              repeat: true
              onTriggered: updateStats()
          }

          // Functions
          function updateStats() {
              // Update system statistics
              // These would be connected to actual system monitoring
              cpuUsage = Math.random() * 100
              memoryUsage = Math.random() * 100
              temperature = 40 + Math.random() * 40
          }
      }
    '';
  };
}
