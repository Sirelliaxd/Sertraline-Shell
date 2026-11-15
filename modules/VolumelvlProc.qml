pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "root:/"

Singleton {
  property int volumeLevel: 0

  Process {
    id: volProc
    command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
    stdout: SplitParser {
      onRead: data => {
        if (!data) return
        var match = data.match(/Volume:\s*([\d.]+)/)
        if (match) {
          volumeLevel = Math.round(parseFloat(match[1]) * 100)
        }
      }
    }
    Component.onCompleted: running = true
  }
}
