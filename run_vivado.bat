@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 27 October 2022
rem 
rem ---------------------------------------------------------------------------------

title Running Vivado
set VIVADO_INSTALL=D:\Xilinx\Vivado\2019.1\bin

%VIVADO_INSTALL%\unwrapped\win64.o\vvgl.exe %VIVADO_INSTALL%\vivado.bat -notrace -source ".\TCL\vivado_synth.tcl"
