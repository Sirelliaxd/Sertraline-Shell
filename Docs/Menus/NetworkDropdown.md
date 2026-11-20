# Network Dropdown

Network menu, opened from the network readout in the right end of the top bar: the connected
network, local and public addresses, the MACs of the active interfaces, the wifi radio, a scan
list, the saved connections, the connection editor, the Mullvad state, MAC randomisation, monitor
mode, the sockets grouped by where they sit and what they are doing, a load graph, a list of every
interface the machine has (each opening its own `ip` stats), and the Tor and I2P daemons. The public address and the MACs come up covered and stay covered
until the `show ip/mac` row is switched on for that open.

The data comes from `modules/NetInfo.qml` (Quickshell's Networking service for the live parts,
`nmcli`, `ip`, `ss`, `curl` and `mullvad` for the rest), the graph from `modules/NetLoad.qml`.
`Docs/NetworkDropdown-Tutorial.md` walks through how the whole thing works, this file is the
reference.

## Files

| File | Role |
| --- | --- |
| `menus/NetworkDropdown.qml` | The menu window, its rows and its animation |
| `modules/NetworkMenuState.qml` | Singleton holding the open state and the bar anchor |
| `modules/NetInfo.qml` | Every value the menu shows, gathered by shelling out |
| `modules/NetLoad.qml` | Throughput sampling for the graph |
| `components/NetGraph.qml` | The two-line throughput graph |
| `bar/Right.qml` | The network readout and the click that toggles the menu |
| `components/Border.qml` | Draws that readout, and reports where it sits |
| `Theme.qml` | Every `networkDropdown*` property |
| `shell.qml` | Instantiates it: `NetworkDropdown {}` |

## Opening it

Click the network readout (`NetworkProc.barTxt`, the wifi glyph) in the right end of the bar, or
use the IPC handler the menu registers:

```
qs ipc call networkdropdown toggle
```

It closes on `Escape`, on a click anywhere outside the panel, and when the readout is clicked
again.

## Window

- `PanelWindow` anchored to all four edges, layer `WlrLayer.Overlay`, namespace
  `quickshell-network-dropdown`. A Hyprland layer rule can match that namespace, the same way the
  other menus are blurred.
- Mask, keyboard focus, on-demand building and the unload timer are the volume menu's, reused:
  the mask is empty while closed, the whole window takes input while open, and `shell.qml` holds
  the window in a `LazyLoader` driven by an explicit `networkAlive` flag, cleared by a timer
  (`Theme.networkDropdownAnimDuration + Theme.menuUnloadGrace`) after it closes. Nothing of the
  menu exists while it is closed.
- The panel opens out of the bar's network widget. `components/Border.qml` computes that widget's
  centre x and writes it to `NetworkMenuState.anchorX`; the menu samples it once when it opens and
  keeps it, so the panel does not follow the bar's text widths while it is up.

## Animation

Both axes animate, exactly like the volume menu: `width` runs `0` to
`Theme.networkDropdownPanelWidth`, `height` runs `0` to
`min(content.implicitHeight, Theme.networkDropdownMaxContentHeight) + 2 * contentMargin`, the top
edge is anchored and the left margin is `anchorX - width / 2` clamped into the margins, so the
panel opens as a small box under the network widget and grows downward and sideways. Closing runs
both values back. The content keeps its full width inside the clipped panel, so no row elides or
squashes while it widens.

## Rows

The menu has two halves: what it reports, and what it lets you change. The divider drawn with
`Theme.networkDropdownSeparatorColor` separates them.

### The active interface line

One centred line above the block, `Theme.networkDropdownNicHeight` tall, showing
`NetInfo.activeInterface` and, next to it, the SSID it is connected to (`NetInfo.ssid`, the wifi
network's name; a wired connection has none). The name is cut to
`Theme.networkDropdownSsidMax` characters with an ellipsis by `root.clip()`, because a long SSID
would push a centred line out of a fixed-width panel. The line falls back to
`Theme.networkDropdownEmptyText` when nothing is connected.

### The info group

The four readouts sit in a two-column `Grid` of `StatCell`s (a bubble, a small dim label, the value
underneath) inside one `Rectangle` that uses the same background a selected row gets, so the group
reads as a single block rather than four rows. A second interface adds one more cell, in grid order.

| Cell | Label | Value |
| --- | --- | --- |
| network | `network` | the connected network and its signal, or `off` |
| local | `local` | the IPv4 address of the active interface |
| public | `public` | the address the world sees (`api.ipify.org`, so through the VPN), covered |
| one per active interface | the device, plus its address when it is not the active interface | the MAC, covered |

`public` and the MACs are covered by `Theme.networkDropdownMaskChar`: the same string with every
letter and digit replaced, so the shape stays and nothing readable is left. `root.cover()` does
that, and the menu sets `revealDetails = false` in `onOpened()`, so every open starts covered no
matter how the last one ended. `local` is deliberately not covered: it is the private address.

### The load row and the graph

Directly under the info group: the same bubble, the label, both rates, and the two-line graph from
`components/NetGraph.qml` on the full width below them.

### The settings rows

| Row | Value | What it does |
| --- | --- | --- |
| `show ip/mac` | `on` / `off`, bubble highlighted when on | reveals the public address and the MACs until the menu closes |
| `wifi` | `on` / `off` | `Networking.wifiEnabled = !wifiOn` |
| `networks` | how many SSIDs the scan found | opens the scan list |
| `rescan` (inside the list) | | `nmcli device wifi rescan`, then re-lists after 4 s |
| one entry per SSID | signal and a lock glyph when secured, the connected one in `foreground` | `nmcli device wifi connect <ssid>` |
| `connections` | how many saved connections | opens the connection list |
| one entry per connection | `on` when active, else its type | `nmcli connection up <name>` |
| `interfaces` | how many interfaces the machine has, loopback included | opens the interface list |
| one row per interface | the name in `Theme.networkDropdownIfaceNameSize`, bold; `up` or `down` and its IPv4 address on the right; a filled bubble with the connected glyph when it is connected | opens that interface's stats |
| the stats under an interface | `mtu`/`qdisc`/`txqlen`, `state`/`link_type`, `flags`, one line per address, and `link/<kind>` with the MAC, covered | nothing, it is a readout |
| `edit` | | launches `nm-connection-editor` |
| `vpn` | the Mullvad state and relay, e.g. `Connected pl-waw-wg-103` | launches `mullvad-vpn` |
| `tor` (footer) | `running` / `stopped`, then its listening ports when it is up, glyph in `Theme.purple` | nothing, it is a readout |
| `i2p` (footer) | same, glyph in `Theme.yellow` | nothing |
| `random mac` | `on` / `off` | `pkexec macchanger -r|-p <interface>` |
| `monitor mode` | `on` / `off` | `pkexec iw dev <interface> set type monitor|managed` |
| `open ports` | how many sockets are listening | opens the socket list |
| a heading per group | `loopback` / `external`, with how many sockets are in it | nothing, it is a heading |
| a heading per state | `listening` / `outgoing` / `connection`, with the count | nothing |
| one row per socket | `tcp  127.0.0.1:9050`, with the process using it (or the state, when the process belongs to another user) | nothing, it is a readout |

- The bubble inverts (bright fill, dark glyph) for the state worth flagging: `wifi` when the radio
  is off, `show ip/mac` when the values are revealed, `random mac` when the current MAC is
  randomised, `monitor mode` when the interface is in monitor mode, and an interface that is
  carrying a connection. The interface glyph itself is `networkDropdownIfaceOnIcon` (a pair of
  linked screens) when connected and `networkDropdownIfaceOffIcon` (the same pair with a cross)
  when not, which is hard to tell apart at that size on its own, hence the filled bubble.
- The toggle values are read back from the system, never from a stored flag: `wifi` from
  `Networking.wifiEnabled`, `random mac` from the locally-administered bit of the current MAC,
  `monitor mode` from `iw dev <interface> info`. A privileged action that fails or is cancelled at
  the polkit prompt therefore leaves the row showing the truth. `show ip/mac` is the one exception:
  it is display state, not system state, so it lives in the menu and resets on open.

### The socket list

Every socket `ss` reports, grouped twice. First by where the local address sits: `loopback`
(127.x and `::1`) or `external` (everything else, including the interfaces' own addresses). Then,
inside each group, by what the socket is doing:

| State | What it is |
| --- | --- |
| `listening` | `LISTEN` for TCP, and `UNCONN` for UDP below the ephemeral range |
| `connection` | not listening, but on a port something is listening on: somebody connected to us |
| `outgoing` | anything else established, i.e. we started it |

The `connection` / `outgoing` split falls out of the data rather than out of a guess: the
listening ports are collected as the lines come in, and an established socket whose local port is
one of them is on the accepted side of a connection. The right-hand column is the process
`ss -p` reports; when the socket belongs to another user the kernel hides it, so the row falls
back to the state word.

## Keys

The panel takes keyboard focus while it is open, one row is always selected, and hovering a row
moves the same selection.

| Key | Effect |
| --- | --- |
| `Up` / `Down` | Move through the actionable rows, wrapping around, including the entries of an opened list |
| `Return` / `Enter` / `Space` | Activate: toggle a switch, reveal the covered values, open or close a list, connect, launch the editor or Mullvad |
| `Escape` | Close the menu |

Rows are addressed by a string key (`reveal`, `wifi`, `scan`, `scan-rescan`, `net-<ssid>`,
`connections`, `conn-<name>`, `interfaces`, `iface-<name>`, `edit`, `vpn`, `randommac`, `monitor`,
`ports`, `port-<index>`, `daemon-tor`, `daemon-i2p`) and `navRows`. Activating an `iface-<name>`
row opens that interface's stats and activating it again closes them; the stats lines themselves
are not selectable. In the socket list only the socket rows are keys, so the arrows step over the
headings. The daemon rows are the last two in the walk, matching the footer they sit in.
builds the same keys in visual order, so the order the arrows walk and the order the rows are
drawn cannot drift apart. The read-only rows are not in it, and the selection starts on
`reveal`, the first row of the settings half.

## Scrolling

The content is capped at `Theme.networkDropdownMaxContentHeight` (shared with the volume menu, 420
px) inside a `Flickable`, and the panel's animated height follows the Flickable's height. The info
group is two cells tall, the graph row is 86 px, and the open port list can be 20 entries, so the
cap is reached as soon as one list is open; moving the selection scrolls the selected row into
view.

## Traps

- `random mac` and `monitor mode` need root: they run through `pkexec`. On this machine they are
  passwordless, because `system/polkit/` installs a polkit action per program plus a rule that
  grants them to the user in a local active session. See `Docs/PrivilegedActions.md` for the
  install steps, the tradeoffs and the undo. Without those files the rows prompt for a password as
  before. Both take the interface down, so the connection drops: `macchanger` brings it back up
  with the new address, and monitor mode leaves the interface unable to associate at all until it
  is set back to `managed`.
- `monitor mode` only works where the driver lists `monitor` in its supported interface modes
  (`iw phy phy0 info`). This machine's card does; a card that does not will fail silently, and the
  row keeps reading `managed`.
- Connecting from the scan list only works for networks NetworkManager already knows or for open
  ones: `nmcli device wifi connect <ssid>` needs a password for a new network and this menu has no
  field for it. Add the network in the connection editor first.
- `wifi` off drops the link, including the VPN running over it. Nothing here confirms that.
- The public address is fetched over whatever route is up, so with the VPN connected it is the
  exit address, not the ISP one. It is cached for a minute so a menu that is opened repeatedly does
  not hammer the API.
- `ss` shows the process behind a socket only when the shell can see it (root); as a user the
  protocol and address are there and the process column is empty.
- The menu takes the pointer and the keyboard while open, so a failure to close leaves the desktop
  unclickable until it is toggled again. Same trap as the other menus.
- The row glyphs are Nerd Font glyphs from the theme's `networkDropdown*Icon` values: a font
  without that range renders boxes.
- `cover()` is not named `mask()`: `PanelWindow` already has a `mask` property, and a function
  of that name on the same object would collide with it.
- The grid cells take their width from `infoGrid.cellW` (half the grid minus the gap). That is a
  file-scoped id used from inside the inline component, which only works because `StatCell` is
  declared in this file and used nowhere else.
- The socket list is the only place in the menu that needs `-a` in its command: `ss -H -tuanp`
  rather than `-tulnp`, because the outgoing and accepted connections are half of what the list
  is for. That is also what makes it long: this machine has around 40 sockets open, so the ports
  section is the one that reaches the scroll cap on its own.
- The grouping labels and the two state words come from `Theme.qml` like every other string, and
  `NetInfo` builds the flat row list (`kind`, `text`, `value`, `index`) that the menu draws with
  three indents from the theme.
- Tor and I2P are detected by process, not by port, because both daemons usually run as their own
  user and their sockets are invisible to this shell: `pgrep -x tor`, and
  `pgrep -f 'i2pd|i2prouter|i2p\.jar'` for I2P, which matches both implementations (the packaged
  `i2pd` router and the Java `i2prouter`). Their ports come out of the same socket list, matched
  against each daemon's well-known set, so `active` means the daemon is up *and* something is
  listening for it. Nothing is installed or configured by the menu, and both are optional: a
  machine without them shows `stopped` and no ports. I2P is not on this machine, so its row reads
  `stopped` here and that branch is the only one that has been seen.
- A UDP socket in `UNCONN` state below the ephemeral range counts as listening, above it as
  outgoing. Without that, every browser's QUIC socket lands in `listening` and buries the real
  listeners. A UDP service that happens to sit above 32768 is filed as outgoing; the code comment
  in `NetInfo.addPort()` says where to look if that ever matters.
- The interface list comes from `ip -j addr`, not from the Networking service: the service only
  knows the devices NetworkManager manages (no loopback, and a `p2p-dev-*` device nobody wants),
  while `ip -j` is exactly what `ip a` prints and carries the stats with it. The JSON is read
  whole by a `StdioCollector` rather than line by line, because `ip -j` is a single very long line.
  Two definitions in `NetInfo.interfaces` are worth knowing: `up` is the carrier (`LOWER_UP`), not
  the administrative `UP` flag, so an interface with nothing plugged in reads as down; and
  `connected` is that plus an address with global scope, so the wifi link and the VPN tunnel count
  and loopback does not. `connected` drives the glyph and the filled bubble, `up` the word.
- The MAC in an interface's stats is covered by the same `cover()` as the info group, which is why
  the stats lines are built in two places: `NetInfo` builds everything except the `link/` line, and
  the menu appends that one, because only the menu knows whether the values are revealed.
- Long stats lines elide (`inet6 fc00:.../128  scope global` does not fit a 400 px panel), and the
  address is first on the line so eliding costs the least.

## Swapping the VPN

The `vpn` row is built for Mullvad, because that is what runs on this machine, but it is three
separate pieces and only the middle one is Mullvad-specific.

| Piece | Where |
| --- | --- |
| The state shown on the row | `modules/NetInfo.qml`: `vpnProc`, plus `vpnState` / `vpnRelay` / `vpnConnected` |
| What a click launches | `modules/NetInfo.qml`: `openMullvad()` |
| The label and the glyph | `Theme.qml`: `networkDropdownVpnText`, `networkDropdownVpnIcon` |

Nothing else knows about Mullvad: the row key stays `vpn`, so `navRows`, the `activate()` branch and
the keyboard navigation keep working untouched. The row prints `vpnState` and, when there is one,
`vpnRelay` next to it, e.g. `Connected pl-waw-wg-103`.

What the current one does, for reference:

```qml
Process {
  id: vpnProc
  command: ["mullvad", "status"]
  stdout: SplitParser {
    onRead: data => {
      var line = data.trim();
      if (root.vpnState === "")
        root.vpnState = line;                                    // first line: "Connected" / ...
      else if (line.indexOf("Relay:") === 0)
        root.vpnRelay = line.substring(6).trim().split(" ")[0];   // "Relay: pl-waw-wg-103"
    }
  }
}

function openMullvad() {
  Quickshell.execDetached(["mullvad-vpn"]);
}
```

`refreshVpn()` clears both properties and starts the process, so a VPN that is down leaves the row
on `Theme.networkDropdownEmptyText`. Keep that pattern: set `vpnState = "Disconnected"` in
`refreshVpn()` instead if your tool prints nothing when it is down and you would rather see that
than an empty row.

### Recipe: a VPN NetworkManager manages (WireGuard or OpenVPN profile)

No new tooling at all, and the `connections` list already brings the profile up with
`nmcli connection up <name>`. Only the state line changes:

```qml
Process {
  id: vpnProc
  command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
  stdout: SplitParser {
    onRead: data => {
      var f = data.split(":");
      if (f[1] === "wireguard" || f[1] === "vpn") {
        root.vpnState = "Connected";
        root.vpnRelay = f[0];               // the profile name reads well where the relay was
      }
    }
  }
}
```

and the click, if you want it to open the profile instead of a client:

```qml
function openMullvad() {
  Quickshell.execDetached(["nm-connection-editor"]);
}
```

### Recipe: plain WireGuard (`wg-quick`)

```qml
Process {
  id: vpnProc
  command: ["wg", "show", "interfaces"]      // one line, the up interfaces, empty when down
  stdout: SplitParser {
    onRead: data => {
      var names = data.trim().split(/\s+/).filter(function (n) { return n.length > 0; });
      root.vpnState = names.length > 0 ? "Connected" : "Disconnected";
      root.vpnRelay = names.length > 0 ? names[0] : "";
    }
  }
}
```

`wg show` needs root, which is exactly what the polkit files in `Docs/PrivilegedActions.md` are
for: add an action for `/usr/bin/wg` with `argv1` `show` and a rule that grants it, then run it
through `pkexec` like the two network rows do.

### Recipe: Tailscale, or anything that prints one line when it is up

```qml
Process {
  id: vpnProc
  command: ["tailscale", "ip", "-4"]         // prints the tunnel address while up, nothing when down
  stdout: SplitParser {
    onRead: data => {
      if (data.trim() !== "") {
        root.vpnState = "Connected";
        root.vpnRelay = data.trim();
      }
    }
  }
}
```

For OpenVPN 3 the same shape with `["openvpn3", "sessions-list"]` and the `Status:` line as the
state. Whatever the tool, the two things the row needs are a short state word and an optional
second value.

### Removing the row instead

If there is no VPN: delete the `ActionRow { rowKey: "vpn" ... }` in `menus/NetworkDropdown.qml`, the
`"vpn"` entry in `navRows`, the `else if (key === "vpn")` branch in `activate()`, the `vpnProc` and
the three `vpn*` properties in `modules/NetInfo.qml`, and the two theme strings. Nothing else
references them.

### Caveat

Only the Mullvad path has been run: it is what this machine uses. The recipes above are the same
shape with the command and the two parse lines swapped, and they have not been tested against a
live server, so check the command's output by hand (`mullvad status`, `wg show interfaces`, ...)
before trusting the parse.
