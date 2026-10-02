# CentOS Stream 10 + KDE Plasma 6 + X410/WSLg

This launcher reproduces the combination that was verified on the tested
CentOS Stream 10 installation:

```text
Plasma Shell, panel, and desktop  ->  X410 (xcb/X11)
KDE applications and windows     ->  WSLg (Wayland wayland-0)
Window management                ->  Windows DWM / WSLg
```

KDE applications therefore report `Graphics Platform: Wayland` while the
Plasma panel and desktop are presented through X410.

The launcher deliberately does not start an extra nested KWin compositor.
KWin 6.7.5 enters a restart loop in this environment: the WSLg backend lacks
a Wayland protocol required by nested KWin, while the nested X410 backend
cannot obtain a compatible compositor. Repeated `startplasma` attempts also
leave partially started systemd user units behind.

## Requirements

- CentOS Stream 10 under WSL 2.
- KDE Plasma 6 with `plasmashell` installed.
- `systemd=true` below `[boot]` in `/etc/wsl.conf`.
- X410 in Desktop mode with WSL 2 access enabled.

## Install

Run as the normal user inside the CentOS WSL distribution:

```bash
cd kde6-wayland
chmod +x install.sh
./install.sh
```

## Use

```bash
centos10-kde6 doctor
centos10-kde6 start
centos10-kde6 status
centos10-kde6 restart
centos10-kde6 stop
centos10-kde6 log
```

One `centos10-kde6 start` is enough. The launcher:

- disables SDDM so it cannot race the manual WSL session;
- repairs a root-owned `~/.local` directory when necessary;
- clears interrupted Plasma/KWin attempts;
- starts the required Plasma support services on the existing systemd user bus;
- starts only Plasma Shell in X410 and waits until it remains stable.

Do not run `startplasma` repeatedly in parallel with this launcher.

From Windows, `Start-CentOS10-KDE6.ps1` starts X410 when needed and invokes
the installed launcher. It also keeps one hidden WSL process attached so WSL
does not terminate the distribution after PowerShell exits. `-Command stop`
stops both Plasma and that keepalive process. The default distribution is
`CentOSStream-10-Alt`.

```powershell
.\Start-CentOS10-KDE6.ps1 -Command start
```

Override the distribution name when required:

```powershell
.\Start-CentOS10-KDE6.ps1 -Command start -Distro MyCentOS
```

Restore SDDM later, if needed:

```bash
sudo systemctl enable --now sddm.service
```
