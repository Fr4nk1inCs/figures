#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "/utils/template.typ": figure-page, subtitle

#show: figure-page.with(use-sans-serif-for-math: false)
#set page(margin: 5pt)

#let RADIUS = 3pt

#let operator(..args, accent: blue) = node(
  shape: rect,
  fill: accent.lighten(75%),
  corner-radius: RADIUS,
  stroke: accent,
  ..args,
)
#let data = node.with(stroke: none)
#let edge = edge.with(marks: "-cone", corner-radius: RADIUS)
#let boxed(..args, accent: black, body) = {
  node(
    ..args,
    shape: rect,
    stroke: accent + 2pt,
    inset: 4pt,
    outset: 0pt,
    text(fill: accent, body),
  )
}
#let content = node.with(stroke: none, fill: none)
#let output = boxed.with(accent: black)
#let divider = edge.with(stroke: (thickness: 2pt, dash: "loosely-dashed", cap: "square"), marks: "-")

#diagram(
  axes: (ltr, btt),
  spacing: (1.5em, 2em),
  {
    data((0, 0), $bold(x)$, name: <dsv3-input>)
    data((1, 1), $bold(W)_r$, name: <dsv3-router-weights>)
    operator((1, 0), `MatMul`, name: <dsv3-router-linear>)
    operator((2, 0), strong(`Sigmoid`), accent: purple, name: <dsv3-router-activation>)
    data((3, 0), $bold(S)$, name: <dsv3-affinity-score>)
    operator((4, 0), `AddBias`, name: <dsv3-add-bias>)
    data((4, 1), $bold(b)$, name: <dsv3-bias>)
    operator((5, 0), strong(`GroupedTopk`), accent: orange, name: <dsv3-router-topk>)
    data((6, 0), `eids`, name: <dsv3-topk-ids>)
    operator((4, -1), `Gather`, name: <dsv3-gather>)
    data((5, -1), `raw_weights`, name: <dsv3-raw-topk-weights>)
    operator((6, -1), `Normalize`, name: <dsv3-normalize>)
    operator((7, -1), `Mul`, name: <dsv3-scale>)
    data((8, -1), $f$, name: <dsv3-scaling-factor>)
    output((7, 0), [`eids` \ `weights`], name: <dsv3-output>)

    edge(<dsv3-input>, <dsv3-router-linear>)
    edge(<dsv3-router-weights>, <dsv3-router-linear>)
    edge(<dsv3-router-linear>, <dsv3-router-activation>)
    edge(<dsv3-router-activation>, <dsv3-affinity-score>)
    edge(<dsv3-affinity-score>, <dsv3-add-bias>)
    edge(<dsv3-bias>, <dsv3-add-bias>)
    edge(<dsv3-add-bias>, <dsv3-router-topk>)
    edge(<dsv3-router-topk>, <dsv3-topk-ids>)
    edge(<dsv3-affinity-score>, (rel: (0, -1)), <dsv3-gather>)
    edge(<dsv3-topk-ids>, (rel: (0, -0.5), to: <dsv3-topk-ids>), (rel: (0, 0.5), to: <dsv3-gather>), <dsv3-gather>)
    edge(<dsv3-gather>, <dsv3-raw-topk-weights>)
    edge(<dsv3-raw-topk-weights>, <dsv3-normalize>)
    edge(<dsv3-normalize>, <dsv3-scale>)
    edge(<dsv3-scaling-factor>, <dsv3-scale>)
    edge(<dsv3-topk-ids>, <dsv3-output>)
    edge(<dsv3-scale>, <dsv3-output>)

    content((0.2, -1), subtitle[DeepSeek V3])

    divider((-0.5, -1.5), (8.5, -1.5))

    data((0, -3), $bold(x)$, name: <dsv4-input>)
    data((1, -2), $bold(W)_r$, name: <dsv4-router-weights>)
    operator((1, -3), `MatMul`, name: <dsv4-router-linear>)
    operator((2, -3), strong(`Softplus`), accent: purple, name: <dsv4-router-activation>)
    data((3, -3), $bold(S)$, name: <dsv4-affinity-score>)
    operator((4, -3), `AddBias`, name: <dsv4-add-bias>)
    data((4, -2), $bold(b)$, name: <dsv4-bias>)
    operator((5, -3), strong(`Topk`), accent: orange, name: <dsv4-router-topk>)
    data((6, -3), `eids`, name: <dsv4-topk-ids>)
    operator((4, -4), `Gather`, name: <dsv4-gather>)
    data((5, -4), `raw_weights`, name: <dsv4-raw-topk-weights>)
    operator((6, -4), `Normalize`, name: <dsv4-normalize>)
    operator((7, -4), `Mul`, name: <dsv4-scale>)
    data((8, -4), $f$, name: <dsv4-scaling-factor>)
    output((7, -3), [`eids` \ `weights`], name: <dsv4-output>)

    edge(<dsv4-input>, <dsv4-router-linear>)
    edge(<dsv4-router-weights>, <dsv4-router-linear>)
    edge(<dsv4-router-linear>, <dsv4-router-activation>)
    edge(<dsv4-router-activation>, <dsv4-affinity-score>)
    edge(<dsv4-affinity-score>, <dsv4-add-bias>)
    edge(<dsv4-bias>, <dsv4-add-bias>)
    edge(<dsv4-add-bias>, <dsv4-router-topk>)
    edge(<dsv4-router-topk>, <dsv4-topk-ids>)
    edge(<dsv4-affinity-score>, (rel: (0, -1)), <dsv4-gather>)
    edge(<dsv4-topk-ids>, (rel: (0, -0.5), to: <dsv4-topk-ids>), (rel: (0, 0.5), to: <dsv4-gather>), <dsv4-gather>)
    edge(<dsv4-gather>, <dsv4-raw-topk-weights>)
    edge(<dsv4-raw-topk-weights>, <dsv4-normalize>)
    edge(<dsv4-normalize>, <dsv4-scale>)
    edge(<dsv4-scaling-factor>, <dsv4-scale>)
    edge(<dsv4-topk-ids>, <dsv4-output>)
    edge(<dsv4-scale>, <dsv4-output>)

    content((0.2, -4), subtitle[DeepSeek V4])

    divider((-0.5, -4.5), (8.5, -4.5))

    data((0, -6), $bold(x)$, name: <hash-router-input>)
    data((1, -5), $bold(W)_r$, name: <hash-router-weights>)
    operator((1, -6), `MatMul`, name: <hash-router-linear>)
    operator((2, -6), strong(`Softplus`), accent: purple, name: <hash-router-activation>)
    data((3, -6), $bold(S)$, name: <hash-affinity-score>)
    data((4.5, -5), `token_ids`, name: <hash-token-ids>)
    operator((4.5, -6), strong(`HashMap`), accent: orange, name: <hash-map>)
    data((6, -6), `eids`, name: <hash-eids>)
    operator((4, -7), `Gather`, name: <hash-gather>)
    data((5, -7), `raw_weights`, name: <hash-raw-topk-weights>)
    operator((6, -7), `Normalize`, name: <hash-normalize>)
    operator((7, -7), `Mul`, name: <hash-scale>)
    data((8, -7), $f$, name: <hash-scaling-factor>)
    output((7, -6), [`eids` \ `weights`], name: <hash-output>)

    edge(<hash-router-input>, <hash-router-linear>)
    edge(<hash-router-weights>, <hash-router-linear>)
    edge(<hash-router-linear>, <hash-router-activation>)
    edge(<hash-router-activation>, <hash-affinity-score>)
    edge(<hash-affinity-score>, (rel: (0, -1)), <hash-gather>)
    edge(<hash-token-ids>, <hash-map>)
    edge(<hash-map>, <hash-eids>)
    edge(<hash-eids>, (rel: (0, -0.5), to: <hash-eids>), (rel: (0, 0.5), to: <hash-gather>), <hash-gather>)
    edge(<hash-gather>, <hash-raw-topk-weights>)
    edge(<hash-raw-topk-weights>, <hash-normalize>)
    edge(<hash-normalize>, <hash-scale>)
    edge(<hash-scaling-factor>, <hash-scale>)
    edge(<hash-eids>, <hash-output>)
    edge(<hash-scale>, <hash-output>)

    content((0.2, -7), subtitle[Hash Routing])
  },
)
