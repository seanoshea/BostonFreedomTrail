#!/bin/bash

ORGANISATION='Upwards Northwards Software Limited'
NAME=BostonFreedomTrail
BRANCH=develop

if [ "$OUTPUT_PATH" == "" ]; then
    OUTPUT_PATH=docs
fi

GITHUB=https://github.com/seanoshea/BostonFreedomTrail

bundle exec jazzy \
  --config .jazzy.json \
  --clean \
  --min-acl private \
  --output "$OUTPUT_PATH" \
  --module-version "$BRANCH" \
  --github_url "$GITHUB" \
  --github-file-prefix "$GITHUB/tree/$BRANCH"
