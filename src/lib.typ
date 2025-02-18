#import "@preview/hydra:0.5.1": hydra
#import "@preview/acrostiche:0.5.1": *
#import "@preview/codly:1.0.0": *

#let small-line = line(length: 100%, stroke: 0.045em)

#let get-current-heading-hydra(top-level: false) = {
  if (top-level) {
    return hydra(1)
  }

  return hydra(2)
}

#show par: it => [#it <meta:content>]

#let project(
  title: "",
  subtitle: "",
  author: "",
  author-email: "",
  matriculate-number: 0,
  prof: none,
  second-prof: none,
  date: none,
  glossary-columns: 1,
  enable-glossary: false,
  enable-acronyms: false,
  enable-lof: false,
  enable-lot: false,
  enable-twoside: false,
  bibliography: none,
  chapter-break-mode: "default",
  language: "de",
  font: "Arial",
  font-size: 12pt,
  body,
) = {
  // Set the document's basic properties.
  set document(author: author, title: title)
  set page("a4")


  show table: set table.cell(align: left)

  set text(font: font, lang: language, size: font-size, hyphenate: false) // replaced this font: New Computer Modern
  show math.equation: set text(weight: 400)


  // heading size
  show heading.where(level: 1): it => pad(bottom: 1em)[
    #set text(2em)
    #it
  ]

  // heading size
  show heading.where(level: 2): it => pad(bottom: 0.4em, top: 0.4em)[
    #set text(1.3em)
    #it
  ]

  // heading size
  show heading.where(level: 3): it => pad(bottom: 0.4em, top: 0.4em)[
    #set text(1.25em)
    #it
  ]

  // heading size
  show heading.where(level: 9): it => pad(rest: 0em, bottom: -1.45em)[
    #it
  ]

  show heading.where(level: 1): set heading(supplement: [Chapter])

  show heading.where(level: 2): set heading(supplement: [Section])

  show heading.where(level: 3): set heading(supplement: [Subsection])

  show heading.where(level: 9): set heading(supplement: [])

  show figure.where(kind: "code"): it => {
    if "label" in it.fields() {
      state("codly-label").update(_ => it.label)
      it
      state("codly-label").update(_ => none)
    } else {
      it
    }
  }

  show: codly-init.with()
  show figure: set block(breakable: true)
  codly(
    zebra-fill: white,
    breakable: true,
    reference-sep: ", line ",
    default-color: rgb("#7d7d7d"),
  )


  // Title page.
  set page(margin: (x: 2.5cm, y: 2cm))
  v(0.6fr)
  align(left, image("Wortmarke.svg", width: 20%))
  v(1.6fr)


  text(2em, weight: 700, title)
  v(2em, weak: true)
  text(1.3em, author)
  v(1.5em, weak: true)
  text(1.3em, subtitle)
  v(3em, weak: true)
  text(1.3em, date)
  v(5em, weak: true)

  align(
    right + bottom, 
    image("Logo.svg", width: 28%),
    )
  pagebreak()

  set par(justify: true)
  // margin setup for all pages
  set page(
    margin: {
      if enable-twoside {
        (inside: 3.0cm, outside: 2.5cm, y: 4cm)
      } else {
        (x: 2.5cm, y: 4cm)
      }
    },
  )
  // Author
  grid(
    columns: (1.2fr, 4fr),
    rows: auto,
    row-gutter: 3em,
    gutter: 13pt,
    text("Author:", weight: "bold"),
    [#author\
      #link("mailto:" + author-email)\
      matriculate-number: #matriculate-number
    ],

    text("First Examiner:", weight: "bold"), prof,
    text("Second Examiner:", weight: "bold"), second-prof,
  )

  align(bottom)[
    #align(center, text("Statement of Authorship", weight: "bold"))
    I hereby declare that I have written the submitted thesis independently and without external assistance, that I have not used any sources or aids other than those specified by me, and that I have clearly marked any passages taken verbatim or in substance from the sources used.


    #v(5.2em, weak: true)

    #grid(
      columns: (auto, 4fr),
      gutter: 13pt,
      [Hanover, #date], align(right)[Signature],
    )
  ]

  pagebreak()

  // Table of contents.
  show outline.entry.where(level: 1): it => {
    if (it.element.has("level")) {
      v(2em, weak: true)
      strong(it)
    } else {
      v(1.2em, weak: true)
      it
    }
  }
  outline(depth: 3, indent: true)
  pagebreak()

  set page(numbering: "I")
  counter(page).update(1)

  // List of Figures
  if enable-lof {
    {
      show heading: none
      heading[List of Figures]
    }
    outline(
      title: [List of Figures],
      target: figure.where(kind: image),
      indent: true,
    )
  }

  // List of Table
  if enable-lot {
    // list of figures
    {
      show heading: none
      heading[List of Tables]
    }
    outline(
      title: [List of Tables],
      target: figure.where(kind: table),
      indent: true,
    )
  }


  pagebreak()

  // glossary

  if enable-glossary {
    show figure.where(kind: "jkrb_glossary"): it => { emph(it.body) }
    [
      = Glossary <Glossary>

      #columns(glossary-columns)[
        #make-glossary(glossary-pool)
      ]
    ]
  }

  // acronyms
  if enable-acronyms {
    [
      #print-index(
        title: "Acronyms",
        outlined: true,
      )

    ]
  }

  // header
  set page(
    header: context {
      // dont print anything when the first element on the page is a level 1 heading
      let chapter = hydra(1)

      if (chapter == none) {
        return
      }

      if enable-twoside {
        if calc.even(here().page()) {
          align(left, smallcaps(get-current-heading-hydra(top-level: true)))
        } else {
          align(right, emph(get-current-heading-hydra()))
        }
      } else {
        align(left, emph(get-current-heading-hydra()))
      }

      small-line
    },
  )


  // footer
  set page(
    footer: context {
      small-line
      if enable-twoside {
        if calc.even(here().page()) {
          align(left, counter(page).display("1"))
        } else {
          align(right, counter(page).display("1"))
        }
      } else {
        align(left, counter(page).display("1"))
      }
    },
  )

  // ensure, that a
  show heading.where(level: 1): it => {
    if chapter-break-mode == "default" {
      //level 1 heading always starts on an empty, left page
      pagebreak(weak: true, to: "even")
    }
    if chapter-break-mode == "recto" {
      //level 1 heading always starts on an empty, right page
      pagebreak(weak: true, to: "odd")
    }
    if chapter-break-mode == "next-page" {
      //level 1 heading always starts on an empty page
      pagebreak(weak: true)
    }
    it
  }


  // Main body.
  set page(numbering: "1", number-align: center)
  counter(page).update(1)
  set heading(numbering: "1.1.")

  body

  set page(header: none)

  // bibliography
  if bibliography != none {
    bibliography
  }

  hide("white page")

}
