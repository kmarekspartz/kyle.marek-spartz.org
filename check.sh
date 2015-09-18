for f in $(git ls-files | grep '.md$'); do
  aspell -c $f
done

# for f in $(git ls-files | grep '.md$'); do
#     diction -bs $f | less
# done

# style?

stack exec site check
