@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 15 October 2022
rem 
rem ---------------------------------------------------------------------------------

title Running Modelsim

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

if not defined MODELSIMDIR (
  echo Variable 'MODELSIMDIR' not set.
  goto error
)
if not defined COMPILEDIR (
  echo Variable 'COMPILEDIR' not set.
  goto error
)

if not exist "%MODELSIMDIR%\" (
  echo Directory '%MODELSIMDIR%' not found.
  goto error
)
if not exist "%COMPILEDIR%\" (
  echo Directory '%COMPILEDIR%' not found.
  goto error
)

set MODELSIMBIN=%MODELSIMDIR%\modelsim_ase\win32aloem

rem Allow a shortcut to define a command line parameter with a path to a logo file to be placed in the GUI for branding.
if not "%~1" == "" (
  set SV_LOGO=%1
)

%MODELSIMBIN%\vsim -do "source {../TCL/start_sim.tcl}"
rem This file can be reported as in use by another process when it is not, so just clean it up.
del /f %COMPILEDIR%\ModelSim\projects\button_leds\vsim.wlf transcript

exit /b %errorcode%

:error
  echo.
  echo Execution FAILED
  pause
  exit /b 1
