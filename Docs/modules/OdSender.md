# OdSender

Singleton that starts and stops the OpenDisplay sender (`od-sender`), the tool that streams
the screen to an iPad.

## API

| Member | Meaning |
| --- | --- |
| `running` | True while `od-sender run` is in the process list |
| `icon` | Play glyph while stopped, stop glyph while running |
| `toggle()` | Starts or stops the sender |
| `refresh()` | Re-checks the process list |

## How it works

- `check` is a `Process` running `pgrep -f "od-sender run"`. Its exit code decides `running`.
- A `Timer` calls `refresh()` every 5 s with `triggeredOnStart: true`, so the state is also
  picked up on startup and after a shell restart.
- `toggle()` calls `Quickshell.execDetached(["od-sender", "run"])` or `["od-sender", "stop"]`,
  then restarts `recheck` (600 ms) to update the icon once the process appears or disappears.
- `forceKill` (2000 ms) is armed after a stop. If the sender is still running, it is killed with
  `pkill -f "od-sender run"` and re-checked.

`modules/IpadButton.qml` is the button in the bar that calls `toggle()`.

## Traps

- The state is derived from `pgrep`, not from the process this module started, so an
  `od-sender` launched by hand shows as running too.
- `forceKill` only exists to cover a sender that ignores `od-sender stop`. Removing it means a
  hung sender keeps the icon in the running state.
