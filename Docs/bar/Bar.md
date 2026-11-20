# Top bar

Three `PanelWindow`s per monitor, one shared look, split into left, notch and right sections.

## Files

| File | Role |
| --- | --- |
| `components/TaskBar.qml` | Builds the three windows for every screen |
| `bar/Left.qml` | Workspace dots |
| `bar/Center.qml` | Clock |
| `bar/Right.qml` | Status readouts |
| `bar/BarText.qml` | Shared text style for bar labels |
| `components/WaveShape.qml` | Curved ends of the notch |
| `shell.qml` | Instantiates it: `TaskBar {}` |

## Structure

`TaskBar` is a `Variants` over `Quickshell.screens`, so each monitor gets its own set:

- Left: `PanelWindow` anchored top left, namespace `quickshell-border`, `exclusionMode: Ignore`,
  width is content plus `Theme.pad` plus `Theme.taskbarFlare`.
- Center: the notch, namespace `quickshell-notch`, `exclusiveZone: Theme.barHeight` so windows
  stop below it, width is content plus 165.
- Right: mirror of the left window on the right edge.

All three are `Theme.barHeight` tall and transparent; `WaveShape` paints the background, with
`mode: "left" | "center" | "right"` and `flare` (`Theme.taskbarFlare`) producing the flared
edges where the sections meet. `WaveShape` turns that flare into the handle length of its
S-curve with `flare * 0.55`, which is what makes the transition look soft rather than angular.

Blur on the notch needs the Hyprland layer rule from the README, matching namespace
`quickshell-notch`.

## Sections

- `Left.qml`: a `Repeater` of 7 workspace dots, each a `BarText` that shows a filled glyph
  when `Hyprland.focusedWorkspace.id` matches, a hollow one when the workspace exists in
  `Hyprland.workspaces.values`, and a dim one when it does not. Clicking one dispatches
  `hl.dsp.focus({ workspace = "<n>" })`. There is also a hardcoded `power` label with a fixed
  color.
- `Center.qml`: a `SystemClock` at `precision: Seconds`. Seconds sit to the left of the time
  and the date to the right, both at `Theme.fontSize * 0.6`, baseline aligned to the `hh:mm`
  `BarText` in the middle.
- `Right.qml`, left to right: `IpadButton`, `NetworkProc.barTxt`, a hardcoded `bt` label,
  `VolumelvlProc.barTxt`, `RamProc.barTxt`, `CpuProc.barTxt`, and `Battery.barTxt`, which turns
  `Theme.red` when `Battery.level` is 25 or less.

## Adding an entry

Drop a `BarText { text: Something.barTxt }` into `bar/Right.qml` and expose a `barTxt` string
from the module in `modules/`. Modules with a `barTxt` are covered in `Docs/modules/`.

## Traps

- `bar/Left.qml` and `bar/Right.qml` are plain `RowLayout`s, not windows; their anchors only
  work because they are placed inside the `PanelWindow`s from `TaskBar.qml`.
- The sections size themselves from content (`implicitWidth`), so a new label that reads
  `undefined` shows up as a collapsed or missing section, not as an error.
