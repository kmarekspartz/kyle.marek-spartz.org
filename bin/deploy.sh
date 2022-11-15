#!/usr/bin/env bash
set -e

# ./bin/check_only_changes.sh

./bin/build_css.sh
./bin/build_presentations.sh
./bin/build_cv.sh
./bin/build_sitemap.sh

# ./bin/tidy.sh
# ./bin/check_bad_links.sh

pushd _site
aws s3 sync . s3://kyle.marek-spartz.org
AWS_CF_DISTRIBUTION_ID=$(aws cloudfront list-distributions | jq -r '.DistributionList.Items[] | select(.Aliases.Items[0] == "kyle.marek-spartz.org") | .Id')
aws cloudfront create-invalidation --distribution-id "$AWS_CF_DISTRIBUTION_ID" --paths "/*"
popd
