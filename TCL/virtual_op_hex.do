#####################################################################################
#
#  Distributed under MIT Licence
#    See https://github.com/house-of-abbey/scratch_vhdl/blob/main/LICENCE.
#
#####################################################################################
#
# ModelSim virtual signal to create a new version of 'pc_value' padded with 3 zero
# bits on the least significant end so that the hexadecimal value displayed matches
# the annotated ASM compilation to assist with debugging the ScratchVHDL version of
# the RISC CPU.
#
# To run this code, keep your compiled design open in Modelsim and run:
#
#   do {path\to\virtual_op_hex.do}
#
# J D Abbey & P A Abbey, 28 July 2023
#
#####################################################################################

virtual signal -env sim:/test_led4_button4/led4_button4_i { sim:/test_led4_button4/led4_button4_i/pc_value & "000" } pc_value_h
add wave -noupdate -radix hexadecimal /test_led4_button4/led4_button4_i/pc_value_h
