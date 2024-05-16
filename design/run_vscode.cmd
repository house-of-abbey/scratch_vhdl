@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 2 July 2023
rem 
rem ---------------------------------------------------------------------------------

title Running VSCode

rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

if exist %SRC%\config.cmd (
  call %SRC%\config.cmd
) else (
  echo Configuration file 'config.cmd' not found. Copy and edit 'config.cmd.editme'.
  goto error
)

if not defined SCRATCH_SRC (
  echo Variable 'SCRATCH_SRC' not set.
  goto error
)
if not defined VSCODE_INSTALL (
  echo Variable 'VSCODE_INSTALL' not set.
  goto error
)

if not exist "%SCRATCH_SRC%\" (
  echo Directory '%SCRATCH_SRC%' not found.
  goto error
)
if not exist "%VSCODE_INSTALL%\" (
  echo Directory '%VSCODE_INSTALL%' not found.
  goto error
)

set PATH=%SCRATCH_SRC%\..\bin;%PATH%

"%VSCODE_INSTALL%\Code.exe" "%SCRATCH_SRC%\..\scratch_vhdl.code-workspace"

exit /b %errorcode%

:error
  echo.
  echo Execution FAILED
  pause
  exit /b 1
