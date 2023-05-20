@echo off
rem ---------------------------------------------------------------------------------
rem
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem
rem  J D Abbey & P A Abbey, 11 November 2022
rem
rem ---------------------------------------------------------------------------------

title Compiling Modelsim Libraries

rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

rem Setup paths to local installations
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

rem Fix the PATH variable for when compiling Scratch VHDL from an external drive
rem Put ModelSim's vcom etc. on the PATH
set PATH=%PATH%;%MODELSIMDIR%\modelsim_ase\win32aloem
rem Fake the location of this directory for when we're not compiling to the assumed location
set USERPROFILE=%COMPILEDIR%
call F:\scratch_vhdl\fpga\VHDL\Local\modelsim_compile.cmd
exit /b %errorcode%

:error
  echo.
  echo Compilation FAILED
  exit /b 1
