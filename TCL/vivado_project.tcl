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
if {![info exists modelsim_install]} {
  error "Set 'modelsim_install' before proceeding." 1
}
# Check the directory exists - belt & braces
if {![file isdirectory $scratch_vhdl_src]} {
  error "'scratch_vhdl_src' does not point to the source code." 1
}
# Check the directory exists - belt & braces
if {![file isdirectory $modelsim_install]} {
  error "'modelsim_install' does not point to the ModelSim installation." 1
}

# Create a Vivado project
set proj_src     [file normalize $env(USERPROFILE)/Xilinx/Workspace/scratch_vhdl]
set modelsim_lib [file normalize $env(USERPROFILE)/ModelSim/libraries]

# Create 'unisim' library for ModelSim only if required
if {![file isdirectory "$modelsim_lib/unisim"]} {
  compile_simlib \
    -simulator modelsim \
    -simulator_exec_path $modelsim_install \
    -family all \
    -language vhdl \
    -library unisim \
    -dir $modelsim_lib

  report_simlib_info $modelsim_lib
}

# Delete the old project structure
if {[file isdirectory $proj_src]} {
  file delete -force $proj_src
}

# Part 'xc7z010clg400-1' required for Zybo Z7-10 development board
create_project scratch_vhdl -part xc7z010clg400-1 $proj_src
set_property board_part digilentinc.com:zybo-z7-10:part0:1.1 [current_project]
set_property compxlib.modelsim_compiled_library_dir $modelsim_lib [current_project]
set_property target_language VHDL [current_project]
set_property default_lib work [current_project]

# Add project files
add_files -fileset [current_fileset] $scratch_vhdl_src/design/demos/src
add_files -fileset [current_fileset] $scratch_vhdl_src/design/Zybo_Z7_10/src
add_files -fileset [current_fileset] $scratch_vhdl_src/design/scratch.vhdl
set_property file_type {VHDL 2008} [get_files {*.vhdl}]
add_files -fileset [current_fileset -constrset] $scratch_vhdl_src/design/Zybo_Z7_10/constraints
# Vivado bleats if it can't manage a constraints file, so we've added one, but we're going to ignore it. Order is important here.
set_property is_enabled false [get_files {managed.xdc}]
set_property target_constrs_file [get_files {managed.xdc}] [current_fileset -constrset]

set_property top zybo_z7_10 [current_fileset]
update_compile_order -fileset [current_fileset]
set_property generic [list \
  sim_g=false \
  rom_file_g=[file normalize "$env(USERPROFILE)/ModelSim/projects/button_leds/instr_files/tests.txt"] \
] [current_fileset]

set ip_inst pll
set ip_dest_file $scratch_vhdl_src/design/Zybo_Z7_10/ip
set user_profile [file normalize $env(USERPROFILE)]
set ip_xci $ip_dest_file/$ip_inst/$ip_inst.xci

# Delete the old version of the PLL before recreating a new
set temp [get_files -quiet $ip_xci]
if {[llength $temp] > 0} {
  puts "NOTE - Deleteing old PLL"
  export_ip_user_files -of_objects $temp -no_script -reset -force -quiet
  remove_files -fileset $ip_inst $ip_xci
}
unset temp
if {[file isdirectory $ip_dest_file/$ip_inst]} {
  file delete -force $ip_dest_file/$ip_inst
}

create_ip \
  -name        clk_wiz \
  -vendor      xilinx.com \
  -library     ip \
  -version     6.0 \
  -module_name $ip_inst \
  -dir         $ip_dest_file

set_property \
  -dict [list \
    CONFIG.PRIMITIVE                  {PLL} \
    CONFIG.PRIM_IN_FREQ               {125.000} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125.000} \
    CONFIG.MMCM_CLKIN1_PERIOD         {8.000} \
    CONFIG.USE_SAFE_CLOCK_STARTUP     {true} \
    CONFIG.FEEDBACK_SOURCE            {FDBK_AUTO} \
    CONFIG.USE_RESET                  {false} \
    CONFIG.USE_LOCKED                 {true} \
    CONFIG.PRIMARY_PORT               {clk_in} \
    CONFIG.CLK_OUT1_PORT              {clk_out} \
  ] \
  [get_ips $ip_inst]

set ip_xci [get_files $ip_dest_file/$ip_inst/$ip_inst.xci]

generate_target all $ip_xci

export_ip_user_files \
  -of_objects $ip_xci \
  -no_script \
  -sync \
  -force \
  -quiet

create_ip_run $ip_xci
launch_runs -jobs 6 ${ip_inst}_synth_1

export_simulation \
  -of_objects          $ip_xci \
  -directory           $ip_dest_file/$ip_inst/sim_scripts \
  -ip_user_files_dir   $ip_dest_file/$ip_inst/ip_user_files \
  -ipstatic_source_dir $ip_dest_file/$ip_inst/ipstatic \
  -lib_map_path [list \
    "modelsim=$user_profile/ModelSim/libraries" \
    "questa=$ip_dest_file/$ip_inst/compile_simlib/questa" \
    "riviera=$ip_dest_file/$ip_inst/compile_simlib/riviera" \
    "activehdl=$ip_dest_file/$ip_inst/compile_simlib/activehdl" \
  ] \
  -use_ip_compiled_libs \
  -force \
  -quiet

source -notrace "$scratch_vhdl_src/TCL/vivado_synth.tcl"
