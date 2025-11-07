#import "./lib.typ": *

#let language = "de"
#show: doc.with(language:language, title: "Title", subtitle: "Subtitle")

#let deftbl(..body) = {
  table(
    columns: (auto, 1fr), table.header([#languages.at(language).term], [#languages.at(language).definition]), ..body,
  )
}

= Template
