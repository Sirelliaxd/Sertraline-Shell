pragma Singleton

import Quickshell
import QtQuick
import "root:/"

// Visibility of the power dropdown. The bar's power icon and the menu share it.
Singleton {
  id: root

  property bool visible: false

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
