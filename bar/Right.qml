import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "root:/"
import "root:/modules"


RowLayout {  // Right
  anchors {
    right: parent.right
    verticalCenter: parent.verticalCenter
    rightMargin: 10
  }

  spacing: 15

  Text { text: "ipad"; color: "#e6e6e8"}
  BarText { text: NetworkProc.barTxt } // Network
  Text { text: "bt"; color: "#e6e6e8"}
  BarText { text: VolumelvlProc.barTxt  } // Volume
  BarText { text: RamProc.barTxt  } // RAM
  BarText { text: CpuProc.barTxt  } // CPU
  Text { // Battery
    text: Battery.barTxt
    color: (Battery.level > 25)? Theme.foreground : Theme.red
    font { family: Theme.fontFamily; pixelSize: Theme.fontSize; bold: true }
  }
}
