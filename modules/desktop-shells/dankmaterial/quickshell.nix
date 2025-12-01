# modules/desktop-shells/dankmaterial/quickshell.nix
# QuickShell QML components for DankMaterialShell

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.dankmaterial;
in {
  config = mkIf cfg.enable {
    # QuickShell configuration
    environment.systemPackages = with pkgs; [
      quickshell
      qt6.qtdeclarative
      qt6.qtquickcontrols2
      qt6.qtgraphicaleffects
    ];

    # QuickShell configuration directory
    environment.etc."quickshell/config.qml".text = ''
      import QtQuick
      import QtQuick.Controls
      import QtQuick.Layouts
      import QtQuick.Effects

      ApplicationWindow {
          id: root
          visible: true
          width: screen.width
          height: screen.height
          color: "transparent"

          // Main panel
          Rectangle {
              id: topPanel
              anchors.top: parent.top
              anchors.left: parent.left
              anchors.right: parent.right
              height: 48
              color: "#2b2b2b"
              z: 1000

              RowLayout {
                  anchors.fill: parent
                  anchors.leftMargin: 16
                  anchors.rightMargin: 16
                  spacing: 16

                  // Application launcher
                  Button {
                      text: "Apps"
                      onClicked: appLauncher.visible = !appLauncher.visible
                  }

                  // Workspace indicator
                  Label {
                      text: "Workspace " + (currentWorkspace + 1)
                      color: "#ffffff"
                  }

                  // System tray area
                  Rectangle {
                      Layout.fillWidth: true
                      height: 32
                      color: "transparent"

                      RowLayout {
                          anchors.right: parent.right
                          anchors.verticalCenter: parent.verticalCenter
                          spacing: 8

                          // Volume indicator
                          Button {
                              text: "🔊"
                              onClicked: volumeControl.visible = !volumeControl.visible
                          }

                          // Network indicator
                          Button {
                              text: "🌐"
                              onClicked: networkControl.visible = !networkControl.visible
                          }

                          // Battery indicator
                          Label {
                              text: batteryLevel + "%"
                              color: "#ffffff"
                          }

                          // Clock
                          Label {
                              text: Qt.formatDateTime(new Date(), "hh:mm")
                              color: "#ffffff"
                          }
                      }
                  }
              }
          }

          // Application launcher overlay
          Rectangle {
              id: appLauncher
              anchors.centerIn: parent
              width: 600
              height: 400
              color: "#3c3c3c"
              radius: 8
              visible: false
              z: 2000

              ColumnLayout {
                  anchors.fill: parent
                  anchors.margins: 16
                  spacing: 8

                  TextField {
                      id: searchField
                      Layout.fillWidth: true
                      placeholderText: "Search applications..."
                      onTextChanged: filterApps(text)
                  }

                  ListView {
                      id: appList
                      Layout.fillWidth: true
                      Layout.fillHeight: true
                      model: filteredApps
                      delegate: Rectangle {
                          width: appList.width
                          height: 48
                          color: mouseArea.containsMouse ? "#4a4a4a" : "transparent"

                          Text {
                              anchors.left: parent.left
                              anchors.verticalCenter: parent.verticalCenter
                              anchors.leftMargin: 16
                              text: modelData.name
                              color: "#ffffff"
                          }

                          MouseArea {
                              id: mouseArea
                              anchors.fill: parent
                              hoverEnabled: true
                              onClicked: launchApp(modelData.exec)
                          }
                      }
                  }
              }
          }

          // Volume control overlay
          Rectangle {
              id: volumeControl
              anchors.right: parent.right
              anchors.top: topPanel.bottom
              anchors.topMargin: 8
              width: 300
              height: 200
              color: "#3c3c3c"
              radius: 8
              visible: false
              z: 2000

              ColumnLayout {
                  anchors.fill: parent
                  anchors.margins: 16
                  spacing: 16

                  Label {
                      text: "Volume Control"
                      color: "#ffffff"
                  }

                  Slider {
                      id: volumeSlider
                      Layout.fillWidth: true
                      from: 0
                      to: 100
                      value: currentVolume
                      onValueChanged: setVolume(value)
                  }

                  Label {
                      text: currentVolume + "%"
                      color: "#ffffff"
                  }
              }
          }

          // Properties
          property int currentWorkspace: 0
          property int batteryLevel: 85
          property int currentVolume: 50
          property var filteredApps: []

          // Functions
          function filterApps(search) {
              // Filter applications based on search text
              filteredApps = applications.filter(app => 
                  app.name.toLowerCase().includes(search.toLowerCase())
              )
          }

          function launchApp(exec) {
              // Launch application
              Qt.openUrlExternally(exec)
              appLauncher.visible = false
          }

          function setVolume(level) {
              // Set system volume
              currentVolume = level
          }
      }
    '';

    # QuickShell autostart
    systemd.user.services.quickshell-dankmaterial = {
      description = "QuickShell for DankMaterialShell";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.quickshell}/bin/quickshell /etc/quickshell/config.qml";
        Restart = "on-failure";
        RestartSec = 1;
        Environment = [
          "QT_QPA_PLATFORM=wayland"
          "XDG_CURRENT_DESKTOP=DankMaterialShell"
        ];
      };
    };
  };
}