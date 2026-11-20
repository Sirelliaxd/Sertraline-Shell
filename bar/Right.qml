import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "root:/"
import "root:/modules"


RowLayout {  // Right
  // Where the volume widget sits, so the volume menu can hang under it
  property alias volumeWidget: volumeTxt

  anchors {
    right: parent.right
    verticalCenter: parent.verticalCenter
    rightMargin: 10
  }

  spacing: 15

  IpadButton {} // OdSender ( ipad screen )
  BarText { text: NetworkProc.barTxt } // Network
  Text { text: "bt"; color: "#e6e6e8"}
  BarText { // Volume, click toggles the volume menu
    id: volumeTxt
    text: VolumelvlProc.barTxt

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      onClicked: VolumeDropdownState.toggle()
    }
  }
  BarText { text: RamProc.barTxt  } // RAM
  BarText { text: CpuProc.barTxt  } // CPU
  Text { // Battery
    text: Battery.barTxt
    color: (Battery.level > 25)? Theme.foreground : Theme.red
    font { family: Theme.fontFamily; pixelSize: Theme.fontSize; bold: true }
  }
}
