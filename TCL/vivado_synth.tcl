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

proc get_my_synth_run {} {
  get_runs -filter {NAME !~ "pll*" && IS_SYNTHESIS}
}

proc get_my_impl_run {} {
  get_runs -filter {NAME !~ "pll*" && IS_IMPLEMENTATION}
}

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
proc synth_my_design {{synth synth_1} {jobs 6}} {
  set d [current_design -quiet]
  if {[llength $d] > 0 && ![string equal [lindex $d 0] $synth]} {
      puts "Closing design [lindex $d 0]"
      close_design
  }
  set synth_run [get_runs $synth]
  if {[get_property NEEDS_REFRESH $synth_run] || [string equal [get_property PROGRESS $synth_run] "0%"]} {
    reset_run $synth
    launch_runs $synth -jobs $jobs
    wait_on_run $synth
  }
  set d [current_design -quiet]
  if {[llength $d] == 0} {
      open_run $synth -name $synth
  }
  # Open a schematic of the basic design
  show_schematic [get_cells {led4_button4_i/*}]
}

# Implement the design and wait for completion.
# We subsequently open just the interesting sub-design.
#
proc impl_my_design {{synth synth_1} {impl impl_1} {jobs 6}} {
  set d [current_design -quiet]
  if {[llength $d] > 0 && ![string equal [lindex $d 0] $impl]} {
      puts "Closing design [lindex $d 0]"
      close_design
  }
  set synth_run [get_runs $synth]
  set impl_run [get_runs $synth]
  if {[get_property NEEDS_REFRESH $synth_run] || [string equal [get_property PROGRESS $synth_run] "0%"]} {
    reset_run $synth
  } elseif {[get_property NEEDS_REFRESH $impl_run] || [string equal [get_property PROGRESS $impl_run] "0%"]} {
    reset_run $impl
  }
  if {![string equal [get_property PROGRESS $impl_run] "100%"]} {
    launch_runs $impl -jobs $jobs
    wait_on_run $impl
    launch_runs $impl -to_step write_bitstream -jobs $jobs
    wait_on_run $impl
  }
  set d [current_design -quiet]
  if {[llength $d] == 0} {
      open_run $impl -name $impl
  }
  # Open a schematic of the basic design
  show_schematic [get_cells {led4_button4_i/*}]
  set bit_files [glob "[get_property DIRECTORY [get_my_impl_run]]/*.bit"]
  if {[llength $bit_files] == 1} {
    open_hw
    connect_hw_server -quiet
    if {[llength [get_hw_devices -quiet]] == 0} {
      open_hw_target
    }
    set hw_device [get_hw_devices xc7z010_1]
    set_property PROBES.FILE {} $hw_device
    set_property FULL_PROBES.FILE {} $hw_device
    set_property PROGRAM.FILE [lindex $bit_files 0] $hw_device
    program_hw_devices $hw_device
    refresh_hw_device [lindex $hw_device 0]
    puts "Zybo Z7 Development Board Programmed."
  } {
    puts "Need a single BIT file, cannot automatically choose one."
  }
}

proc add_my_buttons {} {
  global thisdir
  if {[lsearch [get_gui_custom_commands -quiet] my_elab] < 0} {
    create_gui_custom_command \
      -name my_elab \
      -description "Elaborate the design and show a schematic of generic gates." \
      -menu_name "Elaborate" \
      -show_on_toolbar \
      -toolbar_icon "$thisdir/vivado_icon_e.png" \
      -command elab_my_design
  }
  if {[lsearch [get_gui_custom_commands -quiet] my_synth] < 0} {
    create_gui_custom_command \
      -name my_synth \
      -description "Synthesise the design and show a schematic of technology mapped gates." \
      -menu_name "Synthesise" \
      -show_on_toolbar \
      -toolbar_icon "$thisdir/vivado_icon_s.png" \
      -command synth_my_design
  }
  if {[lsearch [get_gui_custom_commands -quiet] my_impl] < 0} {
    create_gui_custom_command \
      -name my_impl \
      -description "Place & route the design and show a schematic of technology mapped gates." \
      -menu_name "Implement" \
      -show_on_toolbar \
      -toolbar_icon "$thisdir/vivado_icon_i.png" \
      -command impl_my_design
  }
}

proc remove_my_buttons {} {
  foreach i {my_elab my_synth my_impl} {
    if {[lsearch [get_gui_custom_commands -quiet] $i] >= 0} {
      remove_gui_custom_commands -name $i
    }
  }
}

# Refresh the toolbar buttons
remove_my_buttons
add_my_buttons

if {[llength [get_projects]] == 0} {
  set proj_src [file normalize $env(USERPROFILE)/Xilinx/Workspace/scratch_vhdl]
  open_project $proj_src/scratch_vhdl.xpr
  unset proj_src
}
