#import "archive/archive-config.typ": author_name, cover_page_approvers, submission_date, thesis_title

#set page(paper: "us-letter", margin: (left: 1.5in, right: 1in, top: 1in, bottom: 1in))
#set text(font: "Times New Roman", size: 12pt)

// // Draft watermark.
// #set page(background: rotate(24deg, text(72pt, fill: color.luma(90%), strong(upper("Draft")))))

#show heading: it => [
  #set align(center)
  #set text(12pt, weight: "regular")
  #block(upper(it.body), inset: (y: 12pt))
]

// Set starting page numbering.
#set page(
  footer: context {
    if counter(page).get().first() > 1 {
      align(center)[#counter(page).display("i")]
    }
  },
)

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

// Set Double Spacing
#set text(top-edge: 0.7em, bottom-edge: -0.3em)
#set par(leading: 1em, first-line-indent: (amount: 0.5in, all: true))

= Abstract
#include "content/abstract.typ"

#pagebreak(weak: true)

#heading(outlined: false)[Table of Contents]

#context {
  let table_of_contents_page_number = counter(page).get().first()

  query(heading.where(outlined: true))
    .map(heading => {
      let heading_page_number = heading.location().page()

      par(first-line-indent: 0em, link(heading.location())[
        #upper(heading.body)
        #h(1fr)
        #if heading_page_number < table_of_contents_page_number {
          numbering("i", heading_page_number)
        } else {
          numbering("1", heading_page_number - table_of_contents_page_number)
        }
      ])
    })
    .join([])
}

#pagebreak(weak: true)

// Set content page numbering.
#counter(page).update(1)
#set page(
  header: context {
    if counter(page).get().first() < counter(page).final().first() {
      align(right)[#counter(page).display("1")]
    }
  },
  footer: none,
)

#include "content/content.typ"

#pagebreak(weak: true)

#align(center + horizon)[
  Name of Candidate: #author_name

  \

  Date of Submission: #submission_date.display("[month repr:long] [day padding:none], [year]")
]
