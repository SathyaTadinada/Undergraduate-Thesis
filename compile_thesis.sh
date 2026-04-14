#!/bin/sh

set -eo pipefail

typst compile thesis.typ
qpdf thesis.pdf --pages . z -- thesis-end.pdf
qpdf thesis.pdf --pages . 1-r2 -- thesis-main.pdf
qpdf --empty --qdf --pages thesis-main.pdf assets/design-document.pdf thesis-end.pdf -- merged.qdf
fix-qdf < merged.qdf > fixed.qdf
qpdf fixed.qdf thesis-final.pdf
rm thesis-end.pdf thesis-main.pdf merged.qdf fixed.qdf