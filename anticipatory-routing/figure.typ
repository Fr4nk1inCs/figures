#import "@preview/cetz:0.5.1"
#import "/utils/template.typ": figure-page, subtitle
#import "/utils/constants.typ": CANVAS-LENGTH, LIGHTEN, PADDING, TRANSPARENCY
#import "/utils/training.typ": sample

#show: figure-page

#let RADIUS = 4pt

/// A forward-backward training arrow: an upward column with a downward
/// return path and a triangular arrowhead at the bottom of the return.
/// Traced as a single closed path so there are no fill-rule artifacts;
/// the top U-turn has rounded outer corners (radius `w`) and rounded
/// inner cutout corners (radius `w / 2`).
/// - x0, x1 (number): center x-coordinates of the forward/backward columns
/// - y0, y1 (number): bottom/top y-coordinates
/// - thickness (length): visual width of each column
/// - accent (color): tint color
/// - annotate (bool): whether to label the forward/backward strokes
#let fwd-bwd(x0, x1, y0, y1, thickness, accent: none, annotate: true) = {
  let w = thickness / CANVAS-LENGTH
  let r-out = w
  let r-in = w / 2

  let xl = x0 - w / 2
  let xr = x1 + w / 2
  let xli = x0 + w / 2
  let xri = x1 - w / 2
  let yt = y1 - r-out
  let yi = y1 - r-out - r-in

  cetz.draw.merge-path(
    {
      cetz.draw.line((xl, y0), (xl, yt))
      cetz.draw.arc(
        (xl, yt),
        start: 180deg,
        stop: 90deg,
        radius: r-out,
        anchor: "arc-start",
      )
      cetz.draw.line((xli, y1), (xri, y1))
      cetz.draw.arc(
        (xri, y1),
        start: 90deg,
        stop: 0deg,
        radius: r-out,
        anchor: "arc-start",
      )
      cetz.draw.line(
        (xr, yt),
        (xr, y0 + w),
        (x1 + w, y0 + w),
        (x1, y0),
        (x1 - w, y0 + w),
        (xri, y0 + w),
        (xri, yi),
      )
      cetz.draw.arc(
        (xri, yi),
        start: 0deg,
        stop: 90deg,
        radius: r-in,
        anchor: "arc-start",
      )
      cetz.draw.line((xri - r-in, yt), (xli + r-in, yt))
      cetz.draw.arc(
        (xli + r-in, yt),
        start: 90deg,
        stop: 180deg,
        radius: r-in,
        anchor: "arc-start",
      )
      cetz.draw.line((xli, yi), (xli, y0))
    },
    close: true,
    fill: accent.transparentize(TRANSPARENCY),
    stroke: none,
  )

  if annotate {
    cetz.draw.content((xl, y1), anchor: "north-east", padding: PADDING)[Forward]
    cetz.draw.content((xr, y0), anchor: "south-west", padding: PADDING)[Backward]
  }
}

/// A forward-only training arrow: a single upward column capped by a
/// triangular arrowhead at the top.
/// - x (number): center x-coordinate
/// - y0, y1 (number): bottom/top y-coordinates
/// - thickness (length): visual width of the column
/// - accent (color): tint color
/// - annotate (bool): whether to label the stroke
#let fwd(x, y0, y1, thickness, accent: none, annotate: true) = {
  let w = thickness / CANVAS-LENGTH

  cetz.draw.line(
    (x - w / 2, y0),
    (x - w / 2, y1 - w),
    (x - w, y1 - w),
    (x, y1),
    (x + w, y1 - w),
    (x + w / 2, y1 - w),
    (x + w / 2, y0),
    close: true,
    fill: accent.transparentize(TRANSPARENCY),
    stroke: none,
  )

  if annotate {
    cetz.draw.content((x + w / 2, y1), anchor: "north-west", padding: PADDING)[Forward Only]
  }
}

/// An MoE LLM model, 6 wide × 8 tall, with an embedding, three stacked
/// decoder layers (the front-most exposes attention + MoE internals), and
/// an LM head.
/// - x (number): center of the component
/// - y (number): center of the component
/// - name (str): cetz tag prefix for child shapes; defaults to "model-<x>-<y>"
/// - annotation (content): annotation drawn at the top-left of the model
#let model(x, y, name: none, annotation: none) = {
  if name == none {
    name = "model-" + str(x) + "-" + str(y)
  }
  let tag(sub) = name + "-" + sub

  let WIDTH = 6
  let HEIGHT = 8
  let MARGIN = 0.25
  let BAND-HEIGHT = 0.75
  let HEADER-INSET = 0.5
  let LM-HEAD-INSET = 1
  let ROUTER-HEIGHT = 1
  let OUTER-FILL = luma(95%)

  let boxed(a, b, fill, sub, label, label-anchor: "center") = {
    cetz.draw.rect(a, b, radius: RADIUS, fill: fill, name: tag(sub))
    if label-anchor == "center" {
      cetz.draw.content(tag(sub), label)
    } else {
      cetz.draw.content(
        tag(sub + "." + label-anchor),
        anchor: label-anchor,
        padding: PADDING,
        label,
      )
    }
  }

  let x-start = x - WIDTH / 2
  let x-end = x + WIDTH / 2
  let y-start = y - HEIGHT / 2
  let y-end = y + HEIGHT / 2

  cetz.draw.rect(
    (x-start, y-start),
    (x-end, y-end),
    radius: RADIUS,
    fill: OUTER-FILL,
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

  let x-inner-start = x-start + MARGIN
  let x-inner-end = x-end - MARGIN

  let y-emb = y-start + MARGIN
  boxed(
    (x-inner-start, y-emb),
    (x-inner-end, y-emb + BAND-HEIGHT),
    red.lighten(LIGHTEN),
    "emb",
    [Embedding],
  )

  let y-layers = y-emb + BAND-HEIGHT + MARGIN
  let n-illustrate = 3
  let per-layer-offset = 0.1
  let all-offset = (n-illustrate - 1) * per-layer-offset
  let layer-height = HEIGHT - 2 * BAND-HEIGHT - 4 * MARGIN - all-offset
  let layer-width = WIDTH - 2 * MARGIN - all-offset

  for layer-idx in range(n-illustrate).rev() {
    let dx = layer-idx * per-layer-offset

    cetz.draw.rect(
      (x-inner-start + dx, y-layers + dx),
      (x-inner-start + dx + layer-width, y-layers + dx + layer-height),
      radius: RADIUS,
      fill: white,
      name: if layer-idx == 0 { tag("layer0") } else { none },
    )
  }
  cetz.draw.content(
    tag("layer0.north"),
    anchor: "north",
    padding: PADDING,
  )[Decoder Layers]

  let attn-x-start = x-inner-start + MARGIN
  let attn-x-end = x-inner-end - MARGIN - all-offset
  let attn-y-start = y-layers + MARGIN
  boxed(
    (attn-x-start, attn-y-start),
    (attn-x-end, attn-y-start + BAND-HEIGHT),
    orange.lighten(LIGHTEN),
    "attn",
    [Attention],
  )

  let moe-y-start = attn-y-start + BAND-HEIGHT + MARGIN
  let moe-y-end = y-layers + layer-height - MARGIN - HEADER-INSET
  boxed(
    (attn-x-start, moe-y-start),
    (attn-x-end, moe-y-end),
    purple.lighten(LIGHTEN),
    "moe",
    [MoE],
    label-anchor: "north",
  )

  let router-x-start = attn-x-start + MARGIN
  let router-x-end = attn-x-end - MARGIN
  let router-y-start = moe-y-start + MARGIN
  boxed(
    (router-x-start, router-y-start),
    (router-x-end, router-y-start + ROUTER-HEIGHT),
    white,
    "router",
    [Router],
  )

  boxed(
    (router-x-start, router-y-start + ROUTER-HEIGHT + MARGIN),
    (router-x-end, moe-y-end - MARGIN - HEADER-INSET),
    white,
    "experts",
    [Experts],
  )

  let y-lmhead = y-layers + layer-height + MARGIN + all-offset
  boxed(
    (x-inner-start + LM-HEAD-INSET, y-lmhead),
    (x-inner-end - LM-HEAD-INSET, y-lmhead + BAND-HEIGHT),
    green.lighten(LIGHTEN),
    "lmhead",
    [LM Head],
  )
}

#cetz.canvas(length: CANVAS-LENGTH, padding: PADDING, {
  import cetz.draw: *

  let DATA1_COLOR = blue
  let DATA2_COLOR = fuchsia

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

  line((5, -1), (5, 13), stroke: (thickness: 2pt, dash: "loosely-dashed"))

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

  line(
    (10.25, 6.75),
    (16, 6.75),
    (16, 6.5),
    (16.25, 6.875),
    (16, 7.25),
    (16, 7),
    (10.25, 7),
    close: true,
    fill: DATA2_COLOR.transparentize(TRANSPARENCY),
    stroke: none,
  )
  content((13, 7), anchor: "south", align(center)[Replay \ Routing \ Decision])
})
