#####################################################################################
#
#  Distributed under MIT Licence
#    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
#
#####################################################################################
#
# Define the TCL procedures required for automating build functions for ScratchVHDL.
#
# J D Abbey & P A Abbey, 24 September 2025
#
#####################################################################################

# Do not use '[info script]' here as it will get the wrong filename. This file is sourced
# within other TCL scripts, '[info script]' returns the name of the file that was sourced.
set thisscript [file normalize [dict get [info frame 0] file]]
set thisdir    [file dirname $thisscript]
# The aim of this file is to provide a reliable way of knowing where the source code
# is, without setting up variables in a special start up batch file which are relied
# upon but absent when Modelsim is started from Windows start menu.
set configfile "${thisdir}/config.tcl"

if {[file exists $configfile]} {
  # This file sets up the path to source
  source $configfile
} else {
  error "Set up 'config.tcl' file before proceeding." 1
}
# Verify the config has been read
if {![info exists compile_dir]} {
  error "Set 'compile_dir' before proceeding." 1
}
# Check the directory exists - belt & braces
if {![file isdirectory $compile_dir]} {
  error "'compile_dir' does not point to an existing directory." 1
}

source $scratch_vhdl_src/TCL/vivado_synth.tcl
reset
exit
