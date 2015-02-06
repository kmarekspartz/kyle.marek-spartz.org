ROOT_URL="http://kyle.marek-spartz.org/"

echo $ROOT_URL

for page in *.html; do
    echo $ROOT_URL$page
done

for presentation in presentations/*.html; do
    echo $ROOT_URL$presentation
done

for publication in publications/*.pdf; do
    echo $ROOT_URL$publication
done

echo $ROOT_URL"posts/tags/"
for tag in posts/tags/*.html; do
    echo $ROOT_URL$tag
done
