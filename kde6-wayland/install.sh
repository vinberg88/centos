#!/usr/bin/env bash

set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
    printf 'Run this installer as your normal WSL user, not with sudo.\n' >&2
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/bin"
TARGET="$TARGET_DIR/centos10-kde6"
KCM_DIR="/usr/lib64/qt6/plugins/plasma/kcms/systemsettings"
KCM_BACKUP_DIR="/usr/lib64/qt6/plugins/plasma/kcms/disabled-centos10-kde6"

if ! command -v icewm >/dev/null 2>&1; then
    printf 'Installing the lightweight window manager required by Full Desktop mode...\n'
    DNF_ARGS=(-y --setopt=install_weak_deps=False)
    if dnf repolist --enabled 2>/dev/null | awk '{print $1}' | grep -qx terra; then
        DNF_ARGS+=(--disablerepo=terra)
    fi
    sudo dnf "${DNF_ARGS[@]}" install icewm
fi

# CentOS Plasma 6.7.5 builds these two KCMs without an X11 backend. Both return
# a null backend under X410 and crash the System Settings landing page. WSL has
# no Linux touchpad to configure, so keep a reversible backup outside the Qt
# plugin directory and let every other settings module remain available.
sudo install -d -m 0755 "$KCM_BACKUP_DIR"
for kcm_name in kcm_mouse.so kcm_touchpad.so; do
    if [[ -f "$KCM_DIR/$kcm_name" ]]; then
        sudo mv -f -- "$KCM_DIR/$kcm_name" "$KCM_BACKUP_DIR/$kcm_name"
    fi
done

# Remove the short-lived 0.2 development override if this installer created it.
user_settings_entry="$HOME/.local/share/applications/systemsettings.desktop"
if [[ -f "$user_settings_entry" ]] &&
   grep -qx 'Exec=systemsettings kcm_about-distro' "$user_settings_entry"; then
    rm -f -- "$user_settings_entry"
fi

mkdir -p "$TARGET_DIR"
install -m 0755 "$SCRIPT_DIR/centos10-kde6" "$TARGET"
if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

printf '\nInstalled: %s\n\n' "$TARGET"
printf 'Full Desktop with KDE background (default):\n'
printf '  centos10-kde6 doctor desktop\n'
printf '  centos10-kde6 start desktop\n\n'
printf 'Seamless KDE over the Windows desktop:\n'
printf '  centos10-kde6 start seamless\n\n'
printf 'KDE System Settings: WSL-incompatible mouse/touchpad modules disabled\n'
printf '  backup: %s\n' "$KCM_BACKUP_DIR"
printf 'Other commands: stop, restart, status, log\n'
