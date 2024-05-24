@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 23 October 2022
rem 
rem Install required extensions for Microsoft's VSCode
rem
rem ---------------------------------------------------------------------------------

title Installing Extensions

rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

if exist %SRC%\design\config.cmd (
  call %SRC%\design\config.cmd
) else (
  echo Configuration file 'config.cmd' not found. Copy and edit 'config.cmd.editme'.
  goto error
)

if not defined VSCODE_INSTALL (
  echo Variable 'VSCODE_INSTALL' not set.
  goto error
)
if not exist "%VSCODE_INSTALL%\" (
  echo Directory '%VSCODE_INSTALL%' not found.
  goto error
)

curl ^
  --silent ^
  --location ^
  --output %TEMP%\scratch-vhdl-vscode.vsix ^
  https://github.com/house-of-abbey/scratch_vhdl/releases/latest/download/scratch-vhdl-vscode.vsix

set PATH=%VSCODE_INSTALL%;%PATH%

call "%VSCODE_INSTALL%\code" ^
  --install-extension %TEMP%\scratch-vhdl-vscode.vsix ^
  --install-extension hlorenzi.customasm-vscode ^
  --install-extension rjyoung.vscode-modern-vhdl-support ^
  --install-extension JosephAbbey.customasm

pause

rem Delete this after code is closed
del /f %TEMP%\scratch-vhdl-vscode.vsix
