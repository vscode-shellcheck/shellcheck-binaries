#!/usr/bin/env bash

# Fail on error
set -o errexit
# Fail on pipeline
set -o pipefail
# Disable undefined variable reference
set -o nounset

TAG="${TAG?}"

# Delete the release if it already exists
if gh release view "${TAG}" &> /dev/null; then
  gh release delete "${TAG}" --cleanup-tag --yes 2>&1
fi

gh release create "${TAG}" --title "${TAG}" --target main --latest=false \
  --notes "The original release notes can be found [here](https://github.com/koalaman/shellcheck/releases/tag/${TAG})." \
  dist/*
