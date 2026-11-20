# Bluetooth Dropdown

Bluetooth menu, opened from the bluetooth readout in the right end of the top bar: the adapter and
what it calls itself, its power, pairing and discovery switches, a discovery list, and every paired
device with connect, trust, pin and forget.

Unlike the network menu, nothing here shells out. `modules/BlueInfo.qml` binds straight to
Quickshell's Bluetooth service, which talks to BlueZ over D-Bus, so every value is live and nothing
has to be refreshed. This file is the reference for it.

## Files

| File | Role |
| --- | --- |
| `menus/BluetoothDropdown.qml` | The menu window, its rows and its animation |
| `modules/BluetoothMenuState.qml` | Singleton holding the open state and the bar anchor |
| `modules/BlueInfo.qml` | Adapter, devices, the pinned list and every action |
| `bar/Right.qml` | The bluetooth readout and the click that toggles the menu |
| `components/Border.qml` | Reports where that readout sits |
| `Theme.qml` | Every `bluetoothDropdown*` property |
| `shell.qml` | Instantiates it: `BluetoothDropdown {}` |

## Opening it

Click the bluetooth glyph in the right end of the bar, or use the IPC handler the menu registers:

```
qs ipc call bluetoothdropdown toggle
```

It closes on `Escape`, on a click anywhere outside the panel, and when the readout is clicked again.

## Window

- `PanelWindow` anchored to all four edges, layer `WlrLayer.Overlay`, namespace
  `quickshell-bluetooth-dropdown`. A Hyprland layer rule can match that namespace, the same way the
  other menus are blurred.
- Mask, keyboard focus, on-demand building and the unload timer are the volume menu's, reused: the
  mask is empty while closed, the whole window takes input while open, and `shell.qml` holds the
  window in a `LazyLoader` driven by an explicit `bluetoothAlive` flag, cleared by a timer
  (`Theme.bluetoothDropdownAnimDuration + Theme.menuUnloadGrace`) after it closes. Nothing of the
  menu exists while it is closed.
- The panel opens out of the bar's bluetooth widget. `components/Border.qml` computes that widget's
  centre x and writes it to `BluetoothMenuState.anchorX`; the menu samples it once when it opens and
  keeps it, so the panel does not follow the bar's text widths while it is up.

## Animation

Both axes animate, exactly like the network menu: `width` runs `0` to
`Theme.bluetoothDropdownPanelWidth`, `height` runs `0` to
`min(content.implicitHeight, Theme.bluetoothDropdownMaxContentHeight) + 2 * contentMargin`, the top
edge is anchored and the left margin is `anchorX - width / 2` clamped into the margins.

## Rows

Top down. The first four are readouts, the rest do something.

| Row | Value | What it does |
| --- | --- | --- |
| `adapter` | the adapter id, e.g. `hci0` | nothing, it is a readout |
| `alias` | what the adapter calls itself, e.g. `BlueZ 5.88` | nothing |
| `state` | `on` / `off` | nothing |
| `devices` | how many are paired | nothing |
| `power` | `on` / `off`, bubble highlighted when off | `adapter.enabled = !enabled` |
| `pairable` | `on` / `off`, highlighted when on | `adapter.pairable = !pairable` |
| `discoverable` | `on` / `off`, highlighted when on | `adapter.discoverable = !discoverable` |
| `scan` | how many devices discovery has found, bubble highlighted while scanning | opens the found list and starts discovery |
| `rescan` (inside the list) | | stops and restarts discovery |
| one entry per found device | the device name, with the pair glyph on the right | `device.pair()` |
| `paired devices` (heading) | how many are paired | nothing, it is a heading |
| one row per paired device | the name, the device glyph, the status on the right, a filled bubble when connected, a star badge when pinned | opens that device's actions |
| `connect` / `disconnect` | | `device.connect()` / `device.disconnect()` |
| `trust` / `untrust` | | `device.trusted = !trusted` |
| `pin` / `unpin` | | adds or removes the device from the pinned list |
| `forget` | | `device.forget()`, and unpins it |

- The four adapter readouts share one bubble, the same way the network menu's stats do.
- A device row's status shows `connected` or `pairing`, plus the battery percentage when BlueZ
  reports one. Trust and pin are not repeated there: the actions under the row already say which way
  they will go, and a pinned device carries the star badge instead.
- The device glyph comes from the `icon` name BlueZ reports for the device class
  (`audio-headset`, `input-keyboard`, `input-mouse`, ...), mapped in `BlueInfo.deviceIcon()`.
- Pinned devices sort above the rest and keep their order across restarts; the list is stored in
  `~/.local/state/quickshell/bluetooth.ini` under `[Bluetooth] pinnedSerialized`.
- Discovery only runs while the menu is up: opening the scan list starts it, and closing the menu
  stops it (`Component.onDestruction`), so nothing scans for devices in the background.

## Keys

The panel takes keyboard focus while it is open, one row is always selected, and hovering a row
moves the same selection.

| Key | Effect |
| --- | --- |
| `Up` / `Down` | Move through the actionable rows, wrapping around, including the entries of an opened list and the actions of an opened device |
| `Return` / `Enter` / `Space` | Activate: toggle a switch, open or close a list, pair a found device, or run the selected device action |
| `Escape` | Close the menu |

Rows are addressed by a string key (`power`, `pairable`, `discoverable`, `scan`, `scan-rescan`,
`found-<address>`, `device-<address>`, `device-<address>-connect`, `-trust`, `-pin`, `-forget`) and
`navRows` builds the same keys in visual order, so the order the arrows walk and the order the rows
are drawn cannot drift apart. The readouts and the section heading are not in it.

## Scrolling

The content is capped at `Theme.bluetoothDropdownMaxContentHeight` (shared with the other menus, 420
px) inside a `Flickable`, and the panel's animated height follows the Flickable's height. A
discovery list of a dozen devices plus the paired section reaches that cap, and moving the selection
scrolls the selected row into view.

## Traps

- **The adapter properties are writable, the device pairing flags are not.** `BluetoothAdapter` has
  `enabled`, `pairable`, `discoverable` and `discovering` as writable properties, and
  `BluetoothDevice` has `connected`, `trusted`, `blocked`, `wakeAllowed` and `name`. `paired`,
  `bonded`, `pairing`, `state`, `battery` and `icon` are read-only: pairing and unpairing go through
  `device.pair()` and `device.forget()`, which is why the menu never tries to set `paired`.
- A write to an adapter property is a D-Bus round trip. Reading the value back immediately after
  writing it can still show the old one, so a check written as two calls in a row can look like it
  did nothing, or like it toggled twice. Give it a moment before believing a reading, and compare
  the service's value against `bluetoothctl show` rather than against the value you asked for.
- `forget` drops the pairing and the link keys with it. There is no confirmation dialog: the action
  is one row behind a click or a `Return`, and it is the only destructive thing in the menu. The
  same goes for `power`, which takes every connected device down with the adapter.
- Turning the adapter off disconnects whatever is connected to it, headphones included. The menu
  does not warn, and neither does BlueZ.
- `pairing` is the only signal that a pair attempt is in flight; a device that refuses the pairing
  simply never flips `paired`, and the row stays in the found list. There is no error to show,
  because the service does not expose one.
- A discovered device usually has no name, so BlueZ reports its address as one (`05-99-AD-AF-6E-B2`).
  The row shows that rather than an empty label.
- Discovery keeps a device in the list once it has been seen for as long as the adapter remembers it,
  so the found list grows while scanning and does not shrink when a device leaves.
- The menu takes the pointer and the keyboard while open, so a failure to close leaves the desktop
  unclickable until it is toggled again. Same trap as the other menus.
- The row glyphs are Nerd Font glyphs from the theme's `bluetoothDropdown*Icon` values: a font
  without that range renders boxes.
