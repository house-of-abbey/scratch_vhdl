# Synthesis

The process of generating a design from VHDL has been simplified and automated in a way this is customised to this application. We have installed toolbar buttons that run TCL functions from a script. **As long as Vivado is started from the [batch file](https://github.com/house-of-abbey/scratch_vhdl/blob/main/design/run_vivado.bat), the correct TCL script will be read and the design prepared earlier will be loaded.**

![Vivado toolbar with custom buttons](./images/vivado/Toolbar.png)

The letters 'E', 'S' and 'i' on each button refer to the steps detailed below.

## Elaboration Step

This is managed by the TCL function `elab_my_design{}`. It elaborates the design to generic gates and opens up the schematic of the sub-section of the design authored through Scratch VHDL.

From this schematic you may select a gate and press `F7` to display the VHDL code that generated the gate.

## Synthesis Step

This is managed by the TCL function `synth_my_design{}`. It synthesises the design to the technology required for the selected development board (currently a Zybo Z7 board). Synthesis maps the generic gates to the chosen technology and then opens up the schematic of the sub-section of the design authored through Scratch VHDL.

From this schematic you may select a gate and press `F7` to display the VHDL code that generated the gate.

Typically at this stage we will get estimates of timing paths between registers. The figures are based on a model only because without placing the primitives and routing nets between them we have not precision over net delays, only gate delays. Still, the _static timing analysis_ still proves useful in recoding the VHDL for timing closure ahead of more time spend on the next step.

## Implementation Step or "Place and Route"

The product from synthesis is a 'netlist' of gates ready to be placed across the FPGA fabric and nets routed between the gates. This is managed by the TCL function `impl_my_design{}`. When the implementation step completes, it will open up a the schematic of the sub-section of the design authored through Scratch VHDL. In the background the "BIT file" is then generated, which is required to programme the FPGA. The BIT file will also be sent to the FPGA development board ready for testing.
