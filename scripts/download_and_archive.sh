#!/bin/bash

function download_and_archive() {
    local os="${1}"
    local arch="${2}"
    rm -rf /downloads
    mkdir -p /downloads
    curl -fsSL \
        "https://github.com/koalaman/shellcheck/releases/download/v${VERSION}/shellcheck-v${VERSION}.${os}.${arch}.tar.xz" |
        tar --strip-components=1 -xJv -C /downloads "shellcheck-v${VERSION}/shellcheck"

    archive "${os}" "${arch}"
}

function archive() {
    local os="${1}"
    local arch="${2}"

    mkdir -p /archives
    tar -cvzf "/archives/shellcheck-v${VERSION}.${os}.${arch}.tar.gz" -C "/downloads" shellcheck
}

set -euxo pipefail

archive "darwin" "arm64"
download_and_archive "darwin" "x86_64"

download_and_archive "linux" "x86_64"
download_and_archive "linux" "aarch64"
download_and_archive "linux" "armv6hf"
