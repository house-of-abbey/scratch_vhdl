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

# Add this if we get bad reports.
# # Not using the PS7
# # [Designutils 20-1307] Command 'get_drc_violations' is not supported in the xdc constraint file.
# create_waiver -of_objects [get_drc_violations -name zybo_z7_10_drc_routed.rpx {ZPS7-1#1}] -user scratch_vhdl

# Elaborate the design and '-rtl' will open the full design.
# We subsequently open just the interesting sub-design.
#
proc elab_my_design {} {
  synth_design -rtl -name rtl_1
  # Open a schematic of the basic design
  show_schematic [get_cells {led4_button4_i/*}]
}

# Synthesise the design and wait for completion.
# We subsequently open just the interesting sub-design.
#
proc synth_my_design {{design synth_1} {jobs 6}} {
  set d [current_design -quiet]
  if {[llength $d] > 0} {
      puts "Closing design [lindex $d 0]"
      close_design
  }
  reset_run $design
  launch_runs $design -jobs $jobs
  wait_on_run $design
  open_run $design -name $design
  # Open a schematic of the basic design
  show_schematic [get_cells {led4_button4_i/*}]
}

# Implement the design and wait for completion.
# We subsequently open just the interesting sub-design.
#
proc impl_my_design {{design impl_1} {jobs 6}} {
  set d [current_design -quiet]
  if {[llength $d] > 0} {
      puts "Closing design [lindex $d 0]"
      close_design
  }
  reset_run $design
  launch_runs $design -jobs $jobs
  wait_on_run $design
  open_run $design -name $design
  # Open a schematic of the basic design
  show_schematic [get_cells {led4_button4_i/*}]
}

if {[lsearch [get_gui_custom_commands] my_elab] < 0} {
  create_gui_custom_command -name my_elab  -menu_name "Elaborate"  -command elab_my_design
}
if {[lsearch [get_gui_custom_commands] my_synth] < 0} {
  create_gui_custom_command -name my_synth -menu_name "Synthesise" -command synth_my_design
}
if {[lsearch [get_gui_custom_commands] my_impl] < 0} {
  create_gui_custom_command -name my_impl  -menu_name "Implement"  -command impl_my_design
}
