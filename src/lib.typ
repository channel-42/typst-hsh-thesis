#import "@preview/hydra:0.5.1": hydra
#import "@preview/acrostiche:0.5.1": *
#import "@preview/codly:1.0.0": *
#import "@preview/codly-languages:0.1.1": *

#let small-line = line(length: 100%, stroke: 0.045em)

#let get-current-heading-hydra(top-level: false) = {
  if (top-level) {
    return hydra(1)
  }
  return hydra(2)
}

#let page-has-h1-heading() = {
  return query(heading.where(level: 1)).filter(it => here().page() == it.location().page()).len() > 0
}

#let appendix = state("appendix", none)
#let a() = appendix.get()

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
  enable-lol: false,
  enable-twoside: false,
  enable-colored-links: false,
  link-color: rgb("#005D7E"),
  bib: none,
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

  // colored citations and references
  show cite: it => {
    // Only color the number, not the brackets.
    show regex("\d+"): set text(fill: link-color) if enable-colored-links
    it
  }

  show ref: it => {
    if it.element == none {
      // This is a citation, which is handled above.
      return it
    }

    // Only color the number, not the supplement.
    show regex("[A-Za-z]?\.*\d+"): set text(fill: link-color) if enable-colored-links
    it
  }

  // heading size
  show heading.where(level: 1): it => pad(bottom: 1.5em)[
    #set text(1.8em)
    #v(2.5em)
    #it
  ]

  // heading size
  show heading.where(level: 2): it => pad(bottom: 0.5em, top: 0.8em)[
    #set text(1.3em)
    #it
  ]

  // heading size
  show heading.where(level: 3): it => pad(bottom: 0.5em, top: 0.8em)[
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
    languages: codly-languages,
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

  if enable-twoside {
    pagebreak()
  }

  set par(justify: true)
  // margin setup for all pages
  set page(
    margin: {
      if enable-twoside {
        (inside: 3.5cm, outside: 2.0cm, y: 4cm)
      } else {
        (x: 2.5cm, y: 4cm)
      }
    },
  )
  // Author
  grid(
    columns: (1.5fr, 4fr),
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
  if enable-twoside {
    pagebreak()
  }
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
  outline(depth: 3, indent: auto)
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
      indent: auto,
    )
  }

  // List of Tables
  if enable-lot {
    pagebreak()
    {
      show heading: none
      heading[List of Tables]
    }
    outline(
      title: [List of Tables],
      target: figure.where(kind: table),
      indent: auto,
    )
  }

  // List of Listings
  if enable-lol {
    pagebreak()
    {
      show heading: none
      heading[List of Listings]
    }
    outline(
      title: [List of Listings],
      target: figure.where(kind: raw),
      indent: auto,
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
      ) <acronyms>

    ]
  }

  if enable-twoside {
    pagebreak(to: "even")
  }

  // empty content block to store label for the start of the body
  [#metadata("")#label("end-front-matter")]


  // header
  set page(
    header: context {
      // dont print anything when the first element on the page is a level 1 heading
      if page-has-h1-heading() {
        return
      }

      if enable-twoside {
        if calc.even(here().page()) {
          align(left, emph(get-current-heading-hydra(top-level: false)))
        } else {
          align(right, emph(get-current-heading-hydra(top-level: true)))
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
      // dont print a small-line on pages with a level 1 heading
      if not page-has-h1-heading() {
        small-line
      }

      if enable-twoside {
        if calc.even(here().page()) {
          if not page-has-h1-heading() {
            grid(
              columns: 2,
              gutter: 1fr,
              align(left, counter(page).display("1")), align(right, text(author)),
            )
          } else {
            align(left, counter(page).display("1"))
          }
        } else {
          align(right, counter(page).display("1"))
        }
      } else {
        grid(
          columns: 2,
          gutter: 1fr,
          align(left, counter(page).display("1")), align(right, author),
        )
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
  set heading(numbering: "1.1")

  body

  if (enable-twoside) {
    pagebreak(to: "even")
  }

  // backmatter context
  context {
    // calculate page numbering for back matter
    counter(page).update(counter(page).at(<end-front-matter>).first())

    set page(
      numbering: "I",
      header: none,
      footer: context {
        align(center, counter(page).display("I"))
      },
    )

    // bibliography
    if bib != none {
      show link: set text(fill: link-color) if enable-colored-links
      show bibliography: it => {
        show heading: it => {
          set text(1.8em)
          it.body
        }
        it
      }
      bib
    }
    
    if (a() != none) {
      pagebreak(to: "even")
      // appendices
      set heading(numbering: none, supplement: [Appendix])
      [
        = Appendix
      ]
      counter(heading).update(1)
      set heading(numbering: "A.1")
      [
        #show heading: set heading(supplement: [Appendix])
        #a()
      ]
    }

    hide("white page")
  }
}

