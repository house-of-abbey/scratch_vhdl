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

# To compile for simulation:
# TCL script to build project
# * Can we add the PLL from a TCL command for configuring IP?
# * Generate the simualtion model at the correct path
#
# After PLL IP generation from the "Clock Wizard", the simulation model can be
# written from the design using this command.
#
# set_property \
#   -dict [list \
#     CONFIG.PRIM_IN_FREQ {125.000} \
#     CONFIG.CLKIN1_JITTER_PS {80.0} \
#     CONFIG.MMCM_DIVCLK_DIVIDE {1} \
#     CONFIG.MMCM_CLKFBOUT_MULT_F {7} \
#     CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
#     CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
#     CONFIG.MMCM_CLKOUT0_DIVIDE_F {7} \
#     CONFIG.CLKOUT1_JITTER {125.031} \
#     CONFIG.CLKOUT1_PHASE_ERROR {104.065} \
#   ] \
#   [get_ips pll]
#
# write_vhdl \
#   -cell [get_cells {pll_i}] \
#   -force -mode funcsim \
#   -rename_top pll \
#   -prefix decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ \
#   {path\to\scratch_vhdl\demos\pll.vhdl}

# Not using the PS7
# [Designutils 20-1307] Command 'get_drc_violations' is not supported in the xdc constraint file.
create_waiver -of_objects [get_drc_violations -name zybo_z7_10_drc_routed.rpx {ZPS7-1#1}] -user scratch_vhdl

# Open a schematic of the basic design
show_schematic [get_cells {led4_button4_i/*}]
