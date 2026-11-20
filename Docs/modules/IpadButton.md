# IpadButton

The bar button that toggles the OpenDisplay sender. Not a singleton, it is a widget.

## API

| Member | Meaning |
| --- | --- |
| `implicitWidth` / `implicitHeight` | 14 by 18 |
| (no own state) | Text and behavior come from `OdSender` |

## How it works

An `Item` with a centered `Text` showing `OdSender.icon` in `Theme.foreground`,
`Theme.fontFamily` and `Theme.fontSize`, and a `MouseArea` filling it with a pointing hand
cursor that calls `OdSender.toggle()` on click.

`bar/Right.qml` places it as the first entry of the right section.

## Traps

- The item has no fixed color of its own, so it follows `OdSender.icon`: a missing glyph or a
  font without the play and stop symbols shows as an empty button.
- The `MouseArea` has no hover state, so the button gives no feedback beyond the cursor change.
