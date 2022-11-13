# Synthesis

The process of generating a design from VHDL has been simplified and automated in a way this is customised to this application. We have installed toolbar buttons that run TCL functions from a script. **As long as Vivado is started from the batch file [`run_vivado.cmd`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/design/run_vivado.cmd), the correct TCL script will be read and the design prepared earlier will be loaded.**

![Vivado toolbar with custom buttons](./images/vivado/Toolbar.png)

The letters 'E', 'S', 'i', 'P' and 'A' on each button refer to the steps detailed below.

## Elaboration Step

This is managed by the TCL function `elab_my_design`. It elaborates the design to generic gates and opens up the schematic of the sub-section of the design authored through Scratch VHDL.

From this schematic you may select a gate and press `F7` to display the VHDL code that generated the gate.

![Elaboration to generic gates](./images/vivado/logic_gates_elab.png)

## Synthesis Step

This is managed by the TCL function `synth_my_design`. It synthesises the design to the technology required for the selected development board (currently a Zybo Z7 board). Synthesis maps the generic gates to the chosen technology and then opens up the schematic of the sub-section of the design authored through Scratch VHDL.

From this schematic you may select a gate and press `F7` to display the VHDL code that generated the gate.

Typically at this stage we will get estimates of timing paths between registers. The figures are based on a model only because without placing the primitives and routing nets between them we have not precision over net delays, only gate delays. Still, the _static timing analysis_ still proves useful in recoding the VHDL for timing closure ahead of more time spend on the next step.

![Mapping to device specific gates](./images/vivado/logic_gates_synth.png)

## Implementation Step or "Place and Route"

The product from synthesis is a 'netlist' of gates ready to be placed across the FPGA fabric and nets routed between the gates. This is managed by the TCL function `impl_my_design`. When the implementation step completes, it will open up a the schematic of the sub-section of the design authored through Scratch VHDL.

![Place & route the netlist across the device](./images/vivado/place_route_device.png)

When selecting the constituents of the `led4_button4` component's gates, the 'Device' tab in Vivado shows which parts of the FPGA's "sea of gates" have been used. As you can see its a very small fraction of the entire FPGA because these designs are not taxing the device's utilisation.

## Programming Step

A `BIT` file of the implemented design is created, which is required to programme the FPGA, and sent over a USB cable to the [development board](development_board.md) for execution on target. This is managed by the TCL function `prog_my_board`.

## Assembly File Selection

Used when selecting the RISC CPU for the `led4_button4` VHDL entity. You can change the assembly code contents compiled into the ROM by choosing a `.o` file compiled from a `.asm` file by [`asm_compile.cmd`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/design/asm_compile.cmd). This is managed by the TCL function `set_asm_file`, and it changes a generic on the top level VHDL entity after verifying the requested file exists.
