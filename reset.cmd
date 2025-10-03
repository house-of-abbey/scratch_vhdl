@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 23 September 2025
rem 
rem ---------------------------------------------------------------------------------

title Resetting

echo You are about to delete design work
pause

if exist ./design/config.cmd (
  call ./design/config.cmd
) else (
  echo Configuration file 'config.cmd' not found. Copy and edit 'config.cmd.editme'.
  goto error
)
if not defined VIVADO_INSTALL (
  echo Variable 'VIVADO_INSTALL' not set.
  goto error
)
if not defined SCRATCH_SRC (
  echo Variable 'SCRATCH_SRC' not set.
  goto error
)
if not exist "%VIVADO_INSTALL%\" (
  echo Directory '%VIVADO_INSTALL%' not found.
  goto error
)
if not exist "%SCRATCH_SRC%\" (
  echo Directory '%SCRATCH_SRC%' not found.
  goto error
)

cd %SCRATCH_SRC%
git reset --hard HEAD
git pull

call %VIVADO_INSTALL%\vivado.bat ^
  -mode gui ^
  -tempDir %TEMP% ^
  -nojournal ^
  -nolog ^
  -notrace ^
  -source "..\TCL\vivado_reset.tcl"

rem Clean up junk
del /Q /F vivado_pid*.str hs_err_pid*.dmp hs_err_pid*.log
exit /b 0

:error
  echo.
  echo Execution FAILED
  pause
  exit /b 1


pause
