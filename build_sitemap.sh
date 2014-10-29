.cabal-sandbox/bin/site rebuild

pushd _site

../echo_sitemap.sh > ../sitemap.txt

popd

.cabal-sandbox/bin/site build
