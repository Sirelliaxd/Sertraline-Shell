# NetInfo

Every value the network menu shows that Quickshell's Networking service does not provide. The
menu itself is documented in `Docs/Menus/NetworkDropdown.md` and explained in
`Docs/NetworkDropdown-Tutorial.md`, this file covers the module.

## API

| Member | Meaning |
| --- | --- |
| `wifiDevice`, `wiredDevice`, `activeWifi` | The devices and the connected wifi network, straight from `Networking` |
| `wifiOn`, `wifiName`, `wiredName`, `wifiSignal` | Radio state, interface names and the signal in percent |
| `activeInterface` | The interface the load graph samples: the wired one when connected, else the wifi one |
| `connectedName`, `connected` | What the `network` row shows |
| `wifiNetworks` | `[{ ssid, signal, security, secured, active }]`, sorted by signal |
| `connections` | `[{ name, type, device, active }]` |
| `links` | `[{ device, mac, random }]` for the interfaces that are up, without loopback or bridges |
| `addresses` | `[{ device, address }]`, IPv4, without loopback or bridges |
| `ports` | `[{ proto, address, process }]` listening sockets |
| `publicIp`, `publicIpTime` | The address the world sees, and when it was fetched |
| `vpnState`, `vpnRelay` | First line of `mullvad status`, and the relay it is connected to |
| `wifiMode` | `iw`'s type for the wifi interface: `managed`, `monitor`, ... |
| `macRandom`, `monitorOn`, `vpnConnected` | Derived flags the menu's toggles read |
| `localAddress` | IPv4 of the active interface, else the first address found |
| `addressOf(device)` | IPv4 of one interface |
| `refresh()` | Starts every read. The menu calls it when it opens |
| `refreshWifi()`, `rescan()` | Re-list the scan results, or ask for a fresh scan |
| `setWifiEnabled(on)` | `Networking.wifiEnabled = on` |
| `connectWifi(ssid)`, `activate(name)` | `nmcli device wifi connect`, `nmcli connection up` |
| `openEditor()`, `openMullvad()` | Launch `nm-connection-editor` or `mullvad-vpn` |
| `macCommand(on)`, `monitorCommand(on)` | The argv for the two privileged actions, without running them |
| `randomMac(on)`, `monitorMode(on)` | Run those through `pkexec` |

## How it refreshes

`refresh()` starts one `Process` per dataset. Each one clears its list first and guards on
`running`, so a second call while a read is in flight is a no-op and two reads can never
interleave. Nothing polls: the menu calls `refresh()` when it opens, and the individual
`refreshX()` functions are called when a list is opened. The public address is the exception, it
is cached for 60 s.

The only live, poll-free parts are the ones the Networking service gives: the devices, their
networks, the signal and the radio state are bindings, so the `network` and `wifi` rows update
while the menu is open.

## Parsing

- `nmcli -t` separates fields with `:` and escapes the ones inside a field as `\:`, which is what
  `splitCols()` undoes. A naive `split(":")` breaks on an SSID containing a colon.
- The scan is read as `IN-USE,SSID,SIGNAL,SECURITY`; `IN-USE` is `*` for the connected network and
  a space otherwise, and the same SSID appears once per band, so `addWifi()` keeps the entry with
  the stronger signal and carries the `active` flag over to it.
- `ip -br link` is one line per interface: name, state, MAC, flags. Only interfaces that are `UP`
  and carry a MAC are kept, and loopback, bridges, veth and tunnel names are filtered out.
- `ip -4 -o addr show` gives the address as `address/prefix`, so the prefix is stripped.
- `ss -tulnHp` is one line per socket: protocol, state, queues, local address, peer, and the
  process in `users:(("name",pid=...))` when the shell is allowed to see it.
- `mullvad status` puts the state on the first line and the relay on a `Relay:` line.
- The first `nmcli device wifi list` after a scan starts can come back empty. `wifiProc` retries
  once after 2.5 s when it gets nothing, and `wifiRetried` stops that from looping.

## Actions

Every command is an argv array (`["nmcli", "device", "wifi", "connect", ssid]`), never a shell
string: the SSID and the connection name come from the network, and an argv array cannot be
interpreted by a shell. The two privileged actions are built by `macCommand()` and
`monitorCommand()` so their shape can be checked without running them.

## Traps

- `pragma Singleton` must stay on the first line: without it every `NetInfo.x` reads `undefined`
  and the menu shows `--` everywhere, with no error.
- The module is created on first reference, which is the menu window. Its IPC surface (if one is
  ever added) therefore does not exist while the menu is closed.
- `Networking` has no method to connect a network or to list saved connections, which is why those
  go through `nmcli`. Do not add a second source of truth for the same value.
- A process that is started while another is running is silently dropped by the `running` guard, so
  an action that fails to start leaves the lists stale rather than half-filled.
