# Sertraline Shell

A Quickshell desktop shell for Hyprland: a top bar with a notch, a screen border with rounded
corners, a volume OSD and an app launcher.

Per-area docs live next to this file: `bar/Bar.md`, `bar/borders.md`, `OSDs/VolumeOSD.md`,
`Menus/Applauncher.md` and one file per module in `modules/`.

## 1. Structure and approach

```
quickshell/
  shell.qml            entry point, instantiates every window
  Theme.qml            singleton: all sizes, colors, fonts, strings
  RefreshTimer.qml     the one polling loop
  components/          visual building blocks reused by windows
    TaskBar.qml        builds the three bar windows per screen
    WaveShape.qml      flared/curved bar background
    Border.qml         frame around the screen
    Corners.qml        places the four corner shapes
    Corner.qml         one concave corner
  bar/                 bar sections (contents of the bar windows)
    Left.qml Center.qml Right.qml
    BarText.qml        shared label style
  menus/
    AppLauncher.qml    the launcher window
  OSDs/
    VolumeOSD.qml      volume overlay
  modules/             non-visual state, one singleton per readout
    CpuProc.qml RamProc.qml NetworkProc.qml Battery.qml
    VolumelvlProc.qml OdSender.qml ApplauncherState.qml
    IpadButton.qml     the one widget that lives here
  plans/               empty, scratch space
```

The approach is consistent across the config:

- **Windows are declared, not scripted.** Every visible surface is a Quickshell `PanelWindow`,
  so it is a Wayland layer surface with a namespace, an exclusive zone and a layer. No external
  bars, scripts or daemons are involved.
- **`shell.qml` is the only place that instantiates anything.** Files in `components/`,
  `bar/`, `menus/` and `OSDs/` are types; a type that nothing instantiates does nothing, and
  that includes everything commented out in `shell.qml`.
- **State lives in `modules/` singletons.** They hold no UI. Each one either binds to a
  Quickshell service (`Networking`, `UPower`, `Pipewire`, `Hyprland`) or shells out once
  through a `Process`, and then exposes a formatted string. The bar only reads those strings.
- **One polling loop.** The two modules that sample `/proc` and `free` are driven by
  `RefreshTimer.qml`. Everything else is a binding and updates itself.
- **The bar is dumb, the modules are smart.** A bar section contains layout and a `barTxt`
  reference, never parsing or threshold logic. Adding a readout means adding a module with a
  `barTxt` and one line in `bar/Right.qml`.
- **`Theme.qml` owns every number.** No section hardcodes a size, a duration or a color; the
  exceptions are the few leftover hardcoded labels and hex colors in `bar/Left.qml` and
  `bar/Right.qml`.
- **Fullscreen windows that should not block input use `mask: Region {}`**, which is how the
  border, the corners and the volume OSD stay click-through.
- **Multi-monitor is handled by `Variants` over `Quickshell.screens`**, not by per-monitor
  config files, and only where it matters (bar, border, corners). The launcher and the volume
  OSD are single windows that the compositor places.
- **There are no tests and no build step.** Quickshell watches the config and hot-reloads on
  save, so the running shell is the test. `.qmlls.ini` is a symlink into
  `/run/user/1000/quickshell/vfs/<shell id>/` and is gitignored.

Naming and import conventions: singletons are PascalCase files whose first line is
`pragma Singleton` and whose root is `Singleton {}`; files in subdirectories reach the root
with `import "root:/"`; derived values are `readonly property`, settable ones are `property`;
icons are Nerd Font glyphs rendered in `Theme.fontFamily`.

## 2. Theme.qml

`Theme.qml` is the design token file: one singleton holding every constant the shell draws
with. It is deliberately not a component, it creates no window and runs no logic, it is a flat
list of `readonly property` declarations that other files read as `Theme.<name>`.

Structure:

- `pragma Singleton` on line 1, then `import Quickshell` and `import QtQuick`, then a
  `Singleton {` root. The Quickshell `Singleton` root (rather than a bare `QtObject`) is what
  makes reloads propagate into the values.
- Everything is `readonly`. Nothing in the shell writes to `Theme`, so the values are constants
  at runtime and cannot drift from what is declared.
- The file is grouped by consumer, separated by `// -------` rules: colors, font, then a
  `// TaskBar` block, then an `// App Launcher` block. Adding a feature means adding a block
  here, prefixed with that feature's name.
- Names are `<feature><Part><Property>`, for example `appLauncherPanelWidth`,
  `appLauncherSlideAnimDuration`, `appLauncherAppNamesFontSize`. Prefixes are the only
  namespace the file has, and they are what keep it navigable as it grows.
- Values may reference earlier ones, which is how the theme stays coherent: `background`
  resolves to `bgTs` or `bg` depending on `backgroundTransparency`, and the app launcher colors
  are aliases of `foreground`, `inactive` and `border` rather than fresh hex values.
- Property types are the Qt ones the consuming code needs: `int` and `real` for geometry and
  durations, `color` for colors, `string` for text, `bool` for flags. Durations are plain
  `int` milliseconds and easing types are `real` (`Easing.OutCubic`) passed straight to
  `NumberAnimation`.
- Text and other user-facing strings live here too (`appLauncherSearchBoxText`,
  `appLauncherNoAppsFound`, `appLauncherRecentAppsText`), so copy changes do not touch QML
  logic.
- The font block is `fontSize` and `fontFamily` only, and every text element in the shell
  reads both from here, with per-element sizes expressed as a fraction of `fontSize` when they
  need to differ.

The practical consequence: the theme is the contract between the modules and the UI. If a name
here does not match the name a widget uses, the widget reads `undefined`, which QML reports as
a zero size or a wrong color, never as an error. `Docs/Menus/Applauncher.md` records two cases
of exactly that.

## 3. shell.qml

`shell.qml` is the entry point Quickshell loads, and the whole of it is one `ShellRoot` with a
list of children:

```qml
ShellRoot {
    RefreshTimer {}   // drives the CPU and RAM samples
    TaskBar {}        // bar windows, one set per screen
    Border {}         // frame around the screen
    Corners {}        // rounded corners where frame and notch meet
    VolumeOSD {}      // volume overlay
    AppLauncher {}    // app launcher window
}
```

Points worth knowing:

- Imports are `Quickshell`, `QtQuick`, then the directories of the types used (`"OSDs"`,
  `"components"`, `"menus"`). Types in the config root (`Theme`, `RefreshTimer`) need no
  import, which is why `RefreshTimer` is instantiated without one.
- Order in the file has no effect on stacking. What decides layering is the layer each
  `PanelWindow` asks for (`WlrLayer.Bottom` for the border, `WlrLayer.Overlay` for the
  launcher) and the order in which windows are created.
- `ShellRoot` is the process-wide root, and the singletons in `modules/` are created on first
  reference, not here. That is why the bar's data modules (`CpuProc`, `RamProc`,
  `NetworkProc`, `Battery`, `VolumelvlProc`) never appear in this file: the bar sections pull
  them in.
- Nothing here carries configuration. Comments mark the sections (`// Taskbar`, `// OSDs`,
  `// Menus`), and an entry commented out is a feature that is simply not running.

## 4. RefreshTimer.qml

`RefreshTimer.qml` is a plain QtQuick `Timer`, 2000 ms, `running: true`, `repeat: true`, whose
handler pokes the two `Process`-based modules:

```qml
Timer {
  interval: 2000
  running: true
  repeat: true
  onTriggered: {
    CpuProc.running = true
    RamProc.running = true
  }
}
```

It exists because those two modules can only produce a new value by running a command again:
CPU usage is a delta between two `/proc/stat` reads, so it needs a repeat, and `free` is
re-read on the same cadence to stay in step. Both modules also run once from their own
`Component.onCompleted`, so the bar shows a value immediately and then updates every 2 s.
Everything else in the shell is a binding on a Quickshell service and needs no timer.

Two things to keep in mind:

- The assignments only work because `CpuProc` and `RamProc` alias `running` to their inner
  `Process`. Without the alias the assignment is a silent no-op and the value freezes.
- The file is called `RefreshTimer.qml` and not `Timer.qml` on purpose. A local `Timer.qml` in
  the config root would lose to `import QtQuick`'s `Timer`, so a bare `Timer {}` would build
  the QtQuick type with no handlers attached. Local types get names no imported module
  defines.
- Its `import "components"` and `import "bar"` lines are unused leftovers; only the
  `"modules"` import is needed.
