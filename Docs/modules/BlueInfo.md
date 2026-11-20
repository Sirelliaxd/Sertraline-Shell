# BlueInfo

Everything the bluetooth menu and the bar readout need: the adapter, the device lists, the pinned
favourites and every action. The menu is documented in `Docs/Menus/BluetoothDropdown.md`, this file
only covers the module.

There is no shelling out here, unlike `NetInfo`: Quickshell's Bluetooth service talks to BlueZ over
D-Bus, so every value below is a live binding and nothing has to be refreshed.

## API

| Member | Meaning |
| --- | --- |
| `adapter` | `Bluetooth.defaultAdapter`, the first adapter the service reports |
| `hasAdapter` | Whether there is any bluetooth hardware at all |
| `adapterId` / `adapterLabel` | `hci0`, and the alias it calls itself by, both `""` when unset |
| `powered` / `pairable` / `discoverable` / `scanning` | The four adapter switches |
| `devices` | Every device the adapter knows: pinned first, then paired, then by name |
| `paired` / `found` | The same list split into paired and unpaired |
| `pinned` | Addresses of the pinned devices, loaded from settings and written back on change |
| `isPinned(address)` / `togglePin(address)` | Read and flip one pin |
| `deviceLabel(device)` / `deviceIcon(device)` / `deviceStatus(device)` | What a row draws |
| `setPowered` / `setPairable` / `setDiscoverable` / `setScanning` | Adapter switches |
| `connect(device)` | Connects, or disconnects when it is already connected |
| `setTrusted(device, on)` / `pair(device)` / `forget(device)` | Device actions; `forget` also unpins |
| `barTxt` | The bar readout: the glyph, crossed out when the radio is off, plus the connected count |

## State

The only thing persisted is the pinned list, in
`~/.local/state/quickshell/bluetooth.ini` under `[Bluetooth] pinnedSerialized`, written the same way
`ApplauncherState` keeps its recents. It is read once at startup and after every reload.

## Traps

- `pragma Singleton` must stay on the first line, for the same reason as the other modules: without
  it the file loads but every `BlueInfo.x` reads `undefined`.
- The service fills its properties in as BlueZ answers, so `adapter`, `adapterId`, `alias` and
  `adapter.devices.values` can be missing for a moment after startup. Everything here coerces those
  to `""` or `[]` instead of handing `undefined` to a binding, which is what a `text: adapter.alias`
  would do.
- `devices` reads `adapter.devices.values`, which is a plain array, so `filter` and `sort` are the
  whole job. Sorting is done here rather than in the menu because the pin order has to survive a
  reload.
- `forget` is destructive and immediate; it also drops the address from the pinned list, because a
  pinned device that no longer exists would otherwise sit at the top of an empty list forever.
- `barTxt` is empty when there is no adapter, so the bar draws nothing on a machine without
  bluetooth rather than a crossed-out glyph that means "off".
