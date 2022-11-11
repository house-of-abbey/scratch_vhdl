# Scripts Reference

The following scripts are provide with Scratch VHDL to automate some intensive tasks, and enable the projects to be 'run'.

| Source                        | Purpose |
|:------------------------------|:--------|
| `fetch_bin.cmd`               | Fetch the latest `customasm` assembler and create `default_text_override.js` used by the web editor.|
| `install_extension.cmd`       | Install the required (Scratch VHDL) and suggested (VHDL, customasm) plugins for VS Code.|
| `design/config.cmd`           | Derived from `config.cmd.editme`, edit this to define variables that point to locally installed tools. |
| `design/asm_compile.cmd`      | Assemble `*.asm` files to `*.o` with `customasm`. |
| `design/modelsim_compile.cmd` | Compile VHDL for simulation with ModelSim. |
| `design/run_sim.cmd`          | Start ModelSim with the design and TCL-base stimulus user interface. |
| `design/run_vivado.cmd`       | Start Vivado with the design and required TCL scripts. |
| `design/vivado_project.cmd`   | Create the project required to run Vivado using TCL scripts, and ready it for use. After exiting, use `design/run_vivado.cmd` to restart Vivado without recreating your project. |
