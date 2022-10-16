#####################################################################################
#
#  Distributed under MIT Licence
#    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
#
#####################################################################################
#
# TCL script initialise a simulation.
#
# To run this code, keep your compiled design open in Modelsim and run:
#
#   source {path\to\start_sim.tcl}
#
# J D Abbey & P A Abbey, 14 October 2022
#
#####################################################################################

# Set this to your local Git clone
set scratch_vhdl_src {A:\Philip\Work\VHDL\scratch_vhdl}

if {![info exists scratch_vhdl_src]} {
  error "Set 'scratch_vhdl_src' before proceeding." 1
}

cd $env(USERPROFILE)/ModelSim/projects/button_leds
vsim work.test_interactive
source "$scratch_vhdl_src/TCL/led4_button4.tcl"
# Prevent the TCL stop command bleating to the console/transcript with "Simulation stop requested."
set PrefMain(noRunMsg) 1
set PrefMain(AutoReloadModifiedFiles) 1
# Stop ModelSim opening files
# https://technotes.taotek.co.uk/stop-modelsim-opening-files/
set PrefSource(OpenOnBreak) 0
set PrefSource(OpenOnFinish) 0
configure wave -timelineunits ns
configure wave -signalnamewidth 1
add wave -position end sim:/test_led4_button4/led4_button4_i/*
