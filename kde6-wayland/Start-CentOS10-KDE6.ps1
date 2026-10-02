[CmdletBinding()]
param(
    [ValidateSet('start', 'stop', 'restart', 'status', 'doctor', 'log')]
    [string]$Command = 'start',
    [string]$Distro = 'CentOSStream-10-Alt'
)

$ErrorActionPreference = 'Stop'
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
    $x410 = Get-Process -Name 'X410' -ErrorAction SilentlyContinue
    if (-not $x410) {
        $x410Command = Get-Command 'x410.exe' -ErrorAction SilentlyContinue
        if (-not $x410Command) {
            throw 'X410 hittades inte. Starta X410 i Desktop-läge och kör skriptet igen.'
        }

        Write-Host '[INFO] Startar X410 i Desktop-läge ...' -ForegroundColor Cyan
        Start-Process -FilePath $x410Command.Source -ArgumentList '/desktop' -WindowStyle Hidden
        Start-Sleep -Seconds 3
    }

    if (-not (Get-KeepaliveProcess)) {
        New-Item -ItemType Directory -Force -Path $stateDirectory | Out-Null
        $keepalive = Start-Process -FilePath 'wsl.exe' `
            -ArgumentList @('-d', $Distro, '--', 'sleep', 'infinity') `
            -WindowStyle Hidden -PassThru
        Set-Content -LiteralPath $keepalivePidFile -Value $keepalive.Id
        Start-Sleep -Seconds 1
    }
}

$linuxCommand = '"$HOME/bin/centos10-kde6" ' + $Command
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
