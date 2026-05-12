/// Page+text style for a standalone figure: zero-margin auto-sized page,
/// 12pt Helvetica body, Libertinus Math fallback for equations.
/// Apply with `#show: figure-page`.
#let figure-page(body) = {
  set page(width: auto, height: auto, margin: 0pt)
  set text(font: "Helvetica", size: 12pt)
  show math.equation: set text(font: "Libertinus Math")
  show math.text: set text(font: "Helvetica")
  body
}

#let subtitle = text.with(size: 16pt, weight: "bold")
