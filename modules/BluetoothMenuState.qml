pragma Singleton

import Quickshell
import QtQuick
import "root:/"

// Visibility of the bluetooth dropdown. The bar's bluetooth readout and the menu share it.
Singleton {
  id: root

  property bool visible: false

  // Screen x of the bar's bluetooth widget centre, written by the frame surface, so the
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
