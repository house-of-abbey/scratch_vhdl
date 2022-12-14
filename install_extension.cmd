@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 23 October 2022
rem 
rem ---------------------------------------------------------------------------------

title Installing Extensions
curl ^
  --silent ^
  --location ^
  --output %TEMP%/scratch-vhdl-vscode.vsix ^
  https://github.com/house-of-abbey/scratch_vhdl/releases/latest/download/scratch-vhdl-vscode.vsix

code --install-extension %TEMP%/scratch-vhdl-vscode.vsix
code --install-extension josephabbey.customasm
code --install-extension puorc.awesome-vhdl

del /f %TEMP%/scratch-vhdl-vscode.vsix
