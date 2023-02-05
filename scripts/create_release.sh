#!/usr/bin/env bash

# Fail on error
set -o errexit
# Fail on pipeline
set -o pipefail
# Disable undefined variable reference
set -o nounset

TAG="${TAG?}"

# First delete if release is there already
#   https://github.com/cli/cli/issues/6964
output=$(gh release delete "${TAG}" --cleanup-tag --yes 2>&1) || [[ "${output}" == "release not found" ]]
echo "${output}"

gh release create "${TAG}" --title "${TAG}" --target main --latest=false \
  --notes "The original release notes can be found [here](https://github.com/koalaman/shellcheck/releases/tag/${TAG})." \
  dist/*
