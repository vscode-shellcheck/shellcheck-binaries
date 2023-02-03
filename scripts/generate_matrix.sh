#!/usr/bin/env bash

# Fail on error
set -o errexit
# Fail on pipeline
set -o pipefail
# Disable undefined variable reference
set -o nounset

# Just an example for now, but we should generate it dynamically
output=$(cat <<EOF
[
  {
    "version": "0.9.0",
    "homebrew-version": "0.9.0"
  },
  {
    "version": "0.8.0",
    "homebrew-version": "0.8.0"
  },
  {
    "version": "0.7.2",
    "homebrew-version": "0.7.2-1"
  }
]
EOF
)

GITHUB_OUTPUT="${GITHUB_OUTPUT:-/dev/null}"

echo "matrix=${output}" | tee "${GITHUB_OUTPUT}"
