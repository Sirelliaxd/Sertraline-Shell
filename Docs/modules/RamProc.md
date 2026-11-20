# RamProc

Singleton exposing memory usage as a percentage, sampled from `free`.

## API

| Member | Meaning |
| --- | --- |
| `running` | Alias for the inner `Process`, set to true to take a sample |
| `memUsage` | Used memory in percent |
| `barTxt` | Bar label: glyph plus `memUsage` and `%` |

## How it works

`Process` runs `sh -c "free | grep Mem"` and a `SplitParser` reads the line. Field 2 is total
memory and field 3 is used, so `memUsage` is `100 * used / total`, rounded. Total is forced to
at least 1 so a malformed line cannot divide by zero.

`Component.onCompleted` samples once, and `RefreshTimer.qml` (2 s) sets `running = true` for
every following sample. Unlike `CpuProc` there is no delta, so a single sample is already a
correct value.

## Traps

- The column indexes match the default `free` output. A `free` with different columns (for
  example a locale or a busybox build) reports wrong numbers instead of failing.
- `RefreshTimer.qml` drives both this module and `CpuProc`, so the two refresh together and
  share the same 2 s cadence.
