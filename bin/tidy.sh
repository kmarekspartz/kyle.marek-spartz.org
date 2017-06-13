#!/usr/bin/env bash
set -e

stack exec site build

HTML_FILES=$(find _site -name "*.html")

UNTIDY_FILES=$(for f in $HTML_FILES; do
  tidy -e -q $f 2>/dev/null || echo $f
done)

for f in $UNTIDY_FILES; do
  echo $f
  tidy -e -q $f || true
  echo
done

[[ "" == $UNTIDY_FILES ]] || false
