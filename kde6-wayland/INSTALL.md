# Final step: CentOS Stream 10 + KDE Plasma 6 + X410

This guide installs the launcher that starts KDE Plasma 6 reliably with X410
under WSL 2.

> [!IMPORTANT]
> This is the final setup step. CentOS Stream 10, KDE Plasma 6, EPEL, WSL 2,
> systemd, and X410 must already be installed.

## Before you begin

Make sure that:

- CentOS Stream 10 is running under WSL 2.
- KDE Plasma 6 and `plasmashell` are installed.
- EPEL is enabled in CentOS.
- `/etc/wsl.conf` contains `systemd=true` under `[boot]`.
- X410 is installed in Windows 11.

For the first launch, start X410 once from the Windows Start menu. This lets
the launcher locate X410 even when `x410.exe` is not available through the
Windows command path. The launcher will then select the correct X410 mode.

## Easy installation

### 1. Download the project

Open PowerShell and run:

```powershell
cd "$HOME\Downloads"
git clone https://github.com/vinberg88/centos.git
cd "$HOME\Downloads\centos\kde6-wayland"
```

The project will be downloaded to your own Windows profile. You do not need to
replace a username in any of the commands in this guide.

### 2. Install with a double-click

Open this folder in File Explorer:

```text
Downloads\centos\kde6-wayland
```

Double-click:

```text
Install-CentOS10-KDE6.cmd
```

Enter your CentOS password if the installer asks for it. The installer creates
a shortcut named **CentOS 10 KDE 6** on the Windows desktop.

### 3. Start KDE with a double-click

Double-click **CentOS 10 KDE 6** on the Windows desktop. The shortcut starts
X410 in the correct mode and then starts the complete KDE desktop.

That is all you need for normal use.

> [!TIP]
> You can also double-click `Start-CentOS10-KDE6.cmd` directly inside the
> downloaded `kde6-wayland` folder.

## Manual installation from PowerShell

Use these instructions if the double-click installer cannot find your CentOS
distribution or if you want to see every command.

### Install the launcher

Continue in the same PowerShell window:

```powershell
wsl.exe -d CentOSStream-10-Alt `
  --cd "$HOME\Downloads\centos\kde6-wayland" `
  -- bash ./install.sh
```

Enter your CentOS password if the installer asks for it. The installer runs as
your normal CentOS user, not as `root`.

If your distribution has a different name, find the exact name with:

```powershell
wsl --list --verbose
```

Then replace `CentOSStream-10-Alt` in the commands with that name.

The installer:

- installs the small IceWM dependency when needed;
- installs `centos10-kde6` in `~/bin`;
- enables movable and resizable windows in Full Desktop mode; and
- applies the CentOS 10 workaround that keeps KDE System Settings working.

### Start KDE Plasma 6

From the same PowerShell directory, run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Start-CentOS10-KDE6.ps1 `
  -Command start `
  -Mode Desktop
```

The launcher starts X410 in Floating Desktop mode and then starts the complete
KDE desktop, including the Plasma wallpaper and panel. WSLg continues to
provide audio.

One start command is enough. Do not run `startplasma` at the same time.

## Start KDE next time

Normally, just double-click **CentOS 10 KDE 6** on the Windows desktop.

You can also open PowerShell and run:

```powershell
cd "$HOME\Downloads\centos\kde6-wayland"
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Start-CentOS10-KDE6.ps1
```

`Desktop` is the default mode, so no additional options are required.

## Start from the CentOS terminal

If X410 is already running in Floating Desktop mode, you can start KDE from a
CentOS terminal instead:

```bash
centos10-kde6 start desktop
```

Do not set `DISPLAY` manually. The launcher detects the Windows/X410 address
automatically.

## Useful commands

Run these commands in a CentOS terminal:

```bash
centos10-kde6 status
centos10-kde6 doctor desktop
centos10-kde6 restart desktop
centos10-kde6 stop
centos10-kde6 log
```

## Update to the latest version

Run in PowerShell:

```powershell
cd "$HOME\Downloads\centos"
git pull
```

Run the installer again so the updated Linux launcher is copied to `~/bin`:

```powershell
wsl.exe -d CentOSStream-10-Alt `
  --cd "$HOME\Downloads\centos\kde6-wayland" `
  -- bash ./install.sh
```

Then restart KDE:

```powershell
cd "$HOME\Downloads\centos\kde6-wayland"
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Start-CentOS10-KDE6.ps1 `
  -Command restart `
  -Mode Desktop
```

## Optional: Seamless mode

Seamless mode displays KDE applications over the Windows desktop instead of
showing the complete KDE desktop in a separate X410 window:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\Start-CentOS10-KDE6.ps1 `
  -Command restart `
  -Mode Seamless
```

Enable **Re-parenting window manager** in X410 Settings when using Seamless
mode.
