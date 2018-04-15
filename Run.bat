@echo off
setlocal enableDelayedExpansion

set "arg=%~1"
set "script_name=CheckClover.command"
set "thisDir=%~dp0"

REM Get python location
FOR /F "tokens=* USEBACKQ" %%F IN (`where python`) DO (
    SET "python=%%F"
)

if /i "!python!"=="" (
    echo Python is not installed...
    echo.
    echo Press [enter] to quit.
    pause > nul
    exit /b
)

REM Python found
if "!arg!"=="" (
    "!python!" "!thisDir!!script_name!"
) else (
    "!python!" "!arg!"
)

echo.
echo Press [enter] to quit...
pause > nul
