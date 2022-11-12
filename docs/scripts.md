# Scripts Reference

The following scripts are provide with Scratch VHDL to automate some intensive tasks, and enable the projects to be 'run'.

## Batch files for `cmd.exe`

| Source | Stage | Purpose |
|:-------|:------|:--------|
| [`fetch_bin.cmd`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/fetch_bin.cmd) | Installation | Fetch the latest `customasm` assembler and create `default_text_override.js` used by the web editor.|
| [`install_extension.cmd`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/install_extension.cmd) | Installation | Install the required (Scratch VHDL) and suggested (VHDL, customasm) plugins for VS Code.|
| `design\config.cmd` | Setup | Derived from `config.cmd.editme`, edit this to define variables that point to locally installed tools. |
| [`design\config.cmd.editme`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/design/config.cmd.editme) | Setup | Template for customising the paths to locally installed tools. |
| [`design\vivado_project.cmd`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/design/vivado_project.cmd) | Setup | Create the project required to run Vivado using TCL scripts, and ready it for use. Also create a piece of IP in Vivado required for compilation with `design\modelsim_compile.cmd`. After exiting, use `design\run_vivado.cmd` to restart Vivado without recreating your project. Rerunning this batch file will delete and recreate the `scratch_vhdl` project directory, allowing you to swap tool versions or reset the project, but is unnecessary additional work to perform regularly. Invokes `TCL\vivado_project.tcl`. |
| [`design\asm_compile.cmd`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/design/asm_compile.cmd) | Execution | Assemble RISC CPU instruction `*.asm` files to `*.o` with `customasm`. Requires `fetch_bin.cmd` to have been run. |
| [`design\modelsim_compile.cmd`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/design/modelsim_compile.cmd) | Execution | Compile VHDL for simulation with ModelSim. Requires `design\vivado_project.cmd` to have been run. |
| [`design\run_sim.cmd`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/design/run_sim.cmd) | Execution | Start ModelSim with the design and TCL-base stimulus user interface. Requires `design\vivado_project.cmd` to have been run. Invokes `TCL\start_sim.tcl`. |
| [`design\run_vivado.cmd`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/design/run_vivado.cmd) | Execution | Start Vivado with the design and required TCL scripts. Requires `design\vivado_project.cmd` to have been run. Invokes `TCL\vivado_synth.tcl`. |

## TCL Files for FPGA Tools

| Source | Tool | Purpose |
|:-------|:-----|:--------|
| `TCL\config.tcl` | ModelSim & Vivado | Derived from `config.tcl.editme`, edit this to define variables that point to locally installed tools. |
| [`TCL\config.tcl.editme`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/TCL/config.tcl.editme) | ModelSim & Vivado | Template for customising the paths to locally installed tools. |
| [`TCL\led4_button4.tcl`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/TCL/led4_button4.tcl) | ModelSim | The TCL/TK graphical user interface used for test stimulus for VHDL simulation. This is loaded by `TCL\start_sim.tcl` and need not be invoked directly. It is also invoked by the graphical user interface when the `reload` button is pressed. |
| [`TCL\start_sim.tcl`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/TCL/start_sim.tcl) | ModelSim | Used to start up ModelSim with the design and graphical user interface. This is used by `design\run_sim.cmd` and need not be invoked directly. |
| [`TCL\vivado_project.tcl`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/TCL/vivado_project.tcl) | Vivado | Used to create the Vivado project correctly, including generating the PLL for the clock required for the top level of the design. This is used by `design\vivado_project.cmd` and need not be invoked directly. |
| [`TCL\vivado_synth.tcl`](https://github.com/house-of-abbey/scratch_vhdl/blob/main/TCL/vivado_synth.tcl) | Vivado | Used to open Vivado after project creation. This is used by `design\run_vivado.cmd` and need not be invoked directly. |
