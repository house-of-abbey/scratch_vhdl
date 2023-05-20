@echo off
rem Fix the PATH variable for the Scratch VHDL external drive

rem Setup paths to local installations
if exist config.cmd (
  call config.cmd
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
