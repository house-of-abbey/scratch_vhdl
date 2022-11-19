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

# Track if either runs have been marked as out of date.
#
proc check_state {{synth synth_1} {impl impl_1}} {
  set synth_run [get_runs $synth]
  set impl_run [get_runs $impl]
  puts "synth_1 CURRENT_STEP  : [get_property CURRENT_STEP  $synth_run]"
  puts "synth_1 NEEDS_REFRESH : [get_property NEEDS_REFRESH $synth_run]"
  puts "impl_1  CURRENT_STEP  : [get_property CURRENT_STEP  $impl_run]"
  puts "impl_1  NEEDS_REFRESH : [get_property NEEDS_REFRESH $impl_run]"
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
  close_hw_manager -quiet
  set d [current_design -quiet]
  set synth_run [get_runs $synth]
  set must_refesh [get_property NEEDS_REFRESH $synth_run]
  if {[llength $d] > 0} {
    if {![string equal [lindex $d 0] $synth]} {
      puts "Closing design [lindex $d 0] as it is not a synthesis run."
      close_design
    } elseif {$must_refesh} {
      puts "Closing design [lindex $d 0] at it is out of date."
      close_design
    }
  }
  if {$must_refesh || [string equal [get_property PROGRESS $synth_run] "0%"]} {
    reset_run $synth
    launch_runs $synth -jobs $jobs
    wait_on_run $synth
  }
  set d [current_design -quiet]
  if {[llength $d] == 0} {
      open_run $synth -name $synth
  }
  # Open a schematic of the basic design
  show_schematic [get_cells {led4_button4_i/*}] -name "'Led4 Button4' Synthesis"
  report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -name timing_synth
}

# Implement the design and wait for completion.
# We subsequently open just the interesting sub-design.
#
proc impl_my_design {{synth synth_1} {impl impl_1} {jobs 6}} {
  close_hw_manager -quiet
  set d [current_design -quiet]
  set synth_run [get_runs $synth]
  set impl_run [get_runs $impl]
  set must_refesh [get_property NEEDS_REFRESH $impl_run]
  if {[llength $d] > 0} {
    if {![string equal [lindex $d 0] $impl]} {
      puts "Closing design [lindex $d 0] as it is not an implementation run."
      close_design
    } elseif {$must_refesh} {
      puts "Closing design [lindex $d 0] at it is out of date."
      close_design
    }
  }
  if {[get_property NEEDS_REFRESH $synth_run] || [string equal [get_property PROGRESS $synth_run] "0%"]} {
    reset_run $synth
  } elseif {$must_refesh || [string equal [get_property PROGRESS $impl_run] "0%"]} {
    reset_run $impl
  }
  if {![string equal [get_property PROGRESS $impl_run] "100%"]} {
    launch_runs $impl -jobs $jobs
    wait_on_run $impl
  }
  set d [current_design -quiet]
  if {[llength $d] == 0} {
      open_run $impl -name $impl
  }
  # Open a schematic of the basic design
  show_schematic [get_cells {led4_button4_i/*}] -name "'Led4 Button4' Implementation"
  report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -name timing_impl
  set wns [get_property STATS.WNS [get_runs $impl]]
  if {$wns > 0} {
    puts "Timing met, worst slack = ${wns} ns."
    set tp [get_timing_paths -max_paths 1 -nworst 1 -setup]
    set maxSetup [get_property SLACK $tp]
    set maxClkPeriod [expr [get_property REQUIREMENT $tp] - $maxSetup]
    # MHz divide by ns * MHz => (1e-9 * 1e6) = 1e-3
    puts "Maximum clock speed of this design is [expr 1e3/$maxClkPeriod] MHz."
  } else {
    puts "Failed timing closure, worst slack = ${wns} ns"
    puts "Not creating the BIT file."
    set bit_files [glob -nocomplain "[get_property DIRECTORY [get_my_impl_run]]/*.bit"]
    foreach f $bit_files {
      # Avoid confusion: Don't want to programme the development board with an out of date BIT file
      file delete -nocomplain $f
    }
  }
}

# Programme the Zybo Z7 development board.
#
proc prog_my_board {{impl impl_1} {jobs 6}} {
  set bit_files [glob -nocomplain "[get_property DIRECTORY [get_my_impl_run]]/*.bit"]
  set impl_run [get_runs $impl]
  if {
    [llength $bit_files] == 0 ||
    ! [string equal [get_property PROGRESS $impl_run] "100%"]
  } {
    impl_my_design
  }
  # if [string equal [get_property CURRENT_STEP $impl_run] "write_bitstream"] then don't repeat the work
  if {[string equal [get_property CURRENT_STEP $impl_run] "route_design"]} {
    puts "Creating the BIT file."
    launch_runs $impl -to_step write_bitstream -jobs $jobs
    wait_on_run $impl
  }
  set bit_files [glob -nocomplain "[get_property DIRECTORY [get_my_impl_run]]/*.bit"]
  if {[llength $bit_files] == 1} {
    open_hw_manager
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
    } else {
      puts "No hardware targets found."
      disconnect_hw_server
    }
  } else {
    puts "Need a single BIT file, none found, or too many and cannot automatically choose one."
    puts "Try running the implementation step, 'impl_my_design'."
  }
}

# Set the RISC CPU ROM contents to this file
#
# Parameter:
#  1. A file name 'f'. Must contain neither path nor extension as these get added, as
#     in "$env(USERPROFILE)/ModelSim/projects/button_leds/instr_files/${f}.o".
#
# Usage: set_asm_file traffic_lights
#
proc set_asm_file {f} {
  global env

  set ff [file normalize "$env(USERPROFILE)/ModelSim/projects/button_leds/instr_files/${f}.o"]
  if {![file exists $ff]} {
    error "File '$ff' does not exist." 1
  }

  # Make sure we're using the RISC CPU. This does override the use of Scratch to produce the same.
  # set_property top zybo_risc_cpu [current_fileset]

  set_property generic [list \
    sim_g=false \
    rom_file_g=[file normalize $ff] \
  ] [current_fileset]
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
  if {[lsearch [get_gui_custom_commands -quiet] asm_file] < 0} {
    create_gui_custom_command \
      -name asm_file \
      -description "Assembled Code File for ROM." \
      -menu_name "Code File" \
      -show_on_toolbar \
      -toolbar_icon "$thisdir/vivado_icon_a.png" \
      -command set_asm_file
    create_gui_custom_command_arg \
      -command_name asm_file \
      -arg_name f \
      -comment "The base name of the .o file to be used with neither path nor extension."
  }
}

proc remove_my_buttons {} {
  foreach i {my_elab my_synth my_impl my_prog asm_file} {
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
