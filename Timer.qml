import Quickshell
import QtQuick
import "modules"


// Timer refresing every 2s
Timer {
  interval: 2000
  running: true
  repeat: true
  onTriggered: {
    cpuProc.running = true
    memProc.running = true
  }
}
