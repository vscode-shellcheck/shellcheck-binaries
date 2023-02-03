# syntax=docker/dockerfile:1

ARG VERSION

FROM --platform=darwin/arm64 ghcr.io/homebrew/core/shellcheck:${VERSION} AS darwin-arm64

FROM alpine AS archives

RUN apk add --no-cache bash curl tar unzip xz

COPY scripts/download_and_archive.sh /scripts/download_and_archive.sh

ARG VERSION
COPY --from=darwin-arm64 shellcheck/${VERSION}/bin/shellcheck /shellcheck.darwin.arm64.data/
RUN /scripts/download_and_archive.sh

FROM scratch

COPY --from=archives /archives/ /
