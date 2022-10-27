@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 15 October 2022
rem 
rem ---------------------------------------------------------------------------------

title Running Modelsim
set MODELSIM_INSTALL="D:\intelFPGA_lite\20.1\modelsim_ase\win32aloem"

%MODELSIM_INSTALL%\vsim -do "source {./TCL/start_sim.tcl}"
rem This file can be reported as in use by another process when it is not, so just clean it up.
del /f %USERPROFILE%\ModelSim\projects\button_leds\vsim.wlf
