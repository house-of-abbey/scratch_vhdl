@echo off

title Resetting
rem Batch file's directory where the source code is
set SRC=%~dp0
rem drop last character '\'
set SRC=%SRC:~0,-1%

cd %SRC%
git reset --hard HEAD

pause
