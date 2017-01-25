#!/usr/bin/env bash
set -e

./bin/check_only_changes.sh

./bin/build_css.sh

pushd presentations
./build.sh
popd

./bin/build_cv.sh
./bin/build_sitemap.sh
./bin/tidy.sh
./bin/check_bad_links.sh

pushd _site
widely push
popd
