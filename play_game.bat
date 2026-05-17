@echo off
setlocal

cd /d "%~dp0"
set "PROJECT_DIR=%CD%"

set "GODOT="

for /f "delims=" %%G in ('where godot.exe 2^>nul') do (
    if not defined GODOT set "GODOT=%%G"
)

if not defined GODOT (
    set "GODOT=C:\Users\Admin\AppData\Local\Microsoft\WinGet\Links\godot.exe"
)

if not exist "%GODOT%" (
    echo Godot was not found.
    echo Please open Godot manually and import:
    echo %~dp0project.godot
    pause
    exit /b 1
)

echo Starting Adventurer Village Prototype...
echo Project: %PROJECT_DIR%\project.godot
echo.

"%GODOT%" --path "%PROJECT_DIR%" --scene "res://scenes/main.tscn"

if errorlevel 1 (
    echo.
    echo Godot exited with an error. Please copy the message above if you need help.
    pause
)
