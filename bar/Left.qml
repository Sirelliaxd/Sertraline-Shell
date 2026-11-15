import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "root:/"

  RowLayout {  // Left
    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
      leftMargin: 10
    }

    spacing: 15

    Text { text: "power"; color: "#e6e6e8"}

    Repeater { // 9 copies (0-8)
      model: 7

      Text {
        property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1 )
        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

        // text: index + 1
        text: isActive? "" : (ws ? "" : "")
        // color: isActive? "#0db9d7" : (ws ? "#7aa2f7" : "#e6e6e8")
        color: Theme.foreground
        font { family: Theme.fontFamily; pixelSize: Theme.fontSize; bold: true }

        // Click to switch workspace
        MouseArea {
          anchors.fill: parent
          onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = "${index + 1}" })`)

        }
      }
    }
  }
