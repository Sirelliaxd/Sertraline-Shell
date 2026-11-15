import QtQuick
import Quickshell
import Quickshell.Wayland

import "root:/"

Scope {
  id: root

  property int radius: 14
  property int borderTop: Theme.barHeight
  property int borderBottom: Theme.borderThickness
  property int borderLeft: Theme.borderThickness
  property int borderRight: Theme.borderThickness
  property color color: Theme.background

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors { top: true; bottom: true; left: true; right: true }
      color: "transparent"
      WlrLayershell.namespace: "quickshell-border"
      exclusionMode: ExclusionMode.Ignore
      mask: Region {}   // empty region: all input passes through

      Corner {   // top-left
        anchors { top: parent.top; left: parent.left
                  topMargin: root.borderTop; leftMargin: root.borderLeft }
        radius: root.radius; color: root.color
      }
      Corner {   // top-right
        anchors { top: parent.top; right: parent.right
                  topMargin: root.borderTop; rightMargin: root.borderRight }
        radius: root.radius; color: root.color
        flipX: true
      }
      Corner {   // bottom-left
        anchors { bottom: parent.bottom; left: parent.left
                  bottomMargin: root.borderBottom; leftMargin: root.borderLeft }
        radius: root.radius; color: root.color
        flipY: true
      }
      Corner {   // bottom-right
        anchors { bottom: parent.bottom; right: parent.right
                  bottomMargin: root.borderBottom; rightMargin: root.borderRight }
        radius: root.radius; color: root.color
        flipX: true
        flipY: true
      }
    }
  }
}
