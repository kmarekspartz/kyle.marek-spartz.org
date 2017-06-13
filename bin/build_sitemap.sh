#!/usr/bin/env bash
set -e

stack exec site build

./bin/echo_sitemap.sh > ./sitemap.txt

stack exec site build
