for f in $(git ls-files | grep '.md$'); do
  aspell -c $f
done

.cabal-sandbox/bin/site check -i

# for f in $(find . -name "*.md" -not -path "./_site/*"); do
#     diction -bs $f | less
# done

# style?
