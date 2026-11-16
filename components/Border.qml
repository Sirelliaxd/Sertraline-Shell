import Quickshell
import Quickshell.Wayland
import QtQuick

import "root:/"

Scope {
  id: root
  property int thickness: Theme.borderThickness
  property color borderColor: Theme.background

  Variants {
    model: Quickshell.screens

    Item {
      id: screenRoot
      required property var modelData

      PanelWindow { // bottom
        screen: screenRoot.modelData
        anchors { bottom: true; left: true; right: true }
        implicitHeight: root.thickness
        exclusiveZone: root.thickness
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell-border"
        color: root.borderColor
      }

      PanelWindow { // Left
        screen: screenRoot.modelData
        anchors { top: true; bottom: true; left: true; }
        margins { top: Theme.barHeight}
        implicitWidth: root.thickness
        exclusiveZone: root.thickness
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell-border"
        color: root.borderColor
      }

      PanelWindow { // Right
        screen: screenRoot.modelData
        anchors { top: true; bottom: true; right: true }
        margins { top: Theme.barHeight}
        implicitWidth: root.thickness
        exclusiveZone: root.thickness
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell-border"
        color: root.borderColor
      }
    }
  }
}
