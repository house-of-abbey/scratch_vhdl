@echo off
rem ---------------------------------------------------------------------------------
rem
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem
rem  J D Abbey & P A Abbey, 11 November 2022
rem
rem ---------------------------------------------------------------------------------

title Compiling Assembly Files

rem Set the path to the compilation products
set SIM=%USERPROFILE%\ModelSim
set DEST=%SIM%\projects\button_leds

rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

if not exist %DEST%\instr_files (
  md %DEST%\instr_files
  if %ERRORLEVEL% NEQ 0 (goto error)
)

setlocal enabledelayedexpansion
rem Compile the user's own instruction file.

echo Assembling instructions.asm:
%SRC%\..\bin\customasm ^
 --format=binline ^
 --output=%DEST%\instr_files\instructions.o ^
 %SRC%\instructions.asm
set ec=%ERRORLEVEL%
echo.
if !ec! NEQ 0 (goto error)

rem Assemble each file in %SRC%\demos\asm\*.asm

for /f "tokens=*" %%G in ('dir /b %SRC%\demos\asm\*.asm ^| findstr /v ruledef.asm') do (
  echo Assembling %%G:

   %SRC%\..\bin\customasm ^
     --format=binline ^
     --output=%DEST%\instr_files\%%~nG.o ^
     %SRC%\demos\asm\%%G
   set ec=%ERRORLEVEL%
   echo.
   if !ec! NEQ 0 (goto error)
)

echo.
echo Compilation SUCCEEDED
echo.

rem Do not pause inside MS Visual Studio Code, it has its own prompt on completion.
if not "%TERM_PROGRAM%"=="vscode" pause
exit /b %ec%

:error
  echo.
  echo Compilation FAILED
  if not "%TERM_PROGRAM%"=="vscode" pause
  exit /b %ERRORLEVEL%
