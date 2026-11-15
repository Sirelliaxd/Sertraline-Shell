import Quickshell
import Quickshell.Wayland  // wayland specific support
import Quickshell.Hyprland // Hyprland IPC
import Quickshell.Io // Process type
import QtQuick
import QtQuick.Layouts  // RowLayout

import "root:/"
import "root:/bar"
import "root:/modules"


Variants {
  model: Quickshell.screens
  
  PanelWindow {
    id: barRoot
    required property var modelData
    screen: modelData

    property color barBackground: Theme.background // Bcakground Color


    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight


    color: barBackground
    WlrLayershell.namespace: "quickshell-border"

    // Bar 
    Left {
      anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: 10
      }
    }

    Center {
      anchors.centerIn: parent
    }

    Right {
      anchors {
        right: parent.right
        verticalCenter: parent.verticalCenter
        rightMargin: 10
      }
    }
  }
}
