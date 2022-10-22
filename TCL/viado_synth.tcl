#####################################################################################
#
#  Distributed under MIT Licence
#    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
#
#####################################################################################
#
# Constraints file required for synthesis of the full design.
#
# This file is a general .xdc for the Zybo Z7 Rev. B
# It is compatible with the Zybo Z7-20 and Zybo Z7-10
# To use it in a project:
# - uncomment the lines corresponding to used pins
# - rename the used ports (in each line, after get_ports) according to the top level
#   signal names in the project
#
# J D Abbey & P A Abbey, 21 October 2022
#
#####################################################################################

set thisscript [file normalize [info script]]
set thisdir    [file dirname $thisscript]
# The aim of this file is to provide a reliable way of knowing where the source code
# is, without setting up variables in a special start up batch file which are relied
# upon but absent when Modelsim is started from Windows start menu.
set configfile "${thisdir}/config.tcl"

if {[file exists $configfile]} {
  # This file sets up the path to source
  source $configfile
} {
  error "Set up 'config.tcl' file before proceeding." 1
}
# Verify the config has been read
if {![info exists scratch_vhdl_src]} {
  error "Set 'scratch_vhdl_src' before proceeding." 1
}
# Check the directory exists - belt & braces
if {![file isdirectory $scratch_vhdl_src]} {
  error "'scratch_vhdl_src' does not point to the source code." 1
}

# Not using the PS7
# [Designutils 20-1307] Command 'get_drc_violations' is not supported in the xdc constraint file.
create_waiver -of_objects [get_drc_violations -name zybo_z7_10_drc_routed.rpx {ZPS7-1#1}] -user scratch_vhdl

# Open a schematic of the basic design
show_schematic [get_cells {led4_button4_i/*}]
