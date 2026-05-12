#import "@preview/cetz:0.5.1"
#import "/utils/constants.typ": PADDING

/// Draw a dashed coordinate grid with integer labels along the bottom and left.
/// Useful for laying out a `cetz.canvas` block — call once at the top, remove
/// (or comment out) when the layout is finalized.
/// - a (array): one corner of the grid, as `(x, y)`
/// - b (array): the opposite corner
#let debug(a, b) = {
  cetz.draw.grid(
    a,
    b,
    stroke: stroke(paint: gray, dash: "dashed", thickness: 0.5pt),
  )

  let x0 = calc.min(a.at(0), b.at(0))
  let x1 = calc.max(a.at(0), b.at(0))
  for x in range(x0, x1 + 1, step: 1) {
    cetz.draw.content(
      (x, a.at(1)),
      anchor: "north",
      padding: PADDING,
      text(fill: gray, str(x)),
    )
  }

  let y0 = calc.min(a.at(1), b.at(1))
  let y1 = calc.max(a.at(1), b.at(1))
  for y in range(y0, y1 + 1, step: 1) {
    cetz.draw.content(
      (a.at(0), y),
      anchor: "east",
      padding: PADDING,
      text(fill: gray, str(y)),
    )
  }
}
