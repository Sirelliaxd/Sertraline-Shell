# NetworkProc

Singleton exposing the current network connection as a glyph, wired or wireless.

## API

| Member | Meaning |
| --- | --- |
| `wifiDevice` | First device of type `DeviceType.Wifi` |
| `wiredDevice` | First connected non-wifi device |
| `active` | Connected network on the wifi device, or null |
| `wired` | True when a wired device is connected |
| `signal` | `signalStrength` of the active network, 0 to 1 |
| `icon` | Glyph for the current state |
| `barTxt` | Bar label, which is the icon on its own |

## How it works

All properties are bindings on `Networking.devices` and the connected network's
`signalStrength`, so there is no polling. The icon resolves in order: wired, wifi disabled
(`Networking.wifiEnabled`), no active network, then a signal tier. The four signal tiers are
built from the codepoint `0xF091F` with a step of 3 per tier, which is the Nerd Font signal
range.

`bar/Right.qml` shows `barTxt` as a single glyph, there is no percentage in the bar.

## Traps

- `wiredDevice` matches on `type !== DeviceType.Wifi && connected`, so a connected VPN or
  bridge device can win over the wifi icon.
- The tier glyphs are raw codepoints. A font without that range renders boxes instead of
  signal bars, and nothing in the config reports it.
