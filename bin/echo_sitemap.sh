#!/usr/bin/env bash
set -e

pushd _site >/dev/null

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

for tag in posts/*.html; do
    echo $ROOT_URL$tag
done

popd >/dev/null
