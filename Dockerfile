# syntax=docker/dockerfile:1

# ================
# CONFIGURATION
# ================
# ShellCheck version
ARG VERSION

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
