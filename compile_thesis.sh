#!/bin/sh

set -eo pipefail

typst compile thesis.typ
python3 merge_thesis.py