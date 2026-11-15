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
  Text { text: "net"; color: "#e6e6e8"}
  Text { text: "vpn"; color: "#e6e6e8"}
  Text { text: "bt"; color: "#e6e6e8"}
  Text {
    text: " " + VolumelvlProc.volumeLevel + "%"
    color: Theme.foreground
    font { family: Theme.fontFamily; pixelSize: Theme.fontSize; bold: true }
  }
  Text {
    text: " " + RamProc.memUsage + "%"
    color: Theme.foreground
    font { family: Theme.fontFamily; pixelSize: Theme.fontSize; bold: true }
  }
  Text {
    text: " " + CpuProc.cpuUsage + "%"
    color: Theme.foreground
    font { family: Theme.fontFamily; pixelSize: Theme.fontSize; bold: true }
  }
  Text { // Battery
    text: Battery.icon + " " + Battery.level + "%"
    color: (Battery.level > 25)? Theme.foreground : Theme.red
    font { family: Theme.fontFamily; pixelSize: Theme.fontSize; bold: true }
  }
}
