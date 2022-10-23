#####################################################################################
#
#  Distributed under MIT Licence
#    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
#
#####################################################################################
#
# TCL script to initialise a simulation.
#
# To run this code, keep your compiled design open in Modelsim and run:
#
#   source {path\to\start_sim.tcl}
#
# J D Abbey & P A Abbey, 15 October 2022
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

# Turn warnings off: "set_warnings 0"
# Turn warnings on:  "set_warnings 1"
proc set_warnings {bool} {
  global StdArithNoWarnings NumericStdNoWarnings
  if {$bool} {
    echo "Standard library warnings ON"
  } {
    echo "Standard library warnings OFF"
  }
  set StdArithNoWarnings $bool
  set NumericStdNoWarnings $bool
}

proc resim {{time "-all"}} {
  restart -f
  if {$time eq "cursor"} {
    run [getactivecursortime]
  } else {
    run $time
    seetime wave [getactivecursortime]
  }
}

proc scroll_cursor {} {
  seetime wave [getactivecursortime]
}

# Don't add the buttons multiple times
set mybuttonsadded 0
proc mybuttons {} {
  global mybuttonsadded
  if {!$mybuttonsadded} {
    add button "Resim"          {transcribe resim}
    add button "Goto Cursor"    {transcribe scroll_cursor}
    add button "Start Monitor"  {transcribe setup_monitor}
    add button "Stop Monitor"   {transcribe stop_monitor}
    set mybuttonsadded 1
  }
}

proc sim_start_hook {} {
  if {[runStatus] == "ready" || [runStatus] == "break"} {
    set_warnings 0
    # Logging all signals
    log -r *
    configure wave -timelineunits ns
    configure wave -signalnamewidth 1
    delete wave *
    add wave -position end sim:/test_led4_button4/led4_button4_i/*
    WaveRestoreZoom {0 ns} {500 ns}
  }
  # Configuring garbage collector to see if it reduces crashes of large or long runing simulations
  gc config -onrun 1 -onstep 0 -threshold 100
  mybuttons
}

if {![llength [namespace which orignal_vsim]]} {
  rename vsim orignal_vsim

  proc vsim {args} {
    orignal_vsim {*}$args -do sim_start_hook
  }
}

# Prevent the TCL stop command bleating to the console/transcript with "Simulation stop requested."
set PrefMain(noRunMsg) 1
set PrefMain(AutoReloadModifiedFiles) 1
# Stop ModelSim opening files
# https://technotes.taotek.co.uk/stop-modelsim-opening-files/
set PrefSource(OpenOnBreak) 0
set PrefSource(OpenOnFinish) 0

cd $env(USERPROFILE)/ModelSim/projects/button_leds
# 'sim_start_hook' gets run twice when this is called here. Otherwise once. Don't know why.
vsim work.test_interactive
source "$scratch_vhdl_src/TCL/led4_button4.tcl"
