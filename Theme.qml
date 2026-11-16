pragma Singleton

import Quickshell
import QtQuick

Singleton {
  readonly property bool backgroundTransparency: true
// ------- 
  // Colors 
  readonly property color background: backgroundTransparency ? bgTs : bg
  readonly property color bg: "#14141c"
  readonly property color bgTs: "#80000000"
  readonly property color border: "#5f4c5f"
  readonly property color foreground: "#e6e6e8"
  readonly property color foregroundTransparent: "#50ffffff"
  readonly property color inactive: "#787c99"
  readonly property color red: "#f7768e"
  readonly property color blue: "#7aa2f7"
  readonly property color yellow: "#e0af68"
  readonly property color green: "#41a6b5"
// ------- 
  // TaskBar
  readonly property real curveFlare: 28 // Higher -> softer
  readonly property real taskbarFlare: 30
  readonly property real pad: 12
  readonly property int barHeight: 30
  readonly property int borderThickness: 12
  readonly property int fontSize: 13 
  readonly property string fontFamily: "JetBrainsMono Nerd Font"
}
