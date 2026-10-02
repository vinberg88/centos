# CentOS Stream 10 + KDE Plasma 6 + X410

Version 0.2 provides two tested X410 modes. Both run Plasma and KDE programs
through X11/xcb. WSLg supplies PulseAudio and remains available for separately
launched Wayland applications.

## Full Desktop mode (default)

```text
Plasma desktop, wallpaper, and panel  -> X410 Floating Desktop (/desktop)
KDE applications                     -> X410/X11
Window management                    -> IceWM, with its taskbar hidden
Audio                                -> WSLg PulseAudio
```

IceWM only supplies movement, resizing, and decorations inside the X410
desktop. Plasma still owns the wallpaper, desktop widgets, application menu,
and panel. This mode does not replace the Windows desktop; X410 presents the
complete KDE desktop in its own resizable or maximized window.

## Seamless mode

```text
Plasma panel and KDE applications -> X410 Windowed Apps (/wm)
Window management                 -> X410 / Windows
Background and desktop icons      -> Windows
Audio                             -> WSLg PulseAudio
```

Enable `Re-parenting window manager` in X410 Settings for movable and
resizable windows in Seamless mode.

The launcher deliberately does not start KWin Wayland. KWin 6.7.5 enters a
restart loop in this environment, and CentOS Stream 10's current `kwin_x11`
package conflicts with the installed Plasma 6.7.5 packages. Repeated
`startplasma` attempts can also leave partially started systemd user units
behind.

## Requirements

- CentOS Stream 10 under WSL 2.
- KDE Plasma 6 with `plasmashell` installed.
- `systemd=true` below `[boot]` in `/etc/wsl.conf`.
- X410 with WSL 2 access enabled.
- EPEL enabled so the installer can install the small `icewm` dependency.

## Install

Run as the normal user inside the CentOS WSL distribution:

```bash
cd kde6-wayland
chmod +x install.sh
./install.sh
```

The installer installs IceWM when needed and copies the launcher to
`~/bin/centos10-kde6`. It also moves the mouse and touchpad System Settings
plugins to a reversible backup directory. CentOS Plasma 6.7.5 builds those
two modules without an X11 backend; loading them under X410 otherwise crashes
the complete System Settings application. WSL has no Linux touchpad to
configure, and all other settings modules remain available.

Restore the two modules when needed:

```bash
sudo mv /usr/lib64/qt6/plugins/plasma/kcms/disabled-centos10-kde6/*.so \
  /usr/lib64/qt6/plugins/plasma/kcms/systemsettings/
```

## Use from Windows

Full Desktop with KDE wallpaper is the default:

```powershell
.\Start-CentOS10-KDE6.ps1 -Command start -Mode Desktop
```

Switch to KDE windows over the Windows desktop:

```powershell
.\Start-CentOS10-KDE6.ps1 -Command restart -Mode Seamless
```

The PowerShell launcher selects the matching X410 server mode and keeps one
hidden WSL process attached so the distribution does not stop when PowerShell
exits. The default distribution is `CentOSStream-10-Alt`; override it with
`-Distro MyCentOS`.

## Use inside WSL

```bash
centos10-kde6 doctor desktop
centos10-kde6 start desktop
centos10-kde6 restart seamless
centos10-kde6 status
centos10-kde6 stop
centos10-kde6 log
```

One start command is enough. Do not run `startplasma` in parallel with this
launcher.

Restore SDDM later, if needed:

```bash
sudo systemctl enable --now sddm.service
```

See X410's documentation for the difference between
[Windowed Apps and Floating Desktop](https://x410.dev/cookbook/).
