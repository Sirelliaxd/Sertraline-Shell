import Quickshell
import Quickshell.Wayland  // wayland specific support
import Quickshell.Hyprland // Hyprland IPC
import Quickshell.Io // Process type
import QtQuick
import QtQuick.Layouts  // RowLayout

import "bar"
import "modules"

PanelWindow {
  id: root

  anchors { top: true; left: true; right: true }
  implicitHeight: 30


  Rectangle {
    anchors.fill: parent
    color: Theme.background // Background color
  }

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
