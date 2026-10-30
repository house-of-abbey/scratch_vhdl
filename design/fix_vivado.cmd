@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 2 July 2023
rem 
rem ---------------------------------------------------------------------------------
rem
rem Start the potentially missing processes when Vivado fails to programme the FPGA.

title Fix Vivado, check server processes are running.

if exist config.cmd (
  call config.cmd
) else (
  echo Configuration file 'config.cmd' not found. Copy and edit 'config.cmd.editme'.
  goto error
)
if not defined VIVADO_INSTALL (
  echo Variable 'VIVADO_INSTALL' not set.
  goto error
)
if not exist "%VIVADO_INSTALL%\" (
  echo Directory '%VIVADO_INSTALL%' not found.
  goto error
)

rem Hardware Server
set PROCESS_NAME=hw_server.exe
set SCRIPT_NAME="%VIVADO_INSTALL%\hw_server.bat"

:: Check if the process is running
tasklist /fi "imagename eq %PROCESS_NAME%" 2>nul | find /i "%PROCESS_NAME%" >nul

:: If errorlevel is 1, the process was NOT found
if errorlevel 1 (
  echo [Status] %PROCESS_NAME% is not running. Launching %SCRIPT_NAME%...
  start /min "HW Server" "%SCRIPT_NAME%"
) else (
  echo [Status] %PROCESS_NAME% is already running. No action taken.
)

rem Chip Scope Server
set PROCESS_NAME=cs_server.exe
set SCRIPT_NAME="%VIVADO_INSTALL%\cs_server.bat"

:: Check if the process is running
tasklist /fi "imagename eq %PROCESS_NAME%" 2>nul | find /i "%PROCESS_NAME%" >nul

:: If errorlevel is 1, the process was NOT found
if errorlevel 1 (
  echo [Status] %PROCESS_NAME% is not running. Launching %SCRIPT_NAME%...
  start /min "CS Server" "%SCRIPT_NAME%"
) else (
  echo [Status] %PROCESS_NAME% is already running. No action taken.
)

timeout /t 10
exit 0

:error
  echo.
  echo Execution FAILED
  pause
  exit /b 1
