# App Launcher

Bottom-centered overlay menu for searching and launching desktop entries.

## Files

| File | Role |
| --- | --- |
| `menus/AppLauncher.qml` | The panel window and all of its UI |
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
  `quickshell-app-launcher`.
- `mask` is empty while hidden, so the surface takes no input; keyboard focus is `Exclusive`
  only while `ApplauncherState.launcherVisible` is true.
- The visible panel is `Theme.appLauncherPanelWidth` wide, anchored to the bottom center. Its
  height is the header (`Theme.appLauncherPanelHeight`) plus one row
  (`Theme.appLauncherItemHeight`) per app, capped at `Theme.appLauncherMaxVisible` rows.
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
