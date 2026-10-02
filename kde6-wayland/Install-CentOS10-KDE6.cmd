@echo off
setlocal
title Install CentOS 10 KDE 6

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-CentOS10-KDE6.ps1" %*
if errorlevel 1 (
    echo.
    echo Installation failed. Read the error above, then press any key to close.
    pause >nul
    exit /b 1
)

echo.
echo Installation finished. Press any key to close.
pause >nul
