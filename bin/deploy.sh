#!/usr/bin/env bash
set -e

# ./bin/check_only_changes.sh

./bin/build_css.sh
./bin/build_presentations.sh
./bin/build_cv.sh
./bin/build_sitemap.sh

./bin/tidy.sh
# ./bin/check_bad_links.sh

pushd _site
widely push
popd
