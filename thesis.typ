#import "config.typ": author_name, cover_page_approvers, draft_mode, submission_date, thesis_title

#set page(paper: "us-letter", margin: (left: 1.5in, right: 1in, top: 1in, bottom: 1in))
#set text(font: "Times New Roman", size: 12pt)

// Draft watermark.
#set page(background: rotate(24deg, text(72pt, fill: color.luma(90%), strong(upper("Draft"))))) if draft_mode

// Heading styles.
#show heading: it => [
  #if it.level == 1 [
    #set align(center)
    #set text(12pt, weight: "regular")
    #block(upper(it.body), inset: (y: 12pt))
  ] else if it.level == 2 [
    #set align(center) // TODO: left-aligned or center-aligned?
    #set text(12pt, weight: "regular") // TODO: bold or regular?
    #block(it.body, inset: (y: 12pt))
  ] else if it.level == 3 [
    #set text(12pt, weight: "regular")
    #block(it.body, inset: (y: 12pt))
  ]
]

// Cover page.
#align(center)[
  #upper(thesis_title)

  \

  by

  \

  #author_name

  \

  A Senior Honors Thesis Submitted to the Faculty of \
  The University of Utah \
  In Partial Fulfillment of the Requirements for the

  \

  Honors Degree in Bachelor of Science

  In

  Computer Science
]

\
\

Approved:

\
\

#grid(
  columns: 2,
  row-gutter: 48pt,
  column-gutter: 48pt,
  ..cover_page_approvers.map(approver => [
    #line(length: 100%)
    #approver.name
    \
    #approver.role
  ])
)

\

#align(center)[
  #submission_date.display("[month repr:long] [year]")
  \
  Copyright #sym.copyright #submission_date.display("[year]")
  \
  All Rights Reserved
]

#pagebreak(weak: true)

#set page(numbering: "i")

// Set Double Spacing
#set text(top-edge: 0.7em, bottom-edge: -0.3em)
#set par(leading: 1em, first-line-indent: (amount: 0.5in, all: true))

// Set list styling
#set list(indent: 1em)

= Abstract
#include "content/abstract.typ"

#pagebreak(weak: true)

#show outline.entry: it => {
  if it.element.depth == 1 {
    link(
      it.element.location(),
      it.indented(it.prefix(), [
        #upper(it.element.body.text)
        #box(width: 1fr, repeat("", gap: 0.15em))
        #it.page()
      ]),
    )
  } else if it.element.depth == 2 {
    link(
      it.element.location(),
      it,
    )
  }
}
#set outline.entry(fill: none)
#outline(title: "Table of Contents")

#pagebreak(weak: true)

// Set content page numbering.
#set page(numbering: "1")
#counter(page).update(1)
#set page(
  header: context {
    align(right)[#counter(page).display("1")]
  },
  footer: none,
)

#include "content/content.typ"

#include "content/references.typ"

#include "content/appendix.typ"

#pagebreak(weak: true)

#set page(
  header: none,
  footer: none,
)

#align(center + horizon)[
  Name of Candidate: #author_name

  \

  Date of Submission: #submission_date.display("[month repr:long] [day padding:none], [year]")
]
