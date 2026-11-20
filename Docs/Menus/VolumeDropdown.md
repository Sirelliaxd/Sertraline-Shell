# Volume Dropdown

Volume menu, opened from the volume readout in the right end of the top bar. Everything in it is
Pipewire, read and written through Quickshell's `Quickshell.Services.Pipewire` module: no `wpctl`,
`pactl` or other CLI involved, and no daemon of its own.

## Files

| File | Role |
| --- | --- |
| `menus/VolumeDropdown.qml` | The menu window, its rows and its animation |
| `modules/VolumeDropdownState.qml` | Singleton holding the open state and the bar anchor |
| `components/VolumeSlider.qml` | The draggable level bar every slider row is built from |
| `bar/Right.qml` | The volume readout and the click that toggles the menu |
| `components/Border.qml` | Draws that readout, and reports where it sits |
| `Theme.qml` | Every `volumeDropdown*` property |
| `shell.qml` | Instantiates it: `VolumeDropdown {}` |

## Opening it

Click the volume readout (`VolumelvlProc.barTxt`: a speaker glyph and the level) in the right end
of the bar, or use the IPC handler the menu registers:

```
qs ipc call volumedropdown toggle
```

It closes on `Escape`, on a click anywhere outside the panel, and when the readout is clicked
again.

## Window

- `PanelWindow` anchored to all four edges, layer `WlrLayer.Overlay`, namespace
  `quickshell-volume-dropdown`. A Hyprland layer rule can match that namespace, the same way the
  launcher and the power menu are blurred.
- Mask, keyboard focus, on-demand building and the unload timer are the power menu's, reused: the
  mask is empty while closed so the surface takes no input, the whole window takes input while
  open, `Escape` reaches the panel through `WlrKeyboardFocus.Exclusive`, and `shell.qml` holds the
  window in a `LazyLoader` driven by an explicit `volumeAlive` flag, cleared by a timer
  (`Theme.volumeDropdownAnimDuration + Theme.menuUnloadGrace`) after it closes. Nothing of the menu
  exists while it is closed.
- The panel hangs under the bar's volume widget rather than under a corner. `components/Border.qml`
  (the frame surface that draws both bar ends) computes that widget's centre x and writes it to
  `VolumeDropdownState.anchorX`; the panel's left margin is that value minus half the panel width,
  clamped into the margins so a widget near the screen edge cannot push the panel off it.
  `Theme.volumeDropdownMargin` is the power menu's margin by reference, so the gap to the frame and
  the bar matches on both menus.
- The menu reads `anchorX` ONCE, when it opens, and keeps that value for its whole lifetime. It has
  to: the bar's readouts change width as their values change, and the volume widget sits four items
  in from the right end of the bar, so its centre moves whenever the volume percentage, the CPU, the
  RAM or the battery text gets wider or narrower. A live anchor therefore drags the panel sideways
  while a slider is being dragged, and shifts it every couple of seconds on its own. Measured here,
  the live value moved 987.5 → 976.5 → 984 as the volume went 70% → 100% → 5%, which moved the panel
  3.5 px mid-drag; with the snapshot the panel holds its x while the live value keeps changing.

## Animation

Both axes animate, from nothing to the full panel, over `Theme.volumeDropdownAnimDuration` with
`Theme.volumeDropdownAnimType`:

- `width` runs `0` to `Theme.volumeDropdownPanelWidth`,
- `height` runs `0` to `min(content.implicitHeight, Theme.volumeDropdownMaxContentHeight) + 2 *
  contentMargin`.

The panel is anchored to the top of the window and its left margin is `anchorX - width / 2`, clamped
into the margins, so it opens out of the volume widget: the first frames are a small box under that
widget, which then grows downward and sideways. The widget sits near the right end of the bar, so the
panel reaches the right margin within the first few frames and the rest of the growth goes leftward.
Closing runs both values back down, so the panel shrinks into the widget and disappears. Traced frame
by frame, the top edge holds its `y` while the height climbs and the left edge slides out: width
0 → 27 → 57 → 85 ... 340, height 17 → 36 → 54 → 70 ... 216, `x` 988 → 974 → 959 → 945 ... 810, and the
close runs the same numbers back. The resting panel is `340 x 216` at `x = 810` on the iPad screen,
the same place it sat before the width animated.

The content is laid out at its full size and revealed by the panel's `clip: true`: the `Flickable` is
`panelW - 2 * contentMargin` wide regardless of the animated width, so the rows never reflow against
the shrinking box. Nothing elides and no slider squashes while it opens. Opening a device list or the
stream list grows the same animated height instead of snapping, and the height stops at
`Theme.volumeDropdownMaxContentHeight` with the rows scrolling past that point, see Scrolling below.

## Rows

Top down:

| Row | What it does |
| --- | --- |
| `output` | Default sink level. The slider writes `Pipewire.defaultAudioSink.audio.volume`, the icon bubble toggles its mute |
| `output` (device) | Shows the current sink's description, clicking it opens the list of sinks |
| `input` | Default source level, writes `Pipewire.defaultAudioSource.audio.volume`, the bubble toggles its mute |
| `input` (device) | Shows the current source, clicking it opens the list of sources |
| `apps` | Shows or hides one row per playing stream |
| stream rows | One per node that is both a stream and a sink (a playback stream), each writing its own `audio.volume` and muting its own node |

- The two level rows and every stream row use `components/VolumeSlider.qml`: a track, a fill and a
  knob, set by pressing or dragging anywhere on the track and clamped to 0..1. A node can sit above
  100% (the built-in sink on this machine does, at 145%), so the readout shows the real percentage
  while the bar just stays full.
- The icon bubble of a level row or a stream row is that row's mute button. A muted row draws the
  bubble inverted (bright fill, dark glyph) with the crossed-out glyph from the theme
  (`volumeDropdownOutputMutedIcon`, `volumeDropdownInputMutedIcon`) instead of the normal one, so
  the state is readable at a glance and does not depend on the percentage, which keeps showing the
  real level.
- The device lists open one at a time (`openList`). The current device is drawn in `foreground`,
  the others dim, and picking one sets `Pipewire.preferredDefaultAudioSink` or
  `preferredDefaultAudioSource` and closes the list.
- Stream rows are labelled from `application.name`, falling back to the node's description and
  then its name. A node without an `audio` object (video, MIDI, untracked) is never listed, and
  with nothing playing the expanded section says so instead of showing an empty list.
- `PwObjectTracker` holds every node in `Pipewire.nodes`, so a node cannot be destroyed while a row
  still points at it.
- Every value is a binding on Pipewire: the levels, the device names, the stream list and the muted
  state update by themselves, with no polling and no timer.

## Keys

The panel takes keyboard focus while it is open, and one row is always selected. The selected row
is the one with the darker band behind it, and the selection follows the pointer as well: hovering
any row selects it, so the mouse and the keyboard drive the same cursor.

| Key | Effect |
| --- | --- |
| `Up` / `Down` | Move the selection through the rows, wrapping around, including the rows of an opened device list and the stream rows |
| `Left` / `Right` | Move the selected level by `Theme.volumeDropdownKeyStep` (0.05), clamped to 0..1. Does nothing on a device row |
| `Return` / `Enter` / `Space` | Activate the row: open or close a device list, pick a device, show or hide the stream list |
| `M` | Mute or unmute the selected row, if it has a level |
| `Escape` | Close the menu |

- The rows are addressed by a string key (`out-level`, `out-device`, `out-entry-<node id>`,
  `in-level`, `in-device`, `in-entry-<node id>`, `apps`, `stream-<node id>`) and each row binds its
  own `selected` to `root.selectedKey`. `navRows` builds the same keys in visual order, so the
  order the arrow keys walk and the order the rows are drawn cannot drift apart.
- Activating a device row opens its list but leaves the selection on that row, so `Down` then walks
  into the list. Picking a device closes the list and puts the selection back on the device row.
- Hiding the stream list moves the selection back to the `apps` row.
- `M` acts on the selected row only: the output level, the input level, or one stream. Device rows
  have no level, so `M` does nothing there.

## Scrolling

The content is capped at `Theme.volumeDropdownMaxContentHeight` (420 px). Up to that height the
panel grows with its content, as the animation section describes; past it the panel stops growing
and the rows scroll instead, so a long stream list or a machine with many devices cannot push the
panel off the bottom of the screen.

- The cap is a `Flickable` around the row `Column`: `height` is the smaller of the content's
  `implicitHeight` and the cap, `contentHeight` is the content's full height, and the wheel scrolls
  while the pointer is over the panel.
- Moving the selection scrolls the selected row into view (`ensureVisible`), which finds the row by
  its key and sets `contentY` so the row's top or bottom is inside the visible area, clamped to the
  content's own range. Keyboard navigation therefore never leaves the selection off screen.
- `boundsBehavior: Flickable.StopAtBounds` keeps the content from being dragged past its ends.
- The sliders set `preventStealing: true` on their `MouseArea`, so a drag on a knob is never taken
  over by the Flickable: without it, dragging with any vertical wobble scrolls the panel and the
  value jumps around under the cursor.

## Traps

- The menu owns the pointer and the keyboard while open, so a failure to close leaves the desktop
  unclickable until it is toggled again. Same trap as the other menus.
- Every row must carry a `rowKey` and bind its `selected` to it. A new row without one is invisible
  to `ensureVisible` (which finds the row by key), so the arrow keys can walk the selection out of
  the visible area, and it can never show as selected.
- The panel's height is bound to the Flickable's height, not to the content's `implicitHeight`.
  Binding it to the content makes the cap do nothing and the panel grows past the screen again.
- Muting acts on the node behind the row: the output level row mutes the default sink, the input row
  the default source, and a stream row only that stream. A muted node keeps reporting its volume, so
  the percentage is the level, not whether anything can be heard. There is no unmute-all.
- Signal handlers that read the injected parameters (`onPressed: ... mouse.x`, `onMoved: ... level`)
  are deprecated in Qt 6 and log a warning on every load of this file; the handlers here take them as
  formal parameters (`onMoved: function (level) { ... }`). Keep new ones in that form.
- `anchorX` is written by the frame surface of every screen, so on a multi-monitor setup the value
  that survives is the last one written, not necessarily the screen the menu opens on. Because the
  menu samples it once at open, that only ever shows as a few pixels of difference between two
  openings, never as movement while the menu is up; the volume widget sits near the right edge on
  every screen, so the clamped result is close either way. The anchor is not screen-aware.
- A live anchor is the trap this menu already fell into: binding the panel's position straight to
  `VolumeDropdownState.anchorX` makes it follow the bar's text widths, so it slides sideways while a
  slider is dragged and jitters whenever the CPU or RAM readout changes width. Sample it at open.
- `menus/VolumeDropdown.qml` needs `import Quickshell.Services.Pipewire` for the types and
  `import "root:/modules"` for the state singleton. A missing import fails the whole config load
  rather than just this window.
- A row reads `undefined` for any `Theme` name that does not exist, which shows as a zero-sized row
  or a missing glyph, never as an error.
- Picking a device changes the default for new streams, and Pipewire may move what is currently
  playing to it. There is no confirmation step.
- The row glyphs are Nerd Font glyphs, taken from the theme's `volumeDropdown*Icon` and
  `volumeDropdownChevron*` values rather than images: a font without that range renders boxes.
