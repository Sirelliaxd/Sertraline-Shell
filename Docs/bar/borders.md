# Border and corners

The frame around the screen: three bars of background color, four concave corners where that
frame meets the bar and the screen edges, and both ends of the top bar.

## Files

| File | Role |
| --- | --- |
| `components/Border.qml` | Reservation surfaces plus the one visible frame surface |
| `components/Corners.qml` | Places the four corner shapes inside that surface |
| `components/Corner.qml` | One corner, drawn as a shape |
| `shell.qml` | Instantiates it: `Border {}` |

## Why one surface

Hyprland blurs layer surfaces one by one, so a frame made of several surfaces gets a separate
blur pass per piece and shows seams where they meet. Everything visible in the frame is
therefore drawn in a single `PanelWindow` per screen: the three border bars, the four corners
and both bar ends. That surface carries namespace `quickshell-border`, so one blur rule for
that namespace covers the whole frame in one pass.

`Corners.qml` is not a window any more, it is an `Item` that fills its parent and is
instantiated inside that surface.

## Reservation

Space reservation cannot live in that surface: a layer surface reserves space on a single edge
(the top edge wins when a surface is anchored to several), and the frame has to reserve 12 px on
the left, right and bottom. `Border.qml` therefore adds three invisible `PanelWindow`s per
screen on layer `WlrLayer.Bottom`, namespace `quickshell-border`, each `thickness` wide or tall,
with `exclusiveZone: thickness` and `mask: Region {}`:

- bottom: anchored left, right and bottom, height is `thickness`.
- left and right: anchored top, bottom and the side, width is `thickness`, with
  `margins.top: Theme.barHeight` so they start below the bar.

They draw nothing and take no input, they exist only so maximized windows stay inside the
frame. The visible surface uses `exclusionMode: Ignore` for the same reason.

## The visible surface

One `PanelWindow` per screen, anchored to all four edges, transparent, `exclusionMode: Ignore`,
namespace `quickshell-border`:

- three `Rectangle`s in `borderColor` (`Theme.background`): bottom, left and right, `thickness`
  wide or tall, the side ones offset by `Theme.barHeight` so they start below the bar,
- `Corners {}`, the four corner shapes, inset by `borderTop` (`Theme.barHeight`),
  `borderBottom`, `borderLeft` and `borderRight` (`Theme.borderThickness`), radius 14,
- the two bar ends, see `Docs/bar/Bar.md`,
- `mask: Region { item: barInput }`, an invisible item covering the bar strip, so only the bar
  takes input and the frame and corners are click-through,
- a `Binding` writing the volume widget's centre x to `VolumeDropdownState.anchorX`, so the volume
  menu can hang under that widget (the menu samples it once when it opens; a live read would move the
  panel as the bar's text widths change). It reads `rightEnd.x`, `rightContent.x` and the widget's
  own `x` and `width`, which are all real properties, rather than calling `mapToItem` on the widget: a
  binding is only re-evaluated for properties it actually reads, and the reads inside a C++ call are
  invisible to it, so the anchor would go stale as the bar's labels change width.

`Corner.qml` draws the canonical top-left corner only: a square minus a quarter circle, radius
`radius`, filled with `color`. `flipX` and `flipY` mirror it with a `Scale` transform to cover
the other three positions, so all four corners stay consistent by construction. It uses
`preferredRendererType: Shape.CurveRenderer` for smooth edges.

## Traps

- The frame now shares the bar's layer, so it draws over a fullscreen window instead of behind
  it. Windows that ignore the reserved area, fullscreen video for example, get a 12 px frame
  around them. Before the merge the frame was on `WlrLayer.Bottom` and stayed hidden.
- Corner colors come from `Corners.qml` (`Theme.background` by default), not from
  `Corner.qml`'s own default, so changing the default there alone changes nothing. That default
  used to read `backgroundTransparent`, a misspelled name the theme never had, and is now
  `Theme.bgTs`; it stays unused either way.
- The frame, the corners and the bar ends all read `Theme.barHeight` and
  `Theme.borderThickness`. Changing one of the two values moves all of them together, changing
  only one leaves a gap.
- Removing the reservation surfaces lets maximized windows slide under the frame, which hides
  their edges behind the opaque border.
