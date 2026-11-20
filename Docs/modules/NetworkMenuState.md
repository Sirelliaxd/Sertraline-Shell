# NetworkMenuState

Singleton holding the network dropdown's open state and the bar anchor. The menu itself is
documented in `Docs/Menus/NetworkDropdown.md`, this file only covers the module.

## API

| Member | Meaning |
| --- | --- |
| `visible` | Drives the menu window, its mask and its keyboard focus |
| `anchorX` | Screen x of the bar's network widget centre, written by `components/Border.qml`. The menu samples it once when it opens |
| `show()` / `hide()` / `toggle()` | Open state |

## State

Nothing is persisted: the menu is closed at startup and after every reload. The bar's network
readout and the menu window both read this singleton, which is why the click in the bar can open a
window that lives in another file, and `shell.qml` reads it too, to decide whether that window
should exist at all.

This is the second singleton of its kind: `VolumeDropdownState` has the same shape and the same
anchor, one per menu. They are kept separate rather than merged because each menu is otherwise
independent, and a shared state file would couple two features that never talk to each other.

## Traps

- `pragma Singleton` must stay on the first line, for the same reason as `ApplauncherState`: a
  singleton without it loads, but every `NetworkMenuState.x` reads `undefined`, so the menu can
  never open and `anchorX` stays 0, which parks the panel at the left margin.
- The anchor is written by every screen's frame window, so the last writer wins on a multi-monitor
  setup. Because the menu samples it once at open, that only shows as a few pixels of difference
  between two openings.
- The rows, the lists and the selection do not live here. They are in `menus/NetworkDropdown.qml`.
