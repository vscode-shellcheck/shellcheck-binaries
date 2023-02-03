#!/usr/bin/env bash

set -euxo pipefail

# ================
# CONFIGURATION
# ================
# Archives directory
readonly ARCHIVES_DIR="/archives"
# Darwin arm64 directory
readonly DARWIN_ARM64_DIR="/shellcheck.darwin.arm64.data"
# Temporary directory
TMP_DIR=

# ================
# LOGGER
# ================
# Fatal log level. Cause exit failure
readonly LOG_LEVEL_FATAL=100
# Error log level
readonly LOG_LEVEL_ERROR=200
# Warning log level
readonly LOG_LEVEL_WARN=300
# Informational log level
readonly LOG_LEVEL_INFO=500
# Debug log level
readonly LOG_LEVEL_DEBUG=600
# Log level
readonly LOG_LEVEL=$LOG_LEVEL_INFO

# Print log message
# @param $1 Log level
# @param $2 Message
function log_print_message() {
  local log_level=${1:-LOG_LEVEL_FATAL}
  shift
  local log_level_name=
  local log_message=${*:-}

  # Check log level
  [ "$log_level" -le "$LOG_LEVEL" ] || return 0

  case $log_level in
    "$LOG_LEVEL_FATAL")
      log_level_name=FATAL
      ;;
    "$LOG_LEVEL_ERROR")
      log_level_name=ERROR
      ;;
    "$LOG_LEVEL_WARN")
      log_level_name=WARN
      ;;
    "$LOG_LEVEL_INFO")
      log_level_name=INFO
      ;;
    "$LOG_LEVEL_DEBUG")
      log_level_name=DEBUG
      ;;
  esac

  # Log
  printf '[%-5s] %b\n' "$log_level_name" "$log_message"
}

# Fatal log message
# @param $1 Message
function FATAL() {
  log_print_message "$LOG_LEVEL_FATAL" "$@" >&2
  exit 1
}

# Error log message
# @param $1 Message
function ERROR() { log_print_message "$LOG_LEVEL_ERROR" "$@" >&2; }

# Warning log message
# @param $1 Message
function WARN() { log_print_message "$LOG_LEVEL_WARN" "$@" >&2; }

# Informational log message
# @param $1 Message
function INFO() { log_print_message "$LOG_LEVEL_INFO" "$@"; }

# Debug log message
# @param $1 Message
function DEBUG() { log_print_message "$LOG_LEVEL_DEBUG" "$@"; }

# ================
# CLEANUP
# ================
function cleanup() {
  # Exit code
  _exit_code=$?
  [ ${_exit_code} = 0 ] || WARN "Cleanup exit code ${_exit_code}"

  # Cleanup temporary directory
  DEBUG "Removing temporary directory '${TMP_DIR}'"
  rm -rf "${TMP_DIR}" || :

  exit "${_exit_code}"
}

# Trap
trap cleanup INT QUIT TERM EXIT

# ================
# FUNCTIONS
# ================
# Check command is installed
# @param $1 Command name
function check_cmd() {
  command -v "$1" > /dev/null 2>&1
}

# Assert command is installed
# @param $1 Command name
function assert_cmd() {
  check_cmd "$1" || FATAL "Command '$1' not found"
  DEBUG "Command '$1' found at '$(command -v "$1")'"
}

# Download a file
# @param $1 Output location
# @param $2 Download URL
function download() {
  INFO "Downloading file '$2' to '$1'"
  curl --fail --silent --location --show-error --output "$1" "$2" || FATAL "Download file '$2' failed"
  DEBUG "Successfully downloaded file '$2' to '$1'"
}

# Verify system
function verify_system() {
  # Version
  [[ -n "${VERSION-}" ]] || FATAL "Environment variable 'VERSION' not found"

  # Darwin arm64 directory
  [[ -d "${DARWIN_ARM64_DIR}" ]] || FATAL "Darwin arm64 directory '${DARWIN_ARM64_DIR}' does not exists"

  # Commands
  assert_cmd "curl"
  assert_cmd "find"
  assert_cmd "mkdir"
  assert_cmd "mktemp"
  assert_cmd "mv"
  assert_cmd "rmdir"
  assert_cmd "tar"
  assert_cmd "unzip"
}

# Setup system
function setup_system() {
  # Archives directory
  DEBUG "Removing directory '${ARCHIVES_DIR}'"
  rm -rf "${ARCHIVES_DIR}"
  INFO "Creating directory '${ARCHIVES_DIR}'"
  mkdir -p "${ARCHIVES_DIR}"

  # Temporary directory
  TMP_DIR=$(mktemp --directory -t shellcheck.XXXXXXXX)
  readonly TMP_DIR
  DEBUG "Created temporary directory '${TMP_DIR}'"
}

# Download and archive
# @param $1 Operating System
# @param $2 Architecture
function download_and_archive() {
  local os="${1}"
  local os_ext=".${1}"
  local arch="${2}"
  local arch_ext=".${2}"
  local archive_ext=".tar.xz"
  if [[ "${os}" = "windows" ]]; then
    os_ext=""
    arch_ext=""
    archive_ext=".zip"
  fi

  local download_url="https://github.com/koalaman/shellcheck/releases/download/v${VERSION}/shellcheck-v${VERSION}${os_ext}${arch_ext}${archive_ext}"
  local archive_file="${TMP_DIR}/${os}.${arch}.download"
  local archive_data="${TMP_DIR}/${os}.${arch}.data"

  # Download
  download "${archive_file}" "${download_url}"

  # Extract
  INFO "Extracting '${archive_file}' to '${archive_data}'"
  mkdir "${archive_data}"
  if [[ "${os}" != "windows" ]]; then
    # Linux and Darwin
    tar \
      --strip-components=1 \
      --extract \
      --xz \
      --verbose \
      --directory="${archive_data}" \
      --file="${archive_file}"
  else
    # Windows
    unzip \
      -d "${archive_data}" \
      "${archive_file}"
  fi

  # Archive
  archive "${archive_data}" "${os}" "${arch}"
}

# Archive
# @param $1 Input directory
# @param $2 Operating System
# @param $3 Architecture
function archive() {
  local dir="${1}"
  local os="${2}"
  local arch="${3}"

  local archive_file="${ARCHIVES_DIR}/shellcheck-v${VERSION}.${os}.${arch}.tar.gz"

  # Create archive
  INFO "Creating archive '${archive_file}' from directory '${dir}'"
  find "${dir}" -printf "%P\n" \
    | tar \
      --create \
      --verbose \
      --gzip \
      --no-recursion \
      --file="${archive_file}" \
      --directory="${dir}" \
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
  archive "${DARWIN_ARM64_DIR}" "darwin" "arm64"
  download_and_archive "darwin" "x86_64"

  # Linux
  download_and_archive "linux" "x86_64"
  download_and_archive "linux" "aarch64"
  download_and_archive "linux" "armv6hf"

  # Windows
  download_and_archive "windows" "x86_64"
}
