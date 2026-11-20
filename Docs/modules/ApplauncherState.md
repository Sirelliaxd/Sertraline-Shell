# ApplauncherState

Singleton holding the app launcher's visibility and recent apps. The launcher itself is
documented in `Docs/Menus/Applauncher.md`, this file only covers the module.

## API

| Member | Meaning |
| --- | --- |
| `launcherVisible` | Drives the whole launcher panel |
| `recentIds` | Desktop entry ids, most recent first |
| `recentsLength` | Cap on the list, `Theme.appLauncherRecentsLength` (12) |
| `show()` / `hide()` / `toggle()` | Visibility |
| `recordLaunch(id)` | Moves an id to the front and trims the list |
| `clearRecents()` | Empties the list and the stored value |

## State

Recents live in `~/.local/state/quickshell/applauncher.ini`, category `AppLauncher`, key
`recentIdsSerialized`, and are read once on `Component.onCompleted`. `clearRecents()` exists but
nothing calls it, and only `toggle()` is exposed over IPC by the launcher. To clear them, empty
that file (`recentIdsSerialized=[]`) and reload the config, which makes the singleton re-read it.

## Traps

- `pragma Singleton` must stay on the first line. Without it the file still loads, every
  `ApplauncherState.x` reads `undefined`, and the launcher cannot open. The `Singleton` root
  type comes from `import Quickshell`, there is no `Singleton` module to import.
- The `Settings` element needs its explicit `location:`. Quickshell sets no
  `organizationName`, so without a location QSettings never initializes and nothing persists.
