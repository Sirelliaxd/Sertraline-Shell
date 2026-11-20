# Top bar

The bar is `Theme.barHeight` (30) tall and made of three parts: the left end, the notch in the
middle and the right end. Only the notch is a window of its own; both ends are drawn inside the
frame window, see `Docs/bar/borders.md`.

## Files

| File | Role |
| --- | --- |
| `components/TaskBar.qml` | Builds the notch window for every screen |
| `components/Border.qml` | Draws the left and right bar ends in the frame surface |
| `bar/Left.qml` | Workspace dots |
| `bar/Center.qml` | Clock |
| `bar/Right.qml` | Status readouts |
| `bar/BarText.qml` | Shared text style for bar labels |
| `components/WaveShape.qml` | Flared ends of each part |
| `shell.qml` | Instantiates the notch: `TaskBar {}` |

## Structure

`TaskBar.qml` is a `Variants` over `Quickshell.screens`, so every monitor gets its own notch
window:

- `PanelWindow` anchored top, namespace `quickshell-notch`, `exclusiveZone: Theme.barHeight` so
  windows stop below the bar, width is the clock's width plus 165.

The two ends are `Item`s inside the frame window in `Border.qml`, anchored to the top left and
top right of the screen:

- width is the content's `implicitWidth` plus `Theme.pad` plus `Theme.taskbarFlare`,
- each holds a `WaveShape` (`mode: "left"` / `"right"`, `flare: Theme.taskbarFlare`) that paints
  the flared background, and the section itself on top.

`WaveShape` turns the flare into the handle length of its S-curve with `flare * 0.55`, which is
what makes the transition between the ends and the notch look soft rather than angular.

Input: the frame window's mask is the full width bar strip, so clicks on the bar reach the
workspace dots and the `IpadButton` while the frame and corners stay click-through.

Blur: the notch needs the Hyprland layer rule from the README (namespace `quickshell-notch`).
The ends sit in the frame surface, so they are blurred by whatever rule matches namespace
`quickshell-border`.

## Sections

- `Left.qml`: a `Repeater` of 7 workspace dots, each a `BarText` that shows a filled glyph
  when `Hyprland.focusedWorkspace.id` matches, a hollow one when the workspace exists in
  `Hyprland.workspaces.values`, and a dim one when it does not. Clicking one dispatches
  `hl.dsp.focus({ workspace = "<n>" })`. Before the dots sits the Artix glyph
  (`Theme.powerDropdownIcon`), which toggles the power menu, see `Docs/Menus/PowerDropdown.md`.
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

- `bar/Left.qml` and `bar/Right.qml` are plain `RowLayout`s, not windows. They anchor
  themselves, so they only work as children of a container that already has a size: the end
  `Item`s in `Border.qml` for these two, the notch window for `Center.qml`.
- The ends size themselves from content (`implicitWidth`), so a new label that reads
  `undefined` shows up as a collapsed or missing end, not as an error.
- Because the ends live in the frame surface, changing `barHeight` in `Theme.qml` moves them,
  the frame and the corners together. Changing the bar's height in only one of the files leaves
  a gap at the top of the frame.
