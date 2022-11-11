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
call config.cmd
if not defined MODELSIMDIR (goto error)
set MODELSIMBIN=%MODELSIMDIR%\modelsim_ase\win32aloem

%MODELSIMBIN%\vsim -do "source {../TCL/start_sim.tcl}"
rem This file can be reported as in use by another process when it is not, so just clean it up.
del /f %USERPROFILE%\ModelSim\projects\button_leds\vsim.wlf transcript
