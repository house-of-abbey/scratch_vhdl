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

if not defined SCRATCH_SRC (
  echo Variable 'SCRATCH_SRC' not set.
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

if not exist "%SCRATCH_SRC%\" (
  echo Directory '%SCRATCH_SRC%' not found.
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

rem Fix the PATH variable for when compiling Scratch VHDL from an external drive
rem Put ModelSim's vcom etc. on the PATH
set PATH=%PATH%;%MODELSIMDIR%\modelsim_ase\win32aloem
rem Fake the location of this directory for when we're not compiling to the assumed location
set USERPROFILE=%COMPILEDIR%
pushd
echo y | call "%SCRATCH_SRC%\..\fpga\VHDL\Local\modelsim_compile.cmd"
popd
pause
exit /b %errorcode%

:error
  echo.
  echo Compilation FAILED
  pause
  exit /b 1
