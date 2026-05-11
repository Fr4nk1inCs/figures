#import "@preview/cetz:0.5.1"
#import "@preview/suiji:0.5.1": choice-f, gen-rng-f

#set page(width: auto, height: auto, margin: 0pt)

#set text(font: "Helvetica", size: 12pt)
#show math.equation: set text(font: ("Helvetica", "Libertinus Math"))
#let subtitle = text.with(size: 16pt, weight: "bold")

#let PADDING = 0.2
#let RADIUS = 4pt
#let LIGHTEN = 90%
#let CANVAS-LENGTH = 28.35pt
#let TRANSPARENTITY = 60%

#let random-name(len) = {
  let rng = gen-rng-f(len)
  let candidates = "abcdefghijklmnopqrstuvwxyz0123456789".split("")
  choice-f(rng, candidates, size: len).at(1).join()
}

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

/// The size of the component would be 1x1 if no annotation is provided.
/// The annotation would be placed below the component.
/// - x (int): the center of the component
/// - y (int): the center of the component
/// - accent (str): the accent color for the component
/// - fill (bool): whether the component should be filled
/// - annotation (str): the annotation for the component
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
      fill: accent.transparentize(TRANSPARENTITY),
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

/// An MoE LLM model. Size of the component is .
/// - x (int): the center of the component
/// - y (int): the center of the component
/// - name (str): the name of the model
/// - annotation (content): the annotation for the model
#let model(x, y, name: none, annotation: none) = {
  if name == none {
    name = "model-" + random-name(5)
  }
  let tag(sub) = name + "-" + sub

  let WIDTH = 6
  let HEIGHT = 8
  let MARGIN = 0.25

  let x-start = x - WIDTH / 2
  let x-end = x + WIDTH / 2

  let y-start = y - HEIGHT / 2
  let y-end = y + HEIGHT / 2

  cetz.draw.rect(
    (x-start, y-start),
    (x-end, y-end),
    radius: RADIUS,
    fill: luma(95%),
    stroke: none,
  )
  if annotation != none {
    cetz.draw.content(
      (x-start, y-end),
      padding: PADDING,
      anchor: "north-west",
      annotation,
    )
  }

  let x-in-start = x-start + MARGIN
  let x-in-end = x-end - MARGIN
  let per-layer-height = 1 - MARGIN

  // embedding
  let y-curr = y-start + MARGIN
  cetz.draw.rect(
    (x-in-start, y-curr),
    (x-in-end, y-curr + per-layer-height),
    radius: RADIUS,
    fill: red.lighten(LIGHTEN),
    name: tag("emb"),
  )
  cetz.draw.content(tag("emb"))[Embedding]

  // decoder layers (stacked)
  let y-curr = y-curr + per-layer-height + MARGIN
  let n-illustrate = 3
  let per-layer-offset = 0.1
  let all-offset = (n-illustrate - 1) * per-layer-offset
  let layer-height = HEIGHT - 2 - 2 * MARGIN - all-offset
  let layer-width = WIDTH - 2 * MARGIN - all-offset

  for offset in range(0, 3) {
    let offset = 2 - offset
    let name = tag("layer" + str(offset))
    let offset = offset * 0.1

    let x0 = x-in-start + offset
    let x1 = x0 + layer-width
    let y0 = y-curr + offset
    let y1 = y0 + layer-height

    cetz.draw.rect(
      (x0, y0),
      (x1, y1),
      radius: RADIUS,
      fill: white,
      name: name,
    )
  }
  cetz.draw.content(
    tag("layer0.north"),
    anchor: "north",
    padding: PADDING,
  )[Decoder Layers]

  // attention inside layer 0
  let attn-x-start = x-in-start + MARGIN
  let attn-x-end = attn-x-start + layer-width - all-offset - MARGIN
  let attn-y-start = y-curr + MARGIN
  let attn-y-end = attn-y-start + per-layer-height
  cetz.draw.rect(
    (attn-x-start, attn-y-start),
    (attn-x-end, attn-y-end),
    radius: RADIUS * LIGHTEN,
    fill: orange.lighten(LIGHTEN),
    name: tag("attn"),
  )
  cetz.draw.content(tag("attn"))[Attention]

  // MoE inside layer 0
  let moe-y-start = attn-y-end + MARGIN
  let moe-y-end = y-curr + layer-height - MARGIN - 0.5
  cetz.draw.rect(
    (attn-x-start, moe-y-start),
    (attn-x-end, moe-y-end),
    radius: RADIUS * LIGHTEN,
    fill: purple.lighten(LIGHTEN),
    name: tag("moe"),
  )
  cetz.draw.content(tag("moe.north"), anchor: "north", padding: PADDING)[MoE]
  let router-x-start = attn-x-start + MARGIN
  let router-x-end = attn-x-end - MARGIN
  let router-y-start = moe-y-start + MARGIN
  let router-y-end = moe-y-start + 1
  cetz.draw.rect(
    (router-x-start, router-y-start),
    (router-x-end, router-y-end),
    radius: RADIUS * LIGHTEN,
    fill: white,
    name: tag("router"),
  )
  cetz.draw.content(tag("router"), anchor: "center")[Router]
  let experts-y-start = router-y-end + MARGIN
  let experts-y-end = moe-y-end - MARGIN - 0.5
  cetz.draw.rect(
    (router-x-start, experts-y-start),
    (router-x-end, experts-y-end),
    radius: RADIUS * LIGHTEN,
    fill: white,
    name: tag("experts"),
  )
  cetz.draw.content(tag("experts"), anchor: "center")[Experts]

  // LM Head
  let y-curr = y-curr + layer-height + MARGIN + all-offset
  let x-offset = 1
  cetz.draw.rect(
    (x-in-start + x-offset, y-curr),
    (x-in-end - x-offset, y-curr + per-layer-height),
    radius: RADIUS * LIGHTEN,
    fill: green.lighten(LIGHTEN),
    name: tag("lmhead"),
  )
  cetz.draw.content(tag("lmhead"))[LM Head]
}

#let fwd-bwd(x0, x1, y0, y1, thickness, accent: none, annotate: true) = {
  let width-ratio = thickness / CANVAS-LENGTH

  let stroke-style = stroke(paint: accent.transparentize(TRANSPARENTITY), thickness: thickness)
  // cetz.draw.line((x0, y0), (x0, y1), (x1, y1), (x1, y0), stroke: stroke-style)
  cetz.draw.compound-path(
    {
      cetz.draw.rect(
        (x0 - width-ratio / 2, y0),
        (x1 + width-ratio / 2, y1),
        radius: (north: width-ratio),
      )
      cetz.draw.rect(
        (x0 + width-ratio / 2, y0),
        (x1 - width-ratio / 2, y1 - width-ratio),
        radius: (north: width-ratio / 2),
      )
      cetz.draw.rect(
        (x1 - width-ratio / 2, y0),
        (x1 + width-ratio / 2, y0 + width-ratio),
      )
      cetz.draw.line(
        (x1 - width-ratio, y0 + width-ratio),
        (x1 + width-ratio, y0 + width-ratio),
        (x1, y0),
        close: true,
      )
    },
    stroke: none,
    fill: accent.transparentize(TRANSPARENTITY),
    fill-rule: "even-odd",
  )

  if annotate {
    cetz.draw.content((x0 - width-ratio / 2, y1), anchor: "north-east", padding: PADDING)[Forward]
    cetz.draw.content((x1 + width-ratio / 2, y0), anchor: "south-west", padding: PADDING)[Backward]
  }
}

#let fwd(x, y0, y1, thickness, accent: none, annotate: true) = {
  let width-ratio = thickness / CANVAS-LENGTH

  cetz.draw.compound-path(
    {
      cetz.draw.rect(
        (x - width-ratio / 2, y0),
        (x + width-ratio / 2, y1 - width-ratio),
      )
      cetz.draw.line(
        (x - width-ratio, y1 - width-ratio),
        (x + width-ratio, y1 - width-ratio),
        (x, y1),
        close: true,
      )
    },
    stroke: none,
    fill: accent.transparentize(TRANSPARENTITY),
    fill-rule: "even-odd",
  )

  if annotate {
    cetz.draw.content((x + width-ratio / 2, y1), anchor: "north-west", padding: PADDING)[Forward Only]
  }
}


#cetz.canvas(length: CANVAS-LENGTH, padding: PADDING, {
  import cetz.draw: *

  // debug((-5, -2), (21, 14))

  let DATA1_COLOR = blue
  let DATA2_COLOR = fuchsia

  // Without Anticipatory Routing
  content((0, 0), subtitle[Without Anticipatory Routing])
  model(0, 7, annotation: $bold(theta_t)$)
  sample(-0.5, 1.5, accent: DATA1_COLOR, fill: true, annotation: $"Data"_t$)
  fwd-bwd(
    -0.5,
    0.5,
    2,
    11.75,
    CANVAS-LENGTH * 0.5,
    accent: DATA1_COLOR,
  )
  content((0, 12.5), text(size: 14pt)[Step $t$])

  // Divider
  line((5, -1), (5, 13), stroke: (thickness: 2pt, dash: "loosely-dashed"))

  // With Anticipatory Routing
  content((13, 0), subtitle[With Anticipatory Routing])
  model(9, 7, annotation: $bold(theta_(t - Delta t))$)
  sample(8, 1.5, accent: DATA1_COLOR, fill: true, annotation: $"Data"_(t - Delta t)$)
  fwd-bwd(
    8,
    9,
    2,
    11.75,
    CANVAS-LENGTH * 0.5,
    accent: DATA1_COLOR,
    annotate: false,
  )
  sample(10, 1.5, accent: DATA2_COLOR, fill: true, annotation: $"Data"_t$)
  fwd(
    10,
    2,
    11.75,
    CANVAS-LENGTH * 0.5,
    accent: DATA2_COLOR,
  )
  content((9, 12.5), text(size: 14pt)[Step $t - Delta t$])

  model(17, 7, annotation: $bold(theta_t)$)
  sample(16.5, 1.5, accent: DATA2_COLOR, fill: true, annotation: $"Data"_t$)
  fwd-bwd(
    16.5,
    17.5,
    2,
    11.75,
    CANVAS-LENGTH * 0.5,
    accent: DATA2_COLOR,
  )
  content((17, 12.5), text(size: 14pt)[Step $t$])

  // Routing Replay
  compound-path(
    {
      rect((10.25, 6.5), (16, 6.75))
      line((16, 6.25), (16, 7), (16.25, 6.625), close: true)
    },
    fill: DATA2_COLOR.transparentize(TRANSPARENTITY),
    stroke: none,
  )
  content((13, 7), anchor: "south", align(center)[Replay \ Routing \ Decision])
})
