# Hyprland

What the Hyprland side needs to know about this shell, and what the shell needs from it. The shell
draws its own bar, frame, OSD and menus as Wayland layer surfaces, so there is no window
configuration to write: what matters is the layer rules, the startup line and the IPC bindings.

## What the shell expects from Hyprland

- The Lua configuration (`hl.*`). The bar's workspace dots dispatch Lua expressions, so on a
  classic-config Hyprland those clicks would do nothing.
- `wlr-layer-shell` support, which Hyprland has. Every surface the shell draws is a layer surface,
  not a window, so window rules never match them.
- Blur enabled in the decoration section. The layer rules below only have an effect when
  `decoration.blur.enabled` is true, as it is in `modules/LookAndFeel.lua`.

## Starting the shell

The shell is a plain command, started once with the rest of the session. From
`modules/programs.lua` (excerpt, the other programs in that block are unrelated):

```lua
hl.on("hyprland.start", function()
	hl.exec_cmd("quickshell")
end)
```

`quickshell` is a wrapper around the shell that restarts it if it crashes, except when it crashes
within the first ten seconds, where it stops to avoid a crash loop. A load failure therefore shows
up as a shell that is simply gone, and the reason is in the log under
`/run/user/$UID/quickshell/by-id/*/log.log`.

## Layer namespaces

Each surface carries a namespace so Hyprland can match it in a layer rule. The bar, the frame and the
notch exist from the moment the shell loads. The menu namespaces only exist while that menu is
open, because the menu windows are built on demand, see `Menus/Applauncher.md`.

| Namespace | File | Surface | Layer |
| --- | --- | --- | --- |
| `quickshell-border` | `components/Border.qml` | The frame: the four edge strips with the corners and both bar ends, plus three invisible strips per screen that carry the space reservation | `WlrLayer.Bottom` |
| `quickshell-notch` | `components/TaskBar.qml` | The centre of the bar: workspace dots, clock, tray | default |
| `quickshell-app-launcher` | `menus/AppLauncher.qml` | The app launcher window | `WlrLayer.Overlay` |
| `quickshell-power-dropdown` | `menus/PowerDropdown.qml` | The power menu window | `WlrLayer.Overlay` |
| `quickshell-volume-dropdown` | `menus/VolumeDropdown.qml` | The volume menu window | `WlrLayer.Overlay` |

## Layer rules

In `modules/WindowsAndWorkspaces.lua`:

```lua
-- ------ { Quickshell } -------

hl.layer_rule({
	match = { namespace = "quickshell-notch" },

	blur = true,
	ignore_alpha = 0.2,
})

hl.layer_rule({
	match = { namespace = "quickshell-app-launcher" },

	blur = true,
	ignore_alpha = 0.2,
})

hl.layer_rule({
	match = { namespace = "quickshell-border" },

	blur = true,
	ignore_alpha = 0.2,
})

hl.layer_rule({
	match = { namespace = "quickshell-power-dropdown" },

	blur = true,
	ignore_alpha = 0.2,
})

hl.layer_rule({
	match = { namespace = "quickshell-volume-dropdown" },

	blur = true,
	ignore_alpha = 0.2,
})
```

Hyprland blurs each layer surface on its own, which is why the frame, its corners and both bar ends
are a single surface rather than several. Splitting them puts a visible seam at every boundary. The
same reasoning applies to the menus: each is one surface, so its blur is continuous.

## Reserved space

The shell reserves its own screen edges through exclusive zones, so there is nothing to configure:

| Edge | Reserved | Set by |
| --- | --- | --- |
| top | `Theme.barHeight`, 30 | `components/TaskBar.qml` |
| left, right, bottom | `Theme.borderThickness`, 12 | the three reservation strips in `components/Border.qml` |

`hyprctl monitors` reports it as `reserved: 12, 30, 12, 12` on every monitor. Windows are laid out
inside that box, and `gaps_in` and `gaps_out` from `modules/LookAndFeel.lua` sit on top of it. The
visible frame surface uses `ExclusionMode.Ignore` so it draws over the edge without reserving it a
second time; the reservation comes from the invisible strips. Details in `bar/borders.md`.

## IPC

The shell exposes one IPC target per menu:

| Target | Function | Effect |
| --- | --- | --- |
| `applauncher` | `toggle()` | Opens or closes the app launcher |
| `powerdropdown` | `toggle()` | Opens or closes the power menu |
| `volumedropdown` | `toggle()` | Opens or closes the volume menu |

Every handler lives in `shell.qml` rather than inside the menu windows, so the targets exist whether
or not a menu is open. A handler inside a menu window would only be registered while that menu was
on screen, which would make the keybinds below unable to open anything.

```
qs ipc show                              # list the targets and functions
qs ipc call applauncher toggle           # open or close the launcher
qs ipc call powerdropdown toggle         # open or close the power menu
qs ipc call volumedropdown toggle        # open or close the volume menu
```

The bare form works because this shell is the default configuration
(`~/.config/quickshell/shell.qml`). To pick an instance explicitly:

```
qs ipc --pid 1929 call applauncher toggle
qs ipc -i lh1ynzqot call applauncher toggle     # id, or any unique substring of it
qs ipc -n call applauncher toggle               # the most recently launched instance
qs ipc -p ~/QuickShellConf/.config/quickshell call applauncher toggle
qs ipc --any-display -c myconfig call applauncher toggle
```

A call is routed by configuration and display connection, so run it inside the same session and
with the same `XDG_CONFIG_HOME` the shell was started with. With `XDG_CONFIG_HOME` pointing
somewhere else, `qs ipc call ...` looks for an instance of a config that is not running and
reports nothing. The handlers declare no signals, so `qs ipc listen` and `qs ipc wait` have
nothing to print.

### Example keybinds

In `modules/keybinds.lua`, next to the existing binds, with `mainMod` already defined at the top of
that file:

```lua
---     ##### [ QUICKSHELL MENUS ] #####

--  { app launcher }
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("qs ipc call applauncher toggle"))

--  { power menu }
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("qs ipc call powerdropdown toggle"))

--  { volume menu }
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("qs ipc call volumedropdown toggle"))
```

The menus also take the keyboard while they are open. The launcher and the power menu move the
selection with `Up` and `Down`, run the selected entry with `Enter`, and close on `Escape`. The
volume menu adds `Left` and `Right` to move the selected level, `M` to mute the selected row,
`Space` to activate a row, and it scrolls the selected row into view when the content is taller
than its cap.

## What the shell dispatches to Hyprland

The bar's workspace dots read `Hyprland.workspaces` and `Hyprland.focusedWorkspace` and dispatch a
Lua expression when clicked:

```qml
Hyprland.dispatch(`hl.dsp.focus({ workspace = "${index + 1}" })`)
```

That is the only dispatch the shell sends. It is also the reason the Lua configuration is required:
`hyprctl dispatch` parses Lua here, so the older string form (`dispatch workspace 2`) does not work.

## Traps

- A namespace typo in a layer rule matches nothing, and Hyprland says nothing about it. Check the
  spelling against the table above and against `hyprctl layers`.
- `hyprctl layers` lists every layer surface with its namespace, which is the quickest way to see
  whether a surface is where the rules expect it.
- Layer rules apply to layer surfaces only. A window rule aimed at `quickshell-*` will never match,
  and the menus never appear in `hyprctl clients`.
- The menus own the pointer while open: the surface takes all input, so a menu that fails to close
  makes the desktop unclickable until it is toggled again.
- The shell reserves screen space by itself. Hand-written `gaps_out` values that try to make room
  for the bar or the frame will double the offset.
- Reload the Hyprland configuration after editing it (`hyprctl reload`). The shell picks up its own
  QML changes by itself and reloads a few seconds after a file is saved.
