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
  report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -name timing_synth
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
  set impl_run [get_runs $impl]
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
  report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -name timing_impl
  set wns [get_property STATS.WNS [get_runs $impl]]
  if {$wns > 0} {
    puts "Timing met, worst slack = ${wns} ns."
  } {
    puts "Failed timing closure, worst slack = ${wns} ns"
  }
}

# Set the RISC CPU ROM contents to this file
#
# Parameter:
#  1. A file name 'f'. Must contain neither path nor extension as these get added, as
#     in "$env(USERPROFILE)/ModelSim/projects/button_leds/instr_files/${f}.txt".
#
# Usage: set_asm_file traffic_lights
#
proc set_asm_file {f} {
  global env

  set ff [file normalize "$env(USERPROFILE)/ModelSim/projects/button_leds/instr_files/${f}.txt"]

  if {![file exists $ff]} {
    error "File '$ff' does not exist." 1
  }

  set_property generic [list \
    sim_g=false \
    rom_file_g=[file normalize $ff] \
  ] [current_fileset]
}

# Programme the Zybo Z7 development board.
#
proc prog_my_board {} {
  set bit_files [glob -nocomplain "[get_property DIRECTORY [get_my_impl_run]]/*.bit"]
  if {[llength $bit_files] == 1} {
    open_hw
    if {[llength [current_hw_server -quiet]] == 0} {
      connect_hw_server
    }
    if {[llength [get_hw_targets -quiet]] > 0} {
      open_hw_target
      # Check xc7z010_1 is on the list
      set hw_device [get_hw_devices xc7z010_1 -quiet]
      if {[llength $hw_device] > 0} {
        set_property PROBES.FILE {} $hw_device
        set_property FULL_PROBES.FILE {} $hw_device
        set_property PROGRAM.FILE [lindex $bit_files 0] $hw_device
        program_hw_devices $hw_device
        refresh_hw_device $hw_device
        puts "Zybo Z7 Development Board Programmed."
      } {
        puts "Zybo Z7 Development Board not found."
        close_hw_target
      }
    } {
      puts "No hardware targets found."
      disconnect_hw_server
    }
  } {
    puts "Need a single BIT file, none found, or too many and cannot automatically choose one."
    puts "Try running the implementation step, 'impl_my_design'."
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
  if {[lsearch [get_gui_custom_commands -quiet] my_prog] < 0} {
    create_gui_custom_command \
      -name my_prog \
      -description "Programme the development board." \
      -menu_name "Programme" \
      -show_on_toolbar \
      -toolbar_icon "$thisdir/vivado_icon_p.png" \
      -command prog_my_board
  }
}

proc remove_my_buttons {} {
  foreach i {my_elab my_synth my_impl my_prog} {
    if {[lsearch [get_gui_custom_commands -quiet] $i] >= 0} {
      remove_gui_custom_commands -name $i
    }
  }
}

# Refresh the toolbar buttons
remove_my_buttons
add_my_buttons

if {[llength [get_projects -quiet]] == 0} {
  set proj_src [file normalize $env(USERPROFILE)/Xilinx/Workspace/scratch_vhdl]
  open_project $proj_src/scratch_vhdl.xpr
  unset proj_src
}
