#!/usr/bin/env bash

# Fail on error
set -o errexit
# Fail on pipeline
set -o pipefail
# Disable wildcard character expansion
set -o noglob
# Disable undefined variable reference
set -o nounset

# Current directory
# shellcheck disable=SC1007
DIRNAME=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# Load commons
# shellcheck source=./__commons.sh
. "$DIRNAME/__commons.sh"

# ================
# CONFIGURATION
# ================
# Archives directory
ARCHIVES_DIR="/archives"
# Darwin arm64 directory
DARWIN_ARM64_DIR="/shellcheck.darwin.arm64.data"
# Temporary directory
TMP_DIR=

# ================
# CLEANUP
# ================
cleanup() {
  # Exit code
  _exit_code=$?
  [ $_exit_code = 0 ] || WARN "Cleanup exit code $_exit_code"

  # Cleanup temporary directory
  DEBUG "Removing temporary directory '$TMP_DIR'"
  rm -rf "$TMP_DIR" || :

  exit "$_exit_code"
}

# Trap
trap cleanup INT QUIT TERM EXIT

# ================
# FUNCTIONS
# ================
# Verify system
verify_system() {
  INFO "Verifying system"

  # Version
  [ -n "${VERSION-}" ] || FATAL "Environment variable 'VERSION' not found"

  # Darwin arm64 directory
  [ -d "$DARWIN_ARM64_DIR" ] || FATAL "Darwin arm64 directory '$DARWIN_ARM64_DIR' does not exist"

  # Commands
  assert_cmd "find"
  assert_cmd "mkdir"
  assert_cmd "mktemp"
  assert_cmd "mv"
  assert_cmd "tar"
  assert_cmd "unzip"

  # Downloader
  assert_downloader
}

# Setup system
setup_system() {
  INFO "Setting up system"

  # Archives directory
  DEBUG "Removing directory '$ARCHIVES_DIR'"
  rm -rf "$ARCHIVES_DIR"
  INFO "Creating directory '$ARCHIVES_DIR'"
  mkdir -p "$ARCHIVES_DIR"

  # Temporary directory
  TMP_DIR=$(mktemp --directory -t shellcheck.XXXXXXXX)
  DEBUG "Created temporary directory '$TMP_DIR'"
}

# Download and archive
# @param $1 Operating System
# @param $2 Architecture
download_and_archive() {
  _os="$1"
  _os_ext=".$1"
  _arch="$2"
  _arch_ext=".$2"
  _archive_ext=".tar.xz"
  if [ "$_os" = "windows" ]; then
    _os_ext=""
    _arch_ext=""
    _archive_ext=".zip"
  fi

  _download_url="https://github.com/koalaman/shellcheck/releases/download/v$VERSION/shellcheck-v${VERSION}${_os_ext}${_arch_ext}${_archive_ext}"
  _archive_file="$TMP_DIR/$_os.$_arch.download"
  _archive_data="$TMP_DIR/$_os.$_arch.data"

  # Download
  download "$_archive_file" "$_download_url"

  # Extract
  INFO "Extracting '$_archive_file' to '$_archive_data'"
  mkdir "$_archive_data"
  if [ "$_os" != "windows" ]; then
    # Linux and Darwin
    tar \
      --strip-components=1 \
      --extract \
      --xz \
      --verbose \
      --directory="$_archive_data" \
      --file="$_archive_file"
  else
    # Windows
    unzip \
      -d "$_archive_data" \
      "$_archive_file"
  fi

  # Archive
  archive "$_archive_data" "$_os" "$_arch"
}

# Archive
# @param $1 Input directory
# @param $2 Operating System
# @param $3 Architecture
archive() {
  _dir="$1"
  _os="$2"
  _arch="$3"

  _archive_file="$ARCHIVES_DIR/shellcheck-v$VERSION.$_os.$_arch.tar.gz"

  # Create archive
  INFO "Creating archive '$_archive_file' from directory '$_dir'"
  find "$_dir" -printf "%P\n" \
    | tar \
      --create \
      --verbose \
      --gzip \
      --no-recursion \
      --file="$_archive_file" \
      --directory="$_dir" \
      --files-from=-
}

# ================
# MAIN
# ================
{
  # Initialization
  verify_system
  setup_system

  # Darwin
  archive "$DARWIN_ARM64_DIR" "darwin" "aarch64"
  download_and_archive "darwin" "x86_64"

  # Linux
  download_and_archive "linux" "x86_64"
  download_and_archive "linux" "aarch64"
  download_and_archive "linux" "armv6hf"

  # Windows
  download_and_archive "windows" "x86_64"
}
