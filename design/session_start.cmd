@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 2 July 2023
rem 
rem ---------------------------------------------------------------------------------
rem
rem There's a suspicion that Vivado does not start properly all the time because its
rem starting at the same time as other applications, so the hw_server and potentially
rem the cs_server do not start correctly. This script stages the start up process at
rem the start of a class, and allows it complete unattended.

title Laptop Startup Script, Run 3 Applications

echo =======================================================
echo Laptop Startup Script, Run Vivado, ModeSim and VS Code.
echo =======================================================
echo.

echo Launching Vivado...
start /min "" run_vivado.cmd

timeout /t 30 /nobreak
echo ---------------------------------------------------

echo Launching ModelSim...
start /min "" run_sim.cmd

timeout /t 20 /nobreak
echo ---------------------------------------------------

echo Launching VS Code...
start /min "" run_vscode.cmd

echo.
echo =======================================================
echo All applications started.
echo =======================================================
timeout /t 10
