@echo off
title WifiPass Viewer

net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run
) else (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

:run
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -NoProfile -File "WifiPassReveal.ps1"
