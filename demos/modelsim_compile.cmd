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
set VIVADODIR=D:\Xilinx\Vivado\2019.1
rem Do not call this variable MODELSIM
set MODELSIMDIR=D:\intelFPGA_lite\20.1

rem Set the path to the compilation products
set SIM=%USERPROFILE%\ModelSim
set DEST=%SIM%\projects\button_leds

rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

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
  vdel -modelsimini .\modelsim.ini -all
  if %ERRORLEVEL% NEQ 0 (exit /b %ERRORLEVEL%)
)

vmap unisim %SIM%\libraries\unisim
if %ERRORLEVEL% NEQ 0 (exit /b %ERRORLEVEL%)

vmap local %SIM%\libraries\local
if %ERRORLEVEL% NEQ 0 (exit /b %ERRORLEVEL%)

vlib work
if %ERRORLEVEL% NEQ 0 (exit /b %ERRORLEVEL%)

vlog -quiet %VIVADODIR%\data\verilog\src\glbl.v
if %ERRORLEVEL% NEQ 0 (exit /b %ERRORLEVEL%)

vcom -quiet -2008 ^
  %SRC%\test_led4_button4.vhdl ^
  %SRC%\led4_button4.vhdl ^
  %SRC%\stimulus_led4_button4.vhdl ^
  %SRC%\retime.vhdl ^
  %SRC%\zybo_z7_10.vhdl ^
  %SRC%\test_zybo_z7_10.vhdl
set ec=%ERRORLEVEL%
if %ec% NEQ 0 (exit /b %ec%)

echo.
echo cd %DEST%
echo %MODELSIMDIR%\modelsim_ase\win32aloem\vsim work.test_zybo_z7_10
echo.

rem Do not pause inside MS Visual Studio Code, it has its own prompt on completion.
if not "%TERM_PROGRAM%"=="vscode" pause
exit /b %ec%
