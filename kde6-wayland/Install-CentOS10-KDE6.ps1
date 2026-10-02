[CmdletBinding()]
param(
    [string]$Distro = '',
    [switch]$NoDesktopShortcut
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Distro)) {
    $installedDistros = @(
        & wsl.exe --list --quiet |
            ForEach-Object { ($_ -replace "`0", '').Trim() } |
            Where-Object { $_ }
    )
    $Distro = $installedDistros |
        Where-Object { $_ -eq 'CentOSStream-10-Alt' } |
        Select-Object -First 1
    if (-not $Distro) {
        $Distro = $installedDistros |
            Where-Object { $_ -match '(?i)centos.*10|10.*centos' } |
            Select-Object -First 1
    }
    if (-not $Distro) {
        throw 'No CentOS Stream 10 distribution was found. Run again with -Distro "YourDistroName".'
    }
}

$projectDirectory = Split-Path -Parent $PSCommandPath
$linuxInstaller = Join-Path $projectDirectory 'install.sh'
$windowsStarter = Join-Path $projectDirectory 'Start-CentOS10-KDE6.cmd'

if (-not (Test-Path -LiteralPath $linuxInstaller)) {
    throw "install.sh was not found in $projectDirectory"
}

Write-Host "[INFO] Installing the CentOS 10 KDE 6 launcher in $Distro ..." -ForegroundColor Cyan
& wsl.exe -d $Distro --cd $projectDirectory -- bash ./install.sh
if ($LASTEXITCODE -ne 0) {
    throw "The Linux installer exited with code $LASTEXITCODE."
}

if (-not $NoDesktopShortcut) {
    $desktopDirectory = [Environment]::GetFolderPath('Desktop')
    $shortcutPath = Join-Path $desktopDirectory 'CentOS 10 KDE 6.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $windowsStarter
    $shortcut.Arguments = "-Distro `"$Distro`""
    $shortcut.WorkingDirectory = $projectDirectory
    $shortcut.Description = 'Start CentOS Stream 10 with KDE Plasma 6 in X410'
    $shortcut.Save()
    Write-Host "[OK] Desktop shortcut created: $shortcutPath" -ForegroundColor Green
}

Write-Host ''
Write-Host '[OK] Installation complete.' -ForegroundColor Green
Write-Host 'Start KDE by double-clicking "CentOS 10 KDE 6" on the Windows desktop.'
