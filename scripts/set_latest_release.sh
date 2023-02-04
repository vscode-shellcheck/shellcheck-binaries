#!/usr/bin/env bash

# Fail on error
set -o errexit
# Fail on pipeline
set -o pipefail
# Disable undefined variable reference
set -o nounset

latest_tag=$(git tag -l --sort=-version:refname | head -1)
readonly latest_tag

gh release edit "${latest_tag}" --latest
