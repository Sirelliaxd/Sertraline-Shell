import Quickshell
import Quickshell.Wayland
import QtQuick

import "root:/"
import "root:/bar"
import "root:/modules"

Variants {
  model: Quickshell.screens

  Scope {
    id: scope
    required property var modelData

    property real flare: Theme.taskbarFlare
    property real pad: Theme.pad

    // ───────── LEFT ─────────
    PanelWindow {
      screen: scope.modelData
      anchors { top: true; left: true }
      implicitWidth: leftContent.implicitWidth + scope.pad + scope.flare
      implicitHeight: Theme.barHeight
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "quickshell-border"

      WaveShape {
        anchors.fill: parent
        mode: "left"
        flare: scope.flare
        fill: Theme.background
      }

      Left {
        id: leftContent
        anchors {
          left: parent.left
          leftMargin: scope.pad
          verticalCenter: parent.verticalCenter
        }
      }
    }

    // ───────── CENTER ─────────
    PanelWindow {
      screen: scope.modelData
      anchors { top: true }
      implicitWidth: centerContent.implicitWidth + 165
      implicitHeight: Theme.barHeight
      exclusiveZone: Theme.barHeight
      color: "transparent"
      WlrLayershell.namespace: "quickshell-notch"

      WaveShape {
        anchors.fill: parent
        mode: "center"
        flare: scope.flare
        fill: Theme.background
      }

      Center {
        id: centerContent
        anchors.centerIn: parent
      }
    }

    // ───────── RIGHT ─────────
    PanelWindow {
      screen: scope.modelData
      anchors { top: true; right: true }
      implicitWidth: rightContent.implicitWidth + scope.pad + scope.flare
      implicitHeight: Theme.barHeight
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.namespace: "quickshell-border"

      WaveShape {
        anchors.fill: parent
        mode: "right"
        flare: scope.flare
        fill: Theme.background
      }

      Right {
        id: rightContent
        anchors {
          right: parent.right
          rightMargin: scope.pad
          verticalCenter: parent.verticalCenter
        }
      }
    }
  }
}
