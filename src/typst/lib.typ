#let dateformat = "[day].[month].[year]"
#let language = "de"
#let fsize = 11pt
#let columnsnr = 1
#let author= "Georgiy Shevoroshkin",
#let title= "Template",
#let font = (font: "Arimo Nerd Font", lang: language, region: "ch", size: fsize, fill: colors.black)
#let languages = (
  de: (page: "Seite", chapter: "Kapitel", toc: "Inhaltsverzeichnis", term: "Begriff", definition: "Bedeutung", summary: "Zusammenfassung"),
  en: (page: "Page", chapter: "Chapter", toc: "Contents", term: "Term", definition: "Definition", summary: "Summary"),
)

#set document(
  author: author,
  title: title,
  date: date,
)
#set page(
  flipped: false,
  columns: columnsnr,
  margin: if (columnsnr < 2) {
  (top: 2cm, left: 1.5cm, right: 1.5cm, bottom: 2cm)
} else {
  0.5cm
},
  footer: context [
  #set text(font: font.font, size: 0.9em)
  #title
  #h(1fr)
  #languages.at(language).page #counter(page).display()
], header: context [
  #set text(font: font.font, size: 0.9em)
  #author
  #h(1fr)
  #datetime.today().display(dateformat)
]
)
#set columns(columnsnr, gutter: 2em)
#set text(..font)
#set enum(numbering: "1.a)")
#set table.cell(breakable: false)
#set table(
    stroke: (x, y) => (
      left: if x > 0 { 0.07em },
      top: if y > 0 { 0.07em },
    ),
    inset: 0.5em,
  )
#set quote(block: true, quotes: true)
#set outline(indent: 0em)

#show table.cell.where(y: 0): emph
#show math.equation: set text(font: "Fira Math")
#show raw: set text(font: "Fira Code")
