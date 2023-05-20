@echo off
rem Install The Canble Driver for Xilinx
rem NB. Run as  Administrator
rem
rem https://docs.xilinx.com/r/en-US/ug973-vivado-release-notes-install-license/Install-Cable-Drivers

title Installing Cable Drivers

rem Setup paths to local installations
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
if not defined VIVADO_INSTALL (
  echo Variable 'VIVADO_INSTALL' not set.
  goto error
)
set VIVADO_INSTALL_DIR=%VIVADO_INSTALL%\..


pushd %VIVADO_INSTALL_DIR%\data\xicom\cable_drivers\nt64
call install_drivers.cmd -log_filename /driver_install.log
set EC=%errorlevel%
popd

pause
exit /b %EC%

:error
  popd
  echo.
  echo Installation FAILED
  pause
  exit /b 1
