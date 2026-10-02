[CmdletBinding()]
param(
    [ValidateSet('start', 'stop', 'restart', 'status', 'doctor', 'log')]
    [string]$Command = 'start',
    [ValidateSet('Desktop', 'Seamless')]
    [string]$Mode = 'Desktop',
    [string]$Distro = ''
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
        throw 'Ingen CentOS Stream 10-distribution hittades. Ange den med -Distro "DittDistroNamn".'
    }
}

$stateDirectory = Join-Path $env:LOCALAPPDATA 'CentOS10-KDE6'
$keepalivePidFile = Join-Path $stateDirectory 'wsl-keepalive.pid'

function Get-KeepaliveProcess {
    if (-not (Test-Path -LiteralPath $keepalivePidFile)) {
        return $null
    }

    $savedPid = [int](Get-Content -LiteralPath $keepalivePidFile -Raw)
    $process = Get-Process -Id $savedPid -ErrorAction SilentlyContinue
    if (-not $process) {
        Remove-Item -LiteralPath $keepalivePidFile -Force -ErrorAction SilentlyContinue
    }
    return $process
}

if ($Command -in @('start', 'restart')) {
    $x410 = @(Get-Process -Name 'X410' -ErrorAction SilentlyContinue)
    $x410Command = Get-Command 'x410.exe' -ErrorAction SilentlyContinue
    $x410Path = if ($x410Command) {
        $x410Command.Source
    }
    elseif ($x410.Count -gt 0 -and $x410[0].Path) {
        $x410[0].Path
    }
    else {
        $null
    }

    if (-not $x410Path) {
        throw 'X410 hittades inte. Installera eller starta X410 och kör skriptet igen.'
    }

    $x410Mode = if ($Mode -eq 'Desktop') { '/desktop' } else { '/wm' }
    $modeLabel = if ($Mode -eq 'Desktop') { 'Floating Desktop' } else { 'Windowed Apps' }

    # X410 restarts itself automatically when changing server mode.
    Write-Host "[INFO] Säkerställer X410 $modeLabel-läge ..." -ForegroundColor Cyan
    Start-Process -FilePath $x410Path -ArgumentList $x410Mode -WindowStyle Hidden
    Start-Sleep -Seconds 3

    if (-not (Get-KeepaliveProcess)) {
        New-Item -ItemType Directory -Force -Path $stateDirectory | Out-Null
        $keepalive = Start-Process -FilePath 'wsl.exe' `
            -ArgumentList @('-d', $Distro, '--', 'sleep', 'infinity') `
            -WindowStyle Hidden -PassThru
        Set-Content -LiteralPath $keepalivePidFile -Value $keepalive.Id
        Start-Sleep -Seconds 1
    }
}

$linuxCommand = '"$HOME/bin/centos10-kde6" ' + $Command + ' ' + $Mode.ToLowerInvariant()
& wsl.exe -d $Distro -- bash -lc $linuxCommand
if ($LASTEXITCODE -ne 0) {
    throw "centos10-kde6 avslutades med kod $LASTEXITCODE."
}

if ($Command -eq 'stop') {
    $keepalive = Get-KeepaliveProcess
    if ($keepalive) {
        Stop-Process -Id $keepalive.Id -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $keepalivePidFile -Force -ErrorAction SilentlyContinue
    }
}
