@echo off
title WifiPass Viewer

net session >nul 2>&1

:run
cd /d "%~dp0"

powershell -ExecutionPolicy Bypass -NoProfile -File "WifiPassReveal.ps1"
