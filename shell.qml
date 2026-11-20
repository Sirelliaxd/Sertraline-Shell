import Quickshell
import QtQuick

import "OSDs"
import "components"
import "menus"

ShellRoot {
    // Refresh CPU/RAM every 2s
    RefreshTimer {}

    // Taskbar
    TaskBar {}
    Border {}
    Corners {}

    // OSDs
    VolumeOSD {}

    // Menus
    AppLauncher {}

}
