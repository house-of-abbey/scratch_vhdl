@echo off
rem ---------------------------------------------------------------------------------
rem
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem
rem  J D Abbey & P A Abbey, 14 October 2022
rem
rem ---------------------------------------------------------------------------------

title Compiling for Modelsim

rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

rem Setup paths to local installations

if exist %SRC%\config.cmd (
  call %SRC%\config.cmd
) else (
  echo Configuration file 'config.cmd' not found. Copy and edit 'config.cmd.editme'.
  pause
  exit /b 1
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
if not exist "%MODELSIMBIN%\" (
  echo Directory '%MODELSIMBIN%' not found.
  goto error
)

rem Set the path to the compilation products
set SIM=%COMPILEDIR%\ModelSim
set DEST=%SIM%\projects\button_leds

rem Directory the batch file was run from, does not always equal SRC
set DIR=%CD%

echo Compile Source:   %SRC%\*
echo Into Destination: %DEST%
echo.

if not exist %DEST% (
  md %DEST%
)
rem vlib needs to be execute from the local directory, limited command line switches.
cd /d %DEST%
if exist work (
  echo Deleting old work directory
  %MODELSIMBIN%\vdel -modelsimini .\modelsim.ini -all
  if %ERRORLEVEL% NEQ 0 (goto error)
)

%MODELSIMBIN%\vmap unisim %SIM%\libraries\unisim
if %ERRORLEVEL% NEQ 0 (goto error)

%MODELSIMBIN%\vmap local %SIM%\libraries\local
if %ERRORLEVEL% NEQ 0 (goto error)

%MODELSIMBIN%\vlib work
if %ERRORLEVEL% NEQ 0 (goto error)

setlocal enabledelayedexpansion

set includeFiles=
set argCount=0
for %%x in (%*) do (
   set /A argCount+=1
   set includeFiles=!includeFiles! %DIR%\%%~x
)
if %argCount%==0 (
  set includeFiles=%SRC%\scratch_empty.vhdl
  echo Warning - Compiling empty 'scratch' architecture.
) else (
  type !includeFiles! > %SRC%\scratch.vhdl
)

%MODELSIMBIN%\vcom -quiet -2008 ^
  %SRC%\demos\src\risc_pkg.vhdl ^
  %SRC%\demos\src\led4_button4.vhdl ^
  !includeFiles! ^
  %SRC%\demos\src\retime.vhdl ^
  %SRC%\Zybo_Z7_10\ip\pll\pll_sim_netlist.vhdl ^
  %SRC%\Zybo_Z7_10\src\dual_seven_seg_display.vhdl ^
  %SRC%\Zybo_Z7_10\src\zybo_z7_10.vhdl ^
  %SRC%\demos\sim\test_led4_button4.vhdl ^
  %SRC%\demos\sim\stimulus_led4_button4.vhdl ^
  %SRC%\Zybo_Z7_10\sim\test_zybo_z7_10.vhdl
set ec=%ERRORLEVEL%
if %ec% NEQ 0 (goto error)

echo.
echo Compilation SUCCEEDED
echo.
echo To run the top level simulation use:
echo.
echo cd /d %DEST%
echo %MODELSIMDIR%\modelsim_ase\win32aloem\vsim -gsim_g=true work.test_zybo_z7_10
echo.

rem Do not pause inside MS Visual Studio Code, it has its own prompt on completion.
if not "%TERM_PROGRAM%"=="vscode" pause
exit /b %ec%

:error
  echo.
  echo Compilation FAILED
  if not "%TERM_PROGRAM%"=="vscode" pause
  exit /b %ERRORLEVEL%
