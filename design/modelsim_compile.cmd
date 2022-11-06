@echo off
rem ---------------------------------------------------------------------------------
rem
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem
rem  J D Abbey & P A Abbey, 14 October 2022
rem
rem ---------------------------------------------------------------------------------

rem Setup paths to local installations
rem
rem Do not call this variable MODELSIM
set MODELSIMDIR=D:\intelFPGA_lite\20.1
set MODELSIMBIN=%MODELSIMDIR%\modelsim_ase\win32aloem

rem Set the path to the compilation products
set SIM=%USERPROFILE%\ModelSim
set DEST=%SIM%\projects\button_leds

rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

rem Directory the batch file was run from, does not always equal SRC
set DIR=%CD%

title Compiling for Modelsim

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
for %%x in (%*) do (
   set includeFiles=!includeFiles! %DIR%\%%~x
)
if [%1] NEQ [] (type !includeFiles! > %SRC%\scratch.vhdl)

%MODELSIMBIN%\vcom -quiet -2008 ^
  %SRC%\demos\src\risc_pkg.vhdl ^
  %SRC%\demos\src\led4_button4.vhdl ^
  %SRC%\demos\src\retime.vhdl ^
  %SRC%\Zybo_Z7_10\ip\pll\pll_sim_netlist.vhdl ^
  %SRC%\Zybo_Z7_10\src\zybo_z7_10.vhdl ^
  %SRC%\demos\sim\test_led4_button4.vhdl ^
  %SRC%\demos\sim\stimulus_led4_button4.vhdl ^
  %SRC%\Zybo_Z7_10\sim\test_zybo_z7_10.vhdl ^
  !includeFiles!
set ec=%ERRORLEVEL%
if %ec% NEQ 0 (goto error)

rem Assemble each file in %SRC%\demos\asm\*.asm
mkdir %DEST%\instr_files
for /f "tokens=*" %%G in ('dir /b %SRC%\demos\asm\*.asm') do (
  echo.
  echo Assembling %%G:
  %SRC%\..\bin\customasm ^
    --format=binline ^
    --output=%DEST%\instr_files\%%~nG.txt ^
    %SRC%\demos\asm\%%G
  if %ec% NEQ 0 (goto error)
  echo.
)

echo.
echo Compilation SUCCEEDED
echo.
echo To run the top level simulation use:
echo.
echo cd %DEST%
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
