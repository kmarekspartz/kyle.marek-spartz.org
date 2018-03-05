#!/usr/bin/env bash
set -Ceux -o pipefail

grep -R "\bthe\W+the\b" . || true

MARKDOWN_FILES=$(git ls-files | grep '.md$')

MISSPELLED_FILES=$(for f in $MARKDOWN_FILES; do
  MISSPELLED_COUNT=$(cat $f | aspell -p .aspell list | wc -l)
  (( $MISSPELLED_COUNT == "0" )) || echo $f
done)

for f in $MISSPELLED_FILES; do
  echo $f
  cat $f | aspell list | sort | uniq -c | sort
  echo
done

diction -bs $MARKDOWN_FILES

SENTENCE_LENGTH=26
MAX_ARI=10

style --print-long $SENTENCE_LENGTH --print-ari $MAX_ARI --print-nom-passive $MARKDOWN_FILES
