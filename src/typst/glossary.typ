#let glossary = (OSS: (desc: [Open Source Software], link: <oss>))
#let glossary-entry(name, description) = {
  figure([
    #grid(columns: (3fr, 8fr), gutter: 5mm, [
      #align(left, text(size: 12pt, [*#name*]))
    ], align(left, description))
    #line(length: 100%, stroke: 0.5pt + rgb("#c4c4c4"))
  ], kind: "glossary-entry", supplement: name)
}
#let outline-glossary = () => glossary.pairs().map(((k, v)) => [#glossary-entry(k, v.desc) #v.link]).join()
#let g = (k) => link(glossary.at(k).link, k)
