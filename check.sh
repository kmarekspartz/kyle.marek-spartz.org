find . -name "*.md" -exec aspell -c '{}' \;

.cabal-sandbox/bin/site check -i

# for f in $(find . -name "*.md" -not -path "./_site/*"); do
#     diction -bs $f | less
# done

# style?
