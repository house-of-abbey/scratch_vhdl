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

rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

if exist %SRC%\config.cmd (
  call %SRC%\config.cmd
) else (
  echo Configuration file 'config.cmd' not found. Copy and edit 'config.cmd.editme'.
  pause
  exit /b 1
)

if not defined COMPILEDIR (
  echo Variable 'COMPILEDIR' not set.
  goto error
)
if not exist "%COMPILEDIR%\" (
  echo Directory '%COMPILEDIR%' not found.
  goto error
)

rem Set the path to the compilation products
set SIM=%COMPILEDIR%\ModelSim
set DEST=%SIM%\projects\button_leds

if not exist %DEST%\instr_files (
  md %DEST%\instr_files
  if %ERRORLEVEL% NEQ 0 (goto error)
)

rem required for 'set ec' assignment to work
setlocal enabledelayedexpansion
rem Test we have specified a file to compile
if "%1" == "" (
  echo.
  echo No file specified, compiling all files.
  echo.

  rem Compile the user's own instruction file. Must be compiled from the current directory as
  rem a relative include path is used.
  echo Assembling instructions.asm:
  %SRC%\..\bin\customasm ^
    --format=binline ^
    --output=%DEST%\instr_files\instructions.o ^
    %SRC%\instructions.asm
  set ec=!ERRORLEVEL!
  if !ec! NEQ 0 (goto error)
  echo.

  rem Assemble each file in %SRC%\demos\asm\*.asm
  for /f "tokens=*" %%G in ('dir /b %SRC%\demos\asm\*.asm ^| findstr /v ruledef.asm') do (
    echo Assembling %%G:

    %SRC%\..\bin\customasm ^
      --format=binline ^
      --output=%DEST%\instr_files\%%~nG.o ^
      %SRC%\demos\asm\%%G
    set ec=!ERRORLEVEL!
    if !ec! NEQ 0 (goto error)
    echo.
  )
) else (
  rem Executing inside VS Code, need to redirect stderr to stdout for Javascript parsing.
  echo.
  echo Assembling %1:

  set fn=%~n1
  %SRC%\..\bin\customasm ^
    --format=binline ^
    --output=%DEST%\instr_files\!fn!.o ^
    %1 2>&1
  set ec=!ERRORLEVEL!
  if !ec! NEQ 0 (goto error)
)

echo.
echo Compilation SUCCEEDED
echo.
rem Do not pause inside MS Visual Studio Code, it has its own prompt on completion.
if defined VSCODE_PID (
  exit /b 0
) else (
  pause
  exit /b !ec!
)

:error
  echo.
  echo Compilation FAILED
  echo.
  if defined VSCODE_PID (
    exit /b 0
  ) else (
    pause
    exit /b !ec!
  )
