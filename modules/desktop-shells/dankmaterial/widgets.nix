# modules/desktop-shells/dankmaterial/widgets.nix
# Widget configurations for DankMaterialShell

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf (cfg.enable && cfg.enableWidgets) {
    # Widget dependencies
    environment.systemPackages = with pkgs; [
      # System monitoring
      lm_sensors
      acpi
      pciutils
      usbutils
      
      # Network tools
      iwgtk
      blueman
      
      # Audio tools
      pavucontrol
      pamixer
      
      # Battery and power
      tlp
      power-profiles-daemon
      
      # Date/time
      calcurse
      
      # System info
      neofetch
    ];

    # Widget configuration files
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

    environment.etc."dankmaterial/widgets/network.qml".text = ''
      import QtQuick
      import QtQuick.Controls
      import QtQuick.Layouts

      Rectangle {
          id: root
          width: 280
          height: 180
          color: "#2b2b2b"
          radius: 8

          ColumnLayout {
              anchors.fill: parent
              anchors.margins: 16
              spacing: 12

              // Wi-Fi status
              Rectangle {
                  Layout.fillWidth: true
                  height: 50
                  color: "#3c3c3c"
                  radius: 4

                  RowLayout {
                      anchors.fill: parent
                      anchors.leftMargin: 12
                      anchors.rightMargin: 12
                      spacing: 8

                      Text {
                          text: "📶"
                          font.pixelSize: 20
                      }

                      ColumnLayout {
                          Layout.fillWidth: true
                          spacing: 2

                          Text {
                              text: wifiSSID || "No Connection"
                              color: "#ffffff"
                              font.weight: Font.Bold
                          }

                          Text {
                              text: wifiSignal + "%"
                              color: "#ffffff"
                              font.pixelSize: 12
                          }
                      }

                      Button {
                          text: "⚙"
                          onClicked: networkSettings()
                      }
                  }
              }

              // Ethernet status
              Rectangle {
                  Layout.fillWidth: true
                  height: 50
                  color: "#3c3c3c"
                  radius: 4

                  RowLayout {
                      anchors.fill: parent
                      anchors.leftMargin: 12
                      anchors.rightMargin: 12
                      spacing: 8

                      Text {
                          text: "🌐"
                          font.pixelSize: 20
                      }

                      ColumnLayout {
                          Layout.fillWidth: true
                          spacing: 2

                          Text {
                              text: ethernetConnected ? "Connected" : "Disconnected"
                              color: ethernetConnected ? "#4CAF50" : "#F44336"
                              font.weight: Font.Bold
                          }

                          Text {
                              text: ethernetIP || "No IP"
                              color: "#ffffff"
                              font.pixelSize: 12
                          }
                      }
                  }
              }
          }

          // Properties
          property string wifiSSID: "HomeNetwork"
          property real wifiSignal: 85
          property bool ethernetConnected: true
          property string ethernetIP: "192.168.1.100"

          // Functions
          function networkSettings() {
              // Open network settings
              Qt.openUrlExternally("nm-connection-editor")
          }
      }
    '';

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