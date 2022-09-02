#!/bin/bash

set -eu

SHELLCHECK_REPO=ghcr.io/homebrew/core/shellcheck
SHELLCHECK_VERSION=0.8.0

mkdir -p tmp

echo "Retrieving shellcheck image manifest"
crane manifest "${SHELLCHECK_REPO}:${SHELLCHECK_VERSION}" > tmp/manifests.json

# Extract the actual
DIGEST_VERSION=$(jq -r '[ .manifests[] | select ( .platform.os == "darwin" and .platform.architecture == "arm64" ) ] | reverse | .[0].digest' < tmp/manifests.json)

echo "Downloading shellcheck image from ${SHELLCHECK_REPO}@${DIGEST_VERSION}..."
crane pull "${SHELLCHECK_REPO}@${DIGEST_VERSION}" tmp/shellcheck-image.tar

pushd tmp || exit 1
echo "Extracting shellcheck image..."
rm -rf layers && mkdir layers
tar xvzf shellcheck-image.tar -C layers

LAYER=$(jq -r '.[0].Layers[0]' < layers/manifest.json)
popd

mkdir -p dist/
cp "tmp/layers/${LAYER}" "dist/shellcheck-${SHELLCHECK_VERSION}.tar.gz"

echo "dist/shellcheck-${SHELLCHECK_VERSION}.tar.gz"

# At last, upload the artifact :)
