# VolumelvlProc

Singleton exposing the default audio sink as a volume level and an icon.

## API

| Member | Meaning |
| --- | --- |
| `sink` | `Pipewire.defaultAudioSink` |
| `ready` | True when the sink exists, is ready and has an audio object |
| `muted` | True while the sink is muted |
| `volumeLevel` | Volume in percent, rounded, 0 while not ready |
| `icon` | Glyph for the current level |
| `barTxt` | Bar label: icon plus `volumeLevel` and `%` |

## How it works

A `PwObjectTracker` keeps `Pipewire.defaultAudioSink` bound so its properties are tracked, and
every value is a binding on `sink.audio`, so there is no polling. The icon resolves to a muted
or zero glyph, then one of three tiers at 67 and 34 percent.

`bar/Right.qml` shows `barTxt`. The volume OSD in `OSDs/VolumeOSD.qml` reads the sink on its
own and does not use this module.

## Traps

- `ready` gates every other value, so a missing sink shows `0%` rather than failing.
- The last branch of `icon` is unreachable: the tier at 34 percent already covers everything
  below it.
- Muting reports the muted glyph but keeps `volumeLevel` at the real value, so the bar reads
  the old percentage next to a muted icon.
