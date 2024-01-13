@echo off
rem ---------------------------------------------------------------------------------
rem 
rem  Distributed under MIT Licence
rem    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
rem 
rem  J D Abbey & P A Abbey, 27 October 2022
rem 
rem ---------------------------------------------------------------------------------

rem vivado.bat -help
rem vivado
rem
rem Description:
rem Vivado v2019.1.1 (64-bit)
rem SW Build 2580384 on Sat Jun 29 08:12:21 MDT 2019
rem IP Build 2579722 on Sat Jun 29 11:35:40 MDT 2019
rem Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
rem
rem Syntax:
rem vivado  [-mode <arg>] [-init] [-source <arg>] [-nojournal] [-appjournal]
rem         [-journal <arg>] [-nolog] [-applog] [-log <arg>] [-version]
rem         [-tclargs <arg>] [-tempDir <arg>] [-robot <arg>] [-verbose] [<project>]
rem
rem Usage:
rem   Name           Description
rem   --------------------------
rem   [-mode]        Invocation mode, allowed values are 'gui', 'tcl', and
rem                  'batch'
rem                  Default: gui
rem   [-init]        Source vivado.tcl file
rem   [-source]      Source the specified Tcl file
rem   [-nojournal]   Do not create a journal file
rem   [-appjournal]  Open journal file in append mode
rem   [-journal]     Journal file name
rem                  Default: vivado.jou
rem   [-nolog]       Do not create a log file
rem   [-applog]      Open log file in append mode
rem   [-log]         Log file name
rem                  Default: vivado.log
rem   [-version]     Output version information and exit
rem   [-tclargs]     Arguments passed on to tcl argc argv
rem   [-tempDir]     Temporary directory name.
rem   [-robot]       Robot JAR file name.
rem   [-verbose]     Suspend message limits during command execution
rem   [<project>]    Load the specified project (.xpr) or design checkpoint
rem                  (.dcp) file
rem
rem Categories:
rem

title Running Vivado
if exist config.cmd (
  call config.cmd
) else (
  echo Configuration file 'config.cmd' not found. Copy and edit 'config.cmd.editme'.
  goto error
)
if not defined VIVADO_INSTALL (
  echo Variable 'VIVADO_INSTALL' not set.
  goto error
)
if not exist %VIVADO_INSTALL%\ (
  echo Directory %VIVADO_INSTALL% not found.
  goto error
)

call %VIVADO_INSTALL%\vivado.bat ^
  -mode gui ^
  -tempDir %TEMP% ^
  -nojournal ^
  -nolog ^
  -notrace ^
  -source "..\TCL\vivado_synth.tcl"

rem Clean up junk
del /Q /F vivado_pid*.str hs_err_pid*.dmp hs_err_pid*.log
exit /b 0

:error
  echo.
  echo Execution FAILED
  pause
  exit /b 1
