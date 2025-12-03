{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf (cfg.enable && cfg.enableWidgets) {
    # Network widget dependencies
    environment.systemPackages = with pkgs; [
      iwgtk
      blueman
    ];

    # Network Status Widget
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
                          text: "⚙️"
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
                          text: ethernetConnected ? "🌐" : "⚠️"
                          font.pixelSize: 20
                          color: ethernetConnected ? "#4CAF50" : "#F44336"
                      }

                      ColumnLayout {
                          Layout.fillWidth: true
                          spacing: 2

                          Text {
                              text: ethernetConnected ? "Ethernet Connected" : "No Ethernet"
                              color: ethernetConnected ? "#4CAF50" : "#F44336"
                              font.weight: Font.Bold
                          }

                          Text {
                              text: ethernetIP || "N/A"
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
  };
}
