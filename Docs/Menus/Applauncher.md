# App Launcher

Bottom-centered overlay menu for searching and launching desktop entries.

## Files

| File | Role |
| --- | --- |
| `menus/AppLauncher.qml` | The panel window and all of its UI |
| `components/BottomFlare.qml` | The curved bottom edge of the panel |
| `modules/ApplauncherState.qml` | Singleton holding visibility and recent apps |
| `Theme.qml` | Every `appLauncher*` property (sizes, colors, strings, animations) |
| `shell.qml` | Instantiates it: `AppLauncher {}` |

## Opening it

`AppLauncher.qml` registers an IPC handler with the target `applauncher`:

```
qs ipc call applauncher toggle
```

Bind that command in Hyprland (`~/.config/hypr/modules/keybinds.lua`) to get a key for it.
If `qs ipc` cannot find the config, select the instance instead:
`qs ipc --pid $(pgrep -x quickshell) call applauncher toggle`.

It closes on `Escape`, on a click outside the panel, and after launching an app.

## Window

- `PanelWindow` anchored to all four edges, layer `WlrLayer.Overlay`, namespace
  `quickshell-app-launcher`. Overlay sits above the frame, and the window carries a negative
  bottom margin of `Theme.borderThickness` so it reaches past the space the frame reserves: the
  panel's bottom edge is the screen edge itself, drawn over the bottom border bar.
- `mask` is empty while hidden, so the surface takes no input; keyboard focus is `Exclusive`
  only while `ApplauncherState.launcherVisible` is true.
- The visible panel is anchored to the bottom center. The body is `Theme.appLauncherPanelWidth`
  wide and the item that holds it is `2 * Theme.appLauncherFlare` wider, because the bottom
  curve flares out past the body. The panel's height is `Theme.appLauncherPanelHeight` (header,
  bottom padding and the slack below the last row, the flare is drawn inside that) plus one row
  (`Theme.appLauncherItemHeight`) per app, capped at `Theme.appLauncherMaxVisible` rows.
- The bottom edge is `components/BottomFlare.qml`: a quarter ellipse out of each side, flaring
  `Theme.appLauncherFlare` (the value the notch's curve uses, `Theme.taskbarFlare`) past the
  body on both sides and rising `Theme.appLauncherFlareHeight` vertically. The curve leaves the
  bottom edge horizontally and arrives at the body's vertical side vertically, so the flare
  blends into the body instead of meeting it at a right angle. A plain `Rectangle` body fills
  everything above it, with `Theme.appLauncherRadiusTop` on the top corners.
- The content column is anchored to the body rather than to the wider panel item, so the rows
  keep the body's width.
- The bottom padding is `Theme.appLauncherBottomitemHeight` (4) plus the slack inside
  `Theme.appLauncherPanelHeight`, which leaves the last row about 20 px above the panel's bottom
  edge. The rows stay inside the flare's silhouette because they start `Theme.appLauncherFlare`
  plus `Theme.appLauncherContentMargin` in from the panel item's edge.
- Shown and hidden with a `Translate` slide of `Theme.appLauncherSlideAnimDuration`.

## Behavior

- Search box filters by `name`, `genericName` and `keywords`, case-insensitive substring.
- Empty query lists recent apps first, then everything else alphabetically.
- Keys: `Up`/`Down` move the selection, `Enter` launches, `Escape` hides. Mouse wheel scrolls,
  hovering selects a row, clicking launches it.
- Rows show the entry icon, falling back to the first letter of the name when the icon is
  missing. Rows with a `genericName` show it under the name, and the five most recent apps get
  a `recent` badge.

## State and persistence

`modules/ApplauncherState.qml` is a singleton (`pragma Singleton`, root type `Singleton`):

- `launcherVisible` drives the whole menu.
- `recentIds` is a list of desktop entry ids, capped at `Theme.appLauncherRecentsLength` (12).
- `recordLaunch(id)` moves an id to the front, `show()`, `hide()`, `toggle()` and
  `clearRecents()` do what their names say. Only `toggle` is exposed over IPC today.

Recents live in `~/.local/state/quickshell/applauncher.ini`, category `AppLauncher`, key
`recentIdsSerialized`, and are loaded once on `Component.onCompleted`.

## Traps

- The state file needs an explicit `location:`. Quickshell sets no `organizationName`, so a
  QtCore `Settings` without one fails to initialize and silently persists nothing.
- `ApplauncherState.qml` must keep `pragma Singleton`. Without it the file still loads, but
  every `ApplauncherState.x` reads `undefined`: the menu cannot open and the delegate binding
  on `recentIds` throws TypeErrors in a loop. The `Singleton` root type comes from
  `import Quickshell`, there is no `Singleton` module to import.
- Every value used by the panel has to exist in `Theme.qml`. A misspelled property is not an
  error, it is an `undefined` that shows up as a zero size or a wrong color.
- `BottomFlare` reads both of its radii: `flare` is the horizontal one and its own height is
  the vertical one, so raising the height alone stretches the curve instead of moving it. The
  padding below the rows does not have to clear the flare: the rows are already inset by the
  flare plus the content margin, so they stay inside the curve at any depth.
