# PowerDropdownState

Singleton holding the power dropdown's open state. The menu itself is documented in
`Docs/Menus/PowerDropdown.md`, this file only covers the module.

## API

| Member | Meaning |
| --- | --- |
| `visible` | Drives the menu window, its mask and its keyboard focus |
| `show()` / `hide()` / `toggle()` | Open state |

## State

Nothing is persisted: the menu is closed at startup and after every reload. The bar's power icon
and the menu window both read this singleton, which is why the click in the bar can open a window
that lives in another file.

## Traps

- `pragma Singleton` must stay on the first line, for the same reason as `ApplauncherState`: a
  singleton without it loads, but every `PowerDropdownState.x` reads `undefined` and the menu can
  never open.
- The entries and the selection index do not live here. They are in `menus/PowerDropdown.qml`,
  so the state file stays free of anything the bar does not need.
