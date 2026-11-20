pragma Singleton

import Quickshell
import QtQuick
import "root:/"

// Visibility of the volume dropdown. The bar's volume readout and the menu share it.
Singleton {
  id: root

  property bool visible: false

  // Screen x of the bar's volume widget centre, written by the frame surface, so the
  // menu can hang under that widget instead of under a corner.
  property real anchorX: 0

  function show() {
    visible = true;
  }
  function hide() {
    visible = false;
  }
  function toggle() {
    visible = !visible;
  }
}
