#import "@preview/cetz:0.5.1"
#import "/utils/constants.typ": PADDING, TRANSPARENCY

/// A 1×1 grid square representing a data sample, with an optional annotation
/// placed below the component.
/// - x (number): center of the component
/// - y (number): center of the component
/// - accent (color): accent color for the grid and (when filled) tint
/// - fill (bool): whether to fill the component with a tinted background
/// - annotation (content): label placed below the component
#let sample(x, y, accent: black, fill: false, annotation: none) = {
  let WIDTH = 1
  let HEIGHT = 1

  let x-start = x - WIDTH / 2
  let y-start = y - HEIGHT / 2
  let x-end = x-start + WIDTH
  let y-end = y-start + HEIGHT

  if fill {
    cetz.draw.rect(
      (x-start, y-start),
      (x-end, y-end),
      fill: accent.transparentize(TRANSPARENCY),
      stroke: none,
    )
  }

  cetz.draw.grid(
    (x-start, y-start),
    (x-end, y-end),
    stroke: accent,
    step: .25,
  )
  if annotation != none {
    cetz.draw.content(
      (x, y-start),
      anchor: "north",
      padding: PADDING,
      text(fill: accent, annotation),
    )
  }
}
