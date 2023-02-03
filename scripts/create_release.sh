#!/usr/bin/env bash

# Fail on error
set -o errexit
# Fail on pipeline
set -o pipefail
# Disable undefined variable reference
set -o nounset

TAG="${TAG?}"

# First delete if release is there already
output=$(gh release delete "${TAG}" --cleanup-tag --yes 2>&1) || [[ "${output}" == "release not found" ]]
echo "${output}"

# It would be nice if we could unmark the release as latest, but it
# does not seem to be possible currently:
#   https://github.com/cli/cli/issues/6963
gh release create "${TAG}" --title "${TAG}" --target main \
  --notes "The original release notes can be found [here](https://github.com/koalaman/shellcheck/releases/tag/${TAG})." \
  dist/*
