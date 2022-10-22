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
# - rename the used ports (in each line, after get_ports) according to the top level signal names in the project
#
# J D Abbey & P A Abbey, 15 October 2022
#
#####################################################################################

create_clock -add -name clk_port -period 8.000 -waveform {0 4} [get_ports {clk_port}];

# Keep the mapping from hierarchy to code clear.
set_property keep_hierarchy true [get_cells {retime_btn retime_sw led4_button4_i}]

# Not getting clever with max_delay constraints here, keep it simple for this tiny design
set_false_path -to [get_cells {retime_btn/reg_retime_reg[*] retime_sw/reg_retime_reg[*]}]
# These off chip sources and destinations are not synchronous, but we want a clean timing report.
# Time in ns
set_input_delay  -clock [get_clocks clk_port] 0.100 [get_ports {btn[*] sw[*]}]
set_output_delay -clock [get_clocks clk_port] 0.100 [get_ports {leds[*]}]
