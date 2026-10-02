#!/usr/bin/env bash

set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
    printf 'Run this installer as your normal WSL user, not with sudo.\n' >&2
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/bin"
TARGET="$TARGET_DIR/centos10-kde6"

mkdir -p "$TARGET_DIR"
install -m 0755 "$SCRIPT_DIR/centos10-kde6" "$TARGET"

printf '\nInstalled: %s\n\n' "$TARGET"
printf 'Start X410 in Desktop mode, then run:\n'
printf '  centos10-kde6 doctor\n'
printf '  centos10-kde6 start\n\n'
printf 'Other commands: stop, restart, status, log\n'
