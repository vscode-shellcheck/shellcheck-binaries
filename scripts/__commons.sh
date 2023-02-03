#!/usr/bin/env sh

# ================
# GLOBALS
# ================
# Downloader
DOWNLOADER=

# ================
# LOGGER
# ================
# Fatal log level. Cause exit failure
LOG_LEVEL_FATAL=100
# Error log level
LOG_LEVEL_ERROR=200
# Warning log level
LOG_LEVEL_WARN=300
# Informational log level
LOG_LEVEL_INFO=500
# Debug log level
LOG_LEVEL_DEBUG=600
# Log level
LOG_LEVEL=$LOG_LEVEL_INFO

# Print log message
# @param $1 Log level
# @param $2 Message
_log_print_message() {
  log_level=${1:-LOG_LEVEL_FATAL}
  shift
  log_level_name=
  log_message=${*:-}

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
FATAL() {
  _log_print_message "$LOG_LEVEL_FATAL" "$@" >&2
  exit 1
}

# Error log message
# @param $1 Message
ERROR() { _log_print_message "$LOG_LEVEL_ERROR" "$@" >&2; }

# Warning log message
# @param $1 Message
WARN() { _log_print_message "$LOG_LEVEL_WARN" "$@" >&2; }

# Informational log message
# @param $1 Message
INFO() { _log_print_message "$LOG_LEVEL_INFO" "$@"; }

# Debug log message
# @param $1 Message
DEBUG() { _log_print_message "$LOG_LEVEL_DEBUG" "$@"; }

# ================
# ASSERT
# ================
# Assert command is installed
# @param $1 Command name
assert_cmd() {
  check_cmd "$1" || FATAL "Command '$1' not found"
  DEBUG "Command '$1' found at '$(command -v "$1")'"
}

# Assert executable downloader
assert_downloader() {
  [ -z "$DOWNLOADER" ] || return 0

  _assert_downloader() {
    # Return failure if it doesn't exist or is no executable
    [ -x "$(command -v "$1")" ] || return 1

    # Set downloader
    DOWNLOADER=$1
    return 0
  }

  # Downloader command
  _assert_downloader "curl" \
    || _assert_downloader "wget" \
    || FATAL "No executable downloader found: 'curl' or 'wget'"
  DEBUG "Downloader '$DOWNLOADER' found at '$(command -v "$DOWNLOADER")'"
}

# ================
# FUNCTIONS
# ================
# Check command is installed
# @param $1 Command name
check_cmd() {
  command -v "$1" > /dev/null 2>&1
}

# Download a file
# @param $1 Output location
# @param $2 Download URL
download() {
  assert_downloader

  # Download
  INFO "Downloading file '$2' to '$1'"
  case $DOWNLOADER in
    curl)
      curl --fail --silent --location --show-error --output "$1" "$2" || FATAL "Download file '$2' failed"
      ;;
    wget)
      wget --quiet --output-document="$1" "$2" || FATAL "Download file '$2' failed"
      ;;
    *) FATAL "Unknown downloader '$DOWNLOADER'" ;;
  esac
  DEBUG "Successfully downloaded file '$2' to '$1'"
}
