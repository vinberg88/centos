@echo off
setlocal
title Start CentOS 10 KDE 6

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-CentOS10-KDE6.ps1" -Command start -Mode Desktop %*
if errorlevel 1 (
    echo.
    echo KDE could not start. Read the error above, then press any key to close.
    pause >nul
    exit /b 1
)
