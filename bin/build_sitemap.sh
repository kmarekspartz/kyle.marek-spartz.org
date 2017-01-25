#!/usr/bin/env bash
set -e

stack exec site rebuild

./bin/echo_sitemap.sh > ./sitemap.txt

stack exec site build
