for f in $(find . -name "*.md"); do
    new_f=$(echo "$f" | sed s/.md$/.html/)
    echo "Building $f into $new_f"
    pandoc -s --webtex -i -t slidy $f -o $new_f
done
