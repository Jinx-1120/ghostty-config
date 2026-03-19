#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./sync-ghostty-config.sh [apply]
  ./sync-ghostty-config.sh pull
  ./sync-ghostty-config.sh doctor

Commands:
  apply   Copy the repository config to the local Ghostty config path. Default.
  pull    Copy the local Ghostty config back into this repository.
  doctor  Print detected paths and install status.
EOF
}

die() {
  printf '%s\n' "$1" >&2
  exit 1
}

timestamp() {
  date '+%Y%m%d-%H%M%S'
}

ghostty_detected() {
  if command -v ghostty >/dev/null 2>&1; then
    return 0
  fi

  if [ -d "/Applications/Ghostty.app" ] || [ -d "$HOME/Applications/Ghostty.app" ]; then
    return 0
  fi

  return 1
}

backup_file() {
  local source_file="$1"
  local backup_label="$2"
  local backup_file_path

  mkdir -p "$BACKUP_DIR"
  backup_file_path="$BACKUP_DIR/${backup_label}-$(timestamp).bak"
  cp "$source_file" "$backup_file_path"
  printf 'Backed up %s to %s\n' "$backup_label" "$backup_file_path"
}

ensure_supported_os() {
  case "$(uname -s)" in
    Darwin|Linux)
      ;;
    *)
      die "Unsupported OS. This script supports macOS and Linux only."
      ;;
  esac
}

sync_apply() {
  [ -f "$REPO_CONFIG" ] || die "Repository config not found: $REPO_CONFIG"

  mkdir -p "$TARGET_DIR"

  if [ -f "$TARGET_CONFIG" ] && cmp -s "$REPO_CONFIG" "$TARGET_CONFIG"; then
    printf 'Ghostty config is already up to date at %s\n' "$TARGET_CONFIG"
    return 0
  fi

  if [ -f "$TARGET_CONFIG" ]; then
    backup_file "$TARGET_CONFIG" "ghostty-config"
  fi

  cp "$REPO_CONFIG" "$TARGET_CONFIG"
  printf 'Applied repository config to %s\n' "$TARGET_CONFIG"

  if ghostty_detected; then
    printf 'Ghostty installation detected.\n'
  else
    printf 'Ghostty installation was not detected. Config has been staged for first launch.\n'
  fi
}

sync_pull() {
  [ -f "$TARGET_CONFIG" ] || die "Local Ghostty config not found: $TARGET_CONFIG"

  if [ -f "$REPO_CONFIG" ] && cmp -s "$TARGET_CONFIG" "$REPO_CONFIG"; then
    printf 'Repository config is already up to date.\n'
    return 0
  fi

  if [ -f "$REPO_CONFIG" ]; then
    backup_file "$REPO_CONFIG" "repo-config"
  fi

  cp "$TARGET_CONFIG" "$REPO_CONFIG"
  printf 'Pulled local Ghostty config into %s\n' "$REPO_CONFIG"
}

doctor() {
  local install_status="not detected"

  if ghostty_detected; then
    install_status="detected"
  fi

  cat <<EOF
OS: $(uname -s)
Script directory: $SCRIPT_DIR
Repository config: $REPO_CONFIG
Ghostty config directory: $TARGET_DIR
Ghostty config file: $TARGET_CONFIG
Backup directory: $BACKUP_DIR
Ghostty install status: $install_status
EOF
}

ensure_supported_os

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG="$SCRIPT_DIR/config"
BACKUP_DIR="$SCRIPT_DIR/.backup"
CONFIG_HOME="${GHOSTTY_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}"
TARGET_DIR="$CONFIG_HOME/ghostty"
TARGET_CONFIG="$TARGET_DIR/config"
COMMAND="${1:-apply}"

case "$COMMAND" in
  apply)
    sync_apply
    ;;
  pull)
    sync_pull
    ;;
  doctor)
    doctor
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
