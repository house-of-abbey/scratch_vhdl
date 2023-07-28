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

set PATH=%PATH%;F:\scratch_vhdl\bin

if exist %SRC%\config.cmd (
  call %SRC%\config.cmd
) else (
  echo Configuration file 'config.cmd' not found. Copy and edit 'config.cmd.editme'.
  pause
  exit /b 1
)

if not defined SCRATCH_SRC (
  echo Variable 'SCRATCH_SRC' not set.
  goto error
)

if not defined DRIVE (
  echo Variable 'DRIVE' not set.
  goto error
)


"%DRIVE%\Microsoft VS Code\Code.exe" "%SCRATCH_SRC%\..\scratch_vhdl.code-workspace"

exit /b %errorcode%

:error
  echo.
  echo Execution FAILED
  exit /b 1
