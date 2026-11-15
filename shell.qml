import Quickshell
import Quickshell.Wayland  // wayland specific support
import Quickshell.Hyprland // Hyprland IPC
import Quickshell.Io // Process type
import QtQuick
import QtQuick.Layouts  // RowLayout

import "bar"
import "modules"
import "OSDs"
import "components"

ShellRoot {
  // Taskbar
  TaskBar {}
  Border {}
  Corners {}

  // OSDs 
  VolumeOSD {}
}
