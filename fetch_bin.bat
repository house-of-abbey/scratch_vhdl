@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 15 October 2022
rem 
rem ---------------------------------------------------------------------------------

title Fetching Binaries
rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

rem Assumes 'C:\Windows\System32' is on the PATH

if exist %SRC%\bin (
  echo Deleting old bin downloads
  pushd %SRC%\bin
  for %%F IN (customasm customasm.exe customasm.html default_text_override.js) do (
    if exist %%F ( del /f %%F )
  )
  popd
) else (
  mkdir %SRC%\bin
)

curl ^
  --silent ^
  --location ^
  --output %TEMP%\customasm.zip ^
  https://github.com/josephabbey/customasm/releases/latest/download/customasm.zip

tar ^
  -C %SRC%\bin ^
  -xf %TEMP%\customasm.zip

set ASM=%SRC%\design\demos\asm\ruledef.asm
set DEST=%SRC%\bin\default_text_override.js

echo|set /p="window.default_text_override=`" > %DEST%
powershell -Command "(Get-Content %ASM%) -replace '`', '\`' | Out-File -encoding ASCII -Append %DEST%"
echo `>> %DEST%

del /f %TEMP%\customasm.zip

echo Contents of '%SRC%\bin':
dir /b %SRC%\bin

pause
