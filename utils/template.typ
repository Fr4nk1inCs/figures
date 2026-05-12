/// Page+text style for a standalone figure: zero-margin auto-sized page,
/// 12pt Helvetica body, Libertinus Math fallback for equations.
/// Apply with `#show: figure-page`.
/// - use-sans-serif-for-math (bool): whether to use the sans-serif font for
///   math text (default: true)
#let figure-page(use-sans-serif-for-math: true, body) = {
  set page(width: auto, height: auto, margin: 0pt)
  set text(font: "Helvetica", size: 12pt)
  show math.equation: set text(font: "Libertinus Math")
  if use-sans-serif-for-math {
    show math.text: set text(font: "Helvetica")
    body
  } else {
    body
  }
}

#let subtitle = text.with(size: 16pt, weight: "bold")
