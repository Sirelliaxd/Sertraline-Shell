# NetLoad

Throughput of one interface for the network menu's graph. The menu is documented in
`Docs/Menus/NetworkDropdown.md`.

## API

| Member | Meaning |
| --- | --- |
| `device` | The interface being sampled |
| `rxRate`, `txRate` | Bytes per second, from the difference between two samples |
| `history` | `[{ rx, tx }]`, one entry per interval, oldest first, capped at `Theme.networkDropdownGraphSamples` |
| `running` | Alias of the sampling timer, so the menu can stop it from outside |
| `start(device)` | Point it at an interface, reset if it changed, sample immediately and start the timer |
| `stop()` | Stop the timer |
| `reset()` | Drop the history and the counters |
| `formatRate(bytes)` | `1.2 kB/s`, `3.4 MB/s`, `512 B/s` |

## How it samples

Every `Theme.networkDropdownGraphInterval` (1000 ms) a `Process` runs `cat /proc/net/dev`, and
`sample()` picks the line for `device`. That line holds 16 numbers after the name: received bytes
first, transmitted bytes ninth. The rate is `(now - last) / seconds`, and the first sample only
stores the counters, so the graph starts one interval after the menu opens.

`start()` is called by the menu when it opens and `stop()` when the window is destroyed, so the
timer runs only while somebody is looking at the graph. The window is built on demand, which is
what makes that possible.

## Traps

- `/proc/net/dev` counts bytes on the interface, so with a VPN up the graph shows the encrypted
  traffic of the physical interface, not the tunnel's payload.
- The counters are read as numbers: `/proc/net/dev` is fixed-width and padded, so the parse splits
  on whitespace rather than on columns.
- A counter reset (interface re-created, MAC changed) makes the difference negative, which is why
  both rates are clamped at zero.
- The sampler is one process per second while the menu is open. That is the same cost as the CPU
  module's permanent 2 s timer, and it stops when the menu closes.
