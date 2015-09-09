stack exec site rebuild

pushd _site

../echo_sitemap.sh > ../sitemap.txt

popd

stack exec site build
