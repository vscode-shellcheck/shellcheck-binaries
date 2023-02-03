# syntax=docker/dockerfile:1

# ================
# CONFIGURATION
# ================
# ShellCheck version
ARG VERSION
ARG HOMEBREW_VERSION

# ================
# DARWIN ARM64
# ================
FROM --platform=darwin/arm64 ghcr.io/homebrew/core/shellcheck:$HOMEBREW_VERSION AS darwin-arm64

# ================
# ARCHIVES
# ================
FROM alpine AS archives

# Install packages
RUN apk add --no-cache \
  bash \
  findutils \
  tar \
  unzip \
  xz

ARG VERSION

# Copy Darwin arm64 binary
COPY --from=darwin-arm64 shellcheck/$VERSION/bin/shellcheck /shellcheck.darwin.arm64.data/

# Copy scripts directory
COPY scripts /scripts

# Execute script
RUN /scripts/download_and_archive.sh

# ================
# SCRATCH
# ================
FROM scratch

# Copy archives directory
COPY --from=archives /archives/ /
