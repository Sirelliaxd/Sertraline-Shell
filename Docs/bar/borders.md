# Border and corners

The frame around the screen: three bars of background color, plus four concave corners where
that frame meets the notch and the screen edges.

## Files

| File | Role |
| --- | --- |
| `components/Border.qml` | Bottom, left and right bars |
| `components/Corners.qml` | Places the four corner shapes |
| `components/Corner.qml` | One corner, drawn as a shape |
| `shell.qml` | Instantiates both: `Border {}` and `Corners {}` |

## Border

`Border.qml` is a `Scope` holding `thickness` (`Theme.borderThickness`, 12) and `borderColor`
(`Theme.background`). A `Variants` over `Quickshell.screens` gives every monitor three
`PanelWindow`s on layer `WlrLayer.Bottom`, namespace `quickshell-border`, each with
`exclusiveZone: thickness` so windows are inset by the frame:

- bottom: anchored left, right and bottom, height is `thickness`.
- left and right: anchored top, bottom and the side, width is `thickness`, with
  `margins.top: Theme.barHeight` so they start below the bar.

## Corners

`Corners.qml` is one fullscreen transparent `PanelWindow` per screen on namespace
`quickshell-border`, with `exclusionMode: Ignore` and `mask: Region {}`. The empty mask makes
the whole surface click-through, so the window can cover the screen without eating input.

Inside it, four `Corner` shapes are anchored to the four screen corners and inset by the frame:
`borderTop` (`Theme.barHeight`), `borderBottom`, `borderLeft` and `borderRight`
(`Theme.borderThickness`). Default radius is 14.

`Corner.qml` draws the canonical top-left corner only: a square minus a quarter circle, radius
`radius`, filled with `color`. `flipX` and `flipY` mirror it with a `Scale` transform to cover
the other three positions, so all four corners stay consistent by construction. It uses
`preferredRendererType: Shape.CurveRenderer` for smooth edges.

## Traps

- Corner colors come from `Corners.qml` (`Theme.background` by default), not from
  `Corner.qml`'s own default, so changing the default there alone changes nothing.
- Both files anchor against the screen edges and assume the bar is `Theme.barHeight` tall and
  the frame is `Theme.borderThickness` wide. Changing either value in `Theme.qml` moves the
  corners and the border together, changing only one of the two leaves a visible gap.
