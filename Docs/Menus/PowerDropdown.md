# Power Dropdown

Power menu, opened from the Artix logo in the left end of the top bar. Artix has no systemd, so
every action goes through `loginctl`.

## Files

| File | Role |
| --- | --- |
| `menus/PowerDropdown.qml` | The menu window, its entries and its animation |
| `modules/PowerDropdownState.qml` | Singleton holding the open state |
| `components/Border.qml` | Hosts the bar's left end, which is where the trigger lives |
| `bar/Left.qml` | The Artix icon and the click that toggles the menu |
| `Theme.qml` | Every `powerDropdown*` property |
| `shell.qml` | Instantiates it: `PowerDropdown {}` |

## Opening it

Click the Artix glyph (`Theme.powerDropdownIcon`) at the left of the bar, or use the IPC handler
the menu registers:

```
qs ipc call powerdropdown toggle
```

It closes on `Escape`, on a click anywhere outside the panel, and after running an entry.

## Window

- `PanelWindow` anchored to all four edges, layer `WlrLayer.Overlay`, namespace
  `quickshell-power-dropdown`. A Hyprland layer rule can match that namespace, the same way the
  launcher and the notch are blurred in the Hyprland config.
- The mask is empty while closed, so the surface takes no input. While open the whole window
  takes input (that is what makes it own the pointer) and keyboard focus is `Exclusive`, so
  arrow keys and `Enter` reach the menu instead of the focused window.
- The window is built on demand, like the launcher's: `shell.qml` holds it in a `LazyLoader` driven
  by an explicit `powerAlive` flag, set when the menu opens and cleared by a timer
  (`Theme.powerDropdownAnimDuration + Theme.menuUnloadGrace`) after it closes. The flag is written
  only from those two places and is deliberately not derived from `PowerDropdownState.visible`, so
  the window survives long enough to animate out. Nothing of the menu exists while it is closed.
  The panel takes keyboard focus through `Qt.callLater`, since it is created after the state
  flips, and it starts at size `0` so a window created for an opening still grows out of its
  corner.
- The panel is anchored to the top left of the window, which is the top left of the usable area,
  inset by `Theme.powerDropdownMargin`. It therefore opens `Theme.borderThickness` plus that
  margin in from the screen edge, and the same distance below the bar, so it floats just under the
  bar's left end instead of touching the frame and the bar.

## Animation

The panel's `width` and `height` animate between `0` and their full size over
`Theme.powerDropdownAnimDuration` with `Theme.powerDropdownAnimType`, with the top left corner
anchored and `clip: true`. The panel therefore reads as a square growing out of its top left
corner toward the bottom right, and closing runs it back into that corner the same way. The
content sits at its full size inside the clipped panel, so nothing reflows while it resizes.

## Entries

Top down, each one runs through `Quickshell.execDetached` and then closes the menu:

| Row | Icon | Command |
| --- | --- | --- |
| logout | `\uf08b` | `sh -c 'loginctl terminate-session "$XDG_SESSION_ID"'` |
| suspend | `\uf186` | `loginctl suspend` |
| hibernate | `\uf236` | `loginctl hibernate` |
| reboot | `\uf021` | `loginctl reboot` |
| shutdown | `\uf011` | `loginctl poweroff` |

## Keys and selection

- `Up` / `Down` move the selection, wrapping around the list. `Enter` runs the selected entry,
  `Escape` closes the menu.
- Hovering a row selects it and clicking it runs it.
- The selected row gets a bubble behind it and its icon bubble inverts, the same treatment the
  app launcher gives its selected row.

## Traps

- Every entry acts immediately, there is no confirmation step and no countdown. `logout` kills
  the session the shell runs in, so the shell goes down with it.
- `logout` depends on `XDG_SESSION_ID` being in the shell's environment, which elogind sets for
  the graphical session. Without it the command does nothing.
- `loginctl` needs elogind and a polkit agent; the active session is normally allowed to
  suspend, reboot and power off without a prompt. `hibernate` additionally needs a swap area at
  least as large as memory.
- The row icons are Nerd Font glyphs, not icons: a font without that range renders boxes.
- The menu takes over the pointer and the keyboard while open, so a failure to close leaves the
  desktop unresponsive to clicks until it is toggled again.
