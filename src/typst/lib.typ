#let dateformat = "[day].[month].[year]"
#let fsize = 11pt
#let columnsnr = 1
#let language = "de"
#let author = "Georgiy Shevoroshkin"
#let title = "Template"
#let subtitle = "Subtitle"
#let toc = (enabled: true, depth: 9, columnsnr: 1)
#let bib-enable = true
#let illustrations-enable = true 
#let tables-enable = true
#let glossary-enable = true
#let colors = (
  red: rgb("#CD533B"), green: rgb("#84B082"), blue: rgb("#b0c4de"), darkblue: rgb("#4874AD"), black: rgb("#090302"), white: rgb("#f5f5f5"), comment: rgb("#444444"),
)
#let font = (
  font: "Arimo Nerd Font", lang: language, region: "ch", size: fsize, fill: colors.black,
)
#let languages = (
  de: (
    page: "Seite", chapter: "Kapitel", toc: "Inhaltsverzeichnis", term: "Begriff", definition: "Bedeutung", summary: "Zusammenfassung",
  ), en: (
    page: "Page", chapter: "Chapter", toc: "Contents", term: "Term", definition: "Definition", summary: "Summary",
  ),
)
#let glossary-entry(name, description) = {
  figure([
    #grid(columns: (3fr, 8fr), gutter: 5mm, [
      #align(left, text(size: 12pt, [*#name*]))
    ], align(left, description))
    #line(length: 100%, stroke: 0.5pt + rgb("#c4c4c4"))
  ], kind: "glossary-entry", supplement: name)
}
#let glossary = (OSS: (desc: [Open Source Software], link: <oss>))
#let g = (k) => link(glossary.at(k).link, k)
#let outline-glossary = () => glossary.pairs().map(((k, v)) =>
[#glossary-entry(k, v.desc) #v.link]).join()

#let corr(body) = {
  set text(fill: colors.red, weight: "bold")
  body
}
#let comment(body) = {
  set text(fill: colors.comment, style: "italic")
  body
}

#let num(p, n) = {
  set text(fill: colors.comment)
  "0"
  p
  set text(fill: colors.black, weight: "bold")
  n
}
#let hex(n) = {
  // TODO: pad & split
  let res = ""
  let i = 0
  while n != 0 {
    let rem = calc.rem(n, 16)
    res += if rem > 9 { str.from-unicode(55 + rem) } else { str(rem) }
    n = calc.floor(n / 16)
    i += 1
    if calc.rem(i, 2) == 0 and n > 0 {
      res += " "
    }
  }
  res += "0" * (calc.rem(i, 2))
  num("x", res.rev())
}
#let bin(n) = {
  // TODO: pad & split
  let res = ""
  let i = 0
  while n != 0 {
    let rem = calc.rem(n, 2)
    res += str(rem)
    n = calc.floor(n / 2)
    i += 1
    if calc.rem(i, 4) == 0 and n > 0 {
      res += " "
    }
  }
  if calc.rem(i, 4) > 0 {
    res += "0" * (4 - calc.rem(i, 4))
  }
  num("b", res.rev())
}
#let dec(n) = {
  let i = 0
  let res = ""
  for d in str(n).rev() {
    res += d
    i += 1
    if calc.rem(i, 3) == 0 and i != str(n).len() {
      res += "'"
    }
  }
  num("d", res.rev())
}
#let no-ligature(t) = {
  text(features: (calt: 0), t)
}
#let deftbl(..body) = {
  table(
    columns: (auto, 1fr), table.header([#languages.at(language).term], [#languages.at(language).definition]), ..body,
  )
}
#let doc = (body) => {
  set document(author: author, title: title, date: datetime.today())
  set page(flipped: false, columns: columnsnr, margin: if (columnsnr < 2) {
    (top: 2cm, left: 1.5cm, right: 1.5cm, bottom: 2cm)
  } else {
    0.5cm
  }, footer: context[
    #set text(font: font.font, size: 0.9em)
    #title
    #h(1fr)
    #languages.at(language).page #counter(page).display()
  ], header: context[
    #set text(font: font.font, size: 0.9em)
    #author
    #h(1fr)
    #datetime.today().display(dateformat)
  ])
  set columns(columnsnr, gutter: 2em)
  set text(..font)
  set enum(numbering: "1.a)")
  set table.cell(breakable: false)
  set table(
    stroke: (x, y) => (left: if x > 0 { 0.07em }, top: if y > 0 { 0.07em }), inset: 0.5em,
  )
  set quote(block: true, quotes: true)
  show quote: q => {
    set align(left)
    set text(style: "italic")
    q
  }
  set outline(indent: 0em)
  show outline.entry.where(level: 1): entry => {
    v(1.1em, weak: true)
    strong(entry)
  }

  show table.cell.where(y: 0): emph
  show math.equation: set text(font: "Fira Math")
  show raw: set text(font: "Fira Code")
  show link: it => [
    #set text(weight: 500, fill: colors.darkblue)
    #underline(offset: 0.7mm, stroke: colors.blue, it)
  ]
  show ref: it => [
    #set text(weight: 500, fill: colors.darkblue)
    #underline(offset: 0.7mm, stroke: colors.blue, it)
  ]
  show ref: ref => if ref.element.func() != heading {
    ref
  } else {
    let label = ref.target
    let header = ref.element
    link(
      label, ["#header.body" (#languages.at(language).page #header.location().page())],
    )
  }
  set heading(numbering: "1.1.1.", supplement: languages.at(language).chapter)
  show heading: hd => block({
    if hd.numbering != none and hd.level <= 3 {
      context counter(heading).display()
      h(1.3em)
    }
    hd.body
  })

  show heading.where(level: 1): h => {
    set text(..font2, top-edge: 0.18em)
    set par(leading: 1.3em, hanging-indent: 2.5em)
    line(length: 100%, stroke: 0.18em + colors.blue)
    upper(h)
    v(0.45em)
  }

  show heading.where(level: 2): h => {
    set text(size: 0.9em)
    upper(h)
  }

  show heading.where(level: 4): h => {
    v(-0.4em)
    h
  }

  let subtitle-fmt(subt) = [
    #set text(..font2, size: 1.2em)
    #pad(bottom: 1.3em, subt)
  ]

  align(left)[
    #text(..font2, size: 1.8em, title)
    #v(1em, weak: true)
    #subtitle-fmt[#subtitle]
  ]
  if (toc.enabled) {
    heading(outlined: false, numbering: none, languages.at(language).toc)
    columns(
      toc.at("columns", default: 1), outline(depth: toc.at("depth", default: none), title: none),
    )
    pagebreak()
  }

  set par(justify: true)
  body

  if (glossary-enable) {
    [= Glossary]
    outline-glossary()
  }
  if (bib-enable) {
    bibliography("citations.bib")
    pagebreak()
  }
  if (illustrations-enable or tables-enable) {
    if (illustrations-enable) {
      [= Illustrations]
      outline(title: none, target: figure.where(kind: image))
    }
    if (tables-enable) {
      [= Tables]
      outline(title: none, target: figure.where(kind: table))
    }
  }
}
