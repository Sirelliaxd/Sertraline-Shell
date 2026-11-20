# Battery

Singleton exposing the UPower display device as a level and an icon.

## API

| Member | Meaning |
| --- | --- |
| `battery` | `UPower.displayDevice` |
| `charging` | True while the state is `Charging` |
| `homed` | True while the state is `FullyCharged` |
| `level` | Charge in percent, rounded |
| `icon` | Glyph for the current state |
| `barTxt` | Bar label: icon, a space, `level` and `%` |

## How it works

Everything is a binding on `UPower.displayDevice`, so there is no polling and no `Process`.
The icon picks a plug glyph while charging, a full glyph when fully charged, and otherwise one
of five battery glyphs by level. `bar/Right.qml` renders `barTxt` in `Theme.foreground` and
switches to `Theme.red` when `level` is 25 or less.

## Traps

- All three state properties dereference `battery` directly. If UPower reports no display
  device, the bindings throw instead of showing an empty value, so a machine without a battery
  needs a guard here.
- `level` comes from `percentage * 100`, which is a fraction in UPower, not a percentage.
