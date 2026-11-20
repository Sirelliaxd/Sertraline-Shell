# Volume OSD

A small centered overlay with a speaker icon and a volume bar, shown for a second whenever the
default audio sink's volume changes.

Based on the official Quickshell `volume-osd` example (credit in the file header).

## Files

| File | Role |
| --- | --- |
| `OSDs/VolumeOSD.qml` | The whole OSD |
| `shell.qml` | Instantiates it: `VolumeOSD {}` |

## How it works

- A `PwObjectTracker` binds `Pipewire.defaultAudioSink` so its volume is tracked.
- `Connections` on `Pipewire.defaultAudioSink?.audio` catches `onVolumeChanged`, sets
  `shouldShowOsd = true` and restarts `hideTimer`.
- `hideTimer` (1000 ms) sets `shouldShowOsd` back to false.
- A `LazyLoader` with `active: shouldShowOsd` creates and destroys the `PanelWindow`, so the
  window only exists while the OSD is on screen. `PanelWindow.visible` would work too, the
  loader just keeps memory lower.

## Window

- Anchored to the bottom, `margins.bottom: screen.height / 11`, `exclusiveZone: 0` so it
  reserves no space, 350 by 37, transparent.
- `mask: Region {}` keeps it click-through, so it never blocks the mouse.
- The `screen` is left unset, so the compositor picks a monitor when the window is created,
  normally the active one.
- Content: a rounded `Rectangle` in `Theme.bgTs` holding a speaker glyph and a progress bar.
  The track is `Theme.foregroundTransparent`, the fill is the track's width times
  `Pipewire.defaultAudioSink?.audio.volume`.

## Traps

- The file logs two warnings on every load: `Detected function "onVolumeChanged" ... no signal
  of the target matches` and `Unable to assign [undefined] to QObject*`, both from line 17-18.
  They come from the `Connections` target being null until Pipewire reports a sink. The OSD
  still works, the warnings are startup noise.
- The bar reads the sink volume directly, it does not use `VolumelvlProc` from `modules/`.
  The two are independent, so a change to one does not affect the other.
