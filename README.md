# Undergrad Thesis

Source for my University of Utah senior honors thesis: *FreezeTag: Designing and Building a Self-Hosted Image Management Application*.

## Structure

- `thesis.typ` - main Typst source file
- `config.typ` - title, author, date, and approver info
- `content/` - chapter source files (abstract, body, appendix, references)
- `assets/` - screenshots and the design document PDF
- `references.bib` - bibliography

## Building

Requires [Typst](https://typst.app) and Python 3 with `pypdf` installed.

```sh
./compile_thesis.sh
```

This compiles `thesis.typ` to `thesis.pdf`, then runs `merge_thesis.py` to splice in the design document and produce `thesis-final.pdf` (the submission copy).

## Output

- `thesis.pdf` - compiled thesis only
- `thesis-final.pdf` - thesis with design document appended (final submission)
