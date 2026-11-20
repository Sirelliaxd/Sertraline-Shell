# VolumeDropdownState

Singleton holding the volume dropdown's open state and the bar anchor. The menu itself is
documented in `Docs/Menus/VolumeDropdown.md`, this file only covers the module.

## API

| Member | Meaning |
| --- | --- |
| `visible` | Drives the menu window, its mask and its keyboard focus |
| `anchorX` | Screen x of the bar's volume widget centre, written by `components/Border.qml`. The menu samples it once when it opens, see `Docs/Menus/VolumeDropdown.md` |
| `show()` / `hide()` / `toggle()` | Open state |

## State

Nothing is persisted: the menu is closed at startup and after every reload. The bar's volume
readout and the menu window both read this singleton, which is why the click in the bar can open a
window that lives in another file, and `shell.qml` reads it too, to decide whether that window
should exist at all.

`anchorX` is the one value that flows the other way, from the frame surface into the menu. It is a
plain `property` rather than a `readonly` one for exactly that reason. It is written with a
`Binding` inside the frame's window, because a singleton property cannot be assigned from another
file's item scope: `VolumeDropdownState.anchorX: ...` in a window is parsed as an attached
property and fails the load with `Non-existent attached object`.

## Traps

- `pragma Singleton` must stay on the first line, for the same reason as `ApplauncherState`: a
  singleton without it loads, but every `VolumeDropdownState.x` reads `undefined`, so the menu can
  never open and `anchorX` stays 0, which parks the panel at the left margin.
- `anchorX` is not screen-aware. Every screen's frame window writes it, so the last writer wins on
  a multi-monitor setup. See the matching trap in `Docs/Menus/VolumeDropdown.md`.
- The rows, the device lists and the stream list do not live here. They are in
  `menus/VolumeDropdown.qml`, so the state file stays free of anything the bar does not need.
