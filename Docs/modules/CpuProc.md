# CpuProc

Singleton exposing CPU usage as a percentage, sampled from `/proc/stat`.

## API

| Member | Meaning |
| --- | --- |
| `running` | Alias for the inner `Process`, set to true to take a sample |
| `cpuUsage` | Usage in percent, `0` until two samples exist |
| `barTxt` | Bar label: glyph plus `cpuUsage` and `%` |

## How it works

`Process` runs `sh -c "head -1 /proc/stat"` and a `SplitParser` reads the line. Fields 5 and 6
are added up as idle time (idle plus iowait) and fields 2 to 8 as total time. Usage is
`100 * (1 - deltaIdle / deltaTotal)`, rounded, and it is only computed when a previous sample
exists.

The first sample therefore reports nothing and leaves `cpuUsage` at 0, and every sample after
that is a delta against the previous one. `Component.onCompleted` runs it once, and
`RefreshTimer.qml` (2 s) sets `running = true` again for every following sample.

## Traps

- `running` must stay an alias to `cpuProc.running`. Assigning `CpuProc.running = true` from
  outside silently does nothing without it, and a delta based value stays at 0 forever.
- The parser indexes fixed positions in the `cpu` line, so it depends on the kernel layout of
  `/proc/stat`. A field count change reads the wrong columns instead of failing.
