pragma Singleton

import Quickshell
import QtQuick
import "root:/"

// Visibility of the network dropdown, plus where the bar's network readout sits so the menu
// can open out of it. Same shape as VolumeDropdownState.
Singleton {
  id: root

  property bool visible: false

  // Screen x of the bar's network widget centre, written by the frame surface.
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
